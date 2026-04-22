// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Kabyle (`kab`).
class L10nKab extends L10n {
  L10nKab([String locale = 'kab']) : super(locale);

  @override
  String get alwaysUse24HourFormat => 'false';

  @override
  String get repeatPassword => 'Ales awal n uɛeddi';

  @override
  String get notAnImage => 'Mačči d afaylu n tugna.';

  @override
  String get ignoreUser => 'Zgel aseqdac';

  @override
  String get remove => 'Kkes';

  @override
  String get importNow => 'Kter tura';

  @override
  String get importEmojis => 'Kter imujiten';

  @override
  String get importFromZipFile => 'Kter seg ufaylu .zip';

  @override
  String get exportEmotePack => 'Sifeḍ akemmus n Izamulen uḥulfu am .zip';

  @override
  String get replace => 'Semselsi';

  @override
  String get about => 'Ɣef';

  @override
  String aboutHomeserver(String homeserver) {
    return 'Ɣef $homeserver';
  }

  @override
  String get accept => 'Qbel';

  @override
  String acceptedTheInvitation(String username) {
    return '👍 $username yeqbel tinubga';
  }

  @override
  String get account => 'Amiḍan';

  @override
  String activatedEndToEndEncryption(String username) {
    return '🔐 $username irmed awgelhen seg yixef ɣer yixef';
  }

  @override
  String get addEmail => 'Rnu imayl';

  @override
  String get confirmMatrixId =>
      'Ttxil-ik·im, sentem asulay-ik·im n Matriks akken ad tekkseḍ amiḍan-ik·im.';

  @override
  String supposedMxid(String mxid) {
    return 'A win yufan, ad yili d $mxid';
  }

  @override
  String get addToSpace => 'Rnu ɣer tallunt';

  @override
  String get admin => 'Anedbal';

  @override
  String get alias => 'Tazaẓlut';

  @override
  String get all => 'Meṛṛa';

  @override
  String get allChats => 'Meṛṛa idiwenniyen';

  @override
  String get commandHint_roomupgrade =>
      'Sali aswir n txxamt-agi ɣer lqem n texxamt i d-yettunefken';

  @override
  String get commandHint_googly => 'Send some googly eyes';

  @override
  String get commandHint_cuddle => 'Send a cuddle';

  @override
  String get commandHint_hug => 'Send a hug';

  @override
  String googlyEyesContent(String senderName) {
    return '$senderName sends you googly eyes';
  }

  @override
  String cuddleContent(String senderName) {
    return '$senderName cuddles you';
  }

  @override
  String hugContent(String senderName) {
    return '$senderName hugs you';
  }

  @override
  String answeredTheCall(String senderName) {
    return '$senderName yerra-d i usiwel';
  }

  @override
  String get anyoneCanJoin => 'Yal yiwen yezmer ad yettekki';

  @override
  String get appLock => 'Asekkeṛ n usnas';

  @override
  String get appLockDescription =>
      'Sekkeṛ asnas ticki ur tseqdaceḍ ara s tengalt n pin';

  @override
  String get archive => 'Aɣbaṛ';

  @override
  String get areGuestsAllowedToJoin =>
      'Iseqdacen inebgiwen ttusirgen ad ttekkin';

  @override
  String get areYouSure => 'Tetḥeqqeḍ?';

  @override
  String get areYouSureYouWantToLogout => 'D tidet tebɣiḍ ad teffɣeḍ?';

  @override
  String get askSSSSSign =>
      'Iwakken ad teszmeleḍ amdan-nniḍen, ttxil-k·m sekcem tafyirt-ik·im n uḥraz s wudem aɣelsan neɣ tasarut n tririt.';

  @override
  String askVerificationRequest(String username) {
    return 'Qbel asuter-agi n usenqed seg $username?';
  }

  @override
  String get autoplayImages =>
      'Automatically play animated stickers and emotes';

  @override
  String badServerLoginTypesException(
    String serverVersions,
    String supportedVersions,
    Object suportedVersions,
  ) {
    return 'Aqeddac agejdan issefrak anawen n tuqqna:\n$serverVersions\nMaca asnas-agi issefrak kan:\n$supportedVersions';
  }

  @override
  String get sendTypingNotifications => 'Azen alɣu ttaruɣ';

  @override
  String get swipeRightToLeftToReply =>
      'Zuɣer seg uyeffus ɣer uzelmaḍ akken ad d-terreḍ';

  @override
  String get sendOnEnter => 'Azen ɣef Kcem';

  @override
  String get noMoreChatsFound => 'Ulac ugar n idiwenniyen yettwafen…';

  @override
  String get noChatsFoundHere =>
      'Ur d-nufi ula d yiwen n udiwenni da. Bdu adiwenni akked yiwen s useqdec n tqeffalt ukessar-a. ⤵️';

  @override
  String get unread => 'Ur yettwaɣri ara';

  @override
  String get space => 'Tallunt';

  @override
  String get spaces => 'Tallunin';

  @override
  String get banFromChat => 'Gdel seg adiwenni';

  @override
  String get banned => 'Yettwagdel';

  @override
  String bannedUser(String username, String targetName) {
    return '$username yegdel $targetName';
  }

  @override
  String get blockDevice => 'Sewḥel ibenk';

  @override
  String get blocked => 'Yettusewḥel';

  @override
  String get cancel => 'Sefsex';

  @override
  String cantOpenUri(String uri) {
    return 'Ur yezmir ara ad yeldi URl $uri';
  }

  @override
  String get changeDeviceName => 'Snifel isem n yibenk';

  @override
  String changedTheChatAvatar(String username) {
    return '$username yesnifel avaṭar n udiwenni';
  }

  @override
  String changedTheChatDescription(Object username) {
    return '$username yesnifel aglam n udiwenni';
  }

  @override
  String changedTheChatDescriptionTo(String username, String description) {
    return '$username yesnifel aglam n udiwenni ɣer: \'$description\'';
  }

  @override
  String changedTheChatName(Object username) {
    return '$username yesnifel isem n udiwenni';
  }

  @override
  String changedTheChatNameTo(String username, String chatname) {
    return '$username yesnifel isem n udiwenni ɣer: \'$chatname\'';
  }

  @override
  String changedTheChatPermissions(String username) {
    return '$username yesnifel tisirag n udiwenni';
  }

  @override
  String changedTheDisplaynameTo(String username, String displayname) {
    return '$username yesnifel tisirag n udiwenni ɣer: \'$displayname\'';
  }

  @override
  String changedTheGuestAccessRules(String username) {
    return '$username changed the guest access rules';
  }

  @override
  String changedTheGuestAccessRulesTo(String username, String rules) {
    return '$username changed the guest access rules to: $rules';
  }

  @override
  String changedTheHistoryVisibility(String username) {
    return '$username changed the history visibility';
  }

  @override
  String changedTheHistoryVisibilityTo(String username, String rules) {
    return '$username changed the history visibility to: $rules';
  }

  @override
  String changedTheJoinRules(String username) {
    return '$username changed the join rules';
  }

  @override
  String changedTheJoinRulesTo(String username, String joinRules) {
    return '$username changed the join rules to: $joinRules';
  }

  @override
  String changedTheProfileAvatar(String username) {
    return '$username changed their avatar';
  }

  @override
  String changedTheRoomAliases(String username) {
    return '$username changed the room aliases';
  }

  @override
  String changedTheRoomInvitationLink(String username) {
    return '$username changed the invitation link';
  }

  @override
  String get changePassword => 'Asnifel n wawal n uɛeddi';

  @override
  String get changeTheHomeserver => 'Change the homeserver';

  @override
  String get changeTheme => 'Change your style';

  @override
  String get changeTheNameOfTheGroup => 'Change the name of the group';

  @override
  String get changeYourAvatar => 'Change your avatar';

  @override
  String get channelCorruptedDecryptError =>
      'The encryption has been corrupted';

  @override
  String get chat => 'Adiwenni';

  @override
  String get yourChatBackupHasBeenSetUp => 'Aḥraz n udiwenni-ik·im yettusbadu.';

  @override
  String get chatBackup => 'Aḥraz n udiwenni';

  @override
  String get chatBackupDescription =>
      'Iznan-ik·im d iɣelsanen s tsarut n tririt. Ɣur-k·m ad k·em-truḥ.';

  @override
  String get chatDetails => 'Ifatusen n udiwenni';

  @override
  String get chats => 'Idiwenniyen';

  @override
  String get chooseAStrongPassword => 'Fren awal n uɛeddi iǧehden';

  @override
  String get clearArchive => 'Sfeḍ aɣbaṛ';

  @override
  String get close => 'Mdel';

  @override
  String get commandHint_markasdm =>
      'Creḍ d akken taxxamt n yizen usrid i Usulay Matriks i d-yettunefken';

  @override
  String get commandHint_markasgroup => 'Creḍ am ugraw';

  @override
  String get commandHint_ban => 'Gdel aseqdac i d-ittunefken seg texxamt-agi';

  @override
  String get commandHint_clearcache => 'Sfeḍ tazarkatut';

  @override
  String get commandHint_create =>
      'Snulfu-d agraw n udiwenni ilem\nSeqdec -- war awgelhen i tukksa n uwgelhen';

  @override
  String get commandHint_discardsession => 'Kkes tiɣimit';

  @override
  String get commandHint_dm =>
      'Senker adiwenni usrid\nSeqdec --war awgelhen i tukksa n uwgelhen';

  @override
  String get commandHint_html => 'Azen aḍris s umasal HTML';

  @override
  String get commandHint_invite =>
      'Snubg aseqdac i d-ittunefken ɣer texxamt-agi';

  @override
  String get commandHint_join => 'Ddu ɣer texxamt i d-ittunefken';

  @override
  String get commandHint_kick => 'Kkes aseqdac i d-ittunefken seg texxamt-agi';

  @override
  String get commandHint_leave => 'Ffeɣ seg texxamt-a';

  @override
  String get commandHint_me => 'Glem-d iman-ik·im';

  @override
  String get commandHint_myroomavatar =>
      'Sbadu tawlaft-ik·im i texxamt-a (s mxc-uri)';

  @override
  String get commandHint_myroomnick => 'Sbadu isem n uskan i texxamt-agi';

  @override
  String get commandHint_op =>
      'Sbadu aswir n tnezmert n useqdac i d-ittunefken (amezwer: 50)';

  @override
  String get commandHint_plain => 'Send unformatted text';

  @override
  String get commandHint_react => 'Send reply as a reaction';

  @override
  String get commandHint_send => 'Azen aḍris';

  @override
  String get commandHint_unban => 'Unban the given user from this room';

  @override
  String get commandInvalid => 'Command invalid';

  @override
  String commandMissing(String command) {
    return '$command is not a command.';
  }

  @override
  String get compareEmojiMatch => 'Please compare the emojis';

  @override
  String get compareNumbersMatch => 'Please compare the numbers';

  @override
  String get configureChat => 'Swel adiwenni';

  @override
  String get contactHasBeenInvitedToTheGroup => 'Anermis yettwaɛreḍ ɣer ugraw';

  @override
  String get contentHasBeenReported => 'Agbur yettwammel i inedbalen n uqeddac';

  @override
  String get copiedToClipboard => 'Yettwanɣel ɣer tecfawit';

  @override
  String get copy => 'Nɣel';

  @override
  String get copyToClipboard => 'Nɣel ɣer tecfawit';

  @override
  String couldNotDecryptMessage(String error) {
    return 'Ur izmer ara tukksa n uwgelhen n yizen: $error';
  }

  @override
  String get checkList => 'Senqed tabdart';

  @override
  String countParticipants(int count) {
    return '$count imttekkiyen';
  }

  @override
  String countInvited(int count) {
    return '$count yettwaɛerḍen';
  }

  @override
  String get create => 'Snulfu-d';

  @override
  String createdTheChat(String username) {
    return '💬 $username yesnulfa-d adiwenni';
  }

  @override
  String get createGroup => 'Snulfu-d agraw';

  @override
  String get createNewSpace => 'Tallunt tamaynut';

  @override
  String get currentlyActive => 'Yermed akka tura';

  @override
  String get darkTheme => 'Ubrik';

  @override
  String dateAndTimeOfDay(String date, String timeOfDay) {
    return '$timeOfDay, $date';
  }

  @override
  String get deactivateAccountWarning =>
      'Ayagi ad yekkes armed i umiḍan-ik·im n useqdac. Aya ur yezmir ara ad yettwasefsex. Tetḥeqqeḍ s tidet?';

  @override
  String get defaultPermissionLevel =>
      'Aswir n turagt amezwer i yiseqdacen imaynuten';

  @override
  String get delete => 'kkes';

  @override
  String get deleteAccount => 'kkes amiḍan';

  @override
  String get deleteMessage => 'kkes izen';

  @override
  String get device => 'Ibenk';

  @override
  String get deviceId => 'Asulay n yibenk';

  @override
  String get devices => 'Ibenkan';

  @override
  String get directChats => 'Idiwenniyen Usriden';

  @override
  String get displaynameHasBeenChanged => 'Isem n uskan yettusnifel';

  @override
  String get downloadFile => 'Sider afaylu';

  @override
  String get edit => 'Ẓreg';

  @override
  String get editBlockedServers => 'Ẓreg iqeddacen yettusweḥlen';

  @override
  String get chatPermissions => 'Isirigen n Udiwenni';

  @override
  String get editDisplayname => 'Ẓreg isem n ubeqqeḍ';

  @override
  String get editRoomAliases => 'Ẓreg tizeẓla n taxxamt';

  @override
  String get editRoomAvatar => 'Ẓreg avaṭar n texxamt';

  @override
  String get emoteExists => 'Azamul uḥulfu yella yakan!';

  @override
  String get emoteInvalid => 'Tangalt tawezlant n uzamul uḥulfu d tarmeɣtut!';

  @override
  String get emoteKeyboardNoRecents =>
      'Izamulen uḥulfu yettwasqedcen melmi kan ad banen dagi…';

  @override
  String get emotePacks => 'Ikemmusen n uzamul uḥulfu i texxamt';

  @override
  String get emoteSettings => 'Iɣewwaṛen n uzamul uḥulfu';

  @override
  String get globalChatId => 'Asulay n udiwenni amatu';

  @override
  String get accessAndVisibility => 'Addaf d twalit';

  @override
  String get accessAndVisibilityDescription =>
      'Anwa i yesɛan turagt ad yernu ɣer udiwenni-agi u amek adiwenni yezmer ad yettwaf.';

  @override
  String get calls => 'Isawalen';

  @override
  String get customEmojisAndStickers => 'Imujiten yugnen akked tcṛeṭ n tesfift';

  @override
  String get customEmojisAndStickersBody =>
      'Rnu neɣ bḍu imujiten yugnen neɣ tcṛeṭ n tesfift i zemren ad ttwasqedcen deg yal adiwenni.';

  @override
  String get emoteShortcode => 'Emote shortcode';

  @override
  String get emptyChat => 'Adiwenni d ilem';

  @override
  String get enableEmotesGlobally =>
      'Sermed akemmus n uzamul uḥulfu s wudem amatu';

  @override
  String get enableEncryption => 'Rmed awgelhen';

  @override
  String get enableEncryptionWarning =>
      'Ur tettizmireḍ ara ad tessenseḍ awgelhen syagi ɣer zdat. Tetḥeqqeḍ s tidet?';

  @override
  String get encrypted => 'Yettwawgelhen';

  @override
  String get encryption => 'Awgelhen';

  @override
  String get encryptionNotEnabled => 'Awgelhen ur yettwarmed ara';

  @override
  String endedTheCall(String senderName) {
    return '$senderName ifukk asiwel';
  }

  @override
  String get enterAnEmailAddress => 'Sekcem tansa n yimayl';

  @override
  String get homeserver => 'Aqeddac agejdan';

  @override
  String errorObtainingLocation(String error) {
    return 'Tuccḍa deg wawway n yideg: $error';
  }

  @override
  String get everythingReady => 'Kullec ihegga!';

  @override
  String get extremeOffensive => 'Extremely offensive';

  @override
  String get fileName => 'Isem n ufaylu';

  @override
  String get fluffychat => 'FluffyChat';

  @override
  String get fontSize => 'Tiddi n tsefsit';

  @override
  String get forward => 'Ɣer zdat';

  @override
  String get fromJoining => 'Seg unekcam-is';

  @override
  String get fromTheInvitation => 'Seg tinubga';

  @override
  String get group => 'Agraw';

  @override
  String get chatDescription => 'Aglam n udiwenni';

  @override
  String get chatDescriptionHasBeenChanged => 'Aglam n udiwenni yettwabeddel';

  @override
  String get groupIsPublic => 'Agraw d azayez';

  @override
  String get groups => 'Igrawen';

  @override
  String groupWith(String displayname) {
    return 'Agraw s $displayname';
  }

  @override
  String get guestsAreForbidden => 'Guests are forbidden';

  @override
  String get guestsCanJoin => 'Guests can join';

  @override
  String hasWithdrawnTheInvitationFor(String username, String targetName) {
    return '$username has withdrawn the invitation for $targetName';
  }

  @override
  String get help => 'Tallelt';

  @override
  String get hideRedactedEvents => 'Hide redacted events';

  @override
  String get hideRedactedMessages => 'Hide redacted messages';

  @override
  String get hideRedactedMessagesBody =>
      'If someone redacts a message, this message won\'t be visible in the chat anymore.';

  @override
  String get hideInvalidOrUnknownMessageFormats =>
      'Hide invalid or unknown message formats';

  @override
  String get howOffensiveIsThisContent => 'How offensive is this content?';

  @override
  String get id => 'Asulay';

  @override
  String get block => 'Iḥder';

  @override
  String get blockedUsers => 'Iseqdacen yettusweḥlen';

  @override
  String get blockListDescription =>
      'You can block users who are disturbing you. You won\'t be able to receive any messages or room invites from the users on your personal block list.';

  @override
  String get blockUsername => 'Zgel isem n useqdac';

  @override
  String get iHaveClickedOnLink => 'Ttekkiɣ ɣef useɣwen';

  @override
  String get incorrectPassphraseOrKey =>
      'Tafyirt n uɛeddi neɣ tasarut n tririt d tarameɣtut';

  @override
  String get inoffensive => 'Ur yettḍurru ara';

  @override
  String get inviteContact => 'Snubg anermis';

  @override
  String inviteContactToGroup(String groupName) {
    return 'Snubg anermis ɣer $groupName';
  }

  @override
  String get noChatDescriptionYet =>
      'Ulac aglam n udiwenni i d-yenulfan yakan.';

  @override
  String get tryAgain => 'Ɛreḍ tikkelt-nniḍen';

  @override
  String get invalidServerName => 'Isem n uqeddac d armeɣtu';

  @override
  String get invited => 'Yettwaɛreḍ';

  @override
  String get redactMessageDescription =>
      'Izen ad yettwakkesn i imttekkiyen merra deg udiwenni-agi. Ur tezmireḍ ara ad tesfesxeḍ.';

  @override
  String get optionalRedactReason => '(Afrayan) Sebba n tukksa n izen-agi…';

  @override
  String invitedUser(String username, String targetName) {
    return '📩 $username yenced $targetName';
  }

  @override
  String get invitedUsersOnly => 'Iseqdacen kan yettwaɛerḍen';

  @override
  String inviteText(String username, String link) {
    return '$username yeɛreḍ-ik·m ɣer FluffyChat.\n1. Rzu ɣer fluffychat.im syin sbedd asnas \n2. Jerred neɣ kcem \n3. Ldi aseɣwen n tinubga: \n $link';
  }

  @override
  String get isTyping => 'la yettaru…';

  @override
  String joinedTheChat(String username) {
    return '👋$username yekcem ɣer udiwenni';
  }

  @override
  String get joinRoom => 'Tekki deg texxamt';

  @override
  String kicked(String username, String targetName) {
    return '👞$username yessuffeɣ-d $targetName';
  }

  @override
  String kickedAndBanned(String username, String targetName) {
    return '🙅 $username yessuffeɣ-d udiɣ igdel $targetName';
  }

  @override
  String get kickFromChat => 'Suffeɣ seg udiwenni';

  @override
  String lastActiveAgo(String localizedTimeShort) {
    return 'Yermed i tikkelt taneggarut: $localizedTimeShort';
  }

  @override
  String get leave => 'Eǧǧ';

  @override
  String get leftTheChat => 'Ffeɣ seg udiwenni';

  @override
  String get lightTheme => 'Aceɛlal';

  @override
  String loadCountMoreParticipants(int count) {
    return 'Sali-d ugar n $count yimttekkiyen';
  }

  @override
  String get dehydrate => 'Sifeḍ tiɣimit akked usfaḍ n yibenk';

  @override
  String get dehydrateWarning =>
      'Tigawt-agi ur tezmir ara ad tettwasefsex. Tḥeqqeq belli tesseklaseḍ afaylu n weḥraz.';

  @override
  String get hydrate => 'Err-d seg ufaylu n weḥraz';

  @override
  String get loadingPleaseWait => 'Asali... Ttxil-k·m arǧu.';

  @override
  String get loadMore => 'Sali-d ugar…';

  @override
  String get locationDisabledNotice =>
      'Imeẓla n wadig nsan. Ma ulac aɣilif, rmed-iten akken ad izmiren ad bḍun ideg-ik·im.';

  @override
  String get locationPermissionDeniedNotice =>
      'Tisirag n wadig tettwagdel. Ttxil-k·m efk-asen amek ara bḍun ideg-ik·im.';

  @override
  String get login => 'Anekcam';

  @override
  String logInTo(String homeserver) {
    return 'Anekcam ɣer $homeserver';
  }

  @override
  String get logout => 'Tuffɣa';

  @override
  String get mention => 'Abdar';

  @override
  String get messages => 'Iznan';

  @override
  String get messagesStyle => 'Iznan:';

  @override
  String get moderator => 'Moderator';

  @override
  String get muteChat => 'Sgugem adiwenni';

  @override
  String get needPantalaimonWarning =>
      'Ttxil-k·m ẓeṛ belli tesriḍ Palaimon akken ad tesqedceḍ awgelhen seg yixef ɣer yixef.';

  @override
  String get newChat => 'Adiwenni Amaynut';

  @override
  String get newMessageInFluffyChat => '💬 Izen amaynut deg FluffyChat';

  @override
  String get newVerificationRequest => 'Asuter amaynut n uselken!';

  @override
  String get next => 'Uḍfir';

  @override
  String get no => 'Ala';

  @override
  String get noConnectionToTheServer => 'Ulac tuqqna ɣer uqeddac';

  @override
  String get noEmotesFound => 'Ulac izamulen uḥulfu yettwafen. 😕';

  @override
  String get noEncryptionForPublicRooms =>
      'Tzemreḍ kan ad tesremdeḍ awgelhen akken kan ara tuɣal taxxamt s war anekcum azayez.';

  @override
  String get noGoogleServicesWarning =>
      'Firebase Cloud Messaging doesn\'t appear to be available on your device. To still receive push notifications, we recommend installing ntfy. With ntfy or another Unified Push provider you can receive push notifications in a data secure way. You can download ntfy from the PlayStore or from F-Droid.';

  @override
  String noMatrixServer(String server1, String server2) {
    return '$server1 ur yelli d aqeddac matriks, seqdec axir $server2 ?';
  }

  @override
  String get shareInviteLink => 'Bḍu aseɣwen n tinubga';

  @override
  String get scanQrCode => 'Semḍen tangalt QR';

  @override
  String get none => 'Ulac';

  @override
  String get noPasswordRecoveryDescription =>
      'Mazal ur terniḍ ara tarrayt akken ad terreḍ awal-ik·im n uɛeddi.';

  @override
  String get noPermission => 'Ulac tasiregt';

  @override
  String get noRoomsFound => 'Ulac taxxamt i yettwafen…';

  @override
  String get notifications => 'Ilɣa';

  @override
  String numUsersTyping(int count) {
    return '$count n iseqdacen la yettarun…';
  }

  @override
  String get obtainingLocation => 'Aguccel n wadig…';

  @override
  String get offensive => 'Tanṭagt';

  @override
  String get offline => 'Aruqqin';

  @override
  String get ok => 'iH';

  @override
  String get online => 'Deg uẓeṭṭa';

  @override
  String get onlineKeyBackupEnabled => 'Aḥraz n tsarut deg uẓeṭṭa yermed';

  @override
  String get oopsPushError =>
      'Ayhu! nesḥissif, teḍra-d tuccḍa deg usbadu n yilɣa usriden.';

  @override
  String get oopsSomethingWentWrong => 'Ihuh, yella wayen ur neddi ara…';

  @override
  String get openAppToReadMessages => 'Ldi asnas akken ad teɣreḍ iznan';

  @override
  String get openCamera => 'Ldi takamiṛat';

  @override
  String get oneClientLoggedOut => 'One of your clients has been logged out';

  @override
  String get addAccount => 'Rnu amiḍan';

  @override
  String get editBundlesForAccount => 'Edit bundles for this account';

  @override
  String get addToBundle => 'Add to bundle';

  @override
  String get removeFromBundle => 'Remove from this bundle';

  @override
  String get bundleName => 'Bundle name';

  @override
  String get enableMultiAccounts =>
      '(armitan) Rmed aget n yimiḍanen deg yibenk-agi';

  @override
  String get openInMaps => 'Ldi-t deg maps';

  @override
  String get link => 'Aseɣwen';

  @override
  String get serverRequiresEmail =>
      'Aqeddac-agi ilaq ad isentem tansa imayl i ujerred.';

  @override
  String get or => 'Neɣ';

  @override
  String get participant => 'Imttekki';

  @override
  String get passphraseOrKey => 'tafyirt n uɛeddi neɣ tasarut n tririt';

  @override
  String get password => 'Awal n uɛeddi';

  @override
  String get passwordForgotten => 'Awal n uɛeddi yettwattun';

  @override
  String get passwordHasBeenChanged => 'Awal n uɛeddi yettusnifel';

  @override
  String get overview => 'Taskant';

  @override
  String get passwordRecoverySettings => 'Iɣewwaṛen n tririt n wawal n uɛeddi';

  @override
  String get passwordRecovery => 'Tiririt n wawal n uɛeddi';

  @override
  String get pickImage => 'Fren tugna';

  @override
  String get pin => 'Pin';

  @override
  String play(String fileName) {
    return 'Ɣeṛ $fileName';
  }

  @override
  String get pleaseChooseAPasscode => 'Ttxil-k·m fren tangalt n uɛeddi';

  @override
  String get pleaseClickOnLink =>
      'Ma ulac aɣilif, sit ɣef useɣwen yellan deg imayl sakin kemmel.';

  @override
  String get pleaseEnter4Digits =>
      'Ttxil-k·m sekcem 4 n wuṭṭunen neɣ eǧǧ-it d ilem akken ad tsenseḍ asekkeṛ n usnas.';

  @override
  String get pleaseEnterYourPassword =>
      'Ma ulac aɣilif, sekcem-d awal-ik n uɛeddi';

  @override
  String get pleaseEnterYourPin => 'Ttxil-k·m sekcem tangalt-ik·im pin';

  @override
  String get pleaseEnterYourUsername => 'Ma ulac aɣilif sekcem isem n useqdac';

  @override
  String get pleaseFollowInstructionsOnWeb =>
      'Ma ulac aɣilif, ḍfeṛ iwellihen n usmel web sakin sit ɣef uḍfir.';

  @override
  String get privacy => 'Tabaḍnit';

  @override
  String get publicRooms => 'Tixxamin tizuyaz';

  @override
  String get pushRules => 'Push rules';

  @override
  String get reason => 'Taɣẓint';

  @override
  String get recording => 'Asekles';

  @override
  String redactedBy(String username) {
    return 'Redacted by $username';
  }

  @override
  String get directChat => 'Adiwenni usrid';

  @override
  String redactedByBecause(String username, String reason) {
    return 'Redacted by $username because: \"$reason\"';
  }

  @override
  String redactedAnEvent(String username) {
    return '$username redacted an event';
  }

  @override
  String get redactMessage => 'Kkes izen';

  @override
  String get register => 'Jerred';

  @override
  String get reject => 'Aggi';

  @override
  String rejectedTheInvitation(String username) {
    return '$username yugi tinnubga-nni';
  }

  @override
  String get removeAllOtherDevices => 'Kkes akk ibenkan-nniḍen';

  @override
  String removedBy(String username) {
    return 'Yettwakkes sɣur $username';
  }

  @override
  String get unbanFromChat => 'Kkes agdal seg udiwenni';

  @override
  String get removeYourAvatar => 'Kkes avaṭar-ik·im';

  @override
  String get replaceRoomWithNewerVersion => 'Semselsi taxxamt s lqem amaynut';

  @override
  String get reply => 'Err';

  @override
  String get reportMessage => 'Mmel-d izen';

  @override
  String get requestPermission => 'Suter tasiregt';

  @override
  String get roomHasBeenUpgraded => 'Taxxamt tettwaleqqem';

  @override
  String get roomVersion => 'Lqem n texxamt';

  @override
  String get saveFile => 'Sekles afaylu';

  @override
  String get search => 'Nadi';

  @override
  String get security => 'Taɣellist';

  @override
  String get recoveryKey => 'Tasarut n tririt';

  @override
  String get recoveryKeyLost => 'Tasarut n tririt teɛreq?';

  @override
  String get send => 'Azen';

  @override
  String get sendAMessage => 'Azen izen';

  @override
  String get sendAsText => 'Azen am uḍris';

  @override
  String get sendAudio => 'Azen ameslaw';

  @override
  String get sendFile => 'Azen afaylu';

  @override
  String get sendImage => 'Azen tugna';

  @override
  String sendImages(int count) {
    return 'Azen $count n tugna(iwin)';
  }

  @override
  String get sendMessages => 'Azen iznan';

  @override
  String get sendVideo => 'Azen avidyu';

  @override
  String sentAFile(String username) {
    return '📁 $username yuzen afaylu';
  }

  @override
  String sentAnAudio(String username) {
    return '🎤 $username yuzen ameslaw';
  }

  @override
  String sentAPicture(String username) {
    return '🖼️ $username yuzen tugna';
  }

  @override
  String sentASticker(String username) {
    return '😊 $username yuzen ticṛeṭ n tesfift';
  }

  @override
  String sentAVideo(String username) {
    return '🎥 $username yuzen tavidyut';
  }

  @override
  String sentCallInformations(String senderName) {
    return '$senderName yuzen talɣut n usiwel';
  }

  @override
  String get setAsCanonicalAlias => 'Sbadu-t d tazaẓlut tagejdant';

  @override
  String get setChatDescription => 'Sbadu aglam n udiwenni';

  @override
  String get setStatus => 'Sbadu addad';

  @override
  String get settings => 'Iɣewwaren';

  @override
  String get share => 'Bḍu';

  @override
  String sharedTheLocation(String username) {
    return '$username yebḍa adig-is';
  }

  @override
  String get shareLocation => 'Bḍu adig';

  @override
  String get showPassword => 'Sken-d awal n uɛeddi';

  @override
  String get presencesToggle => 'Show status messages from other users';

  @override
  String get skip => 'Zgel';

  @override
  String get sourceCode => 'Tangalt taɣbalutt';

  @override
  String get spaceIsPublic => 'Tallunt d tazayezt';

  @override
  String get spaceName => 'Isem n tallunt';

  @override
  String startedACall(String senderName) {
    return '$senderName yebda-d asiwel';
  }

  @override
  String get status => 'Addad';

  @override
  String get statusExampleMessage => 'Amek telliḍ ass-a?';

  @override
  String get submit => 'Ceyyeɛ';

  @override
  String get synchronizingPleaseWait => 'Amtawi... Ttxil-k·m arǧu.';

  @override
  String synchronizingPleaseWaitCounter(String percentage) {
    return ' Amtawi… ($percentage%)';
  }

  @override
  String get systemTheme => 'Anagraw';

  @override
  String get theyDontMatch => 'Ur mṣadan ara';

  @override
  String get theyMatch => 'mṣadan';

  @override
  String get title => 'FluffyChat';

  @override
  String get tooManyRequestsWarning =>
      'Deqs n tuttriwin. Ttxil-k·m, ɛreḍ tikelt nniḍen ticki!';

  @override
  String get transferFromAnotherDevice => 'Asiweḍ seg yibenk nniḍen';

  @override
  String get tryToSendAgain => 'Ɛreḍ ad tazneḍ tikkelt nniḍen';

  @override
  String get unavailable => 'Ur yewjid ara';

  @override
  String unbannedUser(String username, String targetName) {
    return '$username yekkes agdek n $targetName';
  }

  @override
  String get unblockDevice => 'Kkes asewḥel n yibenk';

  @override
  String get unknownDevice => 'Ibenk arussin';

  @override
  String get unknownEncryptionAlgorithm => 'Alguritm n uwgelhen d arussin';

  @override
  String unknownEvent(String type) {
    return 'Tadyant tarussint \'$type\'';
  }

  @override
  String get unmuteChat => 'Kkes asgugem i udiwenni';

  @override
  String get unpin => 'Kkes anṭaḍ';

  @override
  String userAndOthersAreTyping(String username, int count) {
    return '$username akked $count nniḍen la ad ttarun…';
  }

  @override
  String userAndUserAreTyping(String username, String username2) {
    return '$username akked $username2 la ad ttarun…';
  }

  @override
  String userIsTyping(String username) {
    return '$username la yettaru…';
  }

  @override
  String userLeftTheChat(String username) {
    return '🚪$username yeffeɣ seg udiwenni';
  }

  @override
  String get username => 'Isem n useqdac';

  @override
  String userSentUnknownEvent(String username, String type) {
    return '$username yuzen-d tadyant $type';
  }

  @override
  String get unverified => 'Ur yettwaselken ara';

  @override
  String get verified => 'Yettwaselken';

  @override
  String get verify => 'Selken';

  @override
  String get verifyStart => 'Bdu Aselken';

  @override
  String get verifySuccess => 'Yedda uselken-ik·im akken iwata!';

  @override
  String get verifyTitle => 'Aselken n imiḍanen nniḍen';

  @override
  String get videoCall => 'Asiwel s tvidyut';

  @override
  String get visibilityOfTheChatHistory => 'Tawalit n uzray n udiwenni';

  @override
  String get visibleForAllParticipants => 'Yettban i yimttekkiyen meṛṛa';

  @override
  String get visibleForEveryone => 'Yettban i yal yiwen';

  @override
  String get voiceMessage => 'Izen n taɣect';

  @override
  String get waitingPartnerAcceptRequest => 'Araǧu n uneblag ad yeqbel asuter…';

  @override
  String get waitingPartnerEmoji => 'Araǧu n uneblag ad yeqbel imujit…';

  @override
  String get waitingPartnerNumbers => 'Araǧu n uneblag ad yeqbel uṭṭunen…';

  @override
  String get warning => 'Ɣur-k·m!';

  @override
  String get weSentYouAnEmail => 'Nuzen-ak-d imayl';

  @override
  String get whoCanPerformWhichAction => 'Anwa i izemren ad yexdem anta tigawt';

  @override
  String get whoIsAllowedToJoinThisGroup =>
      'Anwa i izemren ad yernu ɣer ugraw-agi';

  @override
  String get whyDoYouWantToReportThis => 'Ayɣer tebɣiḍ ad temleḍ aya?';

  @override
  String get wipeChatBackup =>
      'Sfeḍ aḥraz-ik·im n udiwenni akken ad d-tesnulfuḍ tasarut tamaynut n tririt?';

  @override
  String get withTheseAddressesRecoveryDescription =>
      'S tansiwin-agi i tzemreḍ ad terreḍ awal-ik·im n uɛeddi.';

  @override
  String get writeAMessage => 'Aru izen…';

  @override
  String get yes => 'Ih';

  @override
  String get you => 'kečč·em';

  @override
  String get youAreNoLongerParticipatingInThisChat =>
      'Ur mazal ara tettekkaḍ deg udiwenni-a';

  @override
  String get youHaveBeenBannedFromThisChat => 'Tettwagedleḍ seg udiwenni-agi';

  @override
  String get yourPublicKey => 'Tasarut-ik·im tazayezt';

  @override
  String get messageInfo => 'Talɣut n yizen';

  @override
  String get time => 'Akud';

  @override
  String get messageType => 'Anaw n yizen';

  @override
  String get sender => 'Amazan';

  @override
  String get openGallery => 'Ldi timidelt';

  @override
  String get removeFromSpace => 'Kkes seg tallunt';

  @override
  String get start => 'Senker';

  @override
  String get pleaseEnterRecoveryKeyDescription =>
      'Akken ad tekkseḍ asekkeṛ i yiznan-ik·im iqburen, ttxil-k·m sekcem tasarut n tririt i d-yenulfan di tɣimit tuzwirt. Tasarut-ik·im n tririt UR TELLI ARA d awal-ik·im n uɛeddi.';

  @override
  String get openChat => 'Ldi Adiwenni';

  @override
  String get markAsRead => 'Creḍ amzun yettwaɣṛa';

  @override
  String get reportUser => 'Cetki aseqdac';

  @override
  String get dismiss => 'Agi';

  @override
  String reactedWith(String sender, String reaction) {
    return '$sender err-d s $reaction';
  }

  @override
  String get pinMessage => 'Senteḍ ɣer texxamt';

  @override
  String get confirmEventUnpin =>
      'Tebɣiḍ ad tekkseḍ s wudem imezgi asenṭed n tadyant-nni?';

  @override
  String get emojis => 'Imujiten';

  @override
  String get placeCall => 'Sɛeddi Asiwel';

  @override
  String get voiceCall => 'Asiwel n taɣect';

  @override
  String get unsupportedAndroidVersion => 'Lqem Android ur yettwasefrak ara';

  @override
  String get unsupportedAndroidVersionLong =>
      'Tamahilt-a tesra lqem Android tamaynut. Ttxil-k·m senqed ileqman neɣ asefrak n Lineage OS.';

  @override
  String get videoCallsBetaWarning =>
      'Please note that video calls are currently in beta. They might not work as expected or work at all on all platforms.';

  @override
  String get experimentalVideoCalls => 'Isawalen uvidya s wudem armitan';

  @override
  String get youRejectedTheInvitation => 'Tugiḍ tinnubga';

  @override
  String get youJoinedTheChat => 'Tekcemeḍ ɣer udiwenni';

  @override
  String get youAcceptedTheInvitation => '👍 Tqebleḍ tinubga';

  @override
  String youBannedUser(String user) {
    return 'Tgedleḍ $user';
  }

  @override
  String youHaveWithdrawnTheInvitationFor(String user) {
    return 'Tekkseḍ tinnubga i $user';
  }

  @override
  String youInvitedBy(String user) {
    return '📩 Tettwaɛerḍeḍ sɣur $user';
  }

  @override
  String invitedBy(String user) {
    return '📩 Tettwaɛerḍeɣ sɣur $user';
  }

  @override
  String youInvitedUser(String user) {
    return '📩 Tɛerḍeḍ-d $user';
  }

  @override
  String youKicked(String user) {
    return '👞 Tegliḍ s rrkel $user';
  }

  @override
  String youKickedAndBanned(String user) {
    return '🙅 Tegliḍ s rrkel u tgedleḍ $user';
  }

  @override
  String youUnbannedUser(String user) {
    return 'Tekkseḍ agdel n $user';
  }

  @override
  String hasKnocked(String user) {
    return '🚪$user yesṭebṭbed';
  }

  @override
  String get usersMustKnock => 'Iseqdacen yessefk ad sṭebṭben';

  @override
  String get noOneCanJoin => 'Yiwen ur yezmir ad d-yernu';

  @override
  String get knock => 'Sqeṛbeb';

  @override
  String get users => 'Iseqdacen';

  @override
  String get unlockOldMessages => 'Kkes asekkeṛ i yiznan iqbuṛen';

  @override
  String get storeInSecureStorageDescription =>
      'Ḥrez tasarut n tririt deg usekles aɣelsan n yibenk-a.';

  @override
  String get saveKeyManuallyDescription =>
      'Sekles tasarut-agi s ufus deg udiwenni n beṭṭu n unagraw neɣ ɣef tecfawit.';

  @override
  String get storeInAndroidKeystore => 'Sekles deg Android KeyStore';

  @override
  String get storeInAppleKeyChain => 'Sekles deg uzrar n tsura n Apple';

  @override
  String get storeSecurlyOnThisDevice => 'Ḥrez s wudem aɣelsan ɣef yibenk-a';

  @override
  String countFiles(int count) {
    return '$count n yifuyla';
  }

  @override
  String get user => 'Aseqdac';

  @override
  String get custom => 'Yugnen';

  @override
  String get foregroundServiceRunning =>
      'Alɣu-agi yettban-d ticki ameẓlu n uɣawas amezwaru iteddu.';

  @override
  String get screenSharingTitle => 'beṭṭu n ugdil';

  @override
  String get screenSharingDetail => 'Tbeṭṭuḍ agdil-ik·im deg FluffyChat';

  @override
  String get whyIsThisMessageEncrypted => 'Acuɣer izen-agi ur yettwaɣri ara?';

  @override
  String get noKeyForThisMessage =>
      'This can happen if the message was sent before you have signed in to your account at this device.\n\nIt is also possible that the sender has blocked your device or something went wrong with the internet connection.\n\nAre you able to read the message on another session? Then you can transfer the message from it! Go to Settings > Devices and make sure that your devices have verified each other. When you open the room the next time and both sessions are in the foreground, the keys will be transmitted automatically.\n\nDo you not want to lose the keys when logging out or switching devices? Make sure that you have enabled the chat backup in the settings.';

  @override
  String get newGroup => 'Agraw amaynut';

  @override
  String get newSpace => 'Tallunt tamaynut';

  @override
  String get allSpaces => 'Akk tallunin';

  @override
  String get hidePresences => 'Hide Status List?';

  @override
  String get doNotShowAgain => 'Ur t-id-sskan ara tikkelt nniḍen';

  @override
  String wasDirectChatDisplayName(String oldDisplayName) {
    return 'Empty chat (was $oldDisplayName)';
  }

  @override
  String get newSpaceDescription =>
      'Spaces allows you to consolidate your chats and build private or public communities.';

  @override
  String get encryptThisChat => 'Wgelhen adiwenni-a';

  @override
  String get disableEncryptionWarning =>
      'For security reasons you can not disable encryption in a chat, where it has been enabled before.';

  @override
  String get sorryThatsNotPossible => 'Sorry... that is not possible';

  @override
  String get deviceKeys => 'Tisura n yibenk:';

  @override
  String get reopenChat => 'Reopen chat';

  @override
  String get noBackupWarning =>
      'Warning! Without enabling chat backup, you will lose access to your encrypted messages. It is highly recommended to enable the chat backup first before logging out.';

  @override
  String get noOtherDevicesFound => 'Ulac ibenkan nniḍen yettwafen';

  @override
  String fileIsTooBigForServer(String max) {
    return 'Ur izmir ara ad yazen! Aqeddac yessefrak kan ifuyla imeddayen almi ɣer $max.';
  }

  @override
  String fileHasBeenSavedAt(String path) {
    return 'Afaylu yettwasekles deg $path';
  }

  @override
  String get jumpToLastReadMessage => 'Ddu ɣer yizen aneggaru yettwaɣen';

  @override
  String get readUpToHere => 'Ɣeṛ dagi';

  @override
  String get jump => 'Neggez';

  @override
  String get openLinkInBrowser => 'Ldi aseɣwen deg yiminig';

  @override
  String get reportErrorDescription =>
      '😭 Uhu. Yella kra n wugur ay yellan. Ma tebɣiḍ, tzemreḍ ad tazneḍ aneqqis-a i yineflayen.';

  @override
  String get report => 'aneqqis';

  @override
  String get setColorTheme => 'Sbadu asentel n yini:';

  @override
  String get invite => 'Snubget';

  @override
  String get inviteGroupChat => '📨Snubget ɣer udiwenni n ugraw';

  @override
  String get invalidInput => 'Anekcam d armeɣtu!';

  @override
  String wrongPinEntered(int seconds) {
    return 'Tettwasekcem tangalt PIN d armeɣtut! Ɛreḍ tikkelt nniḍen deg $seconds n tasinin…';
  }

  @override
  String get pleaseEnterANumber => 'Ma ulac aɣilif sekcem amḍan yugaren 0';

  @override
  String get archiveRoomDescription =>
      'The chat will be moved to the archive. Other users will be able to see that you have left the chat.';

  @override
  String get roomUpgradeDescription =>
      'The chat will then be recreated with the new room version. All participants will be notified that they need to switch to the new chat. You can find out more about room versions at https://spec.matrix.org/latest/rooms/';

  @override
  String get removeDevicesDescription =>
      'You will be logged out of this device and will no longer be able to receive messages.';

  @override
  String get banUserDescription =>
      'The user will be banned from the chat and will not be able to enter the chat again until they are unbanned.';

  @override
  String get unbanUserDescription =>
      'The user will be able to enter the chat again if they try.';

  @override
  String get kickUserDescription =>
      'The user is kicked out of the chat but not banned. In public chats, the user can rejoin at any time.';

  @override
  String get makeAdminDescription =>
      'Once you make this user admin, you may not be able to undo this as they will then have the same permissions as you.';

  @override
  String get pushNotificationsNotAvailable =>
      'Push notifications not available';

  @override
  String get learnMore => 'Issin ugar';

  @override
  String get yourGlobalUserIdIs => 'Your global user-ID is: ';

  @override
  String noUsersFoundWithQuery(String query) {
    return 'Unfortunately no user could be found with \"$query\". Please check whether you made a typo.';
  }

  @override
  String get knocking => 'Sqeṛbeb';

  @override
  String chatCanBeDiscoveredViaSearchOnServer(String server) {
    return 'Chat can be discovered via the search on $server';
  }

  @override
  String get searchChatsRooms => 'Search for #chats, @users...';

  @override
  String get nothingFound => 'Nothing found...';

  @override
  String get groupName => 'Isem n ugraw';

  @override
  String get createGroupAndInviteUsers => 'Create a group and invite users';

  @override
  String get groupCanBeFoundViaSearch => 'Group can be found via search';

  @override
  String get wrongRecoveryKey =>
      'Sorry... this does not seem to be the correct recovery key.';

  @override
  String get commandHint_sendraw => 'Send raw json';

  @override
  String get databaseMigrationTitle => 'Database is optimized';

  @override
  String get databaseMigrationBody => 'Please wait. This may take a moment.';

  @override
  String get leaveEmptyToClearStatus => 'Leave empty to clear your status.';

  @override
  String get select => 'Fren';

  @override
  String get searchForUsers => 'Nadi iseqdacen…';

  @override
  String get pleaseEnterYourCurrentPassword =>
      'Please enter your current password';

  @override
  String get newPassword => 'Awal n uɛeddi amaynut';

  @override
  String get pleaseChooseAStrongPassword => 'Please choose a strong password';

  @override
  String get passwordsDoNotMatch => 'Awalen n uɛeddi mgarraden';

  @override
  String get passwordIsWrong => 'Your entered password is wrong';

  @override
  String get publicChatAddresses => 'Public chat addresses';

  @override
  String get createNewAddress => 'Snulfu-d tansa tamaynut';

  @override
  String get joinSpace => 'Join space';

  @override
  String get publicSpaces => 'Public spaces';

  @override
  String get addChatOrSubSpace => 'Add chat or sub space';

  @override
  String get thisDevice => 'Ibenk-a:';

  @override
  String get initAppError => 'An error occured while init the app';

  @override
  String searchIn(String chat) {
    return 'Nadi deg udiwenni \"$chat\"...';
  }

  @override
  String get searchMore => 'Nadi ugar…';

  @override
  String get gallery => 'Timidelt';

  @override
  String get files => 'Ifuyla';

  @override
  String sessionLostBody(String url, String error) {
    return 'Your session is lost. Please report this error to the developers at $url. The error message is: $error';
  }

  @override
  String restoreSessionBody(String url, String error) {
    return 'The app now tries to restore your session from the backup. Please report this error to the developers at $url. The error message is: $error';
  }

  @override
  String get sendReadReceipts => 'Send read receipts';

  @override
  String get sendTypingNotificationsDescription =>
      'Other participants in a chat can see when you are typing a new message.';

  @override
  String get sendReadReceiptsDescription =>
      'Other participants in a chat can see when you have read a message.';

  @override
  String get formattedMessages => 'Formatted messages';

  @override
  String get formattedMessagesDescription =>
      'Display rich message content like bold text using markdown.';

  @override
  String get verifyOtherUser => '🔐 Verify other user';

  @override
  String get verifyOtherUserDescription =>
      'If you verify another user, you can be sure that you know who you are really writing to. 💪\n\nWhen you start a verification, you and the other user will see a popup in the app. There you will then see a series of emojis or numbers that you have to compare with each other.\n\nThe best way to do this is to meet up or start a video call. 👭';

  @override
  String get verifyOtherDevice => '🔐 Verify other device';

  @override
  String get verifyOtherDeviceDescription =>
      'When you verify another device, those devices can exchange keys, increasing your overall security. 💪 When you start a verification, a popup will appear in the app on both devices. There you will then see a series of emojis or numbers that you have to compare with each other. It\'s best to have both devices handy before you start the verification. 🤳';

  @override
  String acceptedKeyVerification(String sender) {
    return '$sender accepted key verification';
  }

  @override
  String canceledKeyVerification(String sender) {
    return '$sender canceled key verification';
  }

  @override
  String completedKeyVerification(String sender) {
    return '$sender completed key verification';
  }

  @override
  String isReadyForKeyVerification(String sender) {
    return '$sender is ready for key verification';
  }

  @override
  String requestedKeyVerification(String sender) {
    return '$sender requested key verification';
  }

  @override
  String startedKeyVerification(String sender) {
    return '$sender started key verification';
  }

  @override
  String get transparent => 'Afrawan';

  @override
  String get incomingMessages => 'Incoming messages';

  @override
  String get stickers => 'Stickers';

  @override
  String get discover => 'Snirem';

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
    return '$level - Aseqdac';
  }

  @override
  String moderatorLevel(int level) {
    return '$level - Moderator';
  }

  @override
  String adminLevel(int level) {
    return '$level - Tadbelt';
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
  String get changelog => 'Aɣmis n ibeddilen';

  @override
  String get sendCanceled => 'Sending canceled';

  @override
  String get loginWithMatrixId => 'Tuqqna s usulay ID n Matrix';

  @override
  String get doesNotSeemToBeAValidHomeserver =>
      'Doesn\'t seem to be a compatible homeserver. Wrong URL?';

  @override
  String get calculatingFileSize => 'Asiḍen n tiddi n ufaylu...';

  @override
  String get prepareSendingAttachment => 'Prepare sending attachment...';

  @override
  String get sendingAttachment => 'Sending attachment...';

  @override
  String get generatingVideoThumbnail => 'Generating video thumbnail...';

  @override
  String get compressVideo => 'Asekkussem n tvidyut...';

  @override
  String sendingAttachmentCountOfCount(int index, int length) {
    return 'Tuzna umedday $index n $length…';
  }

  @override
  String serverLimitReached(int seconds) {
    return 'Talast n uqeddac tewweḍ! Araǧu n $seconds n tasinin…';
  }

  @override
  String get oneOfYourDevicesIsNotVerified =>
      'iwen seg ibenkan-ik·im ur yettusenqed ara';

  @override
  String get noticeChatBackupDeviceVerification =>
      'Tamawt: Mi ara teqqneḍ akk ibenkan-ik·im ɣer weḥraz udiwenni, ttusneqden s wudem awurman.';

  @override
  String get continueText => 'Ddu';

  @override
  String get welcomeText =>
      'Azul Azul 👋 Wa d FluffyChat. Tzemreḍ ad tkecmeḍ ɣer uqeddac agejdan, yellan yemsaḍa akked https://matrix.org. Dɣa meslay d win tebɣiḍ, d aẓeṭṭa n udiwenni araslemmas amuqṛan!';

  @override
  String get blur => 'Asluɣu:';

  @override
  String get opacity => 'Tiḍullest:';

  @override
  String get setWallpaper => 'Sbadu tugna ugilal';

  @override
  String get manageAccount => 'Sefrek amiḍan';

  @override
  String get noContactInformationProvided =>
      'Aqeddac ur yezmir ara ad d-yefk talɣut n unermis tameɣtut';

  @override
  String get contactServerAdmin => 'Nermes anedbal n uqeddac';

  @override
  String get contactServerSecurity => 'Taɣellist uqeddac n unermis';

  @override
  String get supportPage => 'Asebter n tallalt';

  @override
  String get serverInformation => 'Talɣut n uqeddac:';

  @override
  String get name => 'Isem';

  @override
  String get version => 'Lqem';

  @override
  String get website => 'Asmel Web';

  @override
  String get compress => 'Sekussem';

  @override
  String get boldText => 'Aḍris azuran';

  @override
  String get italicText => 'Aḍris uknan';

  @override
  String get strikeThrough => 'Yettwajeṛṛeḍ';

  @override
  String get pleaseFillOut => 'Ttxil-k·m, ččar';

  @override
  String get invalidUrl => 'url armeɣtu';

  @override
  String get addLink => 'Rnu aseɣwen';

  @override
  String get unableToJoinChat =>
      'Ur yezmir ara ad yernu ɣer udiwenni. Ahat aseqdac n udiwenni-agi imdel-it yakan.';

  @override
  String get previous => 'Uzwir';

  @override
  String get otherPartyNotLoggedIn =>
      'Aḥric nniḍen ur yeqqin ara akka tura, ihi ur yezmir ara ad d-yeṭṭef iznan!';

  @override
  String appWantsToUseForLogin(String server) {
    return 'Seqdec \'$server\' akken ad teqqneḍ';
  }

  @override
  String get appWantsToUseForLoginDescription =>
      'You hereby allow the app and website to share information about you.';

  @override
  String get open => 'Ldi';

  @override
  String get waitingForServer => 'Araǧu n uqeddac...';

  @override
  String get newChatRequest => '📩 Asuter n udiwenni amaynut';

  @override
  String get contentNotificationSettings => 'Iɣewwaṛen n telɣut n ugbur';

  @override
  String get generalNotificationSettings => 'Iɣewwaren imuta n ilɣa';

  @override
  String get roomNotificationSettings => 'Iɣewwaṛen n telɣut n texxamt';

  @override
  String get userSpecificNotificationSettings => 'Iɣewwaṛen n telɣut n useqdac';

  @override
  String get otherNotificationSettings => 'Iɣewwaṛen-nniḍen n telɣut';

  @override
  String get notificationRuleContainsUserName => 'Yegber isem n useqdac';

  @override
  String get notificationRuleContainsUserNameDescription =>
      'Azen tilɣa i useqdac ma yella yizen yegber isem-is useqdac.';

  @override
  String get notificationRuleMaster => 'Sgugem akk tilɣa';

  @override
  String get notificationRuleMasterDescription =>
      'Ad isemselsi akk ilugan-nniḍen sakin ad sexsi akk tilɣa.';

  @override
  String get notificationRuleSuppressNotices => 'Kkes iznan s wudem awurman';

  @override
  String get notificationRuleSuppressNoticesDescription =>
      'Kkes ilɣa seg imsaɣen iwurmanen am yiṛubuten.';

  @override
  String get notificationRuleInviteForMe => 'Asnubget i nekk';

  @override
  String get notificationRuleInviteForMeDescription =>
      'Azen ilɣa i useqdac ticki yettwaɛreḍ ɣer texxamt.';

  @override
  String get notificationRuleMemberEvent => 'Tadyant i yiɛeggalen';

  @override
  String get notificationRuleMemberEventDescription =>
      'Suppresses notifications for membership events.';

  @override
  String get notificationRuleIsUserMention => 'Abdar n useqdac';

  @override
  String get notificationRuleIsUserMentionDescription =>
      'Azen ilɣa i useqdac ma yella yettwabder s srid deg yizen.';

  @override
  String get notificationRuleContainsDisplayName => 'Yegber Isem n ubeqqeḍ';

  @override
  String get notificationRuleContainsDisplayNameDescription =>
      'Azen ilɣa i useqdac ma yella yizen yegber Isem-is n ubeqqeḍ.';

  @override
  String get notificationRuleIsRoomMention => 'Abdar n Texxamt';

  @override
  String get notificationRuleIsRoomMentionDescription =>
      'Azen ilɣa i useqdac ticki yella ubdar n texxamt.';

  @override
  String get notificationRuleRoomnotif => 'Alɣu n texxamt';

  @override
  String get notificationRuleRoomnotifDescription =>
      'Azen alɣu i useqdec mi ara yelli yizen yegber \'@room\'.';

  @override
  String get notificationRuleTombstone => 'Tombstone';

  @override
  String get notificationRuleTombstoneDescription =>
      'Azen alɣu i useqdec ɣef yiznan n usens n texxamt.';

  @override
  String get notificationRuleReaction => 'Tasedmirt';

  @override
  String get notificationRuleReactionDescription => 'Kkes ilɣa i tsedmirin.';

  @override
  String get notificationRuleRoomServerAcl => 'Room Server ACL';

  @override
  String get notificationRuleRoomServerAclDescription =>
      'Suppresses notifications for room server access control lists (ACL).';

  @override
  String get notificationRuleSuppressEdits => 'Kkes Asiẓreg';

  @override
  String get notificationRuleSuppressEditsDescription =>
      'Kkes ilɣa i yeznan yettwaẓergen.';

  @override
  String get notificationRuleCall => 'Asiwel';

  @override
  String get notificationRuleCallDescription =>
      'Azen alɣu i useqdac ɣef isawalen.';

  @override
  String get notificationRuleEncryptedRoomOneToOne =>
      'Taxxamt yettwawgelhen s wudem n yiwen ɣer yiwen';

  @override
  String get notificationRuleEncryptedRoomOneToOneDescription =>
      'Notifies the user about messages in encrypted one-to-one rooms.';

  @override
  String get notificationRuleRoomOneToOne =>
      'Taxxamt s wudem n yiwen ɣer yiwen';

  @override
  String get notificationRuleRoomOneToOneDescription =>
      'Notifies the user about messages in one-to-one rooms.';

  @override
  String get notificationRuleMessage => 'Izen';

  @override
  String get notificationRuleMessageDescription =>
      'Notifies the user about general messages.';

  @override
  String get notificationRuleEncrypted => 'Yettwawgelhen';

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
    return '🎙️ $duration - Voice message from $sender';
  }

  @override
  String get deletePushRuleCanNotBeUndone =>
      'If you delete this notification setting, this can not be undone.';

  @override
  String get more => 'Ugar';

  @override
  String get shareKeysWith => 'Bḍu tisura akked…';

  @override
  String get shareKeysWithDescription =>
      'Which devices should be trusted so that they can read along your messages in encrypted chats?';

  @override
  String get allDevices => 'Akk ibenkan';

  @override
  String get crossVerifiedDevicesIfEnabled =>
      'Cross verified devices if enabled';

  @override
  String get crossVerifiedDevices => 'Cross verified devices';

  @override
  String get verifiedDevicesOnly => 'Ibenkan yettwasneqden kan';

  @override
  String get takeAPhoto => 'Ṭṭef tawlaft';

  @override
  String get recordAVideo => 'Sekles tavidyut';

  @override
  String get optionalMessage => '(D afrayan) izen…';

  @override
  String get notSupportedOnThisDevice => 'Ur itteddu ara deg yibenk-agi';

  @override
  String get enterNewChat => 'Sekcem adiwenni amaynut';

  @override
  String get approve => 'Sqbel';

  @override
  String get youHaveKnocked => 'You have knocked';

  @override
  String get pleaseWaitUntilInvited =>
      'Ttxil-k·m, rǧu arma yeɛreḍ-ik-id yiwen seg texxamt.';

  @override
  String get commandHint_logout => 'Senser seg yibenk-ik·im amiran';

  @override
  String get commandHint_logoutall => 'Senser akk ibenkan urmiden';

  @override
  String get displayNavigationRail => 'Sken afeggag n yinig deg uziraz';

  @override
  String get customReaction => 'Tasedmirt yugnen';

  @override
  String get moreEvents => 'Ugar n ineḍruyen';

  @override
  String get declineInvitation => 'Agi tinnubga';

  @override
  String get noMessagesYet => 'Ulac iznan akka tura';

  @override
  String get longPressToRecordVoiceMessage =>
      'Asiti aɣezzfan i usekles n yizen n taɣect.';

  @override
  String get pause => 'Serǧu';

  @override
  String get resume => 'Kemmel';

  @override
  String get removeFromSpaceDescription =>
      'Adiwenni ad yettwakkes seg tallunt maca mazal ad yettban deg tebdart-ik·im n udiwenni.';

  @override
  String countChats(int chats) {
    return '$chats idiwenniyen';
  }

  @override
  String spaceMemberOf(String spaces) {
    return 'Aɛeggal n tallunt n $spaces';
  }

  @override
  String spaceMemberOfCanKnock(String spaces) {
    return 'Space member of $spaces can knock';
  }

  @override
  String startedAPoll(String username) {
    return '${username}yessenker tafrent.';
  }

  @override
  String get poll => 'Tafrent';

  @override
  String get startPoll => 'Senker tafrent';

  @override
  String get endPoll => 'Eg taggara n tafrent';

  @override
  String get answersVisible => 'Tiririyin yettbanen';

  @override
  String get pollQuestion => 'Isteqsiyen n tefrent';

  @override
  String get answerOption => 'tanefrunt n tririt';

  @override
  String get addAnswerOption => 'Rnu tanefrunt n tririt';

  @override
  String get allowMultipleAnswers => 'Sireg aget n tiririyin';

  @override
  String get pollHasBeenEnded => 'Tafrent tfukk';

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
      'Tiririyin ad banent ticki tafrent tfukk';

  @override
  String get replyInThread => 'Err deg udras udiwenni';

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
  String get thread => 'Adras udiwenni';

  @override
  String get backToMainChat => 'Uɣal ɣer udiwenni agejdan';

  @override
  String get saveChanges => 'Sekles ibeddilen';

  @override
  String get createSticker => 'Snulfu-d ticṛeṭ n tesfift neɣ imujiten';

  @override
  String get useAsSticker => 'Seqdec am tcṛeṭ n tesfift';

  @override
  String get useAsEmoji => 'Seqdec am imujit';

  @override
  String get stickerPackNameAlreadyExists =>
      'Isem ukemmus n tcṛeṭ n tesfift yella yakan';

  @override
  String get newStickerPack => 'Akemmus n tcṛeṭ n tesfift';

  @override
  String get stickerPackName => 'Isem ukemmus n tcṛeṭ n tesfift';

  @override
  String get attribution => 'Attribution';

  @override
  String get skipChatBackup => 'Zgel aḥraz n udiwenni';

  @override
  String get skipChatBackupWarning =>
      'tetḥeqqeḍ? S war armad n weḥraz n udiwenni, tzemreḍ ad tesruḥeḍ anekcum ɣer yiznan-ik·im ma tbeddeleḍ ibenk-ik·im.';

  @override
  String get loadingMessages => 'Asali n yiznan';

  @override
  String get setupChatBackup => 'Sbadu aḥraz n udiwenni';

  @override
  String get noMoreResultsFound => 'Ulac ugar n igmaḍ yettwafen';

  @override
  String chatSearchedUntil(String time) {
    return 'Chat searched until $time';
  }

  @override
  String get federationBaseUrl => 'Federation Base URL';

  @override
  String get clientWellKnownInformation => 'Talɣut yettwasnen ɣef umsaɣ:';

  @override
  String get baseUrl => 'URL n taffa';

  @override
  String get identityServer => 'Aseqdac n tmagit:';

  @override
  String versionWithNumber(String version) {
    return 'Lqem: $version';
  }

  @override
  String get logs => 'Iɣmisen';

  @override
  String get advancedConfigs => 'Tawila leqqayen';

  @override
  String get advancedConfigurations => 'Tawila tinaẓiyin';

  @override
  String get signIn => 'Qqen';

  @override
  String get createNewAccount => 'Snulfu-d amiḍan amaynut';

  @override
  String get signUpGreeting =>
      'FluffyChat d araslemmes! Fren aqeddac anda tebɣiḍ ad ternuḍ amiḍan-ik·im, u yyaw ad neddu!';

  @override
  String get signInGreeting =>
      'Tesɛiḍ yakan amiḍan deg Matriks? Anṣuf yes-k·m tikkelt niḍen! Fren aqeddac-ik·im, u tkecmeḍ.';

  @override
  String get appIntro =>
      'With FluffyChat you can chat with your friends. It\'s a secure decentralized [matrix] messenger! Learn more on https://matrix.org if you like or just sign up.';

  @override
  String get theProcessWasCanceled => 'Tettwasefsex ukala-nni.';

  @override
  String get join => 'Ttekki';

  @override
  String get searchOrEnterHomeserverAddress =>
      'Nadi neɣ sekcem tansa n uqeddac agejdan';

  @override
  String get matrixId => 'Asulay ID Matrix';

  @override
  String get setPowerLevel => 'Sbadu aswir n tezmert';

  @override
  String get makeModerator => 'Make moderator';

  @override
  String get makeAdmin => 'Err-it d anedbal';

  @override
  String get removeModeratorRights => 'Remove moderator rights';

  @override
  String get removeAdminRights => 'Kkes izerfan n unedbal';

  @override
  String get powerLevel => 'Aswir n tezmert';

  @override
  String get setPowerLevelDescription =>
      'Power levels define what a member is allowed to do in this room and usually range between 0 and 100.';

  @override
  String get owner => 'Amli';

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
  String get startVideoCall => 'Bdu asiwel n uvidyu';

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
