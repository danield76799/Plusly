import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

import 'package:Pulsly/generated/l10n/l10n.dart';

/// Een gedeeld contact (Matrix `m.contact`).
///
/// De contactgegevens kunnen in de volgende sleutels staan:
///
/// - `m.contact` (de naam die meerdere clients gebruiken)
/// - `org.matrix.msc4041.contact` (de naam uit de oude Matrix-richtlijn)
/// - `m.relates_to` (sommige clients hangen het daar onder)
///
/// We lezen alle drie, zodat een contact van een andere client niet als
/// kale tekst binnenkomt.
class ContactDetails {
  /// De weergavenaam van het contact.
  final String displayName;

  /// Het Matrix-ID, als bekend (`@gebruiker:server`).
  final String? matrixId;

  /// De telefoonnummers, als bekend.
  final List<String> phones;

  /// De e-mailadressen, als bekend.
  final List<String> emails;

  /// De avatar (mxc://-URI), als bekend.
  final String? avatarUrl;

  /// De URL van het bijgevoegde vCard-bestand (mxc://-URI), als bekend.
  ///
  /// Wordt meegestuurd door de WhatsApp-brug, zodat een contact dat je
  /// niet kunt lezen alsnog op te slaan blijft.
  final String? vcardUrl;

  /// De bestandsnaam van het vCard-bestand.
  final String? vcardName;

  const ContactDetails({
    required this.displayName,
    this.matrixId,
    this.phones = const [],
    this.emails = const [],
    this.avatarUrl,
    this.vcardUrl,
    this.vcardName,
  });

  /// Het eerste telefoonnummer, of null als er geen bekend is.
  String? get primaryPhone => phones.isEmpty ? null : phones.first;

  /// Het eerste e-mailadres, of null als er geen bekend is.
  String? get primaryEmail => emails.isEmpty ? null : emails.first;

  bool get hasDetails =>
      (matrixId != null && matrixId!.isNotEmpty) ||
      phones.isNotEmpty ||
      emails.isNotEmpty;

  /// Leest de contactgegevens uit een Matrix-event.
  ///
  /// Geeft null terug als het event geen contact is.
  static ContactDetails? fromEvent(Event event) {
    if (event.messageType != contactMessageType) return null;

    Map<String, dynamic>? contact;
    for (final key in const [
      'm.contact',
      'org.matrix.msc4041.contact',
      'm.relates_to',
    ]) {
      final map = event.content.tryGetMap<String, dynamic>(key);
      if (map != null && map.isNotEmpty) {
        contact = map;
        break;
      }
    }

    final body = event.content.tryGet<String>('body') ?? '';
    final name =
        contact?['display_name']?.toString() ?? contact?['name']?.toString() ?? '';
    final displayName = name.trim().isNotEmpty ? name.trim() : body.trim();
    if (displayName.isEmpty) return null;

    String? lees(String sleutel) {
      final waarde = contact?[sleutel]?.toString() ?? '';
      final getrimd = waarde.trim();
      return getrimd.isEmpty ? null : getrimd;
    }

    // Sommige clients (en de WhatsApp-brug) sturen een lijst met
    // meerdere telefoonnummers of e-mailadressen.
    List<String> leesLijst(List<String> sleutels) {
      for (final sleutel in sleutels) {
        final waarde = contact?[sleutel];
        if (waarde is List) {
          final uit = waarde
              .map((e) => e.toString().trim())
              .where((e) => e.isNotEmpty)
              .toList();
          if (uit.isNotEmpty) return uit;
        } else if (waarde != null) {
          final getrimd = waarde.toString().trim();
          if (getrimd.isNotEmpty) return [getrimd];
        }
      }
      return const [];
    }

    return ContactDetails(
      displayName: displayName,
      matrixId: lees('matrix_id') ?? lees('matrixId') ?? lees('user_id'),
      phones: leesLijst(const ['phone', 'phone_number']),
      emails: leesLijst(const ['email', 'email_address']),
      avatarUrl: lees('avatar_url'),
      vcardUrl: lees('vcard_url'),
      vcardName: lees('vcard_name'),
    );
  }
}

/// Het berichttype voor een gedeeld contact.
const String contactMessageType = 'm.contact';

/// Kaart met de gegevens van een gedeeld contact.
class ContactBubble extends StatelessWidget {
  final ContactDetails contact;

  /// Wordt aangeroepen als de gebruiker een chat met het contact wil
  /// beginnen (alleen als er een Matrix-ID bekend is).
  final void Function(String matrixId)? onStartChat;

  /// Wordt aangeroepen als de gebruiker het contact in het eigen
  /// telefoonboek wil opslaan.
  final void Function(ContactDetails contact)? onSaveContact;

  const ContactBubble({
    required this.contact,
    this.onStartChat,
    this.onSaveContact,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = L10n.of(context);

    final regels = <Widget>[];
    if (contact.matrixId != null) {
      regels.add(
        _regel(
          context,
          icon: Icons.alternate_email,
          tekst: contact.matrixId!,
          monospace: true,
        ),
      );
    }
    for (final telefoon in contact.phones) {
      regels.add(
        _regel(
          context,
          icon: Icons.phone_outlined,
          tekst: telefoon,
        ),
      );
    }
    for (final email in contact.emails) {
      regels.add(
        _regel(
          context,
          icon: Icons.mail_outline,
          tekst: email,
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  contact.displayName.isNotEmpty
                      ? contact.displayName.characters.first.toUpperCase()
                      : '?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      contact.displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (contact.primaryPhone != null)
                      Text(
                        contact.primaryPhone!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (regels.isNotEmpty) ...[
            const SizedBox(height: 10),
            Divider(
              height: 1,
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 8),
            ...regels,
          ],
          if (onSaveContact != null && contact.hasDetails) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => onSaveContact!(contact),
                icon: const Icon(Icons.person_add_alt, size: 18),
                label: Text(l10n.contactSave),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),
          ],
          if (contact.matrixId != null && onStartChat != null) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => onStartChat!(contact.matrixId!),
                icon: const Icon(Icons.chat_bubble_outline, size: 18),
                label: Text(l10n.contactStartChat),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _regel(
    BuildContext context, {
    required IconData icon,
    required String tekst,
    bool monospace = false,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tekst,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontFamily: monospace ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
