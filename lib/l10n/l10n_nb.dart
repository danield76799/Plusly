// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian Bokmål (`nb`).
class L10nNb extends L10n {
  L10nNb([String locale = 'nb']) : super(locale);

  @override
  String get alwaysUse24HourFormat => 'false';

  @override
  String get repeatPassword => 'Gjenta passord';

  @override
  String get notAnImage => 'Ikke en bildefil.';

  @override
  String get ignoreUser => 'Ignorer bruker';

  @override
  String get remove => 'Fjern';

  @override
  String get importNow => 'Importer nå';

  @override
  String get importEmojis => 'Importer emojier';

  @override
  String get importFromZipFile => 'Importer fra .zip-fil';

  @override
  String get exportEmotePack => 'Eksporter smilefjes som .zip-fil';

  @override
  String get replace => 'Erstatt';

  @override
  String get about => 'Om';

  @override
  String aboutHomeserver(String homeserver) {
    return 'Om $homeserver';
  }

  @override
  String get accept => 'Godta';

  @override
  String acceptedTheInvitation(String username) {
    return '👍 $username godtok invitasjonen';
  }

  @override
  String get account => 'Konto';

  @override
  String activatedEndToEndEncryption(String username) {
    return '$username skrudde på ende-til-ende -kryptering';
  }

  @override
  String get addEmail => 'Legg til e-post';

  @override
  String get confirmMatrixId =>
      'Bekreft Matrix-IDen din for å slette kontoen din.';

  @override
  String supposedMxid(String mxid) {
    return 'Denne bør være $mxid';
  }

  @override
  String get addToSpace => 'Legg til område';

  @override
  String get admin => 'Administrator';

  @override
  String get alias => 'alias';

  @override
  String get all => 'Alle';

  @override
  String get allChats => 'Alle samtaler';

  @override
  String get commandHint_roomupgrade =>
      'Oppgrader dette rommet til den gitte romversjonen';

  @override
  String get commandHint_googly => 'Send noen googly-eyes';

  @override
  String get commandHint_cuddle => 'Send en kos';

  @override
  String get commandHint_hug => 'Send en klem';

  @override
  String googlyEyesContent(String senderName) {
    return '$senderName sender deg googly-eyes';
  }

  @override
  String cuddleContent(String senderName) {
    return '$senderName koser med deg';
  }

  @override
  String hugContent(String senderName) {
    return '$senderName klemmer deg';
  }

  @override
  String answeredTheCall(String senderName) {
    return '$senderName besvarte anropet';
  }

  @override
  String get anyoneCanJoin => 'Hvem som helst kan delta';

  @override
  String get appLock => 'Programlås';

  @override
  String get appLockDescription =>
      'Lås appen med en PIN-kode når den ikke er i bruk';

  @override
  String get archive => 'Arkiv';

  @override
  String get areGuestsAllowedToJoin => 'Kan gjester bli med?';

  @override
  String get areYouSure => 'Er du sikker?';

  @override
  String get areYouSureYouWantToLogout => 'Er du sikker på at du vil logge ut?';

  @override
  String get askSSSSSign =>
      'For å kunne signere den andre personen, skriv inn ditt sikre lagerpassord eller gjenopprettingsnøkkel.';

  @override
  String askVerificationRequest(String username) {
    return 'Godta denne bekreftelsesforespørselen fra $username?';
  }

  @override
  String get autoplayImages =>
      'Automatisk spill av animerte stickers og emojis';

  @override
  String badServerLoginTypesException(
    String serverVersions,
    String supportedVersions,
    Object suportedVersions,
  ) {
    return 'Denne hjemme serveren støtter følgende innloggings-typer:\n$serverVersions\nMen denne applikasjonen støtter kun:\n$supportedVersions';
  }

  @override
  String get sendTypingNotifications => 'Send varsler ved skriving';

  @override
  String get swipeRightToLeftToReply =>
      'Sveip fra høyre mot venstre for å svare';

  @override
  String get sendOnEnter => 'Trykk på enter for å sende';

  @override
  String get noMoreChatsFound => 'Ingen flere chatter funnet ...';

  @override
  String get noChatsFoundHere =>
      'Ingen chatter her. Bruk knappen under for å starte en ny samtale. ⤵️';

  @override
  String get unread => 'Ulest';

  @override
  String get space => 'Område';

  @override
  String get spaces => 'Områder';

  @override
  String get banFromChat => 'Bannlys fra sludring';

  @override
  String get banned => 'Bannlyst';

  @override
  String bannedUser(String username, String targetName) {
    return '$username bannlyste $targetName';
  }

  @override
  String get blockDevice => 'Blokker enhet';

  @override
  String get blocked => 'Blokkert';

  @override
  String get cancel => 'Avbryt';

  @override
  String cantOpenUri(String uri) {
    return 'Kan ikke åpne URI $uri';
  }

  @override
  String get changeDeviceName => 'Endre enhetsnavn';

  @override
  String changedTheChatAvatar(String username) {
    return '$username endret sludreavatar';
  }

  @override
  String changedTheChatDescription(Object username) {
    return '$username endret beskrivelsen av chatten';
  }

  @override
  String changedTheChatDescriptionTo(String username, String description) {
    return '$username endret chatbeskrivelsen til: \'$description\'';
  }

  @override
  String changedTheChatName(Object username) {
    return '$username endret navnet på chatten';
  }

  @override
  String changedTheChatNameTo(String username, String chatname) {
    return '$username endret chatnavnet til: \'$chatname\'';
  }

  @override
  String changedTheChatPermissions(String username) {
    return '$username endret sludretilgangene';
  }

  @override
  String changedTheDisplaynameTo(String username, String displayname) {
    return '$username endret visningsnavn til: \'$displayname\'';
  }

  @override
  String changedTheGuestAccessRules(String username) {
    return '$username endret gjestetilgangsreglene';
  }

  @override
  String changedTheGuestAccessRulesTo(String username, String rules) {
    return '$username endret gjestetilgangsregler til: $rules';
  }

  @override
  String changedTheHistoryVisibility(String username) {
    return '$username endret historikksynlighet';
  }

  @override
  String changedTheHistoryVisibilityTo(String username, String rules) {
    return '$username endret historikksynlighet til: $rules';
  }

  @override
  String changedTheJoinRules(String username) {
    return '$username endret tilgangsreglene';
  }

  @override
  String changedTheJoinRulesTo(String username, String joinRules) {
    return '$username endret tilgangsreglene til: $joinRules';
  }

  @override
  String changedTheProfileAvatar(String username) {
    return '$username endret avataren sin';
  }

  @override
  String changedTheRoomAliases(String username) {
    return '$username endret rom-aliasene';
  }

  @override
  String changedTheRoomInvitationLink(String username) {
    return '$username endret invitasjonslenken';
  }

  @override
  String get changePassword => 'Endre passord';

  @override
  String get changeTheHomeserver => 'Endre hjemmetjener';

  @override
  String get changeTheme => 'Endre din stil';

  @override
  String get changeTheNameOfTheGroup => 'Endre gruppens navn';

  @override
  String get changeYourAvatar => 'Bytt profilbilde';

  @override
  String get channelCorruptedDecryptError => 'Krypteringen er skadet';

  @override
  String get chat => 'Sludring';

  @override
  String get yourChatBackupHasBeenSetUp =>
      'Sikkerhetskopien av chatten din er konfigurert.';

  @override
  String get chatBackup => 'Sludringssikkerhetskopi';

  @override
  String get chatBackupDescription =>
      'Meldingene dine er sikret med en gjenopprettingsnøkkel. Pass på at du ikke mister den.';

  @override
  String get chatDetails => 'Sludringsdetaljer';

  @override
  String get chats => 'Chatter';

  @override
  String get chooseAStrongPassword => 'Velg et sterkt passord';

  @override
  String get clearArchive => 'Tøm arkivet';

  @override
  String get close => 'Lukk';

  @override
  String get commandHint_markasdm =>
      'Marker som rom for direktemeldinger for den angitte Matrix-IDen';

  @override
  String get commandHint_markasgroup => 'Merk som gruppe';

  @override
  String get commandHint_ban => 'Utesteng den gitte brukeren fra dette rommet';

  @override
  String get commandHint_clearcache => 'Tøm cache';

  @override
  String get commandHint_create =>
      'Opprett en tom gruppechat\nBruk --no-encryption for å deaktivere kryptering';

  @override
  String get commandHint_discardsession => 'Forkast økten';

  @override
  String get commandHint_dm =>
      'Start en direkte chat\nBruk --no-encryption for å deaktivere kryptering';

  @override
  String get commandHint_html => 'Send HTML-formatert tekst';

  @override
  String get commandHint_invite =>
      'Inviter den gitte brukeren til dette rommet';

  @override
  String get commandHint_join => 'Bli med i det gitte rommet';

  @override
  String get commandHint_kick => 'Fjern den gitte brukeren fra dette rommet';

  @override
  String get commandHint_leave => 'Forlat dette rommet';

  @override
  String get commandHint_me => 'Beskriv deg selv';

  @override
  String get commandHint_myroomavatar =>
      'Angi bilde for dette rommet (med mxc-uri)';

  @override
  String get commandHint_myroomnick =>
      'Angi visningsnavnet ditt for dette rommet';

  @override
  String get commandHint_op => 'Angi makt-nivå for valgt bruker (standard: 50)';

  @override
  String get commandHint_plain => 'Send uformatert tekst';

  @override
  String get commandHint_react => 'Send svar som en reaksjon';

  @override
  String get commandHint_send => 'Send tekst';

  @override
  String get commandHint_unban =>
      'Opphev utestengelsen til den gitte brukeren fra dette rommet';

  @override
  String get commandInvalid => 'Ugyldig kommando';

  @override
  String commandMissing(String command) {
    return '$command er ikke en kommando.';
  }

  @override
  String get compareEmojiMatch =>
      'Sammenlign og forsikre at følgende emojiene samsvarer med de på den andre enheten';

  @override
  String get compareNumbersMatch =>
      'Sammenlign og forsikre at følgende tall samsvarer med de på den andre enheten';

  @override
  String get configureChat => 'Sett opp sludring';

  @override
  String get contactHasBeenInvitedToTheGroup => 'Kontakt invitert til gruppen';

  @override
  String get contentHasBeenReported =>
      'Innholdet har blitt rapportert til tjeneradministratorene';

  @override
  String get copiedToClipboard => 'Kopiert til utklippstavle';

  @override
  String get copy => 'Kopier';

  @override
  String get copyToClipboard => 'Kopier til utklippstavle';

  @override
  String couldNotDecryptMessage(String error) {
    return 'Kunne ikke dekryptere melding: $error';
  }

  @override
  String get checkList => 'Sjekkliste';

  @override
  String countParticipants(int count) {
    return '$count deltagere';
  }

  @override
  String countInvited(int count) {
    return '$count inviterte';
  }

  @override
  String get create => 'Opprett';

  @override
  String createdTheChat(String username) {
    return '$username opprettet sludringen';
  }

  @override
  String get createGroup => 'Opprett gruppe';

  @override
  String get createNewSpace => 'Nytt område';

  @override
  String get currentlyActive => 'Aktiv nå';

  @override
  String get darkTheme => 'Mørk';

  @override
  String dateAndTimeOfDay(String date, String timeOfDay) {
    return '$timeOfDay, $date';
  }

  @override
  String get deactivateAccountWarning =>
      'Dette vil skru av din brukerkonto for godt, og kan ikke angres! Er du sikker?';

  @override
  String get defaultPermissionLevel => 'Forvalgt tilgangsnivå';

  @override
  String get delete => 'Slett';

  @override
  String get deleteAccount => 'Slett konto';

  @override
  String get deleteMessage => 'Slett melding';

  @override
  String get device => 'Enhet';

  @override
  String get deviceId => 'Enhets-ID';

  @override
  String get devices => 'Enheter';

  @override
  String get directChats => 'Direktesludringer';

  @override
  String get displaynameHasBeenChanged => 'Visningsnavn endret';

  @override
  String get downloadFile => 'Last ned fil';

  @override
  String get edit => 'Rediger';

  @override
  String get editBlockedServers => 'Rediger blokkerte tjenere';

  @override
  String get chatPermissions => 'Chat tillatelser';

  @override
  String get editDisplayname => 'Rediger visningsnavn';

  @override
  String get editRoomAliases => 'Rediger rom aliaser';

  @override
  String get editRoomAvatar => 'Rediger romavatar';

  @override
  String get emoteExists => 'Smilefjeset finnes allerede!';

  @override
  String get emoteInvalid => 'Ugyldig smilefjes-kode!';

  @override
  String get emoteKeyboardNoRecents => 'Nylig brukte emotes vil vises her ...';

  @override
  String get emotePacks => 'Smilefjespakker for rommet';

  @override
  String get emoteSettings => 'Smilefjes-innstillinger';

  @override
  String get globalChatId => 'Global chat-ID';

  @override
  String get accessAndVisibility => 'Tilgang og synlighet';

  @override
  String get accessAndVisibilityDescription =>
      'Hvem som har lov til å bli med i denne chatten og hvordan chatten kan oppdages.';

  @override
  String get calls => 'Anrop';

  @override
  String get customEmojisAndStickers =>
      'Egendefinerte emojier og klistremerker';

  @override
  String get customEmojisAndStickersBody =>
      'Legg til eller del tilpassede emojier eller klistremerker som kan brukes i hvilken som helst chat.';

  @override
  String get emoteShortcode => 'Smilefjes-kode';

  @override
  String get emptyChat => 'Tom sludring';

  @override
  String get enableEmotesGlobally =>
      'Skru på smilefjespakke for hele programmet';

  @override
  String get enableEncryption => 'Skru på kryptering';

  @override
  String get enableEncryptionWarning =>
      'Du vil ikke kunne skru av kryptering lenger. Er du sikker?';

  @override
  String get encrypted => 'Kryptert';

  @override
  String get encryption => 'Kryptering';

  @override
  String get encryptionNotEnabled => 'Kryptering er ikke påskrudd';

  @override
  String endedTheCall(String senderName) {
    return '$senderName avsluttet samtalen';
  }

  @override
  String get enterAnEmailAddress => 'Skriv inn en e-postadresse';

  @override
  String get homeserver => 'Hjemmeserver';

  @override
  String errorObtainingLocation(String error) {
    return 'Feil ved henting av posisjon: $error';
  }

  @override
  String get everythingReady => 'Alt er klart!';

  @override
  String get extremeOffensive => 'Veldig';

  @override
  String get fileName => 'Filnavn';

  @override
  String get fluffychat => 'FluffyChat';

  @override
  String get fontSize => 'Skriftstørrelse';

  @override
  String get forward => 'Videre';

  @override
  String get fromJoining => 'Fra å ta del';

  @override
  String get fromTheInvitation => 'Fra invitasjonen';

  @override
  String get group => 'Gruppe';

  @override
  String get chatDescription => 'Chat beskrivelse';

  @override
  String get chatDescriptionHasBeenChanged => 'Chatbeskrivelsen er endret';

  @override
  String get groupIsPublic => 'Gruppen er offentlig';

  @override
  String get groups => 'Grupper';

  @override
  String groupWith(String displayname) {
    return 'Gruppe med $displayname';
  }

  @override
  String get guestsAreForbidden => 'Gjester forbudt';

  @override
  String get guestsCanJoin => 'Gjester kan ta del';

  @override
  String hasWithdrawnTheInvitationFor(String username, String targetName) {
    return '$username har trukket tilbake invitasjonen til $targetName';
  }

  @override
  String get help => 'Hjelp';

  @override
  String get hideRedactedEvents => 'Skjul tilbaketrukne hendelser';

  @override
  String get hideRedactedMessages => 'Skjul redigerte meldinger';

  @override
  String get hideRedactedMessagesBody =>
      'Hvis noen redigerer en melding, vil ikke denne meldingen lenger være synlig i chatten.';

  @override
  String get hideInvalidOrUnknownMessageFormats =>
      'Skjul ugyldige eller ukjente meldingsformater';

  @override
  String get howOffensiveIsThisContent => 'Hvor støtende er innholdet?';

  @override
  String get id => 'ID';

  @override
  String get block => 'Blokkér';

  @override
  String get blockedUsers => 'Blokkerte brukere';

  @override
  String get blockListDescription =>
      'Du kan blokkere brukere som forstyrrer deg. Du vil ikke kunne motta meldinger eller rominvitasjoner fra brukerne på din personlige blokkeringsliste.';

  @override
  String get blockUsername => 'Ignorer brukernavn';

  @override
  String get iHaveClickedOnLink => 'Jeg har klikket på lenken';

  @override
  String get incorrectPassphraseOrKey =>
      'Feilaktig passord eller gjenopprettingsnøkkel';

  @override
  String get inoffensive => 'Harmløst';

  @override
  String get inviteContact => 'Inviter kontakt';

  @override
  String inviteContactToGroup(String groupName) {
    return 'Inviter kontakt til $groupName';
  }

  @override
  String get noChatDescriptionYet => 'Ingen chatbeskrivelse er opprettet ennå.';

  @override
  String get tryAgain => 'Prøv igjen';

  @override
  String get invalidServerName => 'Ugyldig servernavn';

  @override
  String get invited => 'Invitert';

  @override
  String get redactMessageDescription =>
      'Meldingen vil bli redigert for alle deltakerne i denne samtalen. Dette kan ikke angres.';

  @override
  String get optionalRedactReason =>
      '(Valgfritt) Årsak til redigering av denne meldingen...';

  @override
  String invitedUser(String username, String targetName) {
    return '$username inviterte $targetName';
  }

  @override
  String get invitedUsersOnly => 'Kun inviterte brukere';

  @override
  String inviteText(String username, String link) {
    return '$username har invitert deg til FluffyChat. \n1. Installer FluffyChat: https://fluffychat.im \n2. Registrer deg eller logg inn \n3. Åpne invitasjonslenken: \n $link';
  }

  @override
  String get isTyping => 'skriver…';

  @override
  String joinedTheChat(String username) {
    return '${username}ble med i samtalen';
  }

  @override
  String get joinRoom => 'Ta del i rom';

  @override
  String kicked(String username, String targetName) {
    return '$username kastet ut $targetName';
  }

  @override
  String kickedAndBanned(String username, String targetName) {
    return '$username kastet ut og bannlyste $targetName';
  }

  @override
  String get kickFromChat => 'Kast ut av sludringen';

  @override
  String lastActiveAgo(String localizedTimeShort) {
    return 'Sist aktiv: $localizedTimeShort';
  }

  @override
  String get leave => 'Forlat';

  @override
  String get leftTheChat => 'Forlat sludringen';

  @override
  String get lightTheme => 'Lys';

  @override
  String loadCountMoreParticipants(int count) {
    return 'Last inn $count deltagere til';
  }

  @override
  String get dehydrate => 'Eksporter økten og slett enheten';

  @override
  String get dehydrateWarning =>
      'Denne handlingen kan ikke angres. Sørg for at du lagrer sikkerhetskopifilen på en trygg måte.';

  @override
  String get hydrate => 'Gjenopprett fra sikkerhetskopifil';

  @override
  String get loadingPleaseWait => 'Laster inn… Vent.';

  @override
  String get loadMore => 'Last inn mer…';

  @override
  String get locationDisabledNotice =>
      'Lokasjonstjenester er deaktivert. Vennligst aktiver dem for at du skal kunne dele posisjonen din.';

  @override
  String get locationPermissionDeniedNotice =>
      'Lokasjonstillatelse nektet. Gi dem tillatelse til å dele din lokasjon.';

  @override
  String get login => 'Logg inn';

  @override
  String logInTo(String homeserver) {
    return 'Logg inn på $homeserver';
  }

  @override
  String get logout => 'Logg ut';

  @override
  String get mention => 'Nevn';

  @override
  String get messages => 'Meldinger';

  @override
  String get messagesStyle => 'Meldinger:';

  @override
  String get moderator => 'Moderator';

  @override
  String get muteChat => 'Forstum sludring';

  @override
  String get needPantalaimonWarning =>
      'Merk at du trenger Pantalaimon for å bruke ende-til-ende -kryptering inntil videre.';

  @override
  String get newChat => 'Ny sludring';

  @override
  String get newMessageInFluffyChat => 'Ny melding i FluffyChat';

  @override
  String get newVerificationRequest => 'Ny bekreftelsesforespørsel!';

  @override
  String get next => 'Neste';

  @override
  String get no => 'Nei';

  @override
  String get noConnectionToTheServer => 'Ingen tilkobling til tjeneren';

  @override
  String get noEmotesFound => 'Fant ingen smilefjes. 😕';

  @override
  String get noEncryptionForPublicRooms =>
      'Du kan bare aktivere kryptering på rom som ikke er offentlig tilgjengelig.';

  @override
  String get noGoogleServicesWarning =>
      'Firebase Cloud Messaging ser ikke ut til å være tilgjengelig på enheten din. For å fortsatt kunne motta push-varsler, anbefaler vi at du installerer ntfy. Med ntfy eller en annen UnifiedPush-leverandør kan du motta push-varsler på en datasikker måte. Du kan laste ned ntfy fra Play Store eller F-Droid.';

  @override
  String noMatrixServer(String server1, String server2) {
    return '$server1 er ingen matrix-server, bruk $server2 i stedet?';
  }

  @override
  String get shareInviteLink => 'Del invitasjonslenke';

  @override
  String get scanQrCode => 'Skann QR-kode';

  @override
  String get none => 'Ingen';

  @override
  String get noPasswordRecoveryDescription =>
      'Du har ikke lagt til en måte å gjenopprette passordet ditt på.';

  @override
  String get noPermission => 'Ingen tilgang';

  @override
  String get noRoomsFound => 'Fant ingen rom …';

  @override
  String get notifications => 'Merknader';

  @override
  String numUsersTyping(int count) {
    return '$count brukere skriver …';
  }

  @override
  String get obtainingLocation => 'Henter sted …';

  @override
  String get offensive => 'Støtende';

  @override
  String get offline => 'Frakoblet';

  @override
  String get ok => 'Ok';

  @override
  String get online => 'Pålogget';

  @override
  String get onlineKeyBackupEnabled =>
      'Nettbasert sikkerhetskopiering av nøkler på';

  @override
  String get oopsPushError =>
      'Oops! Dessverre oppsto det en feil under oppsettet av push-varsler.';

  @override
  String get oopsSomethingWentWrong => 'Oida, noe gikk galt …';

  @override
  String get openAppToReadMessages => 'Åpne programmet for å lese meldinger';

  @override
  String get openCamera => 'Åpne kamera';

  @override
  String get oneClientLoggedOut => 'En av klientene dine har blitt logget ut';

  @override
  String get addAccount => 'Legg til konto';

  @override
  String get editBundlesForAccount => 'Rediger pakker for denne kontoen';

  @override
  String get addToBundle => 'Legg til i pakke';

  @override
  String get removeFromBundle => 'Fjern fra denne pakken';

  @override
  String get bundleName => 'Navn på pakke';

  @override
  String get enableMultiAccounts =>
      '(BETA) Aktiver flere kontoer på denne enheten';

  @override
  String get openInMaps => 'Åpne i kart';

  @override
  String get link => 'Lenke';

  @override
  String get serverRequiresEmail =>
      'Denne serveren må validere e-postadressen din for registrering.';

  @override
  String get or => 'Eller';

  @override
  String get participant => 'Deltager';

  @override
  String get passphraseOrKey => 'Passord eller gjenopprettingsnøkkel';

  @override
  String get password => 'Passord';

  @override
  String get passwordForgotten => 'Passord glemt';

  @override
  String get passwordHasBeenChanged => 'Passord endret';

  @override
  String get overview => 'Oversikt';

  @override
  String get passwordRecoverySettings =>
      'Innstillinger for gjenoppretting av passord';

  @override
  String get passwordRecovery => 'Passordgjenoppretting';

  @override
  String get pickImage => 'Velg bilde';

  @override
  String get pin => 'Fest';

  @override
  String play(String fileName) {
    return 'Spill av $fileName';
  }

  @override
  String get pleaseChooseAPasscode => 'Vennligst velg en passordkode';

  @override
  String get pleaseClickOnLink => 'Klikk på lenken i e-posten og fortsett.';

  @override
  String get pleaseEnter4Digits =>
      'Skriv inn fire sifre eller la feltet stå tomt for å deaktivere applåsen.';

  @override
  String get pleaseEnterYourPassword => 'Skriv inn passordet ditt';

  @override
  String get pleaseEnterYourPin => 'Oppgi din PIN-kode';

  @override
  String get pleaseEnterYourUsername => 'Skriv inn brukernavnet ditt';

  @override
  String get pleaseFollowInstructionsOnWeb =>
      'Følg instruksen på nettsiden og trykk på «Neste».';

  @override
  String get privacy => 'Personvern';

  @override
  String get publicRooms => 'Offentlige rom';

  @override
  String get pushRules => 'Dyttingsregler';

  @override
  String get reason => 'Grunn';

  @override
  String get recording => 'Opptak';

  @override
  String redactedBy(String username) {
    return 'Redigert av $username';
  }

  @override
  String get directChat => 'Direkte chat';

  @override
  String redactedByBecause(String username, String reason) {
    return 'Redigert av $username fordi: «$reason»';
  }

  @override
  String redactedAnEvent(String username) {
    return '$username har trukket tilbake en hendelse';
  }

  @override
  String get redactMessage => 'Rediger melding';

  @override
  String get register => 'Registrer';

  @override
  String get reject => 'Avslå';

  @override
  String rejectedTheInvitation(String username) {
    return '$username avslo invitasjonen';
  }

  @override
  String get removeAllOtherDevices => 'Fjern alle andre enheter';

  @override
  String removedBy(String username) {
    return 'Fjernet av $username';
  }

  @override
  String get unbanFromChat => 'Opphev bannlysning';

  @override
  String get removeYourAvatar => 'Fjern din avatar';

  @override
  String get replaceRoomWithNewerVersion => 'Erstatt rom med nyere versjon';

  @override
  String get reply => 'Svar';

  @override
  String get reportMessage => 'Rapporter melding';

  @override
  String get requestPermission => 'Forespør tilgang';

  @override
  String get roomHasBeenUpgraded => 'Rommet har blitt oppgradert';

  @override
  String get roomVersion => 'Rom versjon';

  @override
  String get saveFile => 'Lagre fil';

  @override
  String get search => 'Søk';

  @override
  String get security => 'Sikkerhet';

  @override
  String get recoveryKey => 'Gjenopprettingsnøkkel';

  @override
  String get recoveryKeyLost => 'Mistet gjenopprettingsnøkkel?';

  @override
  String get send => 'Send';

  @override
  String get sendAMessage => 'Send en melding';

  @override
  String get sendAsText => 'Send som tekst';

  @override
  String get sendAudio => 'Send lyd';

  @override
  String get sendFile => 'Send fil';

  @override
  String get sendImage => 'Send bilde';

  @override
  String sendImages(int count) {
    return 'Send $count bilde';
  }

  @override
  String get sendMessages => 'Send meldinger';

  @override
  String get sendVideo => 'Send video';

  @override
  String sentAFile(String username) {
    return '$username sendte en fil';
  }

  @override
  String sentAnAudio(String username) {
    return '$username sendte lyd';
  }

  @override
  String sentAPicture(String username) {
    return '$username sendte et bilde';
  }

  @override
  String sentASticker(String username) {
    return '$username sendte et klistremerke';
  }

  @override
  String sentAVideo(String username) {
    return '$username sendte en video';
  }

  @override
  String sentCallInformations(String senderName) {
    return '$senderName sendte anropsinfo';
  }

  @override
  String get setAsCanonicalAlias => 'Angi som hovedalias';

  @override
  String get setChatDescription => 'Sett chat beskrivelse';

  @override
  String get setStatus => 'Angi status';

  @override
  String get settings => 'Innstilinger';

  @override
  String get share => 'Del';

  @override
  String sharedTheLocation(String username) {
    return '$username delte posisjonen';
  }

  @override
  String get shareLocation => 'Del lokasjon';

  @override
  String get showPassword => 'Vis passord';

  @override
  String get presencesToggle => 'Vis statusmeldinger fra andre brukere';

  @override
  String get skip => 'Hopp over';

  @override
  String get sourceCode => 'Kildekode';

  @override
  String get spaceIsPublic => 'Området er offentlig';

  @override
  String get spaceName => 'Navn på område';

  @override
  String startedACall(String senderName) {
    return '$senderName startet en samtale';
  }

  @override
  String get status => 'Status';

  @override
  String get statusExampleMessage => 'Hvordan har du det i dag?';

  @override
  String get submit => 'Send inn';

  @override
  String get synchronizingPleaseWait => 'Synkroniserer … Vent litt.';

  @override
  String synchronizingPleaseWaitCounter(String percentage) {
    return ' Synkroniserer… ($percentage%)';
  }

  @override
  String get systemTheme => 'System';

  @override
  String get theyDontMatch => 'Samsvarer ikke';

  @override
  String get theyMatch => 'Samsvarer';

  @override
  String get title => 'FluffyChat';

  @override
  String get tooManyRequestsWarning =>
      'For mange forespørsler. Prøv igjen senere!';

  @override
  String get transferFromAnotherDevice => 'Overfør fra en annen enhet';

  @override
  String get tryToSendAgain => 'Prøv å sende igjen';

  @override
  String get unavailable => 'Utilgjengelig';

  @override
  String unbannedUser(String username, String targetName) {
    return '$username opphevet bannlysning av $targetName';
  }

  @override
  String get unblockDevice => 'Opphev blokkering av enhet';

  @override
  String get unknownDevice => 'Ukjent enhet';

  @override
  String get unknownEncryptionAlgorithm => 'Ukjent krypteringsalgoritme';

  @override
  String unknownEvent(String type) {
    return 'Ukjent hendelse \'$type\'';
  }

  @override
  String get unmuteChat => 'Opphev forstumming av sludring';

  @override
  String get unpin => 'Løsne';

  @override
  String userAndOthersAreTyping(String username, int count) {
    return '$username og $count andre skriver…';
  }

  @override
  String userAndUserAreTyping(String username, String username2) {
    return '$username og $username2 skriver…';
  }

  @override
  String userIsTyping(String username) {
    return '$username skriver…';
  }

  @override
  String userLeftTheChat(String username) {
    return '$username har forlatt sludringen';
  }

  @override
  String get username => 'Brukernavn';

  @override
  String userSentUnknownEvent(String username, String type) {
    return '$username sendte en $type-hendelse';
  }

  @override
  String get unverified => 'Ikke verifisert';

  @override
  String get verified => 'Verifisert';

  @override
  String get verify => 'Bekreft';

  @override
  String get verifyStart => 'Start bekreftelse';

  @override
  String get verifySuccess => 'Du har bekreftet!';

  @override
  String get verifyTitle => 'Bekrefter annen konto';

  @override
  String get videoCall => 'Videosamtale';

  @override
  String get visibilityOfTheChatHistory => 'Sludrehistorikkens synlighet';

  @override
  String get visibleForAllParticipants => 'Synlig for alle deltagere';

  @override
  String get visibleForEveryone => 'Synlig for alle';

  @override
  String get voiceMessage => 'Lydmelding';

  @override
  String get waitingPartnerAcceptRequest =>
      'Venter på at partneren skal godta forespørselen…';

  @override
  String get waitingPartnerEmoji =>
      'Venter på at partneren skal godta emojien…';

  @override
  String get waitingPartnerNumbers =>
      'Venter på at samtalepartner skal godta tallene …';

  @override
  String get warning => 'Advarsel!';

  @override
  String get weSentYouAnEmail => 'Du har fått en e-post';

  @override
  String get whoCanPerformWhichAction => 'Hvem kan utføre hvilken handling';

  @override
  String get whoIsAllowedToJoinThisGroup =>
      'Hvem tillates å ta del i denne gruppen';

  @override
  String get whyDoYouWantToReportThis =>
      'Hvorfor ønsker du å rapportere dette?';

  @override
  String get wipeChatBackup =>
      'Vil du slette sikkerhetskopien av chatten din for å opprette en ny gjenopprettingsnøkkel?';

  @override
  String get withTheseAddressesRecoveryDescription =>
      'Med disse adressene kan du gjenopprette passordet ditt hvis du trenger det.';

  @override
  String get writeAMessage => 'Skriv en melding …';

  @override
  String get yes => 'Ja';

  @override
  String get you => 'Deg';

  @override
  String get youAreNoLongerParticipatingInThisChat =>
      'Du deltar ikke lenger i denne sludringen';

  @override
  String get youHaveBeenBannedFromThisChat =>
      'Du har blitt bannlyst fra denne sludringen';

  @override
  String get yourPublicKey => 'Din offentlige nøkkel';

  @override
  String get messageInfo => 'Meldingsinformasjon';

  @override
  String get time => 'Tid';

  @override
  String get messageType => 'Meldingstype';

  @override
  String get sender => 'Avsender';

  @override
  String get openGallery => 'Åpne galleri';

  @override
  String get removeFromSpace => 'Fjern fra området';

  @override
  String get start => 'Start';

  @override
  String get pleaseEnterRecoveryKeyDescription =>
      'For å låse opp gamle meldinger, vennligst skriv inn gjenopprettingsnøkkelen som ble generert i en tidligere økt. Gjenopprettingsnøkkelen er IKKE passordet ditt.';

  @override
  String get openChat => 'Åpne chat';

  @override
  String get markAsRead => 'Marker som lest';

  @override
  String get reportUser => 'Rapporter bruker';

  @override
  String get dismiss => 'Avvis';

  @override
  String reactedWith(String sender, String reaction) {
    return '$sender reagerte med $reaction';
  }

  @override
  String get pinMessage => 'Fest til rommet';

  @override
  String get confirmEventUnpin =>
      'Er du sikker på at du vil løsne hendelsen permanent?';

  @override
  String get emojis => 'Emojier';

  @override
  String get placeCall => 'Ringe opp';

  @override
  String get voiceCall => 'Taleanrop';

  @override
  String get unsupportedAndroidVersion => 'Usupportert Android-versjon';

  @override
  String get unsupportedAndroidVersionLong =>
      'Denne funksjonen krever en nyere Android-versjon. Se etter oppdateringer eller støtte for Lineage OS.';

  @override
  String get videoCallsBetaWarning =>
      'Vær oppmerksom på at videosamtaler for øyeblikket er i betaversjon. Det fungerer kanskje ikke som forventet eller i det hele tatt.';

  @override
  String get experimentalVideoCalls => 'Eksperimentelle videoanrop';

  @override
  String get youRejectedTheInvitation => 'Du har avvist invitasjonen';

  @override
  String get youJoinedTheChat => 'Du har blitt med i chatten';

  @override
  String get youAcceptedTheInvitation => '👍 Du har akseptert invitasjonen';

  @override
  String youBannedUser(String user) {
    return 'Du stengte ute $user';
  }

  @override
  String youHaveWithdrawnTheInvitationFor(String user) {
    return 'Du har trukket tilbake invitasjonen for $user';
  }

  @override
  String youInvitedBy(String user) {
    return '📩 Du har blitt invitert av $user';
  }

  @override
  String invitedBy(String user) {
    return '📩 Invitert av $user';
  }

  @override
  String youInvitedUser(String user) {
    return '📩 Du inviterte $user';
  }

  @override
  String youKicked(String user) {
    return '👞 You sparket ut $user';
  }

  @override
  String youKickedAndBanned(String user) {
    return '🙅 Du sparket og stengte ute $user';
  }

  @override
  String youUnbannedUser(String user) {
    return 'Du opphevet utestengelsen av $user';
  }

  @override
  String hasKnocked(String user) {
    return '🚪$user har banket på';
  }

  @override
  String get usersMustKnock => 'Brukere må banke på';

  @override
  String get noOneCanJoin => 'Ingen kan bli med';

  @override
  String get knock => 'Bank på';

  @override
  String get users => 'Brukere';

  @override
  String get unlockOldMessages => 'Lås opp gamle meldinger';

  @override
  String get storeInSecureStorageDescription =>
      'Oppbevar gjenopprettingsnøkkelen på en sikker lagringsplass på denne enheten.';

  @override
  String get saveKeyManuallyDescription =>
      'Lagre denne nøkkelen manuelt ved å åpne systemets delingsmeny eller kopiere til utklippstavlen.';

  @override
  String get storeInAndroidKeystore => 'Lagre i Android KeyStore';

  @override
  String get storeInAppleKeyChain => 'Lagre i Apple nøkkelring';

  @override
  String get storeSecurlyOnThisDevice => 'Lagre sikkert på denne enheten';

  @override
  String countFiles(int count) {
    return '$count filer';
  }

  @override
  String get user => 'Bruker';

  @override
  String get custom => 'Egendefinert';

  @override
  String get foregroundServiceRunning =>
      'Denne varslingen vises når forgrunnstjenesten kjører.';

  @override
  String get screenSharingTitle => 'skjermdeling';

  @override
  String get screenSharingDetail => 'Du deler skjermen din i FuffyChat';

  @override
  String get whyIsThisMessageEncrypted =>
      'Hvorfor er denne meldingen uleselig?';

  @override
  String get noKeyForThisMessage =>
      'Dette kan skje hvis meldingen ble sendt før du logget inn på kontoen din på denne enheten.\n\nDet er også mulig at senderen har blokkert enheten din, eller at noe gikk galt med internettforbindelsen.\n\nEr du i stand til å lese meldingen i en annen sesjon? Da kan du overføre meldingen fra den! Gå til Innstillinger > Enheter og sørg for at enhetene dine har verifisert hverandre. Neste gang du åpner rommet og begge sesjonene er i forgrunnen, vil nøklene bli overført automatisk.\n\nVil du unngå å miste nøklene når du logger ut eller bytter enhet? Sørg for at du har aktivert sikkerhetskopiering av chat i innstillingene.';

  @override
  String get newGroup => 'Ny gruppe';

  @override
  String get newSpace => 'Nytt område';

  @override
  String get allSpaces => 'Alle områder';

  @override
  String get hidePresences => 'Skjul statuslisten?';

  @override
  String get doNotShowAgain => 'Ikke vis igjen';

  @override
  String wasDirectChatDisplayName(String oldDisplayName) {
    return 'Tom chat (var $oldDisplayName)';
  }

  @override
  String get newSpaceDescription =>
      'Områder lar deg samle chattene dine og bygge private eller offentlige fellesskap.';

  @override
  String get encryptThisChat => 'Krypter denne chatten';

  @override
  String get disableEncryptionWarning =>
      'Av sikkerhetshensyn kan du ikke deaktivere kryptering i en chat der det har vært aktivert tidligere.';

  @override
  String get sorryThatsNotPossible => 'Beklager... det er ikke mulig';

  @override
  String get deviceKeys => 'Enhetsnøkler:';

  @override
  String get reopenChat => 'Gjenåpne chat';

  @override
  String get noBackupWarning =>
      'Advarsel! Hvis du ikke aktiverer sikkerhetskopiering av chatten, vil du miste tilgangen til dine krypterte meldinger. Det anbefales sterkt å aktivere sikkerhetskopiering før du logger ut.';

  @override
  String get noOtherDevicesFound => 'Ingen andre enheter funnet';

  @override
  String fileIsTooBigForServer(String max) {
    return 'Kan ikke sende! Serveren støtter bare vedlegg opptil $max.';
  }

  @override
  String fileHasBeenSavedAt(String path) {
    return 'Filen er lagret på $path';
  }

  @override
  String get jumpToLastReadMessage => 'Hopp til sist leste melding';

  @override
  String get readUpToHere => 'Lest frem til her';

  @override
  String get jump => 'Hopp';

  @override
  String get openLinkInBrowser => 'Åpne lenke i nettleser';

  @override
  String get reportErrorDescription =>
      '😭 Å nei. Noe gikk galt. Hvis du ønsker det, kan du rapportere denne feilen til utviklerne.';

  @override
  String get report => 'rapportere';

  @override
  String get setColorTheme => 'Angi fargetema:';

  @override
  String get invite => 'Inviter';

  @override
  String get inviteGroupChat => '📨 Invitasjon til gruppechat';

  @override
  String get invalidInput => 'Ugyldig inndata!';

  @override
  String wrongPinEntered(int seconds) {
    return 'Feil PIN-kode oppgitt! Prøv igjen om $seconds sekunder...';
  }

  @override
  String get pleaseEnterANumber => 'Vennligst skriv inn et tall større enn 0';

  @override
  String get archiveRoomDescription =>
      'Chatten vil bli flyttet til arkivet. Andre brukere vil kunne se at du har forlatt chatten.';

  @override
  String get roomUpgradeDescription =>
      'Chatten vil deretter bli gjenskapt med den nye romversjonen. Alle deltakere vil bli varslet om at de må bytte til den nye chatten. Du kan finne ut mer om romversjoner på https://spec.matrix.org/latest/rooms/';

  @override
  String get removeDevicesDescription =>
      'Du vil bli logget ut av denne enheten og vil ikke lenger kunne motta meldinger.';

  @override
  String get banUserDescription =>
      'Brukeren vil bli utestengt fra chatten og vil ikke kunne delta i chatten igjen før utestengelsen er opphevet.';

  @override
  String get unbanUserDescription =>
      'Brukeren vil kunne gå inn i chatten igjen hvis vedkommende prøver.';

  @override
  String get kickUserDescription =>
      'Brukeren blir kastet ut av chatten, men ikke utestengt. I offentlige chatter kan brukeren bli med på nytt når som helst.';

  @override
  String get makeAdminDescription =>
      'Når du gjør denne brukeren til administrator, kan du kanskje ikke omgjøre det senere. Brukeren vil da få de samme rettighetene som deg.';

  @override
  String get pushNotificationsNotAvailable =>
      'Push-varsler er ikke tilgjengelige';

  @override
  String get learnMore => 'Lær mer';

  @override
  String get yourGlobalUserIdIs => 'Din globale bruker-ID er: ';

  @override
  String noUsersFoundWithQuery(String query) {
    return 'Dessverre ble ingen bruker funnet med \"$query\". Sjekk om du har skrevet feil.';
  }

  @override
  String get knocking => 'Banker på';

  @override
  String chatCanBeDiscoveredViaSearchOnServer(String server) {
    return 'Chatten kan oppdages via søket på $server';
  }

  @override
  String get searchChatsRooms => 'Søk etter #chatter, @brukere...';

  @override
  String get nothingFound => 'Ingenting funnet...';

  @override
  String get groupName => 'Gruppenavn';

  @override
  String get createGroupAndInviteUsers =>
      'Opprett en gruppe og inviter brukere';

  @override
  String get groupCanBeFoundViaSearch => 'Gruppen kan finnes via søk';

  @override
  String get wrongRecoveryKey =>
      'Beklager ... dette ser ikke ut til å være riktig gjenopprettingsnøkkel.';

  @override
  String get commandHint_sendraw => 'Send raw json';

  @override
  String get databaseMigrationTitle => 'Databasen er optimalisert';

  @override
  String get databaseMigrationBody => 'Vent litt. Dette kan ta et øyeblikk.';

  @override
  String get leaveEmptyToClearStatus =>
      'La stå tomt for å slette statusen din.';

  @override
  String get select => 'Velg';

  @override
  String get searchForUsers => 'Søk etter @brukere...';

  @override
  String get pleaseEnterYourCurrentPassword =>
      'Skriv inn ditt nåværende passord';

  @override
  String get newPassword => 'Nytt passord';

  @override
  String get pleaseChooseAStrongPassword => 'Vennligst velg et sterkt passord';

  @override
  String get passwordsDoNotMatch => 'Passordene stemmer ikke overens';

  @override
  String get passwordIsWrong => 'Det inntastede passordet ditt er feil';

  @override
  String get publicChatAddresses => 'Offentlige chatadresser';

  @override
  String get createNewAddress => 'Opprett ny adresse';

  @override
  String get joinSpace => 'Bli med i området';

  @override
  String get publicSpaces => 'Offentlige områder';

  @override
  String get addChatOrSubSpace => 'Legg til chat eller underområde';

  @override
  String get thisDevice => 'Denne enheten:';

  @override
  String get initAppError => 'Det oppsto en feil under oppstart av appen';

  @override
  String searchIn(String chat) {
    return 'Søk i chatten «$chat»...';
  }

  @override
  String get searchMore => 'Søk mer...';

  @override
  String get gallery => 'Galleri';

  @override
  String get files => 'Filer';

  @override
  String sessionLostBody(String url, String error) {
    return 'Sesjonen din er tapt. Vennligst rapporter denne feilen til utviklerne på $url. Feilmeldingen er: $error';
  }

  @override
  String restoreSessionBody(String url, String error) {
    return 'Appen prøver nå å gjenopprette økten din fra sikkerhetskopien. Rapporter denne feilen til utviklerne på $url. Feilmeldingen er: $error';
  }

  @override
  String get sendReadReceipts => 'Send lesebekreftelser';

  @override
  String get sendTypingNotificationsDescription =>
      'Andre deltakere i en chat kan se når du skriver en ny melding.';

  @override
  String get sendReadReceiptsDescription =>
      'Andre deltakere i en chat kan se når du har lest en melding.';

  @override
  String get formattedMessages => 'Formaterte meldinger';

  @override
  String get formattedMessagesDescription =>
      'Vis rikt meldingsinnhold som fet skrift ved hjelp av markdown.';

  @override
  String get verifyOtherUser => '🔐 Verifiser annen bruker';

  @override
  String get verifyOtherUserDescription =>
      'Hvis du verifiserer en annen bruker, kan du være trygg på at du vet hvem du faktisk skriver med. 💪\n\nNår du starter en verifisering, vil både du og den andre brukeren se et popup-vindu i appen. Der vil dere se en serie emojier eller tall som dere må sammenligne med hverandre.\n\nDen beste måten å gjøre dette på er å møtes ansikt til ansikt eller starte en videosamtale. 👭';

  @override
  String get verifyOtherDevice => '🔐 Verifiser annen enhet';

  @override
  String get verifyOtherDeviceDescription =>
      'Når du verifiserer en annen enhet, kan disse enhetene utveksle nøkler, noe som øker den generelle sikkerheten din. 💪 Når du starter en verifisering, vil det dukke opp et popup-vindu i appen på begge enhetene. Der vil du se en serie emojier eller tall som du må sammenligne med hverandre. Det er best å ha begge enhetene forhånden før du starter verifiseringen. 🤳';

  @override
  String acceptedKeyVerification(String sender) {
    return '$sender godtok nøkkelverifisering';
  }

  @override
  String canceledKeyVerification(String sender) {
    return '$sender avbrøt nøkkelverifisering';
  }

  @override
  String completedKeyVerification(String sender) {
    return '$sender fullførte nøkkelverifisering';
  }

  @override
  String isReadyForKeyVerification(String sender) {
    return '$sender er klar for nøkkelverifisering';
  }

  @override
  String requestedKeyVerification(String sender) {
    return '$sender har bedt om nøkkelverifisering';
  }

  @override
  String startedKeyVerification(String sender) {
    return '$sender startet nøkkelverifisering';
  }

  @override
  String get transparent => 'Gjennomsiktig';

  @override
  String get incomingMessages => 'Innkommende meldinger';

  @override
  String get stickers => 'Stickers';

  @override
  String get discover => 'Oppdag';

  @override
  String get commandHint_ignore => 'Ignorer den oppgitte matrix IDen';

  @override
  String get commandHint_unignore =>
      'Opphev ignorering av den gitte matrix IDen';

  @override
  String unreadChatsInApp(String appname, String unread) {
    return '$appname: $unread uleste chatter';
  }

  @override
  String get noDatabaseEncryption =>
      'Databasekryptering støttes ikke på denne plattformen';

  @override
  String thereAreCountUsersBlocked(Object count) {
    return 'Akkurat nå er det $count blokkerte brukere.';
  }

  @override
  String get restricted => 'Begrenset';

  @override
  String get knockRestricted => 'Banking deaktivert';

  @override
  String goToSpace(Object space) {
    return 'Gå til område: $space';
  }

  @override
  String get markAsUnread => 'Marker som ulest';

  @override
  String userLevel(int level) {
    return '$level - Bruker';
  }

  @override
  String moderatorLevel(int level) {
    return '$level - Moderator';
  }

  @override
  String adminLevel(int level) {
    return '$level - Admin';
  }

  @override
  String get changeGeneralChatSettings => 'Endre generelle chatinnstillinger';

  @override
  String get inviteOtherUsers => 'Inviter andre brukere til denne chatten';

  @override
  String get changeTheChatPermissions => 'Endre chattillatelsene';

  @override
  String get changeTheVisibilityOfChatHistory =>
      'Endre synligheten til chatloggen';

  @override
  String get changeTheCanonicalRoomAlias =>
      'Endre hovedadressen til den offentlige chatten';

  @override
  String get sendRoomNotifications => 'Send en @room varsling';

  @override
  String get changeTheDescriptionOfTheGroup => 'Endre beskrivelsen til chatten';

  @override
  String get chatPermissionsDescription =>
      'Definer hvilket tilgangsnivå som kreves for bestemte handlinger i denne chatten. Nivåene 0, 50 og 100 representerer vanligvis brukere, moderatorer og administratorer, men alle mellomtrinn er mulige.';

  @override
  String updateInstalled(String version) {
    return '🎉 Oppdatering $version installert!';
  }

  @override
  String get changelog => 'Endringslogg';

  @override
  String get sendCanceled => 'Sending avbrutt';

  @override
  String get loginWithMatrixId => 'Logg på med Matrix ID';

  @override
  String get doesNotSeemToBeAValidHomeserver =>
      'Ser ikke ut til å være en kompatibel hjemmeserver. Feil URL?';

  @override
  String get calculatingFileSize => 'Beregner filstørrelse...';

  @override
  String get prepareSendingAttachment => 'Forbered sending av vedlegg...';

  @override
  String get sendingAttachment => 'Sender vedlegg...';

  @override
  String get generatingVideoThumbnail => 'Genererer videominiatyrbilde ...';

  @override
  String get compressVideo => 'Komprimerer video...';

  @override
  String sendingAttachmentCountOfCount(int index, int length) {
    return 'Sender vedlegg $index av $length...';
  }

  @override
  String serverLimitReached(int seconds) {
    return 'Grensen for server er nådd! Venter i $seconds sekunder...';
  }

  @override
  String get oneOfYourDevicesIsNotVerified =>
      'En av dine enheter er ikke verifisert';

  @override
  String get noticeChatBackupDeviceVerification =>
      'Merk: Når du kobler alle enhetene dine til chat-sikkerhetskopien, blir de automatisk bekreftet.';

  @override
  String get continueText => 'Fortsett';

  @override
  String get welcomeText =>
      'Hei, hei! 👋 Dette er FluffyChat. Du kan logge på hvilken som helst hjemmeserver som er kompatibel med https://matrix.org. Og deretter chatte med hvem som helst. Det er et stort desentralisert meldingsnettverk!';

  @override
  String get blur => 'Uskarphet:';

  @override
  String get opacity => 'Ugjennomsiktighet:';

  @override
  String get setWallpaper => 'Sett bakgrunnsbilde';

  @override
  String get manageAccount => 'Administrer konto';

  @override
  String get noContactInformationProvided =>
      'Serveren oppgir ingen gyldig kontaktinformasjon';

  @override
  String get contactServerAdmin => 'Kontakt serveradministrator';

  @override
  String get contactServerSecurity =>
      'Kontakt sikkerhetsansvarlig for serveren';

  @override
  String get supportPage => 'Supportside';

  @override
  String get serverInformation => 'Serverinformasjon:';

  @override
  String get name => 'Navn';

  @override
  String get version => 'Versjon';

  @override
  String get website => 'Nettside';

  @override
  String get compress => 'Komprimer';

  @override
  String get boldText => 'Fet skrift';

  @override
  String get italicText => 'Kursiv tekst';

  @override
  String get strikeThrough => 'Gjennomstreking';

  @override
  String get pleaseFillOut => 'Vennligst fyll ut';

  @override
  String get invalidUrl => 'Ugyldig url';

  @override
  String get addLink => 'Legg til lenke';

  @override
  String get unableToJoinChat =>
      'Kan ikke bli med i chatten. Kanskje den andre parten allerede har lukket samtalen.';

  @override
  String get previous => 'Forrige';

  @override
  String get otherPartyNotLoggedIn =>
      'Den andre parten er ikke logget inn og kan derfor ikke motta meldinger!';

  @override
  String appWantsToUseForLogin(String server) {
    return 'Bruk \'$server\' for å logge inn';
  }

  @override
  String get appWantsToUseForLoginDescription =>
      'Du gir herved tillatelse til at appen og nettstedet deler informasjon om deg.';

  @override
  String get open => 'Åpne';

  @override
  String get waitingForServer => 'Venter på server...';

  @override
  String get newChatRequest => '📩 Ny chatforespørsel';

  @override
  String get contentNotificationSettings =>
      'Innstillinger for innholdsvarslinger';

  @override
  String get generalNotificationSettings => 'Generelle varslingsinnstillinger';

  @override
  String get roomNotificationSettings => 'Innstillinger for romvarsler';

  @override
  String get userSpecificNotificationSettings =>
      'Brukerspesifikke varslingsinnstillinger';

  @override
  String get otherNotificationSettings => 'Andre varslingsinnstillinger';

  @override
  String get notificationRuleContainsUserName => 'Inneholder brukernavn';

  @override
  String get notificationRuleContainsUserNameDescription =>
      'Varsler bruker når en melding inneholder ens brukernavn.';

  @override
  String get notificationRuleMaster => 'Demp alle varslinger';

  @override
  String get notificationRuleMasterDescription =>
      'Overstyrer alle andre regler og deaktiverer alle varsler.';

  @override
  String get notificationRuleSuppressNotices =>
      'Undertrykk automatiserte meldinger';

  @override
  String get notificationRuleSuppressNoticesDescription =>
      'Demper varsler fra automatiserte klienter som roboter.';

  @override
  String get notificationRuleInviteForMe => 'Inviter for meg';

  @override
  String get notificationRuleInviteForMeDescription =>
      'Varsler bruker når en blir invitert til et rom.';

  @override
  String get notificationRuleMemberEvent => 'Medlemshendelse';

  @override
  String get notificationRuleMemberEventDescription =>
      'Skjuler varslinger for medlemsskapshendelser.';

  @override
  String get notificationRuleIsUserMention => 'Brukeromtale';

  @override
  String get notificationRuleIsUserMentionDescription =>
      'Varsler brukeren når de er direkte nevnt i en melding.';

  @override
  String get notificationRuleContainsDisplayName => 'Inneholder visningsnavn';

  @override
  String get notificationRuleContainsDisplayNameDescription =>
      'Varsler brukeren når en melding inneholder ens visningsnavnet.';

  @override
  String get notificationRuleIsRoomMention => 'Romomtale';

  @override
  String get notificationRuleIsRoomMentionDescription =>
      'Varsler brukeren når det er en romomtale.';

  @override
  String get notificationRuleRoomnotif => 'Romvarsel';

  @override
  String get notificationRuleRoomnotifDescription =>
      'Varsler brukeren når en melding inneholder ‘@room’.';

  @override
  String get notificationRuleTombstone => 'Gravstein';

  @override
  String get notificationRuleTombstoneDescription =>
      'Varsler brukeren om meldinger om deaktivering av rom.';

  @override
  String get notificationRuleReaction => 'Reaksjon';

  @override
  String get notificationRuleReactionDescription =>
      'Demper varsler for reaksjoner.';

  @override
  String get notificationRuleRoomServerAcl =>
      'Romserverens tilgangskontrolliste';

  @override
  String get notificationRuleRoomServerAclDescription =>
      'Skjuler varsler for tilgangskontrollister (ACL) for romservere.';

  @override
  String get notificationRuleSuppressEdits => 'Demp redigeringer';

  @override
  String get notificationRuleSuppressEditsDescription =>
      'Demper varsler for redigerte meldinger.';

  @override
  String get notificationRuleCall => 'Anrop';

  @override
  String get notificationRuleCallDescription => 'Varsler brukeren om anrop.';

  @override
  String get notificationRuleEncryptedRoomOneToOne => 'Kryptert rom én-til-én';

  @override
  String get notificationRuleEncryptedRoomOneToOneDescription =>
      'Varsler brukeren om meldinger i krypterte en-til-en-rom.';

  @override
  String get notificationRuleRoomOneToOne => 'Rom én-til-én';

  @override
  String get notificationRuleRoomOneToOneDescription =>
      'Varsler brukeren om meldinger i én-til-én-rom.';

  @override
  String get notificationRuleMessage => 'Melding';

  @override
  String get notificationRuleMessageDescription =>
      'Varsler brukeren om generelle meldinger.';

  @override
  String get notificationRuleEncrypted => 'Kkryptert';

  @override
  String get notificationRuleEncryptedDescription =>
      'Varsler brukeren om meldinger i krypterte rom.';

  @override
  String get notificationRuleJitsi => 'Jitsi';

  @override
  String get notificationRuleJitsiDescription =>
      'Varsler brukeren om hendelser i Jitsi-widgeten.';

  @override
  String get notificationRuleServerAcl => 'Skjul Server ACL-hendelser';

  @override
  String get notificationRuleServerAclDescription =>
      'Skjuler varslinger for Server ACL-hendelser.';

  @override
  String unknownPushRule(String rule) {
    return 'Ukjent push-regel \'$rule\'';
  }

  @override
  String sentVoiceMessage(String sender, String duration) {
    return '🎙️ $duration – Talemelding fra $sender';
  }

  @override
  String get deletePushRuleCanNotBeUndone =>
      'Hvis du sletter denne varslingsinnstillingen, kan du ikke angre dette.';

  @override
  String get more => 'Mer';

  @override
  String get shareKeysWith => 'Del nøkler med...';

  @override
  String get shareKeysWithDescription =>
      'Hvilke enheter bør man stole på, slik at de kan lese meldingene dine i krypterte chatter?';

  @override
  String get allDevices => 'Alle enheter';

  @override
  String get crossVerifiedDevicesIfEnabled =>
      'Kryssbekreftede enheter hvis dette er aktivert';

  @override
  String get crossVerifiedDevices => 'Kryssverifiserte enheter';

  @override
  String get verifiedDevicesOnly => 'Bare verifiserte enheter';

  @override
  String get takeAPhoto => 'Ta et bilde';

  @override
  String get recordAVideo => 'Ta opp en video';

  @override
  String get optionalMessage => '(Valgfritt) melding...';

  @override
  String get notSupportedOnThisDevice => 'Ikke støttet på denne enheten';

  @override
  String get enterNewChat => 'Bli med i ny chat';

  @override
  String get approve => 'Godkjenn';

  @override
  String get youHaveKnocked => 'Du har banket på';

  @override
  String get pleaseWaitUntilInvited =>
      'Vennligst vent nå, til noen fra rommet inviterer deg.';

  @override
  String get commandHint_logout => 'Logg av din nåværende enhet';

  @override
  String get commandHint_logoutall => 'Logg ut alle aktive enheter';

  @override
  String get displayNavigationRail => 'Vis navigasjonsfelt på mobil';

  @override
  String get customReaction => 'Egendefinert reaksjon';

  @override
  String get moreEvents => 'Flere hendelser';

  @override
  String get declineInvitation => 'Avslå invitasjon';

  @override
  String get noMessagesYet => 'Ingen meldinger enda';

  @override
  String get longPressToRecordVoiceMessage =>
      'Langt trykk for å spille inn talemelding.';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Gjenoppta';

  @override
  String get removeFromSpaceDescription =>
      'Chatten blir fjernet fra området, men vises fortsatt i chatlisten din.';

  @override
  String countChats(int chats) {
    return '$chats chats';
  }

  @override
  String spaceMemberOf(String spaces) {
    return 'Områdemedlem av $spaces';
  }

  @override
  String spaceMemberOfCanKnock(String spaces) {
    return 'Et medlem av området $spaces kan banke på';
  }

  @override
  String startedAPoll(String username) {
    return '$username startet en avstemning.';
  }

  @override
  String get poll => 'Avstemning';

  @override
  String get startPoll => 'Start avstemning';

  @override
  String get endPoll => 'Avslutt avstemning';

  @override
  String get answersVisible => 'Svar synlige';

  @override
  String get pollQuestion => 'Spørsmål til avstemning';

  @override
  String get answerOption => 'Svaralternativ';

  @override
  String get addAnswerOption => 'Legg til svaralternativ';

  @override
  String get allowMultipleAnswers => 'Tillat flere svar';

  @override
  String get pollHasBeenEnded => 'Avstemningen er avsluttet';

  @override
  String countVotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stemmer',
      one: 'En stemme',
    );
    return '$_temp0';
  }

  @override
  String get answersWillBeVisibleWhenPollHasEnded =>
      'Svarene vil være synlige når avstemningen er avsluttet';

  @override
  String get replyInThread => 'Svar i tråden';

  @override
  String countReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count svar',
      one: 'Et svar',
    );
    return '$_temp0';
  }

  @override
  String get thread => 'Tråd';

  @override
  String get backToMainChat => 'Tilbake til hovedchatten';

  @override
  String get saveChanges => 'Lagre endringer';

  @override
  String get createSticker => 'Lag sticker eller emoji';

  @override
  String get useAsSticker => 'Bruk som sticker';

  @override
  String get useAsEmoji => 'Bruk som emoji';

  @override
  String get stickerPackNameAlreadyExists =>
      'Klistremerkepakken finnes allerede';

  @override
  String get newStickerPack => 'Ny klistremerkepakke';

  @override
  String get stickerPackName => 'Navn på klistremerkepakke';

  @override
  String get attribution => 'Kreditering';

  @override
  String get skipChatBackup => 'Hopp over sikkerhetskopiering av chat';

  @override
  String get skipChatBackupWarning =>
      'Er du sikker? Uten sikkerhetskopi av chattene kan du miste meldingene dine hvis du bytter enhet.';

  @override
  String get loadingMessages => 'Laster inn meldinger';

  @override
  String get setupChatBackup => 'Konfigurer sikkerhetskopi av chat';

  @override
  String get noMoreResultsFound => 'Ingen flere treff';

  @override
  String chatSearchedUntil(String time) {
    return 'Søkte i chatten frem til $time';
  }

  @override
  String get federationBaseUrl => 'Federation Base URL';

  @override
  String get clientWellKnownInformation => 'Velkjent informasjon om klienten:';

  @override
  String get baseUrl => 'Base URL';

  @override
  String get identityServer => 'Identitetsserver:';

  @override
  String versionWithNumber(String version) {
    return 'Versjon: $version';
  }

  @override
  String get logs => 'Logger';

  @override
  String get advancedConfigs => 'Avanserte innstillinger';

  @override
  String get advancedConfigurations => 'Avanserte innstillinger';

  @override
  String get signIn => 'Logg på';

  @override
  String get createNewAccount => 'Opprett ny konto';

  @override
  String get signUpGreeting =>
      'FluffyChat er desentralisert! Velg en server der du vil opprette kontoen din, så kjører vi på!';

  @override
  String get signInGreeting =>
      'Har du allerede en Matrix-konto? Velkommen tilbake! Velg hjemmeserveren din og logg inn.';

  @override
  String get appIntro =>
      'Med FluffyChat kan du chatte med vennene dine. Det er en sikker, desentralisert [matrix]-meldingsapp! Les mer på https://matrix.org hvis du vil, eller bare registrer deg.';

  @override
  String get theProcessWasCanceled => 'Prosessen ble avbrutt.';

  @override
  String get join => 'Bli med';

  @override
  String get searchOrEnterHomeserverAddress =>
      'Søk eller angi adresse til hjemmeserver';

  @override
  String get matrixId => 'Matrix ID';

  @override
  String get setPowerLevel => 'Angi styrkenivå';

  @override
  String get makeModerator => 'Gjør til moderator';

  @override
  String get makeAdmin => 'Gjør til admin';

  @override
  String get removeModeratorRights => 'Fjern moderator-rettigheter';

  @override
  String get removeAdminRights => 'Fjern admin-rettigheter';

  @override
  String get powerLevel => 'Styrkenivå';

  @override
  String get setPowerLevelDescription =>
      'Styrkenivåer definerer hva et medlem har lov til å gjøre i dette rommet, og varierer vanligvis mellom 0 og 100.';

  @override
  String get owner => 'Eier';

  @override
  String get mute => 'Demp';

  @override
  String get createNewChat => 'Opprett ny chat';

  @override
  String get reset => 'Nullstill';

  @override
  String get supportFluffyChat => 'Støtt FluffyChat';

  @override
  String get support => 'Støtte';

  @override
  String get fluffyChatSupportBannerMessage =>
      'FluffyChat trenger DIN hjelp!\n❤️❤️❤️\nFluffyChat vil alltid være gratis, men utvikling og drift koster fortsatt penger. \nProsjektets fremtid avhenger av støtte fra folk som deg.';

  @override
  String get skipSupportingFluffyChat => 'Hopp over støtte til FluffyChat';

  @override
  String get iDoNotWantToSupport => 'Jeg ønsker ikke å støtte';

  @override
  String get iAlreadySupportFluffyChat => 'Jeg støtter allerede FluffyChat';

  @override
  String get setLowPriority => 'Sett lav prioritet';

  @override
  String get unsetLowPriority => 'Fjern lav prioritet';

  @override
  String get removeCallFromChat => 'Fjern anrop fra chat';

  @override
  String get removeCallFromChatDescription =>
      'Vil du fjerne anropet fra chatten for alle medlemmer?';

  @override
  String get removeCallForEveryone => 'Fjern anrop fra alle';

  @override
  String get startVoiceCall => 'Start lydsamtale';

  @override
  String get startVideoCall => 'Start videosamtale';

  @override
  String get joinVoiceCall => 'Bli med i lydsamtale';

  @override
  String get joinVideoCall => 'Bli med i videosamtale';

  @override
  String get live => 'Direkte';

  @override
  String get playSoundOnNotification => 'Spill av lyd ved varsling';

  @override
  String get addTag => 'Legg til emneknagg';

  @override
  String get removeTag => 'Fjern emneknagg';

  @override
  String get tagName => 'Navn på emneknagg';

  @override
  String get createNewTag => 'Opprett ny emneknagg';
}
