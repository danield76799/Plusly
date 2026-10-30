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

  /// Het telefoonnummer, als bekend.
  final String? phone;

  /// Het e-mailadres, als bekend.
  final String? email;

  /// De avatar (mxc://-URI), als bekend.
  final String? avatarUrl;

  const ContactDetails({
    required this.displayName,
    this.matrixId,
    this.phone,
    this.email,
    this.avatarUrl,
  });

  bool get hasDetails =>
      (matrixId != null && matrixId!.isNotEmpty) ||
      (phone != null && phone!.isNotEmpty) ||
      (email != null && email!.isNotEmpty);

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

    return ContactDetails(
      displayName: displayName,
      matrixId: lees('matrix_id') ?? lees('matrixId') ?? lees('user_id'),
      phone: lees('phone') ?? lees('phone_number'),
      email: lees('email') ?? lees('email_address'),
      avatarUrl: lees('avatar_url'),
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

  const ContactBubble({required this.contact, this.onStartChat, super.key});

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
    if (contact.phone != null) {
      regels.add(
        _regel(
          context,
          icon: Icons.phone_outlined,
          tekst: contact.phone!,
        ),
      );
    }
    if (contact.email != null) {
      regels.add(
        _regel(
          context,
          icon: Icons.mail_outline,
          tekst: contact.email!,
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
              Icon(
                Icons.person_outline,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  contact.displayName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (regels.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...regels,
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
