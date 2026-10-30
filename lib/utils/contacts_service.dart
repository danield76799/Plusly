import 'package:flutter/foundation.dart' show TargetPlatform, debugPrint, defaultTargetPlatform;
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

/// Een contact uit het telefoonboek van het toestel.
class DeviceContact {
  final String id;
  final String name;
  final List<String> phones;
  final List<String> emails;

  const DeviceContact({
    required this.id,
    required this.name,
    this.phones = const [],
    this.emails = const [],
  });

  /// Het eerste telefoonnummer, of null als er geen is.
  String? get primaryPhone => phones.isEmpty ? null : phones.first;

  /// Het eerste e-mailadres, of null als er geen is.
  String? get primaryEmail => emails.isEmpty ? null : emails.first;

  factory DeviceContact.fromMap(Map<dynamic, dynamic> map) => DeviceContact(
    id: map['id']?.toString() ?? '',
    name: map['name']?.toString() ?? '',
    phones: (map['phones'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    emails: (map['emails'] as List?)?.map((e) => e.toString()).toList() ?? const [],
  );
}

/// Leest de contacten uit het telefoonboek van Android.
///
/// WhatsApp-achtig: je kiest een contact uit je eigen telefoonboek en
/// deelt dat als contactkaart. Er wordt nooit iets opgeslagen of
/// gewijzigd, alleen gelezen.
class ContactsService {
  static const MethodChannel _channel = MethodChannel(
    'com.danield.plusly.app/contacts',
  );

  /// Vraagt de toestemming op en geeft de contacten terug.
  ///
  /// Geeft een lege lijst terug als de toestemming niet is verleend.
  static Future<List<DeviceContact>> loadContacts() async {
    if (defaultTargetPlatform != TargetPlatform.android) return const [];
    try {
      final status = await Permission.contacts.request();
      if (!status.isGranted) return const [];
    } catch (e) {
      debugPrint('ContactsService: toestemming mislukt: $e');
      return const [];
    }

    try {
      final resultaat = await _channel.invokeMethod<List<dynamic>>(
        'listContacts',
      );
      if (resultaat == null) return const [];
      return resultaat
          .whereType<Map<dynamic, dynamic>>()
          .map(DeviceContact.fromMap)
          .where((c) => c.name.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('ContactsService: contacten lezen mislukt: $e');
      return const [];
    }
  }

  /// Bewaart een contact in het telefoonboek van het toestel.
  ///
  /// Geeft true terug als het contact is opgeslagen.
  static Future<bool> saveContact({
    required String displayName,
    List<String> phones = const [],
    List<String> emails = const [],
  }) async {
    if (defaultTargetPlatform != TargetPlatform.android) return false;
    try {
      final status = await Permission.contacts.request();
      if (!status.isGranted) return false;
    } catch (e) {
      debugPrint('ContactsService: toestemming mislukt: $e');
      return false;
    }

    try {
      final resultaat = await _channel.invokeMethod<bool>('saveContact', {
        'display_name': displayName,
        'phone': phones,
        'email': emails,
      });
      return resultaat ?? false;
    } catch (e) {
      debugPrint('ContactsService: contact opslaan mislukt: $e');
      return false;
    }
  }
}
