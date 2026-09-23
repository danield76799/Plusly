import 'dart:convert';

import 'package:matrix/matrix.dart' as matrix;
import 'package:matrix/matrix_api_lite/utils/logs.dart';

extension Msc4140Extension on matrix.Room {
  /// Aparte caches: dit zijn TWEE verschillende capabilities. Een server kan
  /// uitgesteld verzenden ondersteunen zonder het cancel-endpoint (en andersom
  /// is cancel zinloos). Ze in één map delen laat de een het antwoord van de
  /// ander teruggeven.
  static final Map<String, bool> _delayedSendSupportCache = {};
  static final Map<String, bool> _cancelSupportCache = {};

  /// MSC4140-capaciteit van de homeserver, uit `GET /_matrix/client/versions`.
  ///
  /// Dit is de ENIGE betrouwbare manier om te weten of `?delay=` werkt. Het
  /// endpoint proberen en naar de statuscode kijken is onbruikbaar: een server
  /// zonder MSC4140 negeert de onbekende `delay`-queryparameter en antwoordt
  /// met **200 OK** op de gewone send. Het bericht gaat dan DIRECT de deur uit
  /// terwijl de app het als "ingepland" registreert. Alleen de
  /// feature-vlag in /versions onderscheidt de twee gevallen.
  ///
  /// Zelfde patroon als msc2666_extension.dart (de bestaande
  /// feature-detectie in dit project).
  Future<bool> supportsMsc4140() async {
    final server = client.baseUri?.host ?? '';
    if (_delayedSendSupportCache.containsKey(server)) {
      return _delayedSendSupportCache[server]!;
    }
    try {
      // getVersions() is gecached door de SDK (3 dagen), dus dit is één
      // netwerk-call per server en daarna gratis.
      final versions = await client.getVersions();
      final supported =
          versions.unstableFeatures?['org.matrix.msc4140'] == true;
      _delayedSendSupportCache[server] = supported;
      Logs().i('MSC4140 support for $server: $supported');
      return supported;
    } catch (e) {
      // Bij een fout NIET als ondersteund behandelen: dan zou een bericht
      // direct verzonden worden. Liever lokaal inplannen (blijft in de app)
      // dan stil een bericht de deur uit sturen.
      _delayedSendSupportCache[server] = false;
      Logs().w('MSC4140 support check failed for $server: $e');
      return false;
    }
  }

  /// Of het annuleer-endpoint werkt. Los van [supportsMsc4140]: een server kan
  /// uitgesteld verzenden wél ondersteunen maar het cancel-endpoint nog niet.
  /// De aanroeper gebruikt dit alleen om de gebruiker te waarschuwen.
  Future<bool> supportsDelayedEventCancel() async {
    final server = client.baseUri?.host ?? '';
    if (_cancelSupportCache.containsKey(server)) {
      return _cancelSupportCache[server]!;
    }

    try {
      // Probe the cancel endpoint with a dummy ID.
      //
      // LET OP: resolveUri is verplicht. client.httpClient is een kale
      // http.Client zonder baseUrl; de SDK geeft hem overal een ABSOLUTE Uri
      // (Uri.https / baseUri!.resolveUri). Een relatieve Uri laat
      // HttpClient.openUrl gooien ("No host specified"), waarna de catch
      // hieronder `false` teruggeeft — de probe meldde dus altijd "geen
      // cancel-support", op elke server. Dat is precies waarom een eerdere
      // versie de guard hierop liet varen ("cancel is optional").
      final requestUri = Uri(
        path: '/_matrix/client/unstable/org.matrix.msc4140/delayed_events/_probe/cancel',
      );
      final response = await client.httpClient.post(
        client.baseUri!.resolveUri(requestUri),
        body: jsonEncode({}),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${client.accessToken}',
        },
      );
      // 404 betekent hier NIET automatisch "endpoint bestaat niet".
      //
      // Er zijn twee verschillende 404's (gemeten op matrix.org én mtux.nl,
      // beide Synapse):
      //   - M_NOT_FOUND     -> route BESTAAT, maar deze dummy delay_id niet
      //   - M_UNRECOGNIZED  -> route bestaat niet
      // De oude toets `statusCode != 404` zag de eerste als "geen support" en
      // meldde dus op elke server dat annuleren niet kon — precies waarom een
      // eerdere versie besloot de guard te laten varen ("cancel is optional").
      //
      // Alleen M_UNRECOGNIZED betekent echt niet-ondersteund. Elke andere
      // uitkomst (400 M_MISSING_PARAM, 401, 403) betekent dat de route er is.
      if (response.statusCode == 404) {
        var errcode = '';
        try {
          errcode = (jsonDecode(response.body) as Map)['errcode'] as String? ?? '';
        } catch (_) {
          // Geen JSON-body: dan is het geen Synapse-achtige M_NOT_FOUND.
        }
        final supported = errcode != 'M_UNRECOGNIZED';
        _cancelSupportCache[server] = supported;
        Logs().i(
          'MSC4140 cancel support for $server: $supported (errcode=$errcode)',
        );
        return supported;
      }
      final supported = true;
      _cancelSupportCache[server] = supported;
      Logs().i('MSC4140 cancel support for $server: $supported');
      return supported;
    } catch (e) {
      _cancelSupportCache[server] = false;
      Logs().w('MSC4140 cancel probe failed for $server: $e');
      return false;
    }
  }

  Future<String> scheduleDelayedEvent(
    Map<String, dynamic> content, {
    required int delay,
    String type = matrix.EventTypes.Message,
    String? txid,
    matrix.Event? inReplyTo,
    String? editEventId,
    String? threadRootEventId,
    String? threadLastEventId,
  }) async {
    // Build enriched content with reply/thread info
    final enrichedContent = Map<String, dynamic>.from(content);

    if (inReplyTo != null) {
      enrichedContent['m.relates_to'] = {
        'm.in_reply_to': {'event_id': inReplyTo.eventId},
      };
    } else if (threadRootEventId != null) {
      enrichedContent['m.relates_to'] = {
        'rel_type': 'm.thread',
        'event_id': threadRootEventId,
        'm.relatesto': threadLastEventId,
        'is_falling_back': inReplyTo == null,
      };
    }

    // PUT /_matrix/client/v3/rooms/{roomId}/send/{eventType}/{txnId}
    //     ?org.matrix.msc4140.delay={ms}
    //
    // De parameternaam MOET de MSC4140-prefix dragen. Synapse leest
    // letterlijk `parse_integer(request, "org.matrix.msc4140.delay")`; een
    // kale `delay` bestaat daar niet, wordt dus genegeerd, en de PUT valt
    // door naar de GEWONE send — het bericht gaat direct de deur uit.
    //
    // Dat is precies het gemelde symptoom ("stuurt weer meteen") en het is
    // stil: Synapse antwoordt 200 OK met een event_id, geen foutmelding.
    // Bevestigd in element-hq/synapse: synapse/rest/client/room.py regel 529
    // en in matrix-js-sdk: getUnstableDelayQueryOpts() plakt
    // `${UNSTABLE_MSC4140_DELAYED_EVENTS}.${k}` vóór elke key.
    final requestUri = Uri(
      path: '/_matrix/client/v3/rooms/$id/send/$type/$txid',
      queryParameters: {'org.matrix.msc4140.delay': delay.toString()},
    );
    final body = jsonEncode(enrichedContent);
    final response = await client.httpClient.put(
      client.baseUri!.resolveUri(requestUri),
      body: body,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${client.accessToken}',
      },
    );
    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      // STRIKT: alleen een échte delay_id bewijst dat de server het bericht
      // heeft uitgesteld. Een server zonder MSC4140 negeert `?delay=` en
      // antwoordt 200 OK met alléén een event_id — het bericht is dan al
      // verzonden. Die response als succes accepteren (de oude
      // `?? txid`-fallback) liet de app "ingepland" tonen voor een bericht dat
      // al de deur uit was. Liever een exception, zodat de aanroeper lokaal
      // inplant en er niets stil verzonden wordt.
      final delayId = responseBody['delay_id'] as String?;
      if (delayId == null || delayId.isEmpty) {
        throw Exception(
          'Server accepted the send but returned no delay_id — MSC4140 is '
          'not actually supported here (event_id: '
          '${responseBody['event_id']}).',
        );
      }
      return delayId;
    } else {
      final errorBody = jsonDecode(response.body);
      var text = "${errorBody['errcode']}: ${errorBody['error']}";
      if (errorBody['max_delay'] != null) {
        text += " (Max delay: ${errorBody['max_delay']})";
      }
      throw Exception(text);
    }
  }

  Future<void> _manageDelayedEvent(String delayId, String action) async {
    // POST /_matrix/client/unstable/org.matrix.msc4140/delayed_events/{delay_id}/{action}
    //
    // Dit pad klopt wel: Synapse registreert de acties als losse routes
    // (/delayed_events/{id}/cancel, /send, /restart). De nieuwere
    // /_matrix/client/v1/delayed_events/... bestaat op deze servers nog niet
    // (gemeten: 404 M_UNRECOGNIZED), dus de unstable-prefix is hier goed.
    //
    // Wel resolveUri toevoegen — zie de toelichting bij supportsDelayedEventCancel.
    final requestUri = Uri(
      path: '/_matrix/client/unstable/org.matrix.msc4140/delayed_events/$delayId/$action',
    );
    final response = await client.httpClient.post(
      client.baseUri!.resolveUri(requestUri),
      body: jsonEncode({}),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${client.accessToken}',
      },
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    try {
      final errorBody = jsonDecode(response.body);
      final text = "${errorBody['errcode']}: ${errorBody['error']}";
      throw Exception(text);
    } catch (e) {
      throw Exception(
        'Failed to $action delayed event $delayId: ${response.statusCode}',
      );
    }
  }

  /// Send the delayed event immediately instead of waiting for the delay time.
  Future<void> sendDelayedEventNow(String delayId) async {
    return _manageDelayedEvent(delayId, 'send');
  }

  /// Cancel the delayed event so that it will never be sent.
  /// Note: Not all servers support this endpoint.
  Future<void> cancelDelayedEvent(String delayId) async {
    return _manageDelayedEvent(delayId, 'cancel');
  }

  /// Restart the timer of a delayed event (reset to now + original_delay).
  Future<void> restartDelayedEvent(String delayId) async {
    return _manageDelayedEvent(delayId, 'restart');
  }

  /// Retrieve delayed events owned by the user.
  /// Optional `status` may be 'scheduled' or 'finalised'.
  Future<Map<String, dynamic>> getDelayedEvents({
    String? status,
    List<String>? delayIds,
    String? from,
  }) async {
    // GET /_matrix/client/unstable/org.matrix.msc4140/delayed_events
    const basePath = '/_matrix/client/unstable/org.matrix.msc4140/delayed_events';
    final queryParts = <String>[];
    if (status != null) {
      queryParts.add('status=${Uri.encodeQueryComponent(status)}');
    }
    if (delayIds != null) {
      for (final id in delayIds) {
        queryParts.add('delay_id=${Uri.encodeQueryComponent(id)}');
      }
    }
    if (from != null) queryParts.add('from=${Uri.encodeQueryComponent(from)}');

    final pathWithQuery = queryParts.isEmpty
        ? basePath
        : '$basePath?${queryParts.join('&')}';
    final requestUri = Uri(path: pathWithQuery);

    final response = await client.httpClient.get(
      client.baseUri!.resolveUri(requestUri),
      headers: {
        'Authorization': 'Bearer ${client.accessToken}',
      },
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return decoded;
      } catch (e) {
        throw Exception('Failed to decode delayed events response: $e');
      }
    }
    try {
      final errorBody = jsonDecode(response.body);
      final text = "${errorBody['errcode']}: ${errorBody['error']}";
      throw Exception(text);
    } catch (e) {
      throw Exception('Failed to fetch delayed events: ${response.statusCode}');
    }
  }
}
