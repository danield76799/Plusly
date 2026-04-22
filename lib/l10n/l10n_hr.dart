// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Croatian (`hr`).
class L10nHr extends L10n {
  L10nHr([String locale = 'hr']) : super(locale);

  @override
  String get alwaysUse24HourFormat => 'true';

  @override
  String get repeatPassword => 'Ponovi lozinku';

  @override
  String get notAnImage => 'Nije slikovna datoteka.';

  @override
  String get ignoreUser => 'Zanemari korisnika';

  @override
  String get remove => 'Ukloni';

  @override
  String get importNow => 'Uvezi sada';

  @override
  String get importEmojis => 'Uvezi emoji slike';

  @override
  String get importFromZipFile => 'Uvezi iz .zip datoteke';

  @override
  String get exportEmotePack => 'Izvezi paket emotikona kao .zip';

  @override
  String get replace => 'Zamijeni';

  @override
  String get about => 'Informacije';

  @override
  String aboutHomeserver(String homeserver) {
    return 'Informacije o $homeserver';
  }

  @override
  String get accept => 'Prihvati';

  @override
  String acceptedTheInvitation(String username) {
    return '👍 $username je prihvatio/la poziv';
  }

  @override
  String get account => 'Račun';

  @override
  String activatedEndToEndEncryption(String username) {
    return '🔐 $username je aktivirao/la obostrano šifriranje';
  }

  @override
  String get addEmail => 'Dodaj e-mail adresu';

  @override
  String get confirmMatrixId =>
      'Za brisanje tvog računa potvrdi svoj Matrix ID.';

  @override
  String supposedMxid(String mxid) {
    return 'Trebao bi biti $mxid';
  }

  @override
  String get addToSpace => 'Dodaj u prostor';

  @override
  String get admin => 'Administrator';

  @override
  String get alias => 'pseudonim';

  @override
  String get all => 'Svi';

  @override
  String get allChats => 'Svi chatovi';

  @override
  String get commandHint_roomupgrade =>
      'Nadogradi ovu sobu na zadanu verziju sobe';

  @override
  String get commandHint_googly => 'Pošalji kotrljajuće oči';

  @override
  String get commandHint_cuddle => 'Pošalji maženje';

  @override
  String get commandHint_hug => 'Pošalji grljenje';

  @override
  String googlyEyesContent(String senderName) {
    return '$senderName ti šalje kotrljajuće oči';
  }

  @override
  String cuddleContent(String senderName) {
    return '$senderName te mazi';
  }

  @override
  String hugContent(String senderName) {
    return '$senderName te grli';
  }

  @override
  String answeredTheCall(String senderName) {
    return '$senderName je odgovorio/la na poziv';
  }

  @override
  String get anyoneCanJoin => 'Svatko se može pridružiti';

  @override
  String get appLock => 'Zaključavanje programa';

  @override
  String get appLockDescription =>
      'Zaključaj aplikaciju kada je ne koristiš s PIN kodom';

  @override
  String get archive => 'Arhiv';

  @override
  String get areGuestsAllowedToJoin => 'Smiju li se gosti pridružiti';

  @override
  String get areYouSure => 'Stvarno to želiš?';

  @override
  String get areYouSureYouWantToLogout => 'Stvarno se želiš odjaviti?';

  @override
  String get askSSSSSign =>
      'Za potpisivanje druge osobe, upiši svoju sigurnosnu lozinku ili ključ za oporavak.';

  @override
  String askVerificationRequest(String username) {
    return 'Prihvatiti ovaj zahtjev za potvrđivanje od $username?';
  }

  @override
  String get autoplayImages =>
      'Automatski pokreni animirane naljepnice i emotikone';

  @override
  String badServerLoginTypesException(
    String serverVersions,
    String supportedVersions,
    Object suportedVersions,
  ) {
    return 'Homeserver podržava vrste prijave:\n$serverVersions\nMeđutim ovaj program podržava samo:\n$supportedVersions';
  }

  @override
  String get sendTypingNotifications => 'Šalji obavijesti o tipkanju';

  @override
  String get swipeRightToLeftToReply =>
      'Za odgovaranje povuci prstom zdesna ulijevo';

  @override
  String get sendOnEnter => 'Pošalji pritiskom tipke enter';

  @override
  String get noMoreChatsFound => 'Nema više chatova …';

  @override
  String get noChatsFoundHere =>
      'Ovdje još nisu pronađeni chatovi. Započni novi chat s nekime pomoću donjeg gumba. ⤵️';

  @override
  String get unread => 'Nepročitano';

  @override
  String get space => 'Prostor';

  @override
  String get spaces => 'Prostori';

  @override
  String get banFromChat => 'Isključi iz chata';

  @override
  String get banned => 'Isključen';

  @override
  String bannedUser(String username, String targetName) {
    return '$username je isključio/la $targetName';
  }

  @override
  String get blockDevice => 'Blokiraj uređaj';

  @override
  String get blocked => 'Blokirano';

  @override
  String get cancel => 'Odustani';

  @override
  String cantOpenUri(String uri) {
    return 'URI adresa $uri se ne može otvoriti';
  }

  @override
  String get changeDeviceName => 'Promijeni ime uređaja';

  @override
  String changedTheChatAvatar(String username) {
    return '$username je promijenio/la avatar chata';
  }

  @override
  String changedTheChatDescription(Object username) {
    return '$username je promijenio/la opis chata';
  }

  @override
  String changedTheChatDescriptionTo(String username, String description) {
    return '$username je promijenio/la opis chata u: \'$description\'';
  }

  @override
  String changedTheChatName(Object username) {
    return '$username je promijenio/la ime chata';
  }

  @override
  String changedTheChatNameTo(String username, String chatname) {
    return '$username je promijenio/la ime chata u: \'$chatname\'';
  }

  @override
  String changedTheChatPermissions(String username) {
    return '$username je promijenio/la dozvole chata';
  }

  @override
  String changedTheDisplaynameTo(String username, String displayname) {
    return '$username je promijenio/la svoje prikazno ime u: \'$displayname\'';
  }

  @override
  String changedTheGuestAccessRules(String username) {
    return '$username je promijenio/la pravila pristupa za goste';
  }

  @override
  String changedTheGuestAccessRulesTo(String username, String rules) {
    return '$username je promijenio/la pravila pristupa za goste u: $rules';
  }

  @override
  String changedTheHistoryVisibility(String username) {
    return '$username je promijenio/la vidljivost kronologije';
  }

  @override
  String changedTheHistoryVisibilityTo(String username, String rules) {
    return '$username je promijenio/la vidljivost kronologije u: $rules';
  }

  @override
  String changedTheJoinRules(String username) {
    return '$username je promijenio/la pravila pridruživanja';
  }

  @override
  String changedTheJoinRulesTo(String username, String joinRules) {
    return '$username je promijenio/la pravila pridruživanja u: $joinRules';
  }

  @override
  String changedTheProfileAvatar(String username) {
    return '$username je promijenio/la svoj avatar';
  }

  @override
  String changedTheRoomAliases(String username) {
    return '$username je promijenio/la pseudonime soba';
  }

  @override
  String changedTheRoomInvitationLink(String username) {
    return '$username je promijenio/la poveznicu poziva';
  }

  @override
  String get changePassword => 'Promijeni lozinku';

  @override
  String get changeTheHomeserver => 'Promijeni domaći server';

  @override
  String get changeTheme => 'Promijeni tvoj stil';

  @override
  String get changeTheNameOfTheGroup => 'Promijeni ime grupe';

  @override
  String get changeYourAvatar => 'Promijeni svoj avatar';

  @override
  String get channelCorruptedDecryptError => 'Šifriranje je oštećeno';

  @override
  String get chat => 'Chat';

  @override
  String get yourChatBackupHasBeenSetUp =>
      'Sigurnosna kopija tvog chata je postavljena.';

  @override
  String get chatBackup => 'Sigurnosna kopija chata';

  @override
  String get chatBackupDescription =>
      'Tvoje poruke su osigurane s ključem za obnavljanje. Pazi da ga ne izgubiš.';

  @override
  String get chatDetails => 'Detalji chata';

  @override
  String get chats => 'Chatovi';

  @override
  String get chooseAStrongPassword => 'Odaberi snažnu lozinku';

  @override
  String get clearArchive => 'Isprazni arhiv';

  @override
  String get close => 'Zatvori';

  @override
  String get commandHint_markasdm =>
      'Označi kao sobu za izravnu razmjenu poruka za zadani Matrix ID';

  @override
  String get commandHint_markasgroup => 'Označi kao grupu';

  @override
  String get commandHint_ban => 'Isključi navedenog korisnika iz ove sobe';

  @override
  String get commandHint_clearcache => 'Isprazni predmemoriju';

  @override
  String get commandHint_create =>
      'Stvori prazan grupni chat\nKoristi --no-encryption za deaktiviranje šifriranja';

  @override
  String get commandHint_discardsession => 'Odbaci sesiju';

  @override
  String get commandHint_dm =>
      'Započni izravni chat\nKoristi --no-encryption za deaktiviranje šifriranja';

  @override
  String get commandHint_html => 'Pošalji HTML formatirani tekst';

  @override
  String get commandHint_invite => 'Pozovi navedenog korisnika u ovu sobu';

  @override
  String get commandHint_join => 'Pridruži se navedenoj sobi';

  @override
  String get commandHint_kick => 'Ukloni navedenog korisnika iz ove sobe';

  @override
  String get commandHint_leave => 'Napusti ovu sobu';

  @override
  String get commandHint_me => 'Opiši se';

  @override
  String get commandHint_myroomavatar =>
      'Postavi svoju sliku za ovu sobu (mxc-uri)';

  @override
  String get commandHint_myroomnick => 'Postavi svoje ime za ovu sobu';

  @override
  String get commandHint_op =>
      'Postavi razinu prava navedenog korisnika (standardno: 50)';

  @override
  String get commandHint_plain => 'Pošalji neformatirani tekst';

  @override
  String get commandHint_react => 'Pošalji odgovor kao reakciju';

  @override
  String get commandHint_send => 'Pošalji tekst';

  @override
  String get commandHint_unban =>
      'Ponovo uključi navedenog korisnika u ovu sobu';

  @override
  String get commandInvalid => 'Naredba nevaljana';

  @override
  String commandMissing(String command) {
    return '$command nije naredba.';
  }

  @override
  String get compareEmojiMatch => 'Usporedi emoji sličice';

  @override
  String get compareNumbersMatch => 'Usporedi brojeve';

  @override
  String get configureChat => 'Konfiguriraj chat';

  @override
  String get contactHasBeenInvitedToTheGroup => 'Kontakt je pozvan u grupu';

  @override
  String get contentHasBeenReported =>
      'Sadržaj je prijavljen administratorima servera';

  @override
  String get copiedToClipboard => 'Kopirano u međuspremnik';

  @override
  String get copy => 'Kopiraj';

  @override
  String get copyToClipboard => 'Kopiraj u međuspremnik';

  @override
  String couldNotDecryptMessage(String error) {
    return 'Neuspjelo dešifriranje poruke: $error';
  }

  @override
  String get checkList => 'Kontrolni popis';

  @override
  String countParticipants(int count) {
    return 'Broj sudionika: $count';
  }

  @override
  String countInvited(int count) {
    return 'Broj pozvanih: $count';
  }

  @override
  String get create => 'Stvori';

  @override
  String createdTheChat(String username) {
    return '💬 $username je stvorio/la chat';
  }

  @override
  String get createGroup => 'Stvori grupu';

  @override
  String get createNewSpace => 'Novi prostor';

  @override
  String get currentlyActive => 'Trenutačno aktivni';

  @override
  String get darkTheme => 'Tamna';

  @override
  String dateAndTimeOfDay(String date, String timeOfDay) {
    return '$date, $timeOfDay';
  }

  @override
  String get deactivateAccountWarning =>
      'Ovo će nepovratno deaktivirati tvoj korisnički račun. Stvarno to želiš?';

  @override
  String get defaultPermissionLevel =>
      'Standardna razina dozvole za nove korisnike';

  @override
  String get delete => 'Izbriši';

  @override
  String get deleteAccount => 'Izbriši račun';

  @override
  String get deleteMessage => 'Izbriši poruku';

  @override
  String get device => 'Uređaj';

  @override
  String get deviceId => 'ID oznaka uređaja';

  @override
  String get devices => 'Uređaji';

  @override
  String get directChats => 'Izravni chatovi';

  @override
  String get displaynameHasBeenChanged => 'Prikazno ime je promijenjeno';

  @override
  String get downloadFile => 'Preuzmi datoteku';

  @override
  String get edit => 'Uredi';

  @override
  String get editBlockedServers => 'Uredi blokirane servere';

  @override
  String get chatPermissions => 'Dozvole za chat';

  @override
  String get editDisplayname => 'Uredi prikazano ime';

  @override
  String get editRoomAliases => 'Uredi pseudonime sobe';

  @override
  String get editRoomAvatar => 'Uredi avatar sobe';

  @override
  String get emoteExists => 'Emotikon već postoji!';

  @override
  String get emoteInvalid => 'Neispravna kratica emotikona!';

  @override
  String get emoteKeyboardNoRecents =>
      'Ovdje će se pojaviti nedavno korišteni emotikoni …';

  @override
  String get emotePacks => 'Paketi emotikona za sobu';

  @override
  String get emoteSettings => 'Postavke emotikona';

  @override
  String get globalChatId => 'Globalni ID chata';

  @override
  String get accessAndVisibility => 'Pristup i vidljivost';

  @override
  String get accessAndVisibilityDescription =>
      'Tko se smije pridružiti ovom chatu i kako se chat može otkriti.';

  @override
  String get calls => 'Pozivi';

  @override
  String get customEmojisAndStickers => 'Prilagođeni emojiji i naljepnice';

  @override
  String get customEmojisAndStickersBody =>
      'Dodaj ili dijeli prilagođene emojije ili naljepnice koje se mogu koristiti u bilo kojem chatu.';

  @override
  String get emoteShortcode => 'Kratica emotikona';

  @override
  String get emptyChat => 'Prazan chat';

  @override
  String get enableEmotesGlobally => 'Aktiviraj paket emotikona globalno';

  @override
  String get enableEncryption => 'Aktiviraj šifriranje';

  @override
  String get enableEncryptionWarning =>
      'Više nećeš moći deaktivirati šifriranje. Stvarno to želiš?';

  @override
  String get encrypted => 'Šifrirano';

  @override
  String get encryption => 'Šifriranje';

  @override
  String get encryptionNotEnabled => 'Šifriranje nije aktivirano';

  @override
  String endedTheCall(String senderName) {
    return '$senderName je završio/la poziv';
  }

  @override
  String get enterAnEmailAddress => 'Upiši e-mail adresu';

  @override
  String get homeserver => 'Homeserver';

  @override
  String errorObtainingLocation(String error) {
    return 'Greška u dohvaćanju lokacije: $error';
  }

  @override
  String get everythingReady => 'Sve je spremno!';

  @override
  String get extremeOffensive => 'Izrazito uvredljiv';

  @override
  String get fileName => 'Ime datoteke';

  @override
  String get fluffychat => 'FluffyChat';

  @override
  String get fontSize => 'Veličina fonta';

  @override
  String get forward => 'Proslijedi';

  @override
  String get fromJoining => 'Od pridruživanja';

  @override
  String get fromTheInvitation => 'Od poziva';

  @override
  String get group => 'Grupiraj';

  @override
  String get chatDescription => 'Opis chata';

  @override
  String get chatDescriptionHasBeenChanged => 'Opis chata je promijenjen';

  @override
  String get groupIsPublic => 'Grupa je javna';

  @override
  String get groups => 'Grupe';

  @override
  String groupWith(String displayname) {
    return 'Grupa s $displayname';
  }

  @override
  String get guestsAreForbidden => 'Gosti su zabranjeni';

  @override
  String get guestsCanJoin => 'Gosti se mogu pridružiti';

  @override
  String hasWithdrawnTheInvitationFor(String username, String targetName) {
    return '$username je povukao/la poziv za $targetName';
  }

  @override
  String get help => 'Pomoć';

  @override
  String get hideRedactedEvents => 'Sakrij promijenjene događaje';

  @override
  String get hideRedactedMessages => 'Sakrij redigirane poruke';

  @override
  String get hideRedactedMessagesBody =>
      'Ako netko redigira poruku, ta poruka više neće biti vidljiva u chatu.';

  @override
  String get hideInvalidOrUnknownMessageFormats =>
      'Sakrij nevažeće ili nepoznate formate poruka';

  @override
  String get howOffensiveIsThisContent => 'Koliko je ovaj sadržaj uvredljiv?';

  @override
  String get id => 'ID';

  @override
  String get block => 'Blokiraj';

  @override
  String get blockedUsers => 'Blokirani korisnici';

  @override
  String get blockListDescription =>
      'Možeš blokirati korisnike koji te ometaju. Nećeš moći primati poruke ili pozivnice za sobe od korisnika koji se nalaze u tvom osobnom popisu blokiranih.';

  @override
  String get blockUsername => 'Zanemari korisničko ime';

  @override
  String get iHaveClickedOnLink => 'Pritisnuo/la sam poveznicu';

  @override
  String get incorrectPassphraseOrKey =>
      'Neispravna lozinka ili ključ za obnavljanje';

  @override
  String get inoffensive => 'Neuvredljiv';

  @override
  String get inviteContact => 'Pozovi kontakt';

  @override
  String inviteContactToGroup(String groupName) {
    return 'Pozovi kontakt u $groupName';
  }

  @override
  String get noChatDescriptionYet => 'Opis chata još nije stvoren.';

  @override
  String get tryAgain => 'Pokušaj ponovo';

  @override
  String get invalidServerName => 'Neispravno ime servera';

  @override
  String get invited => 'Pozvan/a';

  @override
  String get redactMessageDescription =>
      'Poruka će se redigirati za sve sudionike u ovoj konverzaciji. To je nepovratna radnja.';

  @override
  String get optionalRedactReason =>
      '(Opcionalno) Razlog za redigiranje ove poruke …';

  @override
  String invitedUser(String username, String targetName) {
    return '📩 $username je pozvao/la $targetName';
  }

  @override
  String get invitedUsersOnly => 'Samo pozvani korisnici';

  @override
  String inviteText(String username, String link) {
    return '$username te je pozvao/la u FluffyChat. \n1. Posjeti strnicu fluffychat.im i instaliraj aplikaciju \n2. Registriraj ili prijavi se \n3. Otvori poveznicu poziva: \n $link';
  }

  @override
  String get isTyping => 'tipka …';

  @override
  String joinedTheChat(String username) {
    return '👋 $username se pridružio/la chatu';
  }

  @override
  String get joinRoom => 'Pridruži se sobi';

  @override
  String kicked(String username, String targetName) {
    return '👞 $username je izbacio/la $targetName';
  }

  @override
  String kickedAndBanned(String username, String targetName) {
    return '🙅 $username je izbacio/la i isključio/la $targetName';
  }

  @override
  String get kickFromChat => 'Izbaci iz chata';

  @override
  String lastActiveAgo(String localizedTimeShort) {
    return 'Zadnja aktivnost: $localizedTimeShort';
  }

  @override
  String get leave => 'Napusti';

  @override
  String get leftTheChat => 'Napustio/la je chat';

  @override
  String get lightTheme => 'Svijetla';

  @override
  String loadCountMoreParticipants(int count) {
    return 'Učitaj još $count sudionika';
  }

  @override
  String get dehydrate => 'Izvezi sesiju i izbriši uređaj';

  @override
  String get dehydrateWarning =>
      'Ovo je nepovratna radnja. Spremi datoteku sigurnosne kopije na sigurno mjesto.';

  @override
  String get hydrate => 'Obnovi pomoću sigurnosne kopije';

  @override
  String get loadingPleaseWait => 'Učitava se … Pričekaj.';

  @override
  String get loadMore => 'Učitaj još …';

  @override
  String get locationDisabledNotice =>
      'Lokacijske usluge su deaktivirane. Za dijeljenje tvoje lokacije aktiviraj ih.';

  @override
  String get locationPermissionDeniedNotice =>
      'Lokacijske dozvole su odbijene. Za dijeljenje tvoje lokacije dozvoli ih.';

  @override
  String get login => 'Prijava';

  @override
  String logInTo(String homeserver) {
    return 'Prijavi se na $homeserver';
  }

  @override
  String get logout => 'Odjava';

  @override
  String get mention => 'Spominjanje';

  @override
  String get messages => 'Poruke';

  @override
  String get messagesStyle => 'Poruke:';

  @override
  String get moderator => 'Voditelj';

  @override
  String get muteChat => 'Isključi zvuk chata';

  @override
  String get needPantalaimonWarning =>
      'Za trenutačno korištenje obostranog šifriranja trebaš Pantalaimon.';

  @override
  String get newChat => 'Novi chat';

  @override
  String get newMessageInFluffyChat => '💬 Nova poruka u FluffyChatu';

  @override
  String get newVerificationRequest => 'Novi zahtjev za potvrđivanje!';

  @override
  String get next => 'Dalje';

  @override
  String get no => 'Ne';

  @override
  String get noConnectionToTheServer => 'Ne postoji veza sa serverom';

  @override
  String get noEmotesFound => 'Nema emotikona. 😕';

  @override
  String get noEncryptionForPublicRooms =>
      'Šifriranje možeš aktivirati samo nakon što soba više nije javno dostupna.';

  @override
  String get noGoogleServicesWarning =>
      'Čini se da Firebase Cloud Messaging nije dostupan na tvom uređaju. Za daljnje primanje push obavijesti, preporučujemo da instaliraš ntfy. S ntfy ili drugim pružateljem Unified Push usluge možeš primati push obavijesti na podatkovno siguran način. Ntfy možeš preuzeti s PlayStorea ili s F-Droida.';

  @override
  String noMatrixServer(String server1, String server2) {
    return '$server1 nije matrix server. Da li umjesto njega koristiti $server2?';
  }

  @override
  String get shareInviteLink => 'Dijeli poveznicu za poziv';

  @override
  String get scanQrCode => 'Snimi QR kod';

  @override
  String get none => 'Ništa';

  @override
  String get noPasswordRecoveryDescription =>
      'Još nisi dodao/la način za obnavljanje lozinke.';

  @override
  String get noPermission => 'Bez dozvole';

  @override
  String get noRoomsFound => 'Nema soba …';

  @override
  String get notifications => 'Obavijesti';

  @override
  String numUsersTyping(int count) {
    return '$count korisnika tipkaju …';
  }

  @override
  String get obtainingLocation => 'Dohvaćanje lokacije …';

  @override
  String get offensive => 'Uvredljiv';

  @override
  String get offline => 'Nepovezano s internetom';

  @override
  String get ok => 'U redu';

  @override
  String get online => 'Povezano s internetom';

  @override
  String get onlineKeyBackupEnabled =>
      'Internetski ključ sigurnosnih kopija je aktiviran';

  @override
  String get oopsPushError =>
      'Ups! Nažalost se dogodila greška prilikom postavljanja automatskog primanja obavijesti.';

  @override
  String get oopsSomethingWentWrong => 'Ups, dogodila se greška …';

  @override
  String get openAppToReadMessages => 'Za čitanje poruka, otvori program';

  @override
  String get openCamera => 'Otvori kameru';

  @override
  String get oneClientLoggedOut => 'Jedan od tvojih klijenata je odjavljen';

  @override
  String get addAccount => 'Dodaj račun';

  @override
  String get editBundlesForAccount => 'Uredi pakete za ovaj račun';

  @override
  String get addToBundle => 'Dodaj u paket';

  @override
  String get removeFromBundle => 'Ukloni iz ovog paketa';

  @override
  String get bundleName => 'Ime paketa';

  @override
  String get enableMultiAccounts =>
      '(BETA) Omogući korištenje više računa na ovom uređaju';

  @override
  String get openInMaps => 'Otvori u kartama';

  @override
  String get link => 'Poveznica';

  @override
  String get serverRequiresEmail =>
      'Za registraciju ovaj server mora potvrditi tvoju e-mail adresu.';

  @override
  String get or => 'Ili';

  @override
  String get participant => 'Sudionik';

  @override
  String get passphraseOrKey => 'tajni izraz ili ključ za obnavljanje';

  @override
  String get password => 'Lozinka';

  @override
  String get passwordForgotten => 'Zaboravljena lozinka';

  @override
  String get passwordHasBeenChanged => 'Lozinka je promijenjena';

  @override
  String get overview => 'Pregled';

  @override
  String get passwordRecoverySettings => 'Postavke za obnavljanje lozinke';

  @override
  String get passwordRecovery => 'Obnavljanje lozinke';

  @override
  String get pickImage => 'Odaberi sliku';

  @override
  String get pin => 'Prikvači';

  @override
  String play(String fileName) {
    return 'Sviraj $fileName';
  }

  @override
  String get pleaseChooseAPasscode => 'Odaberi lozinku';

  @override
  String get pleaseClickOnLink =>
      'Pritisni poveznicu u e-mailu i zatim nastavi.';

  @override
  String get pleaseEnter4Digits =>
      'Upiši 4 znamenke ili ostavi prazno, za deaktiviranje zaključavanja programa.';

  @override
  String get pleaseEnterYourPassword => 'Upiši svoju lozinku';

  @override
  String get pleaseEnterYourPin => 'Upiši svoj pin';

  @override
  String get pleaseEnterYourUsername => 'Upiši svoje korisničko ime';

  @override
  String get pleaseFollowInstructionsOnWeb =>
      'Slijedi upute na web-stranici i dodirni „Dalje”.';

  @override
  String get privacy => 'Privatnost';

  @override
  String get publicRooms => 'Javne sobe';

  @override
  String get pushRules => 'Pravila slanja';

  @override
  String get reason => 'Razlog';

  @override
  String get recording => 'Snimanje';

  @override
  String redactedBy(String username) {
    return 'Preuređeno od $username';
  }

  @override
  String get directChat => 'Izravni chat';

  @override
  String redactedByBecause(String username, String reason) {
    return 'Preuređeno od $username zbog: „$reason”';
  }

  @override
  String redactedAnEvent(String username) {
    return '$username je preuredio/la događaj';
  }

  @override
  String get redactMessage => 'Ispravi poruku';

  @override
  String get register => 'Registracija';

  @override
  String get reject => 'Odbij';

  @override
  String rejectedTheInvitation(String username) {
    return '$username je odbio/la poziv';
  }

  @override
  String get removeAllOtherDevices => 'Ukloni sve druge uređaje';

  @override
  String removedBy(String username) {
    return 'Uklonjeno od $username';
  }

  @override
  String get unbanFromChat => 'Ponovo uključi u chat';

  @override
  String get removeYourAvatar => 'Ukloni svoj avatar';

  @override
  String get replaceRoomWithNewerVersion => 'Zamijeni sobu s novom verzijom';

  @override
  String get reply => 'Odgovori';

  @override
  String get reportMessage => 'Prijavi poruku';

  @override
  String get requestPermission => 'Zatraži dozvolu';

  @override
  String get roomHasBeenUpgraded => 'Soba je nadograđena';

  @override
  String get roomVersion => 'Verzija sobe';

  @override
  String get saveFile => 'Spremi datoteku';

  @override
  String get search => 'Traži';

  @override
  String get security => 'Sigurnost';

  @override
  String get recoveryKey => 'Ključ za obnavljanje';

  @override
  String get recoveryKeyLost => 'Izgubio/la si ključ za obnavljanje?';

  @override
  String get send => 'Pošalji';

  @override
  String get sendAMessage => 'Pošalji poruku';

  @override
  String get sendAsText => 'Pošalji kao tekst';

  @override
  String get sendAudio => 'Pošalji audio datoteku';

  @override
  String get sendFile => 'Pošalji datoteku';

  @override
  String get sendImage => 'Pošalji sliku';

  @override
  String sendImages(int count) {
    return 'Pošalji $count sliku';
  }

  @override
  String get sendMessages => 'Pošalji poruke';

  @override
  String get sendVideo => 'Pošalji video datoteku';

  @override
  String sentAFile(String username) {
    return '📁 $username ja poslao/la datoteku';
  }

  @override
  String sentAnAudio(String username) {
    return '🎤 $username ja poslao/la audio snimku';
  }

  @override
  String sentAPicture(String username) {
    return '🖼️ $username ja poslao/la sliku';
  }

  @override
  String sentASticker(String username) {
    return '😊 $username je poslao/la naljepnicu';
  }

  @override
  String sentAVideo(String username) {
    return '🎥 $username je poslao/la video';
  }

  @override
  String sentCallInformations(String senderName) {
    return '$senderName je poslao/la podatke poziva';
  }

  @override
  String get setAsCanonicalAlias => 'Postavi kao glavni pseudonim';

  @override
  String get setChatDescription => 'Postavi opis rzgovora';

  @override
  String get setStatus => 'Postavi stanje';

  @override
  String get settings => 'Postavke';

  @override
  String get share => 'Dijeli';

  @override
  String sharedTheLocation(String username) {
    return '$username je dijelio/la svoje mjesto';
  }

  @override
  String get shareLocation => 'Dijeli lokaciju';

  @override
  String get showPassword => 'Pokaži lozinku';

  @override
  String get presencesToggle => 'Prikaži poruke stanja od drugih korisnika';

  @override
  String get skip => 'Preskoči';

  @override
  String get sourceCode => 'Izvorni kȏd';

  @override
  String get spaceIsPublic => 'Prostor je javan';

  @override
  String get spaceName => 'Ime prostora';

  @override
  String startedACall(String senderName) {
    return '$senderName ja započeo/la poziv';
  }

  @override
  String get status => 'Stanje';

  @override
  String get statusExampleMessage => 'Kako si danas?';

  @override
  String get submit => 'Pošalji';

  @override
  String get synchronizingPleaseWait => 'Sinkronizira se … Pričekaj.';

  @override
  String synchronizingPleaseWaitCounter(String percentage) {
    return ' Sinkronizacija … ($percentage %)';
  }

  @override
  String get systemTheme => 'Sustav';

  @override
  String get theyDontMatch => 'Ne poklapaju se';

  @override
  String get theyMatch => 'Poklapaju se';

  @override
  String get title => 'FluffyChat';

  @override
  String get tooManyRequestsWarning =>
      'Previše zahtjeva. Pokušaj ponovo kasnije!';

  @override
  String get transferFromAnotherDevice => 'Prenesi s jednog drugog uređaja';

  @override
  String get tryToSendAgain => 'Pokušaj ponovo poslati';

  @override
  String get unavailable => 'Nedostupno';

  @override
  String unbannedUser(String username, String targetName) {
    return '$username je ponovo uključio/la $targetName';
  }

  @override
  String get unblockDevice => 'Deblokiraj uređaj';

  @override
  String get unknownDevice => 'Nepoznat uređaj';

  @override
  String get unknownEncryptionAlgorithm => 'Nepoznat algoritam šifriranja';

  @override
  String unknownEvent(String type) {
    return 'Nepoznat događaj \'$type\'';
  }

  @override
  String get unmuteChat => 'Uključi zvuk chata';

  @override
  String get unpin => 'Otkvači';

  @override
  String userAndOthersAreTyping(String username, int count) {
    return '$username i još $count korisnika tipkaju …';
  }

  @override
  String userAndUserAreTyping(String username, String username2) {
    return '$username i $username2 tipkaju …';
  }

  @override
  String userIsTyping(String username) {
    return '$username tipka …';
  }

  @override
  String userLeftTheChat(String username) {
    return '🚪 $username je napustio/la chat';
  }

  @override
  String get username => 'Korisničko ime';

  @override
  String userSentUnknownEvent(String username, String type) {
    return '$username ja poslao/la $type događaj';
  }

  @override
  String get unverified => 'Nepotvrđeno';

  @override
  String get verified => 'Potvrđeno';

  @override
  String get verify => 'Potvrdi';

  @override
  String get verifyStart => 'Pokreni potvrđivanje';

  @override
  String get verifySuccess => 'Uspješno si potvrdio/la!';

  @override
  String get verifyTitle => 'Potvrđivanje drugog računa';

  @override
  String get videoCall => 'Video poziv';

  @override
  String get visibilityOfTheChatHistory => 'Vidljivost povijesti chata';

  @override
  String get visibleForAllParticipants => 'Vidljivo za sve sudionike';

  @override
  String get visibleForEveryone => 'Vidljivo za sve';

  @override
  String get voiceMessage => 'Glasovna poruka';

  @override
  String get waitingPartnerAcceptRequest =>
      'Čeka se na sugovornika da prihvati zahtjev …';

  @override
  String get waitingPartnerEmoji =>
      'Čeka se na sugovornika da prihvati emoji …';

  @override
  String get waitingPartnerNumbers =>
      'Čeka se na sugovornika da prihvati brojeve …';

  @override
  String get warning => 'Upozorenje!';

  @override
  String get weSentYouAnEmail => 'Poslali smo ti e-mail';

  @override
  String get whoCanPerformWhichAction => 'Tko može izvršiti koju radnju';

  @override
  String get whoIsAllowedToJoinThisGroup => 'Tko se smije pridružiti grupi';

  @override
  String get whyDoYouWantToReportThis => 'Zašto želiš ovo prijaviti?';

  @override
  String get wipeChatBackup =>
      'Izbrisati sigurnosnu kopiju chata za stvaranje novog sigurnosnog ključa za obnavljanje?';

  @override
  String get withTheseAddressesRecoveryDescription =>
      'Lozinku možeš obnoviti pomoću ovih adresa.';

  @override
  String get writeAMessage => 'Napiši poruku …';

  @override
  String get yes => 'Da';

  @override
  String get you => 'Ti';

  @override
  String get youAreNoLongerParticipatingInThisChat =>
      'Više ne sudjeluješ u ovom chatu';

  @override
  String get youHaveBeenBannedFromThisChat => 'Isključen/a si iz ovog chata';

  @override
  String get yourPublicKey => 'Tvoj javni ključ';

  @override
  String get messageInfo => 'Informacija poruke';

  @override
  String get time => 'Vrijeme';

  @override
  String get messageType => 'Vrsta poruke';

  @override
  String get sender => 'Pošiljatelj';

  @override
  String get openGallery => 'Otvori galeriju';

  @override
  String get removeFromSpace => 'Ukloni iz prostora';

  @override
  String get start => 'Početak';

  @override
  String get pleaseEnterRecoveryKeyDescription =>
      'Za otključavanje starih poruka upiši ključ za obnavljanje koji je generiran u prethodnoj sesiji. Tvoj ključ za obnavljanje NIJE tvoja lozinka.';

  @override
  String get openChat => 'Otvori chat';

  @override
  String get markAsRead => 'Označi kao pročitano';

  @override
  String get reportUser => 'Prijavi korisnika';

  @override
  String get dismiss => 'Odbaci';

  @override
  String reactedWith(String sender, String reaction) {
    return '$sender je reagirao/la sa $reaction';
  }

  @override
  String get pinMessage => 'Prikvači na sobu';

  @override
  String get confirmEventUnpin => 'Stvarno želiš trajno otkvačiti događaj?';

  @override
  String get emojis => 'Emojiji';

  @override
  String get placeCall => 'Nazovi';

  @override
  String get voiceCall => 'Glasovni poziv';

  @override
  String get unsupportedAndroidVersion => 'Nepodržana Android verzija';

  @override
  String get unsupportedAndroidVersionLong =>
      'Ova funkcija zahtijeva noviju verziju Androida. Provjeri, postoje li nove verzije ili podrška za Lineage OS.';

  @override
  String get videoCallsBetaWarning =>
      'Napominjemo da se funkcija videopoziva trenutačno nalazi u beta stanju. Možda neće raditi ispravno ili uopće neće raditi na svim platformama.';

  @override
  String get experimentalVideoCalls => 'Eksperimentalni videopozivi';

  @override
  String get youRejectedTheInvitation => 'Odbio/la si poziv';

  @override
  String get youJoinedTheChat => 'Pridružio/la si se chatu';

  @override
  String get youAcceptedTheInvitation => '👍 Prihvatio/la si poziv';

  @override
  String youBannedUser(String user) {
    return 'Isključio/la si korisnika $user';
  }

  @override
  String youHaveWithdrawnTheInvitationFor(String user) {
    return 'Povukao/la si poziv za korisnika $user';
  }

  @override
  String youInvitedBy(String user) {
    return '📩 $user te je pozvao/la';
  }

  @override
  String invitedBy(String user) {
    return '📩 Pozvan/a si od korisnika $user';
  }

  @override
  String youInvitedUser(String user) {
    return '📩 Pozvao/la si korisnika $user';
  }

  @override
  String youKicked(String user) {
    return '👞 Izbacio/la si korisnika $user';
  }

  @override
  String youKickedAndBanned(String user) {
    return '🙅 Izbacio/la i isključio/la si korisnika $user';
  }

  @override
  String youUnbannedUser(String user) {
    return 'Ponovo si uključio/la korisnika $user';
  }

  @override
  String hasKnocked(String user) {
    return '🚪 $user je pokucao/la';
  }

  @override
  String get usersMustKnock => 'Korisnici moraju pokucati';

  @override
  String get noOneCanJoin => 'Nitko se ne može pridružiti';

  @override
  String get knock => 'Pokucaj';

  @override
  String get users => 'Korisnici';

  @override
  String get unlockOldMessages => 'Otključaj stare poruke';

  @override
  String get storeInSecureStorageDescription =>
      'Ključ za obnavljanje spremi u sigurno spremište na ovom uređaju.';

  @override
  String get saveKeyManuallyDescription =>
      'Spremi ovaj ključ ručno pokretanjem dijaloga za dijeljenje sustava ili međuspremnika.';

  @override
  String get storeInAndroidKeystore => 'Spremi u Android KeyStore';

  @override
  String get storeInAppleKeyChain => 'Spremi u Apple KeyChain';

  @override
  String get storeSecurlyOnThisDevice => 'Spremi sigurno na ovom uređaju';

  @override
  String countFiles(int count) {
    return 'Broj datoteka: $count';
  }

  @override
  String get user => 'Korisnik';

  @override
  String get custom => 'Prilagođeno';

  @override
  String get foregroundServiceRunning =>
      'Ova se obavijest pojavljuje kada se pokreće usluga u prvom planu.';

  @override
  String get screenSharingTitle => 'dijeljenje ekrana';

  @override
  String get screenSharingDetail => 'Dijeliš svoj ekran u FuffyChatu';

  @override
  String get whyIsThisMessageEncrypted =>
      'Zašto nije moguće čitati ovu poruku?';

  @override
  String get noKeyForThisMessage =>
      'To se može dogoditi ako je poruka poslana prije prijave na tvoj račun na ovom uređaju.\n\nTakođer je moguće da je pošiljatelj blokirao tvoj uređaj ili je došlo do greške s internetskom vezom.\n\nMožeš li pročitati poruku na jednoj drugoj sesiji? U tom slučaju možeš prenijeti poruku iz nje! Idi na Postavke > Uređaji i uvjeri se da su se tvoji uređaji međusobno potvrdili. Kada sljedeći put otvoriš sobu i obje sesije su u prednjem planu, ključevi će se automatski prenijeti.\n\nNe želiš izgubiti ključeve kada se odjaviš ili zamijeniš uređaje? Aktiviraj spremanje sigurnosne kopije chata u postavkama.';

  @override
  String get newGroup => 'Nova grupa';

  @override
  String get newSpace => 'Novi prostor';

  @override
  String get allSpaces => 'Svi prostori';

  @override
  String get hidePresences => 'Sakriti popis stanja?';

  @override
  String get doNotShowAgain => 'Nemoj više prikazivati';

  @override
  String wasDirectChatDisplayName(String oldDisplayName) {
    return 'Prazan chat (zvao se $oldDisplayName)';
  }

  @override
  String get newSpaceDescription =>
      'Prostori omogućuju konsolidiranje tvojih chatova i izgradnju privatne ili javne zajednice.';

  @override
  String get encryptThisChat => 'Šifiraj ovaj chat';

  @override
  String get disableEncryptionWarning =>
      'Iz sigurnosnih razloga ne možeš deaktivirati šifriranje u chatu u kojem je prije bilo aktivirano.';

  @override
  String get sorryThatsNotPossible => 'Žao nam je … to nije moguće';

  @override
  String get deviceKeys => 'Ključevi uređaja:';

  @override
  String get reopenChat => 'Ponovo otvori chat';

  @override
  String get noBackupWarning =>
      'Upozorenje! Bez aktiviranja spremanja sigurnosne kopije chata, izgubit ćeš pristup tvojim šifriranim porukama. Preporučujemo spremanje sigurnosne kopije chata prije odjave.';

  @override
  String get noOtherDevicesFound => 'Nijedan drugi uređaj nije pronađen';

  @override
  String fileIsTooBigForServer(String max) {
    return 'Neuspjelo slanje! Server podržava samo priloge do $max.';
  }

  @override
  String fileHasBeenSavedAt(String path) {
    return 'Datoteka je spremljena u $path';
  }

  @override
  String get jumpToLastReadMessage => 'Skoči na zadnju pročitanu poruku';

  @override
  String get readUpToHere => 'Pročitaj do ovdje';

  @override
  String get jump => 'Skoči';

  @override
  String get openLinkInBrowser => 'Otvori poveznicu u pregledniku';

  @override
  String get reportErrorDescription =>
      '😭 Joj! Dogodila se greška. Pokušaj ponovo kasnije. Ako želiš, grešku možeš prijaviti programerima.';

  @override
  String get report => 'prijavi';

  @override
  String get setColorTheme => 'Postavi boju teme:';

  @override
  String get invite => 'Pozovi';

  @override
  String get inviteGroupChat => '📨 Pozivnica u grupni chat';

  @override
  String get invalidInput => 'Neispravan unos!';

  @override
  String wrongPinEntered(int seconds) {
    return 'Unesen je pogrešan PIN! Pokušaj ponovo za $seconds sekunde …';
  }

  @override
  String get pleaseEnterANumber => 'Upiši broj veći od 0';

  @override
  String get archiveRoomDescription =>
      'Chat će se premjestiti u arhivu. Drugi korisnici će moći vidjeti da si napustio/la chat.';

  @override
  String get roomUpgradeDescription =>
      'Chat će se tada ponovo stvoriti s novom verzijom sobe. Svi sudionici će biti obaviješteni da se moraju prebaciti na novi chat. Više o verzijama soba možeš saznati na https://spec.matrix.org/latest/rooms/';

  @override
  String get removeDevicesDescription =>
      'Bit ćeš odjavljen/a s ovog uređaja i više nećeš moći primati poruke.';

  @override
  String get banUserDescription =>
      'Korisnik će biti isključen iz chata i moći će ponovo prisustvovati chatu kada ga se ponovo uključi.';

  @override
  String get unbanUserDescription =>
      'Korisnik će se ponovo moći pridružiti chatu ako pokuša.';

  @override
  String get kickUserDescription =>
      'Korisnik je izbačen iz chata, ali nije isključen. U javnim chatovima se korisnik može ponovo pridružiti u bilo kojem trenutku.';

  @override
  String get makeAdminDescription =>
      'Nakon postavljanja ovog korisnika kao administratora, to možda nećeš moći poništiti jer će on tada imati iste dozvole kao i ti.';

  @override
  String get pushNotificationsNotAvailable =>
      'Automatsko slanje obavijesti nije dostupno';

  @override
  String get learnMore => 'Saznaj više';

  @override
  String get yourGlobalUserIdIs => 'Tvoj globalni korisnički ID je: ';

  @override
  String noUsersFoundWithQuery(String query) {
    return 'Nažalost nije pronađen nijedan korisnik s „$query”. Provjeri točnost upisa.';
  }

  @override
  String get knocking => 'Kucanje';

  @override
  String chatCanBeDiscoveredViaSearchOnServer(String server) {
    return 'Chat se može otkriti pretraživanjem servera $server';
  }

  @override
  String get searchChatsRooms => 'Traži #chats, @users …';

  @override
  String get nothingFound => 'Ništa nije pronađeno...';

  @override
  String get groupName => 'Ime grupe';

  @override
  String get createGroupAndInviteUsers => 'Stvori grupu i pozovi korisnike';

  @override
  String get groupCanBeFoundViaSearch => 'Grupa se može pronaći putem pretrage';

  @override
  String get wrongRecoveryKey =>
      'Oprosti … čini se da ovo nije ispravan ključ za obnavljanje.';

  @override
  String get commandHint_sendraw => 'Pošalji neobrađeni json';

  @override
  String get databaseMigrationTitle => 'Baza podataka je optimirana';

  @override
  String get databaseMigrationBody => 'Pričekaj. Ovo može potrajati.';

  @override
  String get leaveEmptyToClearStatus =>
      'Ostavi prazno za brisanje tvog stanja.';

  @override
  String get select => 'Odaberi';

  @override
  String get searchForUsers => 'Traži @users...';

  @override
  String get pleaseEnterYourCurrentPassword => 'Upiši svoju trenutačnu lozinku';

  @override
  String get newPassword => 'Nova lozinka';

  @override
  String get pleaseChooseAStrongPassword => 'Odaberi snažnu lozinku';

  @override
  String get passwordsDoNotMatch => 'Lozinke se ne poklapaju';

  @override
  String get passwordIsWrong => 'Tvoja upisana lozinka je kriva';

  @override
  String get publicChatAddresses => 'Adrese javnih chatova';

  @override
  String get createNewAddress => 'Stvori novu adresu';

  @override
  String get joinSpace => 'Pridruži se prostoru';

  @override
  String get publicSpaces => 'Javni prostori';

  @override
  String get addChatOrSubSpace => 'Dodaj chat ili podpodručje';

  @override
  String get thisDevice => 'Ovaj uređaj:';

  @override
  String get initAppError =>
      'Dogodila se greška prilikom inicijaliziranja aplikacije';

  @override
  String searchIn(String chat) {
    return 'Traži u chatu „$chat”...';
  }

  @override
  String get searchMore => 'Traži više...';

  @override
  String get gallery => 'Galerija';

  @override
  String get files => 'Datoteke';

  @override
  String sessionLostBody(String url, String error) {
    return 'Tvoja je sesija izgubljena. Prijavi ovu grešku programerima na $url. Poruka o grešci glasi: $error';
  }

  @override
  String restoreSessionBody(String url, String error) {
    return 'Aplikacija sada pokušava obnoviti tvoju sesiju iz sigurnosne kopije. Prijavi ovu grešku programerima na $url. Poruka o grešci glasi: $error';
  }

  @override
  String get sendReadReceipts => 'Šalji potvrde o čitanju';

  @override
  String get sendTypingNotificationsDescription =>
      'Drugi sudionici u chatu mogu vidjeti kada tipkaš novu poruku.';

  @override
  String get sendReadReceiptsDescription =>
      'Drugi sudionici u raygovoru mogu vidjeti kada pročitaš poruku.';

  @override
  String get formattedMessages => 'Formatirane poruke';

  @override
  String get formattedMessagesDescription =>
      'Prikaži formatirani sadržaj poruke poput podebljanog teksta koristeći markdown.';

  @override
  String get verifyOtherUser => '🔐 Potvrdi drugog korisnika';

  @override
  String get verifyOtherUserDescription =>
      'Ako potvrdiš jednog drugog korisnika, možeš biti siguran/na da znaš kome zapravo pišeš. 💪\n\nKada pokreneš provjeru, vi i drugi korisnik vidjet ćete skočni prozor u aplikaciji. Tamo ćeš tada vidjeti niz emojija ili brojeve koje morate međusobno usporediti.\n\nNajbolji način za to je da se nađete zajedno ili započnete videopoziv. 👭';

  @override
  String get verifyOtherDevice => '🔐 Potvrdi drugi uređaj';

  @override
  String get verifyOtherDeviceDescription =>
      'Kada potvrdiš jedan drugi uređaj, ti uređaji mogu razmjenjivati ključeve, povećavajući tvoju ukupnu sigurnost. 💪 Kada pokreneš provjeru, pojavit će se skočni prozor u aplikaciji na oba uređaja. Tamo ćeš tada vidjeti niz emojija ili brojeve koje moraš međusobno usporediti. Najbolje je imati oba uređaja pri ruci prije nego što započneš provjeru. 🤳';

  @override
  String acceptedKeyVerification(String sender) {
    return '$sender je prihvatio/la potvrđivanje ključa';
  }

  @override
  String canceledKeyVerification(String sender) {
    return '$sender je prekinuo/la potvrđivanje ključa';
  }

  @override
  String completedKeyVerification(String sender) {
    return '$sender je završio/la potvrđivanje ključa';
  }

  @override
  String isReadyForKeyVerification(String sender) {
    return '$sender je spreman/na za potvrđivanje ključa';
  }

  @override
  String requestedKeyVerification(String sender) {
    return '$sender je zatražio/la potvrđivanje ključa';
  }

  @override
  String startedKeyVerification(String sender) {
    return '$sender je pokrenuo/la potvrđivanje ključa';
  }

  @override
  String get transparent => 'Prozirno';

  @override
  String get incomingMessages => 'Dolazne poruke';

  @override
  String get stickers => 'Naljepnice';

  @override
  String get discover => 'Otkrij';

  @override
  String get commandHint_ignore => 'Zanemari navedeni matrix ID';

  @override
  String get commandHint_unignore =>
      'Poništi zanemarivanje navedenog matrix ID-a';

  @override
  String unreadChatsInApp(String appname, String unread) {
    return '$appname: Broj nepročitanih chatova: $unread';
  }

  @override
  String get noDatabaseEncryption =>
      'Šifriranje baze podataka nije podržano na ovoj platformi';

  @override
  String thereAreCountUsersBlocked(Object count) {
    return 'Broj trenutačno blokiranih korisnika: $count.';
  }

  @override
  String get restricted => 'Ograničeni';

  @override
  String get knockRestricted => 'Pokucaj na ograničene sobe';

  @override
  String goToSpace(Object space) {
    return 'Idi u prostor: $space';
  }

  @override
  String get markAsUnread => 'Označi kao nepročitano';

  @override
  String userLevel(int level) {
    return '$level – Korisnik';
  }

  @override
  String moderatorLevel(int level) {
    return '$level – Moderator';
  }

  @override
  String adminLevel(int level) {
    return '$level – Administrator';
  }

  @override
  String get changeGeneralChatSettings => 'Promijeni opće postavke chata';

  @override
  String get inviteOtherUsers => 'Pozovi druge korisnike u ovaj chat';

  @override
  String get changeTheChatPermissions => 'Promijeni dozvole za chat';

  @override
  String get changeTheVisibilityOfChatHistory =>
      'Promijeni vidljivost povijesti chatova';

  @override
  String get changeTheCanonicalRoomAlias =>
      'Promijeni glavnu adresu javnog chata';

  @override
  String get sendRoomNotifications => 'Pošalji @room obavijesti';

  @override
  String get changeTheDescriptionOfTheGroup => 'Promijeni opis chata';

  @override
  String get chatPermissionsDescription =>
      'Definiraj razine dozvola koja su potrebna za određene radnje u ovom chatu. Razine dozvola 0, 50 i 100 obično predstavljaju korisnike, moderatore i administratore, ali je moguća svaka gradacija.';

  @override
  String updateInstalled(String version) {
    return '🎉 Aktualizirana verzija $version je instalirana!';
  }

  @override
  String get changelog => 'Dnevnik promjena';

  @override
  String get sendCanceled => 'Slanje je prekinuto';

  @override
  String get loginWithMatrixId => 'Prijava pomoću Matrix-ID-a';

  @override
  String get doesNotSeemToBeAValidHomeserver =>
      'Čini se da nije kompatibilan homeserver. Pogrešan URL?';

  @override
  String get calculatingFileSize => 'Izračunavanje veličine datoteke …';

  @override
  String get prepareSendingAttachment => 'Pripremi slanje priloga …';

  @override
  String get sendingAttachment => 'Slanje priloga …';

  @override
  String get generatingVideoThumbnail => 'Generiranje minijatura videa …';

  @override
  String get compressVideo => 'Komprimiranje videa …';

  @override
  String sendingAttachmentCountOfCount(int index, int length) {
    return 'Slanje priloga $index od $length …';
  }

  @override
  String serverLimitReached(int seconds) {
    return 'Granica servera je dosegnuta! Čeka $seconds s …';
  }

  @override
  String get oneOfYourDevicesIsNotVerified =>
      'Jedan od tvojih uređaja nije potvrđen';

  @override
  String get noticeChatBackupDeviceVerification =>
      'Napomena: Kada spojiš sve svoje uređaje na sigurnosnu kopiju chata, oni se automatski potvrđuju.';

  @override
  String get continueText => 'Nastavi';

  @override
  String get welcomeText =>
      'Hej, hej 👋, ovdje FluffyChat. Možeš se prijaviti na bilo koji homeserver koji je kompatibilan s https://matrix.org. I onda razgovaraj s bilo kim. To je ogromna decentralizirana mreža za razmjenu poruka!';

  @override
  String get blur => 'Zamućenost:';

  @override
  String get opacity => 'Neprozirnost:';

  @override
  String get setWallpaper => 'Postavi sliku pozadine';

  @override
  String get manageAccount => 'Upravljaj računom';

  @override
  String get noContactInformationProvided =>
      'Server ne pruža nikoje valjane kontakt podatke';

  @override
  String get contactServerAdmin => 'Kontaktiraj administratora servera';

  @override
  String get contactServerSecurity =>
      'Kontaktiraj zadužene za sigurnost servera';

  @override
  String get supportPage => 'Stranica podrške';

  @override
  String get serverInformation => 'Podaci servera:';

  @override
  String get name => 'Ime';

  @override
  String get version => 'Verzija';

  @override
  String get website => 'Web-stranica';

  @override
  String get compress => 'Komprimiraj';

  @override
  String get boldText => 'Podebljani tekst';

  @override
  String get italicText => 'Kurzivni tekst';

  @override
  String get strikeThrough => 'Precrtano';

  @override
  String get pleaseFillOut => 'Ispuni';

  @override
  String get invalidUrl => 'Neispravan URL';

  @override
  String get addLink => 'Dodaj poveznicu';

  @override
  String get unableToJoinChat =>
      'Neuspjelo pridruživanje chatu. Možda je druga strana već zatvorila konverzaciju.';

  @override
  String get previous => 'Prethodni';

  @override
  String get otherPartyNotLoggedIn =>
      'Druga strana trenutačno nije prijavljena i stoga ne može primati poruke!';

  @override
  String appWantsToUseForLogin(String server) {
    return 'Koristi \'$server\' za prijavu';
  }

  @override
  String get appWantsToUseForLoginDescription =>
      'Ovime dopuštaš aplikaciji i web-stranici da dijele podatke o tebi.';

  @override
  String get open => 'Otvori';

  @override
  String get waitingForServer => 'Čekanje na server …';

  @override
  String get newChatRequest => '📩 Novi zahtjev za chat';

  @override
  String get contentNotificationSettings => 'Postavke obavijesti o sadržaju';

  @override
  String get generalNotificationSettings => 'Opće postavke obavijesti';

  @override
  String get roomNotificationSettings => 'Postavke obavijesti sobe';

  @override
  String get userSpecificNotificationSettings =>
      'Koriničke postavke obavijesti';

  @override
  String get otherNotificationSettings => 'Druge postavke obavijesti';

  @override
  String get notificationRuleContainsUserName => 'Sadrži korisničko ime';

  @override
  String get notificationRuleContainsUserNameDescription =>
      'Obavještava korisnika kada poruka sadrži njegovo korisničko ime.';

  @override
  String get notificationRuleMaster => 'Isključi sve obavijesti';

  @override
  String get notificationRuleMasterDescription =>
      'Nadjačava sva druga pravila i deaktivira sve obavijesti.';

  @override
  String get notificationRuleSuppressNotices =>
      'Isključi automatizirane poruke';

  @override
  String get notificationRuleSuppressNoticesDescription =>
      'Isključi obavijesti od automatiziranih klijenata poput botova.';

  @override
  String get notificationRuleInviteForMe => 'Poziv za mene';

  @override
  String get notificationRuleInviteForMeDescription =>
      'Obavještava korisnika kada je pozvan u sobu.';

  @override
  String get notificationRuleMemberEvent => 'Događaj člana';

  @override
  String get notificationRuleMemberEventDescription =>
      'Isključi obavijesti o događajima članstva.';

  @override
  String get notificationRuleIsUserMention => 'Spominjanje korisnika';

  @override
  String get notificationRuleIsUserMentionDescription =>
      'Obavještava korisnika kada je izravno spomenut u poruci.';

  @override
  String get notificationRuleContainsDisplayName => 'Sadrži prikazano ime';

  @override
  String get notificationRuleContainsDisplayNameDescription =>
      'Obavještava korisnika kada poruka sadrži njegovo prikazano ime.';

  @override
  String get notificationRuleIsRoomMention => 'Spominjanje sobe';

  @override
  String get notificationRuleIsRoomMentionDescription =>
      'Obavještava korisnika kad se spomene soba.';

  @override
  String get notificationRuleRoomnotif => 'Obavijest o sobi';

  @override
  String get notificationRuleRoomnotifDescription =>
      'Obavještava korisnika kada poruka sadrži „@room“.';

  @override
  String get notificationRuleTombstone => 'Nadgrobni spomenik';

  @override
  String get notificationRuleTombstoneDescription =>
      'Obavještava korisnika o porukama o deaktivaciji sobe.';

  @override
  String get notificationRuleReaction => 'Reakcija';

  @override
  String get notificationRuleReactionDescription =>
      'Isključi obavijesti za reakcije.';

  @override
  String get notificationRuleRoomServerAcl =>
      'Kontrolni popis za pristup serveru sobe';

  @override
  String get notificationRuleRoomServerAclDescription =>
      'Isključi obavijesti o kontrolnim popisima za pristup serveru sobe (ACL).';

  @override
  String get notificationRuleSuppressEdits => 'Isključi uređivanja';

  @override
  String get notificationRuleSuppressEditsDescription =>
      'Isključi obavijesti za uređene poruke.';

  @override
  String get notificationRuleCall => 'Poziv';

  @override
  String get notificationRuleCallDescription =>
      'Obavještava korisnika o pozivima.';

  @override
  String get notificationRuleEncryptedRoomOneToOne =>
      'Šifrirana soba jedan-na-jedan';

  @override
  String get notificationRuleEncryptedRoomOneToOneDescription =>
      'Obavještava korisnika o porukama u šifriranim sobama jedan-na-jedan.';

  @override
  String get notificationRuleRoomOneToOne => 'Soba jedan-na-jedan';

  @override
  String get notificationRuleRoomOneToOneDescription =>
      'Obavještava korisnika o porukama u sobama jedan-na-jedan.';

  @override
  String get notificationRuleMessage => 'Poruka';

  @override
  String get notificationRuleMessageDescription =>
      'Obavještava korisnika o općim porukama.';

  @override
  String get notificationRuleEncrypted => 'Šifrirano';

  @override
  String get notificationRuleEncryptedDescription =>
      'Obavještava korisnika o porukama u šifriranim sobama.';

  @override
  String get notificationRuleJitsi => 'Jitsi';

  @override
  String get notificationRuleJitsiDescription =>
      'Obavještava korisnika o događajima Jitsi widgeta.';

  @override
  String get notificationRuleServerAcl =>
      'Isključi događaje kontrole pristupa servera (ACL)';

  @override
  String get notificationRuleServerAclDescription =>
      'Isključi obavijesti za kontrolne popise za pristup (ACL).';

  @override
  String unknownPushRule(String rule) {
    return 'Nepoznato push pravilo \'$rule\'';
  }

  @override
  String sentVoiceMessage(String sender, String duration) {
    return '🎙️ $duration – Glasovna poruka od $sender';
  }

  @override
  String get deletePushRuleCanNotBeUndone =>
      'Brisanje postavki obavijesti je nopovratna radnja.';

  @override
  String get more => 'Više';

  @override
  String get shareKeysWith => 'Dijeli ključeve s …';

  @override
  String get shareKeysWithDescription =>
      'Kojim se uređajima treba vjerovati za čitanje tvojih poruka u šifriranim chatovima?';

  @override
  String get allDevices => 'Svi uređaji';

  @override
  String get crossVerifiedDevicesIfEnabled =>
      'Unakrsno potvrđeni uređaji, ako je uključeno';

  @override
  String get crossVerifiedDevices => 'Unakrsno potvrđeni uređaji';

  @override
  String get verifiedDevicesOnly => 'Samo potvrđeni uređaji';

  @override
  String get takeAPhoto => 'Snimi sliku';

  @override
  String get recordAVideo => 'Snimi video';

  @override
  String get optionalMessage => '(Opcionalna) poruka …';

  @override
  String get notSupportedOnThisDevice => 'Nije podržano na ovom uređaju';

  @override
  String get enterNewChat => 'Upiši novi chat';

  @override
  String get approve => 'Odobri';

  @override
  String get youHaveKnocked => 'Pokucao/la si';

  @override
  String get pleaseWaitUntilInvited =>
      'Sad pričekaj, dok te netko iz sobe ne pozove.';

  @override
  String get commandHint_logout => 'Odjavi tvoj trenutačni uređaj';

  @override
  String get commandHint_logoutall => 'Odjavi sve aktivne uređaje';

  @override
  String get displayNavigationRail =>
      'Prikaži navigacijsku traku na mobilnom uređaju';

  @override
  String get customReaction => 'Prilagođena reakcija';

  @override
  String get moreEvents => 'Više događaja';

  @override
  String get declineInvitation => 'Odbij poziv';

  @override
  String get noMessagesYet => 'Još nema poruka';

  @override
  String get longPressToRecordVoiceMessage =>
      'Pritisni dugo za snimanje glasovne poruke.';

  @override
  String get pause => 'Pauza';

  @override
  String get resume => 'Nastavi';

  @override
  String get removeFromSpaceDescription =>
      'Chat će se ukloniti iz prostora, ali će se i dalje pojaviti na tvom popisu chatova.';

  @override
  String countChats(int chats) {
    return 'Broj chatova: $chats';
  }

  @override
  String spaceMemberOf(String spaces) {
    return 'Član $spaces prostora';
  }

  @override
  String spaceMemberOfCanKnock(String spaces) {
    return 'Član $spaces prostora smije pokucati';
  }

  @override
  String startedAPoll(String username) {
    return '$username je pokrenuo/la anketu.';
  }

  @override
  String get poll => 'Anketa';

  @override
  String get startPoll => 'Početak ankete';

  @override
  String get endPoll => 'Kraj ankete';

  @override
  String get answersVisible => 'Odgovori vidljivi';

  @override
  String get pollQuestion => 'Pitanje u anketi';

  @override
  String get answerOption => 'Opcija za odgovor';

  @override
  String get addAnswerOption => 'Dodaj opciju za odgovor';

  @override
  String get allowMultipleAnswers => 'Dopusti više odgovora';

  @override
  String get pollHasBeenEnded => 'Anketa je završena';

  @override
  String countVotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count glasova',
      few: '$count glasa',
      one: 'Jedan glas',
    );
    return '$_temp0';
  }

  @override
  String get answersWillBeVisibleWhenPollHasEnded =>
      'Odgovori će biti vidljivi nakon završetka ankete';

  @override
  String get replyInThread => 'Odgovori u temi';

  @override
  String countReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count odgovora',
      few: '$count odgovora',
      one: 'Jedan odgovor',
    );
    return '$_temp0';
  }

  @override
  String get thread => 'Tema';

  @override
  String get backToMainChat => 'Natrag na glavni chat';

  @override
  String get saveChanges => 'Spremi promjene';

  @override
  String get createSticker => 'Stvori naljepnicu ili emoji';

  @override
  String get useAsSticker => 'Koristi kao naljepnicu';

  @override
  String get useAsEmoji => 'Koristi kao emoji';

  @override
  String get stickerPackNameAlreadyExists =>
      'Ime paketa naljepnica već postoji';

  @override
  String get newStickerPack => 'Novi paket naljepnica';

  @override
  String get stickerPackName => 'Ime paketa naljepnica';

  @override
  String get attribution => 'Atribucija';

  @override
  String get skipChatBackup => 'Preskoči sigurnosno kopiranje chata';

  @override
  String get skipChatBackupWarning =>
      'Sigurno? Bez aktiviranja sigurnosne kopije chata možeš izgubiti pristup svojim porukama ako promijeniš uređaj.';

  @override
  String get loadingMessages => 'Učitavanje poruka';

  @override
  String get setupChatBackup => 'Postavi sigurnosno kopiranje chata';

  @override
  String get noMoreResultsFound => 'Nema više rezultata';

  @override
  String chatSearchedUntil(String time) {
    return 'Chat je pretražen do $time';
  }

  @override
  String get federationBaseUrl => 'Osnovni URL federacije';

  @override
  String get clientWellKnownInformation =>
      'Dobro poznate informacije o klijentu:';

  @override
  String get baseUrl => 'Osnovni URL';

  @override
  String get identityServer => 'Server identiteta:';

  @override
  String versionWithNumber(String version) {
    return 'Verzija: $version';
  }

  @override
  String get logs => 'Zapisi';

  @override
  String get advancedConfigs => 'Napredne konfiguracije';

  @override
  String get advancedConfigurations => 'Napredne konfiguracije';

  @override
  String get signIn => 'Sign in';

  @override
  String get createNewAccount => 'Create new account';

  @override
  String get signUpGreeting =>
      'FluffyChat is decentralized! Select a server where you want to create your account and let\'s go!';

  @override
  String get signInGreeting =>
      'You already have an account in Matrix? Welcome back! Select your homeserver and sign in.';

  @override
  String get appIntro =>
      'With FluffyChat you can chat with your friends. It\'s a secure decentralized [matrix] messenger! Learn more on https://matrix.org if you like or just sign up.';

  @override
  String get theProcessWasCanceled => 'The process was canceled.';

  @override
  String get join => 'Join';

  @override
  String get searchOrEnterHomeserverAddress =>
      'Search or enter homeserver address';

  @override
  String get matrixId => 'Matrix ID';

  @override
  String get setPowerLevel => 'Set power level';

  @override
  String get makeModerator => 'Make moderator';

  @override
  String get makeAdmin => 'Make admin';

  @override
  String get removeModeratorRights => 'Remove moderator rights';

  @override
  String get removeAdminRights => 'Remove admin rights';

  @override
  String get powerLevel => 'Power level';

  @override
  String get setPowerLevelDescription =>
      'Power levels define what a member is allowed to do in this room and usually range between 0 and 100.';

  @override
  String get owner => 'Owner';

  @override
  String get mute => 'Mute';

  @override
  String get createNewChat => 'Create new chat';

  @override
  String get reset => 'Reset';

  @override
  String get supportFluffyChat => 'Support FluffyChat';

  @override
  String get support => 'Support';

  @override
  String get fluffyChatSupportBannerMessage =>
      'FluffyChat needs YOUR help!\n❤️❤️❤️\nFluffyChat will always be free, but development and hosting still cost money.\nThe future of the project depends on support from people like you.';

  @override
  String get skipSupportingFluffyChat => 'Skip supporting FluffyChat';

  @override
  String get iDoNotWantToSupport => 'I do not want to support';

  @override
  String get iAlreadySupportFluffyChat => 'I already support FluffyChat';

  @override
  String get setLowPriority => 'Set low priority';

  @override
  String get unsetLowPriority => 'Unset low priority';

  @override
  String get removeCallFromChat => 'Remove call from chat';

  @override
  String get removeCallFromChatDescription =>
      'Do you want to remove the call from the chat for all members?';

  @override
  String get removeCallForEveryone => 'Remove call for everyone';

  @override
  String get startVoiceCall => 'Start voice call';

  @override
  String get startVideoCall => 'Start video call';

  @override
  String get joinVoiceCall => 'Join voice call';

  @override
  String get joinVideoCall => 'Join video call';

  @override
  String get live => 'Live';

  @override
  String get playSoundOnNotification => 'Play sound on notification';

  @override
  String get addTag => 'Add tag';

  @override
  String get removeTag => 'Remove tag';

  @override
  String get tagName => 'Tag name';

  @override
  String get createNewTag => 'Create new tag';
}
