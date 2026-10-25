import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

/// Extension to clean bridge-related noise from message previews
extension MessagePreviewCleaner on String {
  /// Removes bridge prefixes like ". (WA): " or "Facebook (WA): " and leading punctuation
  String sanitizePreview() {
    if (isEmpty) return this;

    // 1. Remove known bridge prefixes (e.g., "WhatsApp (WA): ", "bridge bot: ")
    final prefixRegex = RegExp(r'^(\.?\s*([a-zA-Z]+)?\s*\(WA\):?|bridge bot:?)\s*', caseSensitive: false);
    var cleaned = replaceFirst(prefixRegex, '');

    // 2. Remove leading punctuation/whitespace that might remain (e.g., ". Hello")
    cleaned = cleaned.replaceFirst(RegExp(r'^[\.\s,\-]+'), '');

    // 3. Remove double spaces
    cleaned = cleaned.replaceAll(RegExp(r'\s{2,}'), ' ');

    return cleaned.trim();
  }
}

/// Gets a display name for a bridge type
String getBridgeTypeLabel(String? type) {
// ... rest of the file
  switch (type) {
    case 'whatsapp':
      return 'WhatsApp';
    case 'telegram':
      return 'Telegram';
    case 'signal':
      return 'Signal';
    case 'discord':
      return 'Discord';
    case 'slack':
      return 'Slack';
    case 'matrix':
      return 'Matrix';
    case 'linkedin':
      return 'LinkedIn';
    default:
      return 'Other';
  }
}

/// Gets an icon for a bridge type
IconData getBridgeTypeIcon(String? type) {
  switch (type) {
    case 'whatsapp':
      return Icons.chat;
    case 'telegram':
      return Icons.send;
    case 'signal':
      return Icons.wifi_tethering;
    case 'discord':
      return Icons.headset;
    case 'slack':
      return Icons.tag;
    case 'matrix':
      return Icons.view_module;
    default:
      return Icons.link;
  }
}

/// Gets the brand SVG asset path for a bridge type, or null if there is no
/// dedicated brand icon (fall back to [getBridgeTypeIcon] in that case).
String? getBridgeTypeSvg(String? type) {
  switch (type) {
    case 'whatsapp':
    case 'telegram':
    case 'signal':
    case 'discord':
    case 'slack':
    case 'matrix':
    case 'linkedin':
      return 'assets/bridge_icons/$type.svg';
    default:
      return null;
  }
}

/// Gets a color for a bridge type
Color getBridgeTypeColor(String? type) {
  switch (type) {
    case 'whatsapp':
      return const Color(0xFF25D366);
    case 'telegram':
      return const Color(0xFF0088CC);
    case 'signal':
      return const Color(0xFF3A76F0);
    case 'discord':
      return const Color(0xFF5865F2);
    case 'slack':
      return const Color(0xFF4A154B);
    case 'matrix':
      return const Color(0xFF0DBD8B);
    case 'linkedin':
      return const Color(0xFF0A66C2);
    default:
      return const Color(0xFF9E9E9E); // Medium grey — visible in both light and dark
  }
}

/// Known bridge bot suffixes/patterns for common Matrix bridges
const _excludedBotPatterns = ['extera'];

const _bridgePatterns = [
  // Generic bot patterns (any server)
  'bot.signal',
  'bot.telegram',
  'bot.whatsapp',
  'bot.discord',
  'bot.slack',
  'signalbot',
  'telegrambot',
  'whatsappbot',
  'botwhatsapp',
  'whatsapp.bot',
  'bot.whatsapp',
  'discordbot',
  'slackbot',
  'bridgebot',
  'relaybot',
  'bridge bot',
  // Bridge participant IDs (any server)
  'whatsapp_',
  'telegram_',
  'signal_',
  'discord_',
  'slack_',
  'whatsapp_lid',
  // Specific patterns (any server)
  'wa-bot',
  'telegram-bot',
  'mautrix-telegram',
  'tgbot',
  'tg-bot',
  'heisenbridge',
  'beeper',
  't2bot',
  'whappbot',
  'mx-puppet-bridge',
  'mx-puppet',
  'whatsapp-bot',
  'signal-bot',
  'discord-bot',
  'slack-bot',
  'hangouts-bot',
  'gitter-bot',
  'bridged',
  // Server-independent patterns
  '@whatsapp',
  '@telegram',
  '@signal',
  '@discord',
  '@slack',
];

/// Known bridge state event types
const _bridgeStateEventTypes = [
  // mautrix (v1 t/m v3)
  'im.vector.modular.bridge',
  'im.vector.modular.bridge.v2',
  'im.vector.modular.bridge.v3',
  // Beeper
  'com.beeper.bridge',
  // Element / oudere MSC2776-achtige bruggen
  'io.element.bridge',
  'uk.half-shot.msc2776.bridge',
];

/// Checks if a user ID matches known bridge bot patterns
bool isBridgeBotByUserId(String userId) {
  final lowerUserId = userId.toLowerCase();
  for (final pattern in _excludedBotPatterns) {
    if (lowerUserId.contains(pattern)) {
      return false;
    }
  }
  for (final pattern in _bridgePatterns) {
    if (lowerUserId.contains(pattern)) {
      return true;
    }
  }
  return false;
}

/// Checks if a room is a bridge room by looking at the bridge state events
bool isBridgeRoomByState(Room room) {
  for (final eventType in _bridgeStateEventTypes) {
    final stateEvent = room.getState(eventType);
    if (stateEvent != null) {
      return true;
    }
  }
  return false;
}

/// Checks if a user ID is a known bridge bot
/// Also checks direct chat matrix ID as bridge bots often initiate DM
bool isBridgeBot(String userId, Room room) {
  // Check by user ID pattern
  if (isBridgeBotByUserId(userId.toString())) {
    return true;
  }

  // Check if this is a direct chat with a bridge bot
  final directChatMatrixId = room.directChatMatrixID;
  if (directChatMatrixId != null && isBridgeBotByUserId(directChatMatrixId)) {
    return true;
  }

  return false;
}

/// Netwerkpatronen per brugnetwerk, gekoppeld aan de user-id's van de
/// bridge-bots. De patronen zijn bewust streng: ze moeten een brug
/// identificeren en niet per ongeluk een gewone Matrix-account treffen.
const _bridgeNetworkUserPatterns = <String, List<String>>{
  'whatsapp': [
    'whatsapp_',
    'whatsappbot',
    'whatsapp-bot',
    'whatsapp.bot',
    'bot.whatsapp',
    'botwhatsapp',
    'whappbot',
    'wa-bot',
  ],
  'telegram': [
    'telegram_',
    'telegram-bot',
    'telegrambot',
    'telegram.bot',
    'bot.telegram',
    'mautrix-telegram',
    'tgbot',
    'tg-bot',
    '@tg:',
    '@tg_',
  ],
  'signal': ['signal_', 'signal-bot', 'signalbot', 'signal.bot', 'bot.signal'],
  'discord': ['discord_', 'discord-bot', 'discordbot', 'discord.bot', 'bot.discord'],
  'slack': ['slack_', 'slack-bot', 'slackbot', 'slack.bot', 'bot.slack'],
  'linkedin': ['linkedin_', 'linkedin-bot', 'linkedinbot', 'bot.linkedin'],
};

/// Aliassen van brugkamers bevatten altijd een netwerkspecifiek voorvoegsel.
const _bridgeAliasPrefixes = <String, List<String>>{
  'whatsapp': ['whatsapp_', 'wa_'],
  'telegram': ['telegram_', 'tg_'],
  'signal': ['signal_'],
  'discord': ['discord_'],
  'slack': ['slack_'],
  'linkedin': ['linkedin_'],
};

/// Herkent een netwerk op basis van vrije tekst (bv. de bridge_name of het
/// netwerk-veld van een state-event). Wordt alleen gebruikt voor waarden
/// die door de brug zelf zijn gezet — nooit voor kamer- of gebruikersnamen.
String? bridgeNetworkFromString(String? value) {
  if (value == null) return null;
  final v = value.toLowerCase();
  if (v.contains('whatsapp')) return 'whatsapp';
  if (v.contains('telegram')) return 'telegram';
  if (v.contains('signal')) return 'signal';
  if (v.contains('discord')) return 'discord';
  if (v.contains('slack')) return 'slack';
  if (v.contains('linkedin')) return 'linkedin';
  return null;
}

/// Korte brugcodes waarmee een bridge-bot zichzelf aanduidt. De localpart
/// moet volledig uit de code bestaan, eventueel gevolgd door een
/// scheidingsteken en cijfers (bv. @wa, @wa_31612345678, @telegram).
const _shortCodeNetworks = <String, String>{
  'wa': 'whatsapp',
  'whatsapp': 'whatsapp',
  'tg': 'telegram',
  'telegram': 'telegram',
  'signal': 'signal',
  'discord': 'discord',
  'slack': 'slack',
  'linkedin': 'linkedin',
};

final _shortCodePattern = RegExp(
  r'^@(wa|whatsapp|tg|telegram|signal|discord|slack|linkedin)([_\-]\d*)?$',
);

/// Herkent het netwerk op basis van een bridge-bot user-id.
String? bridgeNetworkFromUserId(String? userId) {
  if (userId == null || userId.isEmpty) return null;
  final id = userId.toLowerCase();
  final localpart = id.split(':').first;
  final shortCode = _shortCodePattern.firstMatch(localpart);
  if (shortCode != null) {
    return _shortCodeNetworks[shortCode.group(1)!];
  }
  for (final entry in _bridgeNetworkUserPatterns.entries) {
    if (entry.value.any(id.contains)) return entry.key;
  }
  return null;
}

/// Herkent het netwerk op basis van de alias van de kamer.
String? bridgeNetworkFromAlias(String? alias) {
  if (alias == null || alias.isEmpty) return null;
  final a = alias.toLowerCase();
  for (final entry in _bridgeAliasPrefixes.entries) {
    if (entry.value.any(a.contains)) return entry.key;
  }
  return null;
}

/// Bepaalt het netwerk van een brugkamer, of null als de kamer géén
/// brugkamer is.
///
/// Alleen harde signalen worden gebruikt:
///  - bridge state-events (mautrix, Beeper, Element)
///  - bridge-bot user-ids
///  - bridge-aliases
///
/// Vrije tekst uit kamer- of gebruikersnamen wordt bewust NIET gebruikt.
/// Daarmee werden gewone Matrix-chats ten onrechte als WhatsApp of
/// Telegram aangemerkt: een contact "Ritsa wa", een groep met een lid
/// "Signal", of een kamer die op een telefoonnummer begint.
String? getBridgeType(Room room) {
  // 1. Bridge state-events: het meest betrouwbare signaal.
  for (final eventType in _bridgeStateEventTypes) {
    final stateEvent = room.getState(eventType);
    if (stateEvent == null) continue;
    final content = stateEvent.content;
    for (final key in const ['bridge_name', 'network', 'name', 'service', 'type']) {
      final network = bridgeNetworkFromString(content[key]?.toString());
      if (network != null) return network;
    }
    // Er staat een brug-state-event, maar het netwerk is niet te herkennen.
    return 'other';
  }

  // 2. De directe chat loopt via een bridge-bot.
  final byDirect = bridgeNetworkFromUserId(room.directChatMatrixID);
  if (byDirect != null) return byDirect;

  // 3. De alias van de kamer verwijst naar een brug.
  final byAlias = bridgeNetworkFromAlias(room.canonicalAlias);
  if (byAlias != null) return byAlias;

  // 4. Een lid van de kamer is een bridge-bot.
  final memberStates = room.states[EventTypes.RoomMember];
  if (memberStates != null) {
    for (final memberId in memberStates.keys) {
      final byMember = bridgeNetworkFromUserId(memberId);
      if (byMember != null) return byMember;
    }
  }

  // 5. De kamer is aangemaakt door een bridge-bot.
  final createEvent = room.getState(EventTypes.RoomCreate);
  if (createEvent != null) {
    final byCreator = bridgeNetworkFromUserId(
      createEvent.content['creator']?.toString(),
    );
    if (byCreator != null) return byCreator;
  }

  return null;
}

/// Beschrijft welk signaal een kamer als brugkamer aanmerkt, in
/// leesbare vorm. Handig om te controleren waarom een chat wél of juist
/// niet als brugkamer wordt herkend. Geeft null terug als er geen signaal is.
String? bridgeDetectionSignal(Room room) {
  for (final eventType in _bridgeStateEventTypes) {
    final stateEvent = room.getState(eventType);
    if (stateEvent == null) continue;
    final content = stateEvent.content;
    for (final key in const ['bridge_name', 'network', 'name', 'service', 'type']) {
      final network = bridgeNetworkFromString(content[key]?.toString());
      if (network != null) {
        return 'state-event $eventType · $key = $network';
      }
    }
    return 'state-event $eventType · netwerk onbekend';
  }
  final direct = room.directChatMatrixID;
  if (bridgeNetworkFromUserId(direct) != null) {
    return 'bridge-bot $direct';
  }
  final alias = room.canonicalAlias;
  if (bridgeNetworkFromAlias(alias) != null) {
    return 'alias $alias';
  }
  final memberStates = room.states[EventTypes.RoomMember];
  if (memberStates != null) {
    for (final memberId in memberStates.keys) {
      if (bridgeNetworkFromUserId(memberId) != null) {
        return 'bridge-bot $memberId';
      }
    }
  }
  final createEvent = room.getState(EventTypes.RoomCreate);
  if (createEvent != null) {
    final creator = createEvent.content['creator']?.toString();
    if (bridgeNetworkFromUserId(creator) != null) {
      return 'maker $creator';
    }
  }
  return null;
}

/// Checks if a room is a bridge room (has bridge-related state or direct chat with bridge bot)
bool isBridgeRoom(Room room) => getBridgeType(room) != null;
