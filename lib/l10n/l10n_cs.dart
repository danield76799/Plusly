// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class L10nCs extends L10n {
  L10nCs([String locale = 'cs']) : super(locale);

  @override
  String get alwaysUse24HourFormat => 'Vypnuto';

  @override
  String get repeatPassword => 'Zopakujte heslo';

  @override
  String get notAnImage => 'Není obrázek.';

  @override
  String get ignoreUser => 'Ignorovat uživatele';

  @override
  String get remove => 'Odstranit';

  @override
  String get importNow => 'Importovat nyní';

  @override
  String get importEmojis => 'Importovat emodži';

  @override
  String get importFromZipFile => 'Importovat ze .zip souboru';

  @override
  String get exportEmotePack => 'Exportovat emodži jako .zip';

  @override
  String get replace => 'Nahradit';

  @override
  String get about => 'O aplikaci';

  @override
  String aboutHomeserver(String homeserver) {
    return 'O $homeserver';
  }

  @override
  String get accept => 'Přijmout';

  @override
  String acceptedTheInvitation(String username) {
    return '👍 $username přijal/a pozvání';
  }

  @override
  String get account => 'Účet';

  @override
  String activatedEndToEndEncryption(String username) {
    return '🔐 $username aktivoval/a koncové šifrování';
  }

  @override
  String get addEmail => 'Přidat e-mail';

  @override
  String get confirmMatrixId =>
      'Pro smazání svého účtu potvrďte, prosím, své Matrix ID.';

  @override
  String supposedMxid(String mxid) {
    return 'Tady by mělo být $mxid';
  }

  @override
  String get addToSpace => 'Přidat do prostoru';

  @override
  String get admin => 'Správce';

  @override
  String get alias => 'alias';

  @override
  String get all => 'Vše';

  @override
  String get allChats => 'Všechny chaty';

  @override
  String get commandHint_roomupgrade => 'Aktualizovat místnost na danou verzi';

  @override
  String get commandHint_googly => 'Poslat kroutící se očička';

  @override
  String get commandHint_cuddle => 'Poslat mazlení';

  @override
  String get commandHint_hug => 'Poslat obejmutí';

  @override
  String googlyEyesContent(String senderName) {
    return '$senderName vám posílá kroutící se očička';
  }

  @override
  String cuddleContent(String senderName) {
    return '$senderName se s vámi mazlí';
  }

  @override
  String hugContent(String senderName) {
    return '$senderName vás objímá';
  }

  @override
  String answeredTheCall(String senderName) {
    return '$senderName odpověděl na hovor';
  }

  @override
  String get anyoneCanJoin => 'Kdokoliv se může připojit';

  @override
  String get appLock => 'Zámek aplikace';

  @override
  String get appLockDescription =>
      'Zamknout aplikaci pomocí PIN kódu když není používána';

  @override
  String get archive => 'Archivovat';

  @override
  String get areGuestsAllowedToJoin => 'Mohou se připojit hosté';

  @override
  String get areYouSure => 'Jste si jistý?';

  @override
  String get areYouSureYouWantToLogout => 'Opravdu se chcete odhlásit?';

  @override
  String get askSSSSSign =>
      'Pro ověření této osoby zadejte prosím přístupovou frázi k „bezpečnému úložišti“ anebo „klíč pro obnovu“.';

  @override
  String askVerificationRequest(String username) {
    return 'Přijmout žádost o ověření od $username?';
  }

  @override
  String get autoplayImages =>
      'Automaticky přehrajte animované nálepky a emoce';

  @override
  String badServerLoginTypesException(
    String serverVersions,
    String supportedVersions,
    Object suportedVersions,
  ) {
    return 'Homeserver podporuje přihlášení typu:\n$serverVersions\nAle tato aplikace podporuje pouze:\n$supportedVersions';
  }

  @override
  String get sendTypingNotifications => 'Posílat oznámení o psaní';

  @override
  String get swipeRightToLeftToReply =>
      'Potáhnutím zprava doleva odpovědět na zprávu';

  @override
  String get sendOnEnter => 'Odeslat při vstupu';

  @override
  String get noMoreChatsFound => 'Žádné další konverzace nalezeny...';

  @override
  String get noChatsFoundHere =>
      'Nejsou zde žádné konverzace. Začněte novou konverzaci s někým pomocí tlačítka níže. ⤵️';

  @override
  String get unread => 'Nepřečtené';

  @override
  String get space => 'Prostor';

  @override
  String get spaces => 'Prostory';

  @override
  String get banFromChat => 'Zakázat chat';

  @override
  String get banned => 'Zakázán';

  @override
  String bannedUser(String username, String targetName) {
    return '$username zakázal $targetName';
  }

  @override
  String get blockDevice => 'Blokovat zařízení';

  @override
  String get blocked => 'Zakázán';

  @override
  String get cancel => 'Zrušit';

  @override
  String cantOpenUri(String uri) {
    return 'Nelze otevřít URI $uri';
  }

  @override
  String get changeDeviceName => 'Změnit název zařízení';

  @override
  String changedTheChatAvatar(String username) {
    return '$username změnil avatar chatu';
  }

  @override
  String changedTheChatDescription(Object username) {
    return '$username změnil/a popis konverzace';
  }

  @override
  String changedTheChatDescriptionTo(String username, String description) {
    return '$username změnil/a popis konverzace na: „$description“';
  }

  @override
  String changedTheChatName(Object username) {
    return '$username změnil/a název konverzace';
  }

  @override
  String changedTheChatNameTo(String username, String chatname) {
    return '$username změnil/a název konverzace na: „$chatname“';
  }

  @override
  String changedTheChatPermissions(String username) {
    return '$username změnili nastavení oprávnění v chatu';
  }

  @override
  String changedTheDisplaynameTo(String username, String displayname) {
    return '$username změnil/a svoji přezdívku na: „$displayname“';
  }

  @override
  String changedTheGuestAccessRules(String username) {
    return '$username změnili přístupová práva pro hosty';
  }

  @override
  String changedTheGuestAccessRulesTo(String username, String rules) {
    return '$username změnili přístupová práva pro hosty na: $rules';
  }

  @override
  String changedTheHistoryVisibility(String username) {
    return '$username změnili nastavení viditelnosti historie diskuze';
  }

  @override
  String changedTheHistoryVisibilityTo(String username, String rules) {
    return '$username změnili nastavení viditelnosti historie diskuze na: $rules';
  }

  @override
  String changedTheJoinRules(String username) {
    return '$username změnili nastavení pravidel připojení';
  }

  @override
  String changedTheJoinRulesTo(String username, String joinRules) {
    return '$username změnili nastavení pravidel připojení na: $joinRules';
  }

  @override
  String changedTheProfileAvatar(String username) {
    return '$username změnili svůj avatar';
  }

  @override
  String changedTheRoomAliases(String username) {
    return '$username změnili nastavení aliasů místnosti';
  }

  @override
  String changedTheRoomInvitationLink(String username) {
    return '$username změnili odkaz k pozvání do místnosti';
  }

  @override
  String get changePassword => 'Změnit heslo';

  @override
  String get changeTheHomeserver => 'Změnit domovský server';

  @override
  String get changeTheme => 'Změňte svůj styl';

  @override
  String get changeTheNameOfTheGroup => 'Změnit název skupiny';

  @override
  String get changeYourAvatar => 'Změňte svůj avatar';

  @override
  String get channelCorruptedDecryptError => 'Šifrování bylo poškozeno';

  @override
  String get chat => 'Chat';

  @override
  String get yourChatBackupHasBeenSetUp => 'Vaše záloha chatu byla nastavena.';

  @override
  String get chatBackup => 'Záloha chatu';

  @override
  String get chatBackupDescription =>
      'Vaše zprávy jsou zabezpečeny bezpečnostním klíčem. Ujistěte se, prosím, že klíč neztratíte.';

  @override
  String get chatDetails => 'Bližší údaje o chatu';

  @override
  String get chats => 'Chaty';

  @override
  String get chooseAStrongPassword => 'Vyberte silné heslo';

  @override
  String get clearArchive => 'Vymazat archiv';

  @override
  String get close => 'Zavřít';

  @override
  String get commandHint_markasdm =>
      'Označit jako místnost přímé konverzace s daným Matrix ID';

  @override
  String get commandHint_markasgroup => 'Označit jako skupinu';

  @override
  String get commandHint_ban =>
      'Zakázat danému uživateli přístup do této místnosti';

  @override
  String get commandHint_clearcache => 'Vymazat mezipamět';

  @override
  String get commandHint_create =>
      'Vytvořte prázdný skupinový chat\n K deaktivaci šifrování použijte --no-encryption';

  @override
  String get commandHint_discardsession => 'Zahodit relaci';

  @override
  String get commandHint_dm =>
      'Zahajte přímý chat\nK deaktivaci šifrování použijte --no-encryption';

  @override
  String get commandHint_html => 'Odeslat text ve formátu HTML';

  @override
  String get commandHint_invite => 'Pozvěte daného uživatele do této místnosti';

  @override
  String get commandHint_join => 'Připojte se k dané místnosti';

  @override
  String get commandHint_kick => 'Odeberte daného uživatele z této místnosti';

  @override
  String get commandHint_leave => 'Opusťte tuto místnost';

  @override
  String get commandHint_me => 'Představ se';

  @override
  String get commandHint_myroomavatar =>
      'Nastavte si obrázek pro tuto místnost (autor mxc-uri)';

  @override
  String get commandHint_myroomnick =>
      'Nastavte si váš zobrazovaný název pro tuto místnost';

  @override
  String get commandHint_op =>
      'Nastavit úroveň práv daného uživatele (výchozí: 50)';

  @override
  String get commandHint_plain => 'Odeslat neformátovaný text';

  @override
  String get commandHint_react => 'Odeslat odpověď jako reakci';

  @override
  String get commandHint_send => 'Poslat zprávu';

  @override
  String get commandHint_unban =>
      'Zrušte zákaz přístupu daného uživatele do této místnosti';

  @override
  String get commandInvalid => 'Příkaz je neplatný';

  @override
  String commandMissing(String command) {
    return '$command není příkaz.';
  }

  @override
  String get compareEmojiMatch =>
      'Porovnejte a přesvědčete se, že následující emotikony se shodují na obou zařízeních';

  @override
  String get compareNumbersMatch =>
      'Porovnejte a přesvědčete se, že následující čísla se shodují na obou zařízeních';

  @override
  String get configureChat => 'Nastavení chatu';

  @override
  String get contactHasBeenInvitedToTheGroup => 'Kontakt byl pozván do skupiny';

  @override
  String get contentHasBeenReported => 'Obsah byl nahlášen správcům serveru';

  @override
  String get copiedToClipboard => 'Zkopírováno do schránky';

  @override
  String get copy => 'Kopírovat';

  @override
  String get copyToClipboard => 'Zkopírovat do schránky';

  @override
  String couldNotDecryptMessage(String error) {
    return 'Nebylo možné dešifrovat zprávu: $error';
  }

  @override
  String get checkList => 'Kontrolní seznam';

  @override
  String countParticipants(int count) {
    return '$count účastníků';
  }

  @override
  String countInvited(int count) {
    return '$count pozváno';
  }

  @override
  String get create => 'Vytvořit';

  @override
  String createdTheChat(String username) {
    return '💬 $username založil/a chat';
  }

  @override
  String get createGroup => 'Vytvořit skupinu';

  @override
  String get createNewSpace => 'Nový prostor';

  @override
  String get currentlyActive => 'Aktuálně aktivní';

  @override
  String get darkTheme => 'Tmavé';

  @override
  String dateAndTimeOfDay(String date, String timeOfDay) {
    return '$date, $timeOfDay';
  }

  @override
  String get deactivateAccountWarning =>
      'Tímto krokem se deaktivuje váš uživatelský účet. Akci nelze vrátit zpět! Jste si jistí?';

  @override
  String get defaultPermissionLevel =>
      'Výchozí úroveň oprávnění nových uživatelů';

  @override
  String get delete => 'Smazat';

  @override
  String get deleteAccount => 'Smazat účet';

  @override
  String get deleteMessage => 'Smazat zprávu';

  @override
  String get device => 'Zařízení';

  @override
  String get deviceId => 'ID zařízení';

  @override
  String get devices => 'Zařízení';

  @override
  String get directChats => 'Přímé chatování';

  @override
  String get displaynameHasBeenChanged => 'Přezdívka byla změněna';

  @override
  String get downloadFile => 'Stáhnout soubor';

  @override
  String get edit => 'Upravit';

  @override
  String get editBlockedServers => 'Upravit zakázané servery';

  @override
  String get chatPermissions => 'Oprávnění konverzace';

  @override
  String get editDisplayname => 'Změnit přezdívku';

  @override
  String get editRoomAliases => 'Upravit aliasy místností';

  @override
  String get editRoomAvatar => 'Upravit avatara místnosti';

  @override
  String get emoteExists => 'Emotikona již existuje!';

  @override
  String get emoteInvalid => 'Neplatný kód emotikony!';

  @override
  String get emoteKeyboardNoRecents =>
      'Naposledy použité emodži se zobrazí zde...';

  @override
  String get emotePacks => 'Balíček emotikonů pro místnost';

  @override
  String get emoteSettings => 'Nastavení emotikonů';

  @override
  String get globalChatId => 'Globální ID chatu';

  @override
  String get accessAndVisibility => 'Přístup a viditelnost';

  @override
  String get accessAndVisibilityDescription =>
      'Kdo se může připojit a najít tuto konverzaci.';

  @override
  String get calls => 'Volání';

  @override
  String get customEmojisAndStickers => 'Vlastní emodži a nálepky';

  @override
  String get customEmojisAndStickersBody =>
      'Přidat nebo sdílet vlastní emodži či nálepky, které lze použít v konverzaci.';

  @override
  String get emoteShortcode => 'Klávesová zkratka emotikonu';

  @override
  String get emptyChat => 'Prázdný chat';

  @override
  String get enableEmotesGlobally => 'Povolit balíček emotikon všude';

  @override
  String get enableEncryption => 'Povolit šifrování';

  @override
  String get enableEncryptionWarning =>
      'Šifrování již nebude možné vypnout. Jste si tím jisti?';

  @override
  String get encrypted => 'Šifrováno';

  @override
  String get encryption => 'Šifrování';

  @override
  String get encryptionNotEnabled => 'Šifrování není aktivní';

  @override
  String endedTheCall(String senderName) {
    return '$senderName ukončil hovor';
  }

  @override
  String get enterAnEmailAddress => 'Zadejte e-mailovou adresu';

  @override
  String get homeserver => 'Domácí server';

  @override
  String errorObtainingLocation(String error) {
    return 'Chyba při získávání polohy: $error';
  }

  @override
  String get everythingReady => 'Vše připraveno!';

  @override
  String get extremeOffensive => 'Extrémně urážlivé';

  @override
  String get fileName => 'Název souboru';

  @override
  String get fluffychat => 'FluffyChat';

  @override
  String get fontSize => 'Velikost písma';

  @override
  String get forward => 'Přeposlat';

  @override
  String get fromJoining => 'Od vstupu';

  @override
  String get fromTheInvitation => 'Od pozvání';

  @override
  String get group => 'Skupina';

  @override
  String get chatDescription => 'Popis konverzace';

  @override
  String get chatDescriptionHasBeenChanged => 'Popis konverzace byl změněn';

  @override
  String get groupIsPublic => 'Skupina je veřejná';

  @override
  String get groups => 'Skupiny';

  @override
  String groupWith(String displayname) {
    return 'Skupina s $displayname';
  }

  @override
  String get guestsAreForbidden => 'Hosté jsou zakázáni';

  @override
  String get guestsCanJoin => 'Hosté se mohou připojit';

  @override
  String hasWithdrawnTheInvitationFor(String username, String targetName) {
    return '$username stáhl pozvánku pro $targetName';
  }

  @override
  String get help => 'Pomoc';

  @override
  String get hideRedactedEvents => 'Skrýt redigované události';

  @override
  String get hideRedactedMessages => 'Skrýt upravené zprávy';

  @override
  String get hideRedactedMessagesBody =>
      'Pokud někdo zprávu zrediguje, nebude tato zpráva v chatu již viditelná.';

  @override
  String get hideInvalidOrUnknownMessageFormats =>
      'Skrýt nesprávné nebo neznámé formáty zpráv';

  @override
  String get howOffensiveIsThisContent => 'Jak urážlivý je tento obsah?';

  @override
  String get id => 'ID';

  @override
  String get block => 'Zablokovat';

  @override
  String get blockedUsers => 'Zablokování uživatelé';

  @override
  String get blockListDescription =>
      'Můžete blokovat uživatele, kteří vás obtěžují. Od uživatelů na vašem osobním seznamu blokovaných uživatelů nebudete moci přijímat žádné zprávy ani pozvánky do místnosti.';

  @override
  String get blockUsername => 'Ignorovat uživatelské jméno';

  @override
  String get iHaveClickedOnLink => 'Klikl jsem na odkaz';

  @override
  String get incorrectPassphraseOrKey =>
      'Nesprávné přístupové heslo anebo klíč pro obnovu';

  @override
  String get inoffensive => 'Neškodný';

  @override
  String get inviteContact => 'Pozvat kontakt';

  @override
  String inviteContactToGroup(String groupName) {
    return 'Pozvat kontakt do $groupName';
  }

  @override
  String get noChatDescriptionYet =>
      'Zatím nebyl vytvořen žádný popis konverzace.';

  @override
  String get tryAgain => 'Zkuste to znovu';

  @override
  String get invalidServerName => 'Neplatné jméno serveru';

  @override
  String get invited => 'Pozvaný';

  @override
  String get redactMessageDescription =>
      'Tato zpráva bude smazána pro všechny účastníky konverzace. Tuto akci nelze vzít zpět.';

  @override
  String get optionalRedactReason => '(Nepovinné) Důvod smazání této zprávy…';

  @override
  String invitedUser(String username, String targetName) {
    return '📩 $username pozval/a $targetName';
  }

  @override
  String get invitedUsersOnly => 'Pouze pozvaní uživatelé';

  @override
  String inviteText(String username, String link) {
    return '$username vás pozval/a na FluffyChat.\n1. Navštivte fluffychat.im a nainstalujte si aplikaci.\n2. Zaregistrujte se nebo se přihlaste.\n3. Otevřte pozvánku: \n $link';
  }

  @override
  String get isTyping => 'píše…';

  @override
  String joinedTheChat(String username) {
    return '👋 $username se připojil/a do konverzace';
  }

  @override
  String get joinRoom => 'Připojte se k místnosti';

  @override
  String kicked(String username, String targetName) {
    return '👞 $username vyhodil/a $targetName';
  }

  @override
  String kickedAndBanned(String username, String targetName) {
    return '$username vyhodil/a a zabanoval/a $targetName';
  }

  @override
  String get kickFromChat => 'Vyhodit z chatu';

  @override
  String lastActiveAgo(String localizedTimeShort) {
    return 'Naposledy aktivní: $localizedTimeShort';
  }

  @override
  String get leave => 'Opustit';

  @override
  String get leftTheChat => 'Opustil chat';

  @override
  String get lightTheme => 'Světlé';

  @override
  String loadCountMoreParticipants(int count) {
    return 'Načíst dalších $count účastníků';
  }

  @override
  String get dehydrate => 'Exportovat relaci a promazat zařízení';

  @override
  String get dehydrateWarning =>
      'Tuto akci nelze vzít zpět. Ujistěte se, že máte bezpečně uložený soubor zálohy.';

  @override
  String get hydrate => 'Obnovit ze souboru zálohy';

  @override
  String get loadingPleaseWait => 'Načítání… Prosíme vyčkejte.';

  @override
  String get loadMore => 'Načíst další…';

  @override
  String get locationDisabledNotice =>
      'Služby určování polohy jsou deaktivovány. Povolte jim, aby mohli sdílet vaši polohu.';

  @override
  String get locationPermissionDeniedNotice =>
      'Oprávnění k poloze odepřeno. Udělte jim prosím možnost sdílet vaši polohu.';

  @override
  String get login => 'Přihlásit se';

  @override
  String logInTo(String homeserver) {
    return 'Přihlášení k $homeserver';
  }

  @override
  String get logout => 'Odhlásit';

  @override
  String get mention => 'Zmínit se';

  @override
  String get messages => 'Zprávy';

  @override
  String get messagesStyle => 'Zprávy:';

  @override
  String get moderator => 'Moderátor';

  @override
  String get muteChat => 'Ztlumit chat';

  @override
  String get needPantalaimonWarning =>
      'Prosím vezměte na vědomí, že pro použití koncového šifrování je prozatím potřeba použít Pantalaimon.';

  @override
  String get newChat => 'Nový chat';

  @override
  String get newMessageInFluffyChat => '💬 Nová zpráva ve FluffyChatu';

  @override
  String get newVerificationRequest => 'Nová žádost o ověření!';

  @override
  String get next => 'Další';

  @override
  String get no => 'Ne';

  @override
  String get noConnectionToTheServer => 'Žádné připojení k serveru';

  @override
  String get noEmotesFound => 'Nebyly nalezeny žádné emotikony. 😕';

  @override
  String get noEncryptionForPublicRooms =>
      'Můžete aktivovat šifrování jakmile místnost přestane být veřejně dostupná.';

  @override
  String get noGoogleServicesWarning =>
      'Zdá se, že služba Firebase Cloud Messaging není ve vašem zařízení k dispozici. Chcete-li i nadále přijímat push oznámení, doporučujeme nainstalovat ntfy. Pomocí ntfy nebo jiného poskytovatele Unified Push můžete přijímat oznámení push zabezpečeným způsobem přenosu dat. Aplikaci ntfy si můžete stáhnout z obchodu PlayStore nebo z webu F-Droid.';

  @override
  String noMatrixServer(String server1, String server2) {
    return '$server1 není matrixový server, použít místo toho server $server2?';
  }

  @override
  String get shareInviteLink => 'Sdílet pozvánku';

  @override
  String get scanQrCode => 'Naskenujte QR kód';

  @override
  String get none => 'Žádný';

  @override
  String get noPasswordRecoveryDescription =>
      'Dosud jste nepřidali způsob, jak obnovit své heslo.';

  @override
  String get noPermission => 'Chybí oprávnění';

  @override
  String get noRoomsFound => 'Nebyly nalezeny žádné místnosti…';

  @override
  String get notifications => 'Oznámení';

  @override
  String numUsersTyping(int count) {
    return '$count uživatelé píší…';
  }

  @override
  String get obtainingLocation => 'Získávání polohy…';

  @override
  String get offensive => 'Urážlivé';

  @override
  String get offline => 'Odpojeni';

  @override
  String get ok => 'Ok';

  @override
  String get online => 'Připojeni';

  @override
  String get onlineKeyBackupEnabled => 'Online záloha kíčů je zapnuta';

  @override
  String get oopsPushError =>
      'Jejda! Při nastavování oznámení push došlo bohužel k chybě.';

  @override
  String get oopsSomethingWentWrong => 'Jejda, něco se pokazilo…';

  @override
  String get openAppToReadMessages => 'Otevřete aplikaci pro přečtení zpráv';

  @override
  String get openCamera => 'Otevřít fotoaparát';

  @override
  String get oneClientLoggedOut => 'Jeden z vašich klientů byl odhlášen';

  @override
  String get addAccount => 'Přidat účet';

  @override
  String get editBundlesForAccount => 'Upravit balíčky pro tento účet';

  @override
  String get addToBundle => 'Přidat do balíčku';

  @override
  String get removeFromBundle => 'Odstranit z tohoto balíčku';

  @override
  String get bundleName => 'Název balíčku';

  @override
  String get enableMultiAccounts =>
      '(BETA) Na tomto zařízení povolte více účtů';

  @override
  String get openInMaps => 'Otevřít v mapách';

  @override
  String get link => 'Odkaz';

  @override
  String get serverRequiresEmail =>
      'Tento server potřebuje k registraci ověřit vaši e -mailovou adresu.';

  @override
  String get or => 'Nebo';

  @override
  String get participant => 'Účastník';

  @override
  String get passphraseOrKey => 'heslo nebo klíč pro obnovení';

  @override
  String get password => 'Heslo';

  @override
  String get passwordForgotten => 'Zapomenuté heslo';

  @override
  String get passwordHasBeenChanged => 'Heslo bylo změněno';

  @override
  String get overview => 'Přehled';

  @override
  String get passwordRecoverySettings => 'Nastavení obnovení hesla';

  @override
  String get passwordRecovery => 'Obnova hesla';

  @override
  String get pickImage => 'Zvolit obrázek';

  @override
  String get pin => 'Připnout zprávu';

  @override
  String play(String fileName) {
    return 'Přehrát $fileName';
  }

  @override
  String get pleaseChooseAPasscode => 'Vyberte přístupový kód';

  @override
  String get pleaseClickOnLink => 'Klikněte na odkaz v e-mailu a pokračujte.';

  @override
  String get pleaseEnter4Digits =>
      'Chcete-li deaktivovat zámek aplikace, zadejte 4 číslice nebo nechte prázdné.';

  @override
  String get pleaseEnterYourPassword => 'Zadejte prosím své heslo';

  @override
  String get pleaseEnterYourPin => 'Zadejte svůj PIN';

  @override
  String get pleaseEnterYourUsername => 'Zadejte prosím své uživatelské jméno';

  @override
  String get pleaseFollowInstructionsOnWeb =>
      'Postupujte podle pokynů na webu a klepněte na další.';

  @override
  String get privacy => 'Soukromí';

  @override
  String get publicRooms => 'Veřejné místnosti';

  @override
  String get pushRules => 'Pravidla push';

  @override
  String get reason => 'Důvod';

  @override
  String get recording => 'Nahrávání';

  @override
  String redactedBy(String username) {
    return 'Smazáno uživatelem $username';
  }

  @override
  String get directChat => 'Přímá konverzace';

  @override
  String redactedByBecause(String username, String reason) {
    return 'Smazáno uživatelem $username s důvodem: \"$reason\"';
  }

  @override
  String redactedAnEvent(String username) {
    return '$username opravili událost';
  }

  @override
  String get redactMessage => 'Redigovat zprávu';

  @override
  String get register => 'Registrovat';

  @override
  String get reject => 'Zamítnout';

  @override
  String rejectedTheInvitation(String username) {
    return '$username odmítli pozvání';
  }

  @override
  String get removeAllOtherDevices => 'Odstranit všechna další zařízení';

  @override
  String removedBy(String username) {
    return 'Odstraněno $username';
  }

  @override
  String get unbanFromChat => 'Zrušit zákaz chatu';

  @override
  String get removeYourAvatar => 'Odstraňte svého avatara';

  @override
  String get replaceRoomWithNewerVersion => 'Nahradit místnost novou verzí';

  @override
  String get reply => 'Odpovědět';

  @override
  String get reportMessage => 'Nahlásit zprávu';

  @override
  String get requestPermission => 'Vyžádat oprávnění';

  @override
  String get roomHasBeenUpgraded => 'Místnost byla upgradována';

  @override
  String get roomVersion => 'Verze místnosti';

  @override
  String get saveFile => 'Uložit soubor';

  @override
  String get search => 'Hledat';

  @override
  String get security => 'Bezpečnostní';

  @override
  String get recoveryKey => 'Klíč k obnovení';

  @override
  String get recoveryKeyLost => 'Ztracený klíč k obnovení?';

  @override
  String get send => 'Odeslat';

  @override
  String get sendAMessage => 'Odeslat zprávu';

  @override
  String get sendAsText => 'Odeslat jako text';

  @override
  String get sendAudio => 'Odeslat audio';

  @override
  String get sendFile => 'Odeslat soubor';

  @override
  String get sendImage => 'Odeslat obrázek';

  @override
  String sendImages(int count) {
    return 'Poslat $count obrazků';
  }

  @override
  String get sendMessages => 'Odeslat zprávy';

  @override
  String get sendVideo => 'Odeslat video';

  @override
  String sentAFile(String username) {
    return '$username poslali soubor';
  }

  @override
  String sentAnAudio(String username) {
    return '$username poslali zvukovou nahrávku';
  }

  @override
  String sentAPicture(String username) {
    return '$username poslali obrázek';
  }

  @override
  String sentASticker(String username) {
    return '$username poslali samolepku';
  }

  @override
  String sentAVideo(String username) {
    return '$username poslali video';
  }

  @override
  String sentCallInformations(String senderName) {
    return '$senderName odeslal informace o hovoru';
  }

  @override
  String get setAsCanonicalAlias => 'Nastavit jako hlavní alias';

  @override
  String get setChatDescription => 'Nastavit popis konverzace';

  @override
  String get setStatus => 'Nastavit stav';

  @override
  String get settings => 'Nastavení';

  @override
  String get share => 'Sdílet';

  @override
  String sharedTheLocation(String username) {
    return '$username sdílel jejich polohu';
  }

  @override
  String get shareLocation => 'Sdílet polohu';

  @override
  String get showPassword => 'Zobrazit heslo';

  @override
  String get presencesToggle => 'Zobrazení stavových zpráv od jiných uživatelů';

  @override
  String get skip => 'Přeskočit';

  @override
  String get sourceCode => 'Zdrojové kódy';

  @override
  String get spaceIsPublic => 'Prostor je veřejný';

  @override
  String get spaceName => 'Název prostoru';

  @override
  String startedACall(String senderName) {
    return '$senderName zahájil hovor';
  }

  @override
  String get status => 'Stav';

  @override
  String get statusExampleMessage => 'Jak se dneska máš?';

  @override
  String get submit => 'Odeslat';

  @override
  String get synchronizingPleaseWait => 'Synchronizace ... Čekejte prosím.';

  @override
  String synchronizingPleaseWaitCounter(String percentage) {
    return ' Synchronizuji… ($percentage %)';
  }

  @override
  String get systemTheme => 'Téma systému';

  @override
  String get theyDontMatch => 'Neshodují se';

  @override
  String get theyMatch => 'Shodují se';

  @override
  String get title => 'FluffyChat';

  @override
  String get tooManyRequestsWarning =>
      'Příliš mnoho požadavků. Prosím zkuste to znovu později!';

  @override
  String get transferFromAnotherDevice => 'Přenos z jiného zařízení';

  @override
  String get tryToSendAgain => 'Zkuste odeslat znovu';

  @override
  String get unavailable => 'Nedostupní';

  @override
  String unbannedUser(String username, String targetName) {
    return '$username zrušili zákaz pro $targetName';
  }

  @override
  String get unblockDevice => 'Odblokovat zařízení';

  @override
  String get unknownDevice => 'Neznámé zařízení';

  @override
  String get unknownEncryptionAlgorithm => 'Neznámý šifrovací algoritmus';

  @override
  String unknownEvent(String type) {
    return 'Neznámá událost „$type“';
  }

  @override
  String get unmuteChat => 'Zrušit ztlumení chatu';

  @override
  String get unpin => 'Odepnout zprávu';

  @override
  String userAndOthersAreTyping(String username, int count) {
    return '$username a $count dalších píší…';
  }

  @override
  String userAndUserAreTyping(String username, String username2) {
    return '$username a $username2 píší…';
  }

  @override
  String userIsTyping(String username) {
    return '$username píše…';
  }

  @override
  String userLeftTheChat(String username) {
    return '$username opustili chat';
  }

  @override
  String get username => 'Uživatelské jméno';

  @override
  String userSentUnknownEvent(String username, String type) {
    return '$username poslali událost $type';
  }

  @override
  String get unverified => 'Neověřeno';

  @override
  String get verified => 'Ověřeno';

  @override
  String get verify => 'Ověřit';

  @override
  String get verifyStart => 'Zahájit ověření';

  @override
  String get verifySuccess => 'Ověření proběhlo úspěšně!';

  @override
  String get verifyTitle => 'Ověřuji druhý účet';

  @override
  String get videoCall => 'Video hovor';

  @override
  String get visibilityOfTheChatHistory => 'Viditelnost historie chatu';

  @override
  String get visibleForAllParticipants => 'Viditelné pro všechny účastnící se';

  @override
  String get visibleForEveryone => 'Viditelné pro všechny';

  @override
  String get voiceMessage => 'Hlasová zpráva';

  @override
  String get waitingPartnerAcceptRequest =>
      'Čeká se na potvrzení žádosti partnerem…';

  @override
  String get waitingPartnerEmoji => 'Čeká se na potvrzení emoji partnerem…';

  @override
  String get waitingPartnerNumbers => 'Čekání na partnera až přijme čísla…';

  @override
  String get warning => 'Varování!';

  @override
  String get weSentYouAnEmail => 'Zaslali jsme vám e-mail';

  @override
  String get whoCanPerformWhichAction => 'Kdo může provést jakou akci';

  @override
  String get whoIsAllowedToJoinThisGroup =>
      'Kdo se může připojit do této skupiny';

  @override
  String get whyDoYouWantToReportThis => 'Proč to chcete nahlásit?';

  @override
  String get wipeChatBackup =>
      'Chcete vymazat zálohu chatu a vytvořit nový bezpečnostní klíč?';

  @override
  String get withTheseAddressesRecoveryDescription =>
      'S těmito adresami můžete obnovit své heslo.';

  @override
  String get writeAMessage => 'Napište zprávu…';

  @override
  String get yes => 'Ano';

  @override
  String get you => 'Vy';

  @override
  String get youAreNoLongerParticipatingInThisChat =>
      'Tohoto chatu se nadále neúčastníte';

  @override
  String get youHaveBeenBannedFromThisChat =>
      'Byl vám zablokován přístup k tomuto chatu';

  @override
  String get yourPublicKey => 'Váš veřejný klíč';

  @override
  String get messageInfo => 'Informace o zprávě';

  @override
  String get time => 'Čas';

  @override
  String get messageType => 'Typ zprávy';

  @override
  String get sender => 'Odesílatel';

  @override
  String get openGallery => 'Otevřít galerii';

  @override
  String get removeFromSpace => 'Odstranit z tohoto místa';

  @override
  String get start => 'Start';

  @override
  String get pleaseEnterRecoveryKeyDescription =>
      'K odemknutí vašich starých zpráv prosím vložte váš klíč k obnovení vygenerovaný v předchozím sezení. Váš klíč k obnovení NENÍ vaše heslo.';

  @override
  String get openChat => 'Otevřete chat';

  @override
  String get markAsRead => 'Označit jako přečtené';

  @override
  String get reportUser => 'Nahlásit uživatele';

  @override
  String get dismiss => 'Zavrhnout';

  @override
  String reactedWith(String sender, String reaction) {
    return '$sender reagoval s $reaction';
  }

  @override
  String get pinMessage => 'Připnout zprávu do místnosti';

  @override
  String get confirmEventUnpin => 'Opravdu chcete událost trvale odepnout?';

  @override
  String get emojis => 'Emojis';

  @override
  String get placeCall => 'Zavolejte';

  @override
  String get voiceCall => 'Hlasový hovor';

  @override
  String get unsupportedAndroidVersion => 'Nepodporovaná verze Androidu';

  @override
  String get unsupportedAndroidVersionLong =>
      'Tato funkce vyžaduje novější verzi Android. Zkontrolujte prosím aktualizace nebo podporu Lineage OS.';

  @override
  String get videoCallsBetaWarning =>
      'Upozorňujeme, že videohovory jsou aktuálně ve verzi beta. Nemusí fungovat podle očekávání nebo fungovat vůbec na všech platformách.';

  @override
  String get experimentalVideoCalls => 'Experimentální videohovory';

  @override
  String get youRejectedTheInvitation => 'Odmítli jste pozvání';

  @override
  String get youJoinedTheChat => 'Připojili jste se k chatu';

  @override
  String get youAcceptedTheInvitation => 'Přijal jsi pozvání';

  @override
  String youBannedUser(String user) {
    return 'Zakázali jste uživatele $user';
  }

  @override
  String youHaveWithdrawnTheInvitationFor(String user) {
    return 'Stáhli jste pozvánku pro uživatele $user';
  }

  @override
  String youInvitedBy(String user) {
    return 'Byli jste pozváni uživatelem $user';
  }

  @override
  String invitedBy(String user) {
    return '📩 Pozván $user';
  }

  @override
  String youInvitedUser(String user) {
    return 'Pozvali jste uživatele $user';
  }

  @override
  String youKicked(String user) {
    return 'Vykopli jste uživatele $user';
  }

  @override
  String youKickedAndBanned(String user) {
    return 'Vykopli jste a zakázali jste uživatele $user';
  }

  @override
  String youUnbannedUser(String user) {
    return 'Zrušili jste zákaz uživateli $user';
  }

  @override
  String hasKnocked(String user) {
    return '🚪 $user zaklepal';
  }

  @override
  String get usersMustKnock => 'Uživatelé musí zaklepat';

  @override
  String get noOneCanJoin => 'Nikdo se nemůže připojit';

  @override
  String get knock => 'Zaklepat';

  @override
  String get users => 'Uživatelé';

  @override
  String get unlockOldMessages => 'Odemknout staré zprávy';

  @override
  String get storeInSecureStorageDescription =>
      'Klíč k obnovení uložte v zabezpečeném úložišti tohoto zařízení.';

  @override
  String get saveKeyManuallyDescription =>
      'Uložte tento klíč manuálně pomocí systémového dialogu sdílení nebo zkopírováním do schránky.';

  @override
  String get storeInAndroidKeystore => 'Uložit v Android KeyStore';

  @override
  String get storeInAppleKeyChain => 'Uložit v Apple KeyChain';

  @override
  String get storeSecurlyOnThisDevice => 'Uložit bezpečně na tomto zařízení';

  @override
  String countFiles(int count) {
    return '$count souborů';
  }

  @override
  String get user => 'Uživatel';

  @override
  String get custom => 'Vlastní';

  @override
  String get foregroundServiceRunning =>
      'Toto oznámení se zobrazuje když běží služba na pozadí.';

  @override
  String get screenSharingTitle => 'sdílení obrazovky';

  @override
  String get screenSharingDetail => 'Sdílíte svou obrazovku přes FluffyChat';

  @override
  String get whyIsThisMessageEncrypted => 'Proč nelze přečíst tuto zprávu?';

  @override
  String get noKeyForThisMessage =>
      'K tomuto může dojít, pokud byla zpráva odeslána před přihlášením k účtu v tomto zařízení.\n\nJe také možné, že odesílatel zablokoval vaše zařízení nebo se něco pokazilo s internetovým připojením.\n\nJste schopni si zprávu přečíst v jiné relaci? Pak můžete zprávu přenést z něj! Přejděte do Nastavení > Zařízení a zkontrolujte, zda se Vaše zařízení vzájemně ověřila. Při příštím otevření místnosti, kdy budou obě relace v popředí, se klíče přenesou automaticky.\n\nNechcete klíče ztratit při odhlašování nebo přepínání zařízení? Ujistěte se, že jste v nastaveních povolili zálohování konverzací.';

  @override
  String get newGroup => 'Nová skupina';

  @override
  String get newSpace => 'Nový prostor';

  @override
  String get allSpaces => 'Všechny prostory';

  @override
  String get hidePresences => 'Skrýt seznam událostí?';

  @override
  String get doNotShowAgain => 'Nezobrazovat znovu';

  @override
  String wasDirectChatDisplayName(String oldDisplayName) {
    return 'Prázdná konverzace (dříve $oldDisplayName)';
  }

  @override
  String get newSpaceDescription =>
      'Prostory umožňují organizovat Vaše konverzace a vytvářet soukromé nebo veřejné komunity.';

  @override
  String get encryptThisChat => 'Zašifrovat tuto konverzaci';

  @override
  String get disableEncryptionWarning =>
      'Z bezpečnostních důvodů nemůžete vypnout šifrování v chatu, kde již bylo dříve zapnuto.';

  @override
  String get sorryThatsNotPossible => 'Omlouváme se… to není možné';

  @override
  String get deviceKeys => 'Klíče zařízení:';

  @override
  String get reopenChat => 'Znovu otevřít konverzaci';

  @override
  String get noBackupWarning =>
      'Pozor! Bez povolení zálohování konverzací ztratíte přístup k zašifrovaným zprávám. Důrazně doporučujeme zálohování konverzací před odhlášením povolit.';

  @override
  String get noOtherDevicesFound => 'Žádná ostatní zařízení nebyla nalezena';

  @override
  String fileIsTooBigForServer(String max) {
    return 'Neodesláno! Server povoluje maximálně $max příloh.';
  }

  @override
  String fileHasBeenSavedAt(String path) {
    return 'Soubor uložen do $path';
  }

  @override
  String get jumpToLastReadMessage => 'Skočit na naposledy přečtenou zprávu';

  @override
  String get readUpToHere => 'Čtěte až sem';

  @override
  String get jump => 'Skočit';

  @override
  String get openLinkInBrowser => 'Otevřít odkaz v prohlížeči';

  @override
  String get reportErrorDescription =>
      '😭 Ale ne, něco se porouchalo. Pokud chcete, můžete tento bug nahlásit vývojářům.';

  @override
  String get report => 'hlášení';

  @override
  String get setColorTheme => 'Nastavit barvy:';

  @override
  String get invite => 'Pozvánka';

  @override
  String get inviteGroupChat => '📨 Skupinová pozvánka';

  @override
  String get invalidInput => 'Nevhodný vstup!';

  @override
  String wrongPinEntered(int seconds) {
    return 'Nespravný PIN! Zkuste to znovu za $seconds vteřin...';
  }

  @override
  String get pleaseEnterANumber => 'Prosím, zadejte číslo větší než 0';

  @override
  String get archiveRoomDescription =>
      'Konverzace bude přesunuta do archivu. Ostatní uživatelé uvidí, že jste konverzaci opustil/a.';

  @override
  String get roomUpgradeDescription =>
      'Konverzace bude vytvořena znovu s novou verzí místnosti. Všem účastníkům bude oznámeno, že se musí přesunout do nové konverzace. Více o verzích místností se dočtete na https://spec.matrix.org/latest/';

  @override
  String get removeDevicesDescription =>
      'Budete odhlášen/a z tohoto zařízení a nebudete nadále moci přijímat zprávy.';

  @override
  String get banUserDescription =>
      'Uživatel bude vyhozen z konverzace a nebude se moci znovu připojit dokud nebude odblokován.';

  @override
  String get unbanUserDescription =>
      'Uživatel se bude moci vrátit do konverzace pokud se o to pokusí.';

  @override
  String get kickUserDescription =>
      'Uživatel bude vyhozen z chatu, ale nikoliv zabanován. V případě veřejných chatů to znamená, že se kdykoliv může znovu připojit.';

  @override
  String get makeAdminDescription =>
      'Jestliže tohoto uživatele povýšíte na administrátora, nebude tak moci odčinit, protože bude mít stejná oprávnění jako Vy.';

  @override
  String get pushNotificationsNotAvailable => 'Notifikace nejsou dostupné';

  @override
  String get learnMore => 'Dozvědět se více';

  @override
  String get yourGlobalUserIdIs =>
      'Vaše globální uživatelské ID (user-ID) je: ';

  @override
  String noUsersFoundWithQuery(String query) {
    return 'Nepodařilo se najít uživatele \"$query\". Zkontrolujte, prosím, že jste se nepřepsali.';
  }

  @override
  String get knocking => 'Klepání';

  @override
  String chatCanBeDiscoveredViaSearchOnServer(String server) {
    return 'Konverzaci naleznete vyhledáváním na $server';
  }

  @override
  String get searchChatsRooms => 'Vyhledat #konverzace, @uživatele...';

  @override
  String get nothingFound => 'Nic nenalezeno...';

  @override
  String get groupName => 'Název skupiny';

  @override
  String get createGroupAndInviteUsers => 'Vytvořit skupinu a pozvat uživatele';

  @override
  String get groupCanBeFoundViaSearch => 'Skupinu naleznete vyhledávním';

  @override
  String get wrongRecoveryKey =>
      'Jejda... toto nejspíš není správný obnovovací klíč.';

  @override
  String get commandHint_sendraw => 'Odeslat soubor json';

  @override
  String get databaseMigrationTitle => 'Databáze je optimalizována';

  @override
  String get databaseMigrationBody => 'Vydržte prosím. Bude to chvilku trvat.';

  @override
  String get leaveEmptyToClearStatus => 'Zanechte prázdné pro smazání statusu.';

  @override
  String get select => 'Vybrat';

  @override
  String get searchForUsers => 'Vyhledat @uživatele...';

  @override
  String get pleaseEnterYourCurrentPassword =>
      'Prosím, zadejte Vaše současné heslo';

  @override
  String get newPassword => 'Nové heslo';

  @override
  String get pleaseChooseAStrongPassword => 'Prosím, zvolte si silné heslo';

  @override
  String get passwordsDoNotMatch => 'Hesla se neshodují';

  @override
  String get passwordIsWrong => 'Zadané heslo je nesprávné';

  @override
  String get publicChatAddresses => 'Adresy veřejných konverzací';

  @override
  String get createNewAddress => 'Vytvořit novou adresu';

  @override
  String get joinSpace => 'Připojit se do prostoru';

  @override
  String get publicSpaces => 'Veřejné prostory';

  @override
  String get addChatOrSubSpace => 'Add chat or sub space';

  @override
  String get thisDevice => 'Toto zařzení:';

  @override
  String get initAppError => 'Při načítání nastala chyba';

  @override
  String searchIn(String chat) {
    return 'Search in chat \"$chat\"...';
  }

  @override
  String get searchMore => 'Search more...';

  @override
  String get gallery => 'Galerie';

  @override
  String get files => 'Soubory';

  @override
  String sessionLostBody(String url, String error) {
    return 'Vaše relace byla ztracena. Nahlaste, prosím, tuto chybu vývojářům na adrese $url. Chybová hláška je: $error';
  }

  @override
  String restoreSessionBody(String url, String error) {
    return 'Aplikace se pokusí obnovit vaši relaci ze zálohy. Nahlaste, prosím, tuto chybu vývojářům na adrese $url. Chybová hláška je: $error';
  }

  @override
  String get sendReadReceipts => 'Posílat potvrzení o přečtení';

  @override
  String get sendTypingNotificationsDescription =>
      'Ostatní účastníci konverzace uvidí, že píšete novou zprávu.';

  @override
  String get sendReadReceiptsDescription =>
      'Ostatní účastníci konverzace uvidí, že jste si přečetl/a jejich zprávu.';

  @override
  String get formattedMessages => 'Formátované zprávy';

  @override
  String get formattedMessagesDescription =>
      'Zobrazovat formátovaný obsah zpráv, jako například tučný text pomocí markdownu.';

  @override
  String get verifyOtherUser => '🔐 Ověřit jiného uživatele';

  @override
  String get verifyOtherUserDescription =>
      'Když ověříte jiného uživatele, můžete si být jistí, že víte, s kým si píšete. 💪\n\nJakmile začnete s ověřením, vy a druhý uživatel uvidíte v aplikaci vyskakovací okno. V něm uvidíte sérii emodži nebo čísel, které musíte společně porovnat.\n\nNejjednodušší je setkat se osobně nebo si udělat videohovor. 👭';

  @override
  String get verifyOtherDevice => '🔐 Ověřit jiné zařízení';

  @override
  String get verifyOtherDeviceDescription =>
      'Když ověříte jiné zařízení, tato zařízení si mohou vyměnit klíče, čímž zvýšíte vaše zabezpečení. 💪 Jakmile začnete s ověřením, v aplikaci na obou zařízeních se objeví vyskakovací okno. V něm uvidíte sérii emodži nebo čísel, které musíte na zařízeních porovnat mezi sebou. Než začnete s ověřováním, je fajn mít obě zařízení po ruce. 🤳';

  @override
  String acceptedKeyVerification(String sender) {
    return '$sender přijal/a ověření klíče';
  }

  @override
  String canceledKeyVerification(String sender) {
    return '$sender zrušil ověření klíče';
  }

  @override
  String completedKeyVerification(String sender) {
    return '$sender dokončil ověření klíče';
  }

  @override
  String isReadyForKeyVerification(String sender) {
    return '$sender je připraven/a na ověření klíče';
  }

  @override
  String requestedKeyVerification(String sender) {
    return '$sender požádal/a o ověření klíče';
  }

  @override
  String startedKeyVerification(String sender) {
    return '$sender začal/a s ověřením klíče';
  }

  @override
  String get transparent => 'Transparent';

  @override
  String get incomingMessages => 'Incoming messages';

  @override
  String get stickers => 'Stickers';

  @override
  String get discover => 'Discover';

  @override
  String get commandHint_ignore => 'Ignore the given matrix ID';

  @override
  String get commandHint_unignore => 'Unignore the given matrix ID';

  @override
  String unreadChatsInApp(String appname, String unread) {
    return '$appname: $unread unread chats';
  }

  @override
  String get noDatabaseEncryption =>
      'Database encryption is not supported on this platform';

  @override
  String thereAreCountUsersBlocked(Object count) {
    return 'Right now there are $count users blocked.';
  }

  @override
  String get restricted => 'Restricted';

  @override
  String get knockRestricted => 'Knock restricted';

  @override
  String goToSpace(Object space) {
    return 'Go to space: $space';
  }

  @override
  String get markAsUnread => 'Mark as unread';

  @override
  String userLevel(int level) {
    return '$level - User';
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
  String get changeGeneralChatSettings => 'Change general chat settings';

  @override
  String get inviteOtherUsers => 'Invite other users to this chat';

  @override
  String get changeTheChatPermissions => 'Change the chat permissions';

  @override
  String get changeTheVisibilityOfChatHistory =>
      'Change the visibility of the chat history';

  @override
  String get changeTheCanonicalRoomAlias =>
      'Change the main public chat address';

  @override
  String get sendRoomNotifications => 'Send a @room notifications';

  @override
  String get changeTheDescriptionOfTheGroup =>
      'Change the description of the chat';

  @override
  String get chatPermissionsDescription =>
      'Define which power level is necessary for certain actions in this chat. The power levels 0, 50 and 100 are usually representing users, moderators and admins, but any gradation is possible.';

  @override
  String updateInstalled(String version) {
    return '🎉 Update $version installed!';
  }

  @override
  String get changelog => 'Changelog';

  @override
  String get sendCanceled => 'Sending canceled';

  @override
  String get loginWithMatrixId => 'Login with Matrix-ID';

  @override
  String get doesNotSeemToBeAValidHomeserver =>
      'Doesn\'t seem to be a compatible homeserver. Wrong URL?';

  @override
  String get calculatingFileSize => 'Calculating file size...';

  @override
  String get prepareSendingAttachment => 'Připravuji odeslání přílohy...';

  @override
  String get sendingAttachment => 'Posílám přílohu...';

  @override
  String get generatingVideoThumbnail => 'Vytvářím náhledový obrázek videa...';

  @override
  String get compressVideo => 'Komprimuji video...';

  @override
  String sendingAttachmentCountOfCount(int index, int length) {
    return 'Odesílám přílohu $index z $length...';
  }

  @override
  String serverLimitReached(int seconds) {
    return 'Dosažen limit serveru! Čekám $seconds sekund...';
  }

  @override
  String get oneOfYourDevicesIsNotVerified =>
      'Jedno z vašich zařízení není ověřeno';

  @override
  String get noticeChatBackupDeviceVerification =>
      'Note: When you connect all your devices to the chat backup, they are automatically verified.';

  @override
  String get continueText => 'Pokračovat';

  @override
  String get welcomeText =>
      'Ahoj, ahoj 👋 Tohle je FluffyChat. Můžete se přihlásit k jakémukoliv domácímu serveru, který je kompatibilní s https://matrix.org, a začít s kýmkoliv chatovat. Je to obří decentralizovaná chatovací síť!';

  @override
  String get blur => 'Blur:';

  @override
  String get opacity => 'Opacity:';

  @override
  String get setWallpaper => 'Nastavit tapetu';

  @override
  String get manageAccount => 'Spravovat účet';

  @override
  String get noContactInformationProvided =>
      'Server neposkytl žádné platné kontaktní informace';

  @override
  String get contactServerAdmin => 'Kontaktovat administrátora serveru';

  @override
  String get contactServerSecurity => 'Contact server security';

  @override
  String get supportPage => 'Podpora';

  @override
  String get serverInformation => 'Informace o serveru:';

  @override
  String get name => 'Název';

  @override
  String get version => 'Verze';

  @override
  String get website => 'Webová stránka';

  @override
  String get compress => 'Komprimovat';

  @override
  String get boldText => 'Tučný text';

  @override
  String get italicText => 'Kurzíva';

  @override
  String get strikeThrough => 'Přeškrtnutý text';

  @override
  String get pleaseFillOut => 'Prosím vyplňte';

  @override
  String get invalidUrl => 'Neplatná URL adresa';

  @override
  String get addLink => 'Přidat odkaz';

  @override
  String get unableToJoinChat =>
      'Nepodařilo se připojit ke konverzaci. Je možné, že druhá strana ji už uzavřela.';

  @override
  String get previous => 'Předchozí';

  @override
  String get otherPartyNotLoggedIn =>
      'Druhá strana aktuálně není přihlášená, takže nemůže přijímat zprávy!';

  @override
  String appWantsToUseForLogin(String server) {
    return 'Použít \'$server\' k přihlášení';
  }

  @override
  String get appWantsToUseForLoginDescription =>
      'Pokračováním povolíte aplikaci a webové stránce sdílet mezi sebou informace o vás.';

  @override
  String get open => 'Otevřít';

  @override
  String get waitingForServer => 'Čekám na server...';

  @override
  String get newChatRequest => '📩 Nová žádost o konverzaci';

  @override
  String get contentNotificationSettings => 'Content notification settings';

  @override
  String get generalNotificationSettings => 'Obecné nastavení oznámení';

  @override
  String get roomNotificationSettings => 'Nastavení oznámení pro místnost';

  @override
  String get userSpecificNotificationSettings =>
      'Nastavení oznámení pro uživatele';

  @override
  String get otherNotificationSettings => 'Ostatní nastavení oznámení';

  @override
  String get notificationRuleContainsUserName => 'Obsahuje uživatelské jméno';

  @override
  String get notificationRuleContainsUserNameDescription =>
      'Pošle uživateli oznámení, když zpráva obsahuje jeho uživatelské jméno.';

  @override
  String get notificationRuleMaster => 'Ztlumit veškerá oznámení';

  @override
  String get notificationRuleMasterDescription =>
      'Přepíše veškerá ostatní pravidla a zakáže všechna oznámení.';

  @override
  String get notificationRuleSuppressNotices => 'Ztlumit automatizované zprávy';

  @override
  String get notificationRuleSuppressNoticesDescription =>
      'Ztlumí oznámení od automatizovaných klientů, jako jsou např. roboti.';

  @override
  String get notificationRuleInviteForMe => 'Pozvánka adresovaná mně';

  @override
  String get notificationRuleInviteForMeDescription =>
      'Pošle uživateli oznámení, když je pozván do místnosti.';

  @override
  String get notificationRuleMemberEvent => 'Události týkající se členství';

  @override
  String get notificationRuleMemberEventDescription =>
      'Ztlumí oznámení týkající se veškerých událostí souvisejících s členstvím.';

  @override
  String get notificationRuleIsUserMention => 'Zmínka uživatele';

  @override
  String get notificationRuleIsUserMentionDescription =>
      'Pošle uživateli oznámení, když je někdo přímo zmíní ve zprávě.';

  @override
  String get notificationRuleContainsDisplayName => 'Obsahuje přezdívku';

  @override
  String get notificationRuleContainsDisplayNameDescription =>
      'Pošle uživateli oznámení, když zpráva obsahuje jejich přezdívku.';

  @override
  String get notificationRuleIsRoomMention => 'Označení místnosti';

  @override
  String get notificationRuleIsRoomMentionDescription =>
      'Pošle uživateli oznámení, když je označena celá místnost.';

  @override
  String get notificationRuleRoomnotif => 'Označení místnosti';

  @override
  String get notificationRuleRoomnotifDescription =>
      'Pošle uživateli oznámení, když zpráva obsahuje \'@room\'.';

  @override
  String get notificationRuleTombstone => 'Náhrobek';

  @override
  String get notificationRuleTombstoneDescription =>
      'Pošle uživateli oznámení ohledně zpráv o deaktivaci místnosti.';

  @override
  String get notificationRuleReaction => 'Reakce';

  @override
  String get notificationRuleReactionDescription =>
      'Ztlumí oznámení o reakcích.';

  @override
  String get notificationRuleRoomServerAcl => 'Room Server ACL';

  @override
  String get notificationRuleRoomServerAclDescription =>
      'Suppresses notifications for room server access control lists (ACL).';

  @override
  String get notificationRuleSuppressEdits => 'Ztlumit úpravy';

  @override
  String get notificationRuleSuppressEditsDescription =>
      'Ztlumí notifikace týkající se upravených zpráv.';

  @override
  String get notificationRuleCall => 'Hovor';

  @override
  String get notificationRuleCallDescription =>
      'Pošle uživateli oznámení ohledně hovorů.';

  @override
  String get notificationRuleEncryptedRoomOneToOne =>
      'Encrypted Room One-to-One';

  @override
  String get notificationRuleEncryptedRoomOneToOneDescription =>
      'Notifies the user about messages in encrypted one-to-one rooms.';

  @override
  String get notificationRuleRoomOneToOne => 'Room One-to-One';

  @override
  String get notificationRuleRoomOneToOneDescription =>
      'Notifies the user about messages in one-to-one rooms.';

  @override
  String get notificationRuleMessage => 'Message';

  @override
  String get notificationRuleMessageDescription =>
      'Notifies the user about general messages.';

  @override
  String get notificationRuleEncrypted => 'Encrypted';

  @override
  String get notificationRuleEncryptedDescription =>
      'Notifies the user about messages in encrypted rooms.';

  @override
  String get notificationRuleJitsi => 'Jitsi';

  @override
  String get notificationRuleJitsiDescription =>
      'Notifies the user about Jitsi widget events.';

  @override
  String get notificationRuleServerAcl => 'Suppress Server ACL Events';

  @override
  String get notificationRuleServerAclDescription =>
      'Suppresses notifications for Server ACL events.';

  @override
  String unknownPushRule(String rule) {
    return 'Unknown push rule \'$rule\'';
  }

  @override
  String sentVoiceMessage(String sender, String duration) {
    return '🎙️ $duration - Hlasová zpráva od $sender';
  }

  @override
  String get deletePushRuleCanNotBeUndone =>
      'Odstranění tohoto nastavení oznámení nelze vzít zpět.';

  @override
  String get more => 'Více';

  @override
  String get shareKeysWith => 'Sdílet klíče s...';

  @override
  String get shareKeysWithDescription =>
      'Která zařízení mají být označena jako důvěryhodná, aby mohla současně číst vaše zprávy v šifrovaných konverzacích?';

  @override
  String get allDevices => 'Všechna zařízení';

  @override
  String get crossVerifiedDevicesIfEnabled =>
      'Křížově ověřená zařízení, pokud je povoleno';

  @override
  String get crossVerifiedDevices => 'Křížově ověřená zařízení';

  @override
  String get verifiedDevicesOnly => 'Pouze ověřená zařízení';

  @override
  String get takeAPhoto => 'Take a photo';

  @override
  String get recordAVideo => 'Nahrát video';

  @override
  String get optionalMessage => '(Volitelné) zpráva...';

  @override
  String get notSupportedOnThisDevice => 'Není na tomto zařízení podporováno';

  @override
  String get enterNewChat => 'Enter new chat';

  @override
  String get approve => 'Schválit';

  @override
  String get youHaveKnocked => 'Zaklepali jste';

  @override
  String get pleaseWaitUntilInvited =>
      'Nyní musíte počkat, až vás nějaký člen této místnosti pozve dovnitř.';

  @override
  String get commandHint_logout => 'Odhlásit se z aktuálního zařízení';

  @override
  String get commandHint_logoutall => 'Odhlásit se ze všech aktivních zařízení';

  @override
  String get displayNavigationRail => 'Zobrazit navigační lištu na mobilu';

  @override
  String get customReaction => 'Vlastní reakce';

  @override
  String get moreEvents => 'Více událostí';

  @override
  String get declineInvitation => 'Odmítnout pozvánku';

  @override
  String get noMessagesYet => 'Zatím tu nejsou žádné zprávy';

  @override
  String get longPressToRecordVoiceMessage =>
      'Podržte pro nahrání hlasové zprávy.';

  @override
  String get pause => 'Pozastavit';

  @override
  String get resume => 'Pokračovat';

  @override
  String get removeFromSpaceDescription =>
      'Tato konverzace bude odstraněna z tohoto prostoru, stále však bude dostupná ve vašem seznamu konverzací.';

  @override
  String countChats(int chats) {
    return '$chats konverzací';
  }

  @override
  String spaceMemberOf(String spaces) {
    return 'Členové prostoru $spaces';
  }

  @override
  String spaceMemberOfCanKnock(String spaces) {
    return 'Členové prostoru $spaces mohou zaklepat';
  }

  @override
  String startedAPoll(String username) {
    return '$username spustil/a hlasování.';
  }

  @override
  String get poll => 'Hlasování';

  @override
  String get startPoll => 'Spustit hlasování';

  @override
  String get endPoll => 'Ukončit hlasování';

  @override
  String get answersVisible => 'Odpovědi budou viditelné';

  @override
  String get pollQuestion => 'Předmět hlasování';

  @override
  String get answerOption => 'Možnost';

  @override
  String get addAnswerOption => 'Přidat možnost';

  @override
  String get allowMultipleAnswers => 'Povolit více odpovědí';

  @override
  String get pollHasBeenEnded => 'Hlasování skončilo';

  @override
  String countVotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count votes',
      one: 'One vote',
    );
    return '$_temp0';
  }

  @override
  String get answersWillBeVisibleWhenPollHasEnded =>
      'Odpovědi budou viditelné jakmile hlasování skončí';

  @override
  String get replyInThread => 'Odpovědět ve vlákně';

  @override
  String countReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count replies',
      one: 'One reply',
    );
    return '$_temp0';
  }

  @override
  String get thread => 'Vlákno';

  @override
  String get backToMainChat => 'Zpátky do hlavního chatu';

  @override
  String get saveChanges => 'Uložit změny';

  @override
  String get createSticker => 'Vytvořit nálepku nebo emodži';

  @override
  String get useAsSticker => 'Použít jako nálepku';

  @override
  String get useAsEmoji => 'Použít jako emodži';

  @override
  String get stickerPackNameAlreadyExists =>
      'Balíček nálepek s tímto názvem již existuje';

  @override
  String get newStickerPack => 'Nový balíček nálepek';

  @override
  String get stickerPackName => 'Název balíčku nálepek';

  @override
  String get attribution => 'Zdroj';

  @override
  String get skipChatBackup => 'Přeskočit zálohu konverzací';

  @override
  String get skipChatBackupWarning =>
      'Jste si jistí? Pokud nepovolíte zálohu konverzací, můžete ztratit přístup ke svým zprávám v případě změny zařízení.';

  @override
  String get loadingMessages => 'Načítám zprávy';

  @override
  String get setupChatBackup => 'Nastavit zálohování konverzací';

  @override
  String get noMoreResultsFound => 'Žádné další výsledky nenalezeny';

  @override
  String chatSearchedUntil(String time) {
    return 'Konverzace prohledána do $time';
  }

  @override
  String get federationBaseUrl => 'Základní URL pro federování';

  @override
  String get clientWellKnownInformation => 'Client-Well-Known Information:';

  @override
  String get baseUrl => 'Základní URL';

  @override
  String get identityServer => 'Identity Server:';

  @override
  String versionWithNumber(String version) {
    return 'Verze: $version';
  }

  @override
  String get logs => 'Záznamy';

  @override
  String get advancedConfigs => 'Pokročilá nastavení';

  @override
  String get advancedConfigurations => 'Advanced configurations';

  @override
  String get signIn => 'Přihlásit se';

  @override
  String get createNewAccount => 'Vytvořit nový účet';

  @override
  String get signUpGreeting =>
      'FluffyChat je decentralizovaný! Vyberte server, kde si chcete vytvořit účet, a jdeme na věc!';

  @override
  String get signInGreeting =>
      'Již máte účet na Matrixu? Vítejte zpět! Vyberte svůj domácí server a přihlaste se.';

  @override
  String get appIntro =>
      'S FluffyChatem můžeme chatovat s přáteli. Je to decentralizovaná chatovací aplikace pro [matrix]! Zjistěte více na https://matrix.org nebo se zaregistrujte.';

  @override
  String get theProcessWasCanceled => 'Proces byl zrušen.';

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
