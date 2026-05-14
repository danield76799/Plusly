import 'dart:convert';

import 'package:http/http.dart';
import 'package:matrix/matrix.dart' as matrix;

extension Msc2666Extension on matrix.Client {
  Future<bool> isMsc2666Supported() async {
    final versions = await getVersions();
    return versions
                .unstableFeatures?['uk.half-shot.msc2666.query_mutual_rooms'] ==
            true ||
        versions.unstableFeatures?['uk.half-shot.msc2666.query_mutual_rooms.stable'] ==
            true;
  }

  Future<bool> isMsc2666StableSupported() async {
    return (await getVersions())
            .unstableFeatures?['uk.half-shot.msc2666.query_mutual_rooms.stable'] ==
        true;
  }

  Future<List<String>> queryMutualRoomsIds(String userId) async {
    final msc2666Stable = await isMsc2666StableSupported();

    final requestUri = Uri(
      path:
          '/_matrix/client/${msc2666Stable ? 'v1' : 'unstable/uk.half-shot.msc2666/user'}/mutual_rooms',
      query: 'user_id=$userId',
    );

    if (baseUri == null) return [];

    final request = Request('GET', baseUri!.resolveUri(requestUri));
    request.headers['authorization'] = 'Bearer $accessToken';
    final response = await httpClient.send(request);
    final responseBody = await response.stream.toBytes();
    if (response.statusCode != 200) unexpectedResponse(response, responseBody);

    final responseString = utf8.decode(responseBody);
    final json = jsonDecode(responseString);
    final joined = json['joined'] as List<dynamic>;

    return joined.cast<String>();
  }
}
