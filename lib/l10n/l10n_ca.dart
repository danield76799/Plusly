// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class L10nCa extends L10n {
  L10nCa([String locale = 'ca']) : super(locale);

  @override
  String get alwaysUse24HourFormat => 'true';

  @override
  String get repeatPassword => 'Repetiu la contrasenya';

  @override
  String get notAnImage => 'No és un arxiu d\'image.';

  @override
  String get ignoreUser => 'Ignora l\'usuàriï';

  @override
  String get remove => 'Elimina';

  @override
  String get importNow => 'Importa-ho ara';

  @override
  String get importEmojis => 'Importa emojis';

  @override
  String get importFromZipFile => 'Importa des d\'un arxiu zip';

  @override
  String get exportEmotePack => 'Exporta com un pack Emote en .zip';

  @override
  String get replace => 'Reemplaça';

  @override
  String get about => 'Quant a';

  @override
  String aboutHomeserver(String homeserver) {
    return 'Quant a $homeserver';
  }

  @override
  String get accept => 'Accepta';

  @override
  String acceptedTheInvitation(String username) {
    return '👍 $username ha acceptat la invitació';
  }

  @override
  String get account => 'Compte';

  @override
  String activatedEndToEndEncryption(String username) {
    return '🔐 $username ha activat el xifratge d’extrem a extrem';
  }

  @override
  String get addEmail => 'Afegeix una adreça electrònica';

  @override
  String get confirmMatrixId =>
      'Confirma la teva ID de Matrix per poder esborrar el compte.';

  @override
  String supposedMxid(String mxid) {
    return 'Això hauria de ser $mxid';
  }

  @override
  String get addToSpace => 'Afegeix a un espai';

  @override
  String get admin => 'Administració';

  @override
  String get alias => 'àlies';

  @override
  String get all => 'Tot';

  @override
  String get allChats => 'Tots els xats';

  @override
  String get commandHint_roomupgrade =>
      'Actualitza aquesta sala a la versió indicada';

  @override
  String get commandHint_googly => 'Envia uns ulls curiosos';

  @override
  String get commandHint_cuddle => 'Envia una carícia';

  @override
  String get commandHint_hug => 'Envia una abraçada';

  @override
  String googlyEyesContent(String senderName) {
    return '$senderName t\'ha enviat un parell d\'ulls';
  }

  @override
  String cuddleContent(String senderName) {
    return '$senderName et fa una carícia';
  }

  @override
  String hugContent(String senderName) {
    return '$senderName t\'abraça';
  }

  @override
  String answeredTheCall(String senderName) {
    return '$senderName ha respost a la trucada';
  }

  @override
  String get anyoneCanJoin => 'Qualsevol pot unir-se';

  @override
  String get appLock => 'Blocatge de l’aplicació';

  @override
  String get appLockDescription =>
      'Bloca l\'app amb un pin quan no la facis servir';

  @override
  String get archive => 'Arxiu';

  @override
  String get areGuestsAllowedToJoin => 'Es pot entrar al xat com a convidadi?';

  @override
  String get areYouSure => 'N’esteu seguri?';

  @override
  String get areYouSureYouWantToLogout =>
      'Segur que voleu finalitzar la sessió?';

  @override
  String get askSSSSSign =>
      'Per a poder donar accés a l’altra persona, introduïu la frase de seguretat o clau de recuperació.';

  @override
  String askVerificationRequest(String username) {
    return 'Voleu acceptar aquesta sol·licitud de verificació de: $username?';
  }

  @override
  String get autoplayImages =>
      'Reprodueix automàticament enganxines i emoticones animades';

  @override
  String badServerLoginTypesException(
    String serverVersions,
    String supportedVersions,
    Object suportedVersions,
  ) {
    return 'El servidor admet els inicis de sessió:\n$serverVersions\nPerò l\'aplicació només admet:\n$supportedVersions';
  }

  @override
  String get sendTypingNotifications => 'Envia notificacions d\'escriptura';

  @override
  String get swipeRightToLeftToReply =>
      'Llisca de dreta esquerra per respondre';

  @override
  String get sendOnEnter => 'Envia en prémer Retorn';

  @override
  String get noMoreChatsFound => 'No hi ha més xats...';

  @override
  String get noChatsFoundHere =>
      'Encara no hi ha xats. Obre una conversa amb algú picant al botó de sota. ⤵️';

  @override
  String get unread => 'Sense llegir';

  @override
  String get space => 'Espai';

  @override
  String get spaces => 'Espais';

  @override
  String get banFromChat => 'Veta del xat';

  @override
  String get banned => 'Vetadi';

  @override
  String bannedUser(String username, String targetName) {
    return '$username ha vetat a $targetName';
  }

  @override
  String get blockDevice => 'Bloca el dispositiu';

  @override
  String get blocked => 'Blocat';

  @override
  String get cancel => 'Cancel·la';

  @override
  String cantOpenUri(String uri) {
    return 'No es pot obrir l’URI $uri';
  }

  @override
  String get changeDeviceName => 'Canvia el nom del dispositiu';

  @override
  String changedTheChatAvatar(String username) {
    return '$username ha canviat la imatge del xat';
  }

  @override
  String changedTheChatDescription(Object username) {
    return '$username ha canviat la descripció del xat';
  }

  @override
  String changedTheChatDescriptionTo(String username, String description) {
    return '$username ha canviat la descripció del xat a: \'$description\'';
  }

  @override
  String changedTheChatName(Object username) {
    return '$username ha canviat el nom del xat';
  }

  @override
  String changedTheChatNameTo(String username, String chatname) {
    return '$username ha canviat el nom del xat a: \'$chatname\'';
  }

  @override
  String changedTheChatPermissions(String username) {
    return '$username ha canviat els permisos del xat';
  }

  @override
  String changedTheDisplaynameTo(String username, String displayname) {
    return '$username ha canviat el seu àlies a: \'$displayname\'';
  }

  @override
  String changedTheGuestAccessRules(String username) {
    return '$username ha canviat les normes d’accés dels convidats';
  }

  @override
  String changedTheGuestAccessRulesTo(String username, String rules) {
    return '$username ha canviat les normes d’accés dels convidats a: $rules';
  }

  @override
  String changedTheHistoryVisibility(String username) {
    return '$username ha canviat la visibilitat de l’historial';
  }

  @override
  String changedTheHistoryVisibilityTo(String username, String rules) {
    return '$username ha canviat la visibilitat de l’historial a: $rules';
  }

  @override
  String changedTheJoinRules(String username) {
    return '$username ha canviat les normes d’unió';
  }

  @override
  String changedTheJoinRulesTo(String username, String joinRules) {
    return '$username ha canviat les normes d’unió a: $joinRules';
  }

  @override
  String changedTheProfileAvatar(String username) {
    return '$username ha canviat la seva imatge de perfil';
  }

  @override
  String changedTheRoomAliases(String username) {
    return '$username ha canviat l’àlies de la sala';
  }

  @override
  String changedTheRoomInvitationLink(String username) {
    return '$username ha canviat l’enllaç per a convidar';
  }

  @override
  String get changePassword => 'Canvia la contrasenya';

  @override
  String get changeTheHomeserver => 'Canvia el servidor';

  @override
  String get changeTheme => 'Canvia l’estil';

  @override
  String get changeTheNameOfTheGroup => 'Canvia el nom del grup';

  @override
  String get changeYourAvatar => 'Canvia l’avatar';

  @override
  String get channelCorruptedDecryptError => 'El xifratge s’ha corromput';

  @override
  String get chat => 'Xat';

  @override
  String get yourChatBackupHasBeenSetUp =>
      'S’ha configurat la còpia de seguretat del xat.';

  @override
  String get chatBackup => 'Còpia de seguretat del xat';

  @override
  String get chatBackupDescription =>
      'Els teus xats estan protegits amb una clau de recuperació. Assegura\'t de no perdre-la.';

  @override
  String get chatDetails => 'Detalls del xat';

  @override
  String get chats => 'Xats';

  @override
  String get chooseAStrongPassword => 'Trieu una contrasenya forta';

  @override
  String get clearArchive => 'Neteja l’arxiu';

  @override
  String get close => 'Tanca';

  @override
  String get commandHint_markasdm =>
      'Marca com a conversa directa la sala amb aquesta ID de Matrix';

  @override
  String get commandHint_markasgroup => 'Marca com un grup';

  @override
  String get commandHint_ban => 'Veta uni usuàriï d\'aquesta sala';

  @override
  String get commandHint_clearcache => 'Neteja la memòria cau';

  @override
  String get commandHint_create =>
      'Crea un xat de grup buit\nUsa --no-encryption per desactivar l\'encriptatge';

  @override
  String get commandHint_discardsession => 'Descarta la sessió';

  @override
  String get commandHint_dm =>
      'Inicia un xat directe\nUsa --no-encryption per desactivar l\'encriptatge';

  @override
  String get commandHint_html => 'Envia text en format HTML';

  @override
  String get commandHint_invite => 'Convida uni usuàriï a aquesta sala';

  @override
  String get commandHint_join => 'Uneix-te a la sala indicada';

  @override
  String get commandHint_kick => 'Expulsa uni usuàriï d\'aquesta sala';

  @override
  String get commandHint_leave => 'Abandona aquesta sala';

  @override
  String get commandHint_me => 'Descriviu-vos';

  @override
  String get commandHint_myroomavatar =>
      'Establiu la imatge per a aquesta sala (per mxc-uri)';

  @override
  String get commandHint_myroomnick =>
      'Estableix el teu àlies per a aquesta sala';

  @override
  String get commandHint_op =>
      'Estableix el nivell d\'autoritat d\'uni usuàriï (per defecte: 50)';

  @override
  String get commandHint_plain => 'Envia text sense format';

  @override
  String get commandHint_react => 'Envia una resposta com a reacció';

  @override
  String get commandHint_send => 'Envia text';

  @override
  String get commandHint_unban =>
      'Aixeca el veto a aquesti usuàriï per aquesta sala';

  @override
  String get commandInvalid => 'L’ordre no és vàlida';

  @override
  String commandMissing(String command) {
    return '$command no és una ordre.';
  }

  @override
  String get compareEmojiMatch => 'Compareu aquests emojis';

  @override
  String get compareNumbersMatch => 'Compareu aquests números';

  @override
  String get configureChat => 'Configura el xat';

  @override
  String get contactHasBeenInvitedToTheGroup =>
      'El contacte ha estat convidat al grup';

  @override
  String get contentHasBeenReported =>
      'El contingut s’ha denunciat als administradors del servidor';

  @override
  String get copiedToClipboard => 'S’ha copiat al porta-retalls';

  @override
  String get copy => 'Copia';

  @override
  String get copyToClipboard => 'Copia al porta-retalls';

  @override
  String couldNotDecryptMessage(String error) {
    return 'No s\'ha pogut desxifrar el missatge: $error';
  }

  @override
  String get checkList => 'Llista de tasques';

  @override
  String countParticipants(int count) {
    return '$count participants';
  }

  @override
  String countInvited(int count) {
    return '$count convidadis';
  }

  @override
  String get create => 'Crea';

  @override
  String createdTheChat(String username) {
    return '💬 $username ha creat el xat';
  }

  @override
  String get createGroup => 'Crea un grup';

  @override
  String get createNewSpace => 'Espai nou';

  @override
  String get currentlyActive => 'Actiu actualment';

  @override
  String get darkTheme => 'Fosc';

  @override
  String dateAndTimeOfDay(String date, String timeOfDay) {
    return '$date, $timeOfDay';
  }

  @override
  String get deactivateAccountWarning =>
      'Es desactivarà el vostre compte d’usuàriï. És irreversible! Voleu fer-ho igualment?';

  @override
  String get defaultPermissionLevel =>
      'Nivell de permisos per defecte per nous membres';

  @override
  String get delete => 'Suprimeix';

  @override
  String get deleteAccount => 'Suprimeix el compte';

  @override
  String get deleteMessage => 'Suprimeix el missatge';

  @override
  String get device => 'Dispositiu';

  @override
  String get deviceId => 'Id. de dispositiu';

  @override
  String get devices => 'Dispositius';

  @override
  String get directChats => 'Xats directes';

  @override
  String get displaynameHasBeenChanged => 'Ha canviat l\'àlies';

  @override
  String get downloadFile => 'Baixa el fitxer';

  @override
  String get edit => 'Edita';

  @override
  String get editBlockedServers => 'Edita els servidors bloquejats';

  @override
  String get chatPermissions => 'Permisos del xat';

  @override
  String get editDisplayname => 'Edita l\'àlies';

  @override
  String get editRoomAliases => 'Canvia els àlies de la sala';

  @override
  String get editRoomAvatar => 'Canvia la imatge de la sala';

  @override
  String get emoteExists => 'L\'emoticona ja existeix!';

  @override
  String get emoteInvalid => 'Codi d\'emoticona invàlid!';

  @override
  String get emoteKeyboardNoRecents =>
      'Els últims emotes usats apareixeran aquí...';

  @override
  String get emotePacks => 'Paquet d\'emoticones de la sala';

  @override
  String get emoteSettings => 'Paràmetres de les emoticones';

  @override
  String get globalChatId => 'Identificador global de xat';

  @override
  String get accessAndVisibility => 'Accés i visibilitat';

  @override
  String get accessAndVisibilityDescription =>
      'Qui pot entrar a aquesta conversa i com pot ser descoberta.';

  @override
  String get calls => 'Trucades';

  @override
  String get customEmojisAndStickers => 'Emojis i stickers propis';

  @override
  String get customEmojisAndStickersBody =>
      'Afegeix o comparteix emojis o stickers. Els podràs fer servir en qualsevol conversa.';

  @override
  String get emoteShortcode => 'Codi d\'emoticona';

  @override
  String get emptyChat => 'Xat buit';

  @override
  String get enableEmotesGlobally => 'Activa el paquet d\'emoticones global';

  @override
  String get enableEncryption => 'Activa el xifratge';

  @override
  String get enableEncryptionWarning =>
      'No podreu desactivar el xifratge mai més. N’esteu segur?';

  @override
  String get encrypted => 'Xifrat';

  @override
  String get encryption => 'Xifratge';

  @override
  String get encryptionNotEnabled => 'El xifratge no s’ha activat';

  @override
  String endedTheCall(String senderName) {
    return '$senderName ha finalitzat la trucada';
  }

  @override
  String get enterAnEmailAddress => 'Introduïu una adreça electrònica';

  @override
  String get homeserver => 'Servidor';

  @override
  String errorObtainingLocation(String error) {
    return 'S’ha produït un error en obtenir la ubicació: $error';
  }

  @override
  String get everythingReady => 'Tot és a punt!';

  @override
  String get extremeOffensive => 'Extremadament ofensiu';

  @override
  String get fileName => 'Nom del fitxer';

  @override
  String get fluffychat => 'FluffyChat';

  @override
  String get fontSize => 'Mida de la lletra';

  @override
  String get forward => 'Reenvia';

  @override
  String get fromJoining => 'Des de la unió';

  @override
  String get fromTheInvitation => 'Des de la invitació';

  @override
  String get group => 'Grup';

  @override
  String get chatDescription => 'Descripció del xat';

  @override
  String get chatDescriptionHasBeenChanged =>
      'Ha canviat la descripció del xat';

  @override
  String get groupIsPublic => 'El grup és públic';

  @override
  String get groups => 'Grups';

  @override
  String groupWith(String displayname) {
    return 'Grup amb $displayname';
  }

  @override
  String get guestsAreForbidden => 'Els convidats no poden unir-se';

  @override
  String get guestsCanJoin => 'Els convidats es poden unir';

  @override
  String hasWithdrawnTheInvitationFor(String username, String targetName) {
    return '$username ha retirat la invitació de $targetName';
  }

  @override
  String get help => 'Ajuda';

  @override
  String get hideRedactedEvents => 'Amaga els esdeveniments estripats';

  @override
  String get hideRedactedMessages => 'Amaga els missatges estripats';

  @override
  String get hideRedactedMessagesBody =>
      'Si algú estripa un missatge, ja no apareixerà a l\'historial de la conversa.';

  @override
  String get hideInvalidOrUnknownMessageFormats =>
      'Amaga els missatges que tinguin un format desconegut';

  @override
  String get howOffensiveIsThisContent => 'Com d’ofensiu és aquest contingut?';

  @override
  String get id => 'Id.';

  @override
  String get block => 'Bloca';

  @override
  String get blockedUsers => 'Usuàrïis blocadis';

  @override
  String get blockListDescription =>
      'Pots bloquejar usuàrïis que et molestin. No rebràs missatges seus ni invitacions de part seva a cap sala.';

  @override
  String get blockUsername => 'Ignora aquesti usuàrïi';

  @override
  String get iHaveClickedOnLink => 'He fet clic a l\'enllaç';

  @override
  String get incorrectPassphraseOrKey =>
      'Frase de seguretat o clau de recuperació incorrecta';

  @override
  String get inoffensive => 'Inofensiu';

  @override
  String get inviteContact => 'Convida contacte';

  @override
  String inviteContactToGroup(String groupName) {
    return 'Convida contacte a $groupName';
  }

  @override
  String get noChatDescriptionYet => 'No s\'ha afegit una descripció de xat.';

  @override
  String get tryAgain => 'Torna-ho a provar';

  @override
  String get invalidServerName => 'El nom del servidor és invàlid';

  @override
  String get invited => 'Convidat';

  @override
  String get redactMessageDescription =>
      'S\'estriparà el missatge per a totser d\'aquesta conversa. Aquesta acció és irreversible.';

  @override
  String get optionalRedactReason =>
      '(Opcional) El motiu per estripar el missatge...';

  @override
  String invitedUser(String username, String targetName) {
    return '📩 $username ha convidat a $targetName';
  }

  @override
  String get invitedUsersOnly => 'Només usuàriïs convidadis';

  @override
  String inviteText(String username, String link) {
    return '$username t\'ha convidat a FluffyChat.\n1. Visita fluffychat.im i instaŀla l\'app\n2. Registra\'t o inicia sessió\n3. Obre l\'enllaç d\'invitació:\n$link';
  }

  @override
  String get isTyping => 'escrivint…';

  @override
  String joinedTheChat(String username) {
    return '👋 $username s\'ha unit al xat';
  }

  @override
  String get joinRoom => 'Uneix-te a la sala';

  @override
  String kicked(String username, String targetName) {
    return '👞 $username ha expulsat a $targetName';
  }

  @override
  String kickedAndBanned(String username, String targetName) {
    return '🙅 $username ha expulsat i vetat a $targetName';
  }

  @override
  String get kickFromChat => 'Expulsa del xat';

  @override
  String lastActiveAgo(String localizedTimeShort) {
    return 'Actiu per última vegada: $localizedTimeShort';
  }

  @override
  String get leave => 'Abandona';

  @override
  String get leftTheChat => 'Ha marxat del xat';

  @override
  String get lightTheme => 'Clar';

  @override
  String loadCountMoreParticipants(int count) {
    return 'Carrega $count participants més';
  }

  @override
  String get dehydrate => 'Exporta la sessió i neteja el dispositiu';

  @override
  String get dehydrateWarning =>
      'Aquesta acció és irreversible. Assegura\'t que deses l\'arxiu de recuperació en un lloc segur.';

  @override
  String get hydrate => 'Restaura un arxiu de recuperació';

  @override
  String get loadingPleaseWait => 'S’està carregant… Espereu.';

  @override
  String get loadMore => 'Carrega’n més…';

  @override
  String get locationDisabledNotice =>
      'S’han desactivat els serveis d’ubicació. Activeu-los per a compartir la vostra ubicació.';

  @override
  String get locationPermissionDeniedNotice =>
      'S’ha rebutjat el permís d’ubicació. Atorgueu-lo per a poder compartir la vostra ubicació.';

  @override
  String get login => 'Inicia la sessió';

  @override
  String logInTo(String homeserver) {
    return 'Inicia sessió a $homeserver';
  }

  @override
  String get logout => 'Finalitza la sessió';

  @override
  String get mention => 'Menciona';

  @override
  String get messages => 'Missatges';

  @override
  String get messagesStyle => 'Missatges:';

  @override
  String get moderator => 'Moderador';

  @override
  String get muteChat => 'Silencia el xat';

  @override
  String get needPantalaimonWarning =>
      'Tingueu en compte que, ara per ara, us cal el Pantalaimon per a poder utilitzar el xifratge d’extrem a extrem.';

  @override
  String get newChat => 'Xat nou';

  @override
  String get newMessageInFluffyChat => '💬 Missatge nou al FluffyChat';

  @override
  String get newVerificationRequest => 'Nova sol·licitud de verificació!';

  @override
  String get next => 'Següent';

  @override
  String get no => 'No';

  @override
  String get noConnectionToTheServer => 'Sense connexió al servidor';

  @override
  String get noEmotesFound => 'No s’ha trobat cap emoticona. 😕';

  @override
  String get noEncryptionForPublicRooms =>
      'Només podreu activar el xifratge quan la sala ja no sigui accessible públicament.';

  @override
  String get noGoogleServicesWarning =>
      'Sembla que no teniu els Serveis de Google al telèfon. Això és una bona decisió respecte a la vostra privadesa! Per a rebre notificacions automàtiques del FluffyChat, us recomanem instaŀlar ntfy. Amb ntfy o qualsevol altre proveïdor de Unified Push, pots rebre notificacions de forma segura i lliure. Pots instaŀlar ntfy des de la PlayStore o des de F-Droid.';

  @override
  String noMatrixServer(String server1, String server2) {
    return '$server1 no és un servidor de matrix, vols fer servir $server2 ?';
  }

  @override
  String get shareInviteLink => 'Comparteix un enllaç d\'invitació';

  @override
  String get scanQrCode => 'Escaneja un codi QR';

  @override
  String get none => 'Cap';

  @override
  String get noPasswordRecoveryDescription =>
      'Encara no heu afegit cap mètode per a poder recuperar la contrasenya.';

  @override
  String get noPermission => 'Sense permís';

  @override
  String get noRoomsFound => 'No s’ha trobat cap sala…';

  @override
  String get notifications => 'Notificacions';

  @override
  String numUsersTyping(int count) {
    return '$count usuàriïs escrivint…';
  }

  @override
  String get obtainingLocation => 'S’està obtenint la ubicació…';

  @override
  String get offensive => 'Ofensiu';

  @override
  String get offline => 'Fora de línia';

  @override
  String get ok => 'D\'acord';

  @override
  String get online => 'En línia';

  @override
  String get onlineKeyBackupEnabled =>
      'La còpia de seguretat de claus en línia està activada';

  @override
  String get oopsPushError =>
      'Ep! Sembla que s\'ha produït un error en configurar les notificacions.';

  @override
  String get oopsSomethingWentWrong => 'Alguna cosa ha anat malament…';

  @override
  String get openAppToReadMessages =>
      'Obre l\'aplicació per llegir els missatges';

  @override
  String get openCamera => 'Obre la càmera';

  @override
  String get oneClientLoggedOut =>
      'Una de les teves aplicacions ha tancat la sessió';

  @override
  String get addAccount => 'Afegeix un compte';

  @override
  String get editBundlesForAccount => 'Edita paquets per aquest compte';

  @override
  String get addToBundle => 'Afegeix al pquet';

  @override
  String get removeFromBundle => 'Esborra del paquet';

  @override
  String get bundleName => 'Nom del paquet';

  @override
  String get enableMultiAccounts =>
      '(Beta) Activa multi-compte en aquest dispositiu';

  @override
  String get openInMaps => 'Obre als mapes';

  @override
  String get link => 'Enllaç';

  @override
  String get serverRequiresEmail =>
      'Aquest servidor necessita validar la teva adreça per registrar-t\'hi.';

  @override
  String get or => 'O';

  @override
  String get participant => 'Participant';

  @override
  String get passphraseOrKey => 'contrasenya o clau de recuperació';

  @override
  String get password => 'Contrasenya';

  @override
  String get passwordForgotten => 'Contrasenya oblidada';

  @override
  String get passwordHasBeenChanged => 'La contrasenya ha canviat';

  @override
  String get overview => 'Resum';

  @override
  String get passwordRecoverySettings => 'Recuperació de contrasenya';

  @override
  String get passwordRecovery => 'Recuperació de contrassenya';

  @override
  String get pickImage => 'Selecciona una imatge';

  @override
  String get pin => 'Fixa';

  @override
  String play(String fileName) {
    return 'Reproduir $fileName';
  }

  @override
  String get pleaseChooseAPasscode => 'Tria un codi d\'accés';

  @override
  String get pleaseClickOnLink =>
      'Fes clic a l\'enllaç del correu i, després, segueix.';

  @override
  String get pleaseEnter4Digits =>
      'Introdueix 4 dígits o deixa-ho buit per desactivar el bloqueig.';

  @override
  String get pleaseEnterYourPassword => 'Introdueix la teva contrasenya';

  @override
  String get pleaseEnterYourPin => 'Introdueix el teu pin';

  @override
  String get pleaseEnterYourUsername => 'Introdueix el teu nom d\'usuàriï';

  @override
  String get pleaseFollowInstructionsOnWeb =>
      'Seguiu les instruccions al lloc web i toqueu «Següent».';

  @override
  String get privacy => 'Privadesa';

  @override
  String get publicRooms => 'Sales públiques';

  @override
  String get pushRules => 'Regles push';

  @override
  String get reason => 'Raó';

  @override
  String get recording => 'Enregistrant';

  @override
  String redactedBy(String username) {
    return 'Estripat per $username';
  }

  @override
  String get directChat => 'Xat directe';

  @override
  String redactedByBecause(String username, String reason) {
    return 'Estripat per $username per: \"$reason\"';
  }

  @override
  String redactedAnEvent(String username) {
    return '$username ha estripat un esdeveniment';
  }

  @override
  String get redactMessage => 'Estripa el missatge';

  @override
  String get register => 'Registra\'t';

  @override
  String get reject => 'Rebutja';

  @override
  String rejectedTheInvitation(String username) {
    return '$username ha rebutjat la invitació';
  }

  @override
  String get removeAllOtherDevices => 'Elimina tots els altres dispositius';

  @override
  String removedBy(String username) {
    return 'Eliminat per $username';
  }

  @override
  String get unbanFromChat => 'Aixeca el veto';

  @override
  String get removeYourAvatar => 'Esborra el teu avatar';

  @override
  String get replaceRoomWithNewerVersion =>
      'Substitueix la sala amb la versió més recent';

  @override
  String get reply => 'Respon';

  @override
  String get reportMessage => 'Denuncia el missatge';

  @override
  String get requestPermission => 'Sol·licita permís';

  @override
  String get roomHasBeenUpgraded => 'La sala s\'ha actualitzat';

  @override
  String get roomVersion => 'Versió de la sala';

  @override
  String get saveFile => 'Desa el fitxer';

  @override
  String get search => 'Cerca';

  @override
  String get security => 'Seguretat';

  @override
  String get recoveryKey => 'Clau de recuperació';

  @override
  String get recoveryKeyLost => 'Que has perdut la clau de recuperació?';

  @override
  String get send => 'Envia';

  @override
  String get sendAMessage => 'Envia un missatge';

  @override
  String get sendAsText => 'Envia com a text';

  @override
  String get sendAudio => 'Envia un àudio';

  @override
  String get sendFile => 'Envia un fitxer';

  @override
  String get sendImage => 'Envia una imatge';

  @override
  String sendImages(int count) {
    return 'Envia $count imatge';
  }

  @override
  String get sendMessages => 'Envia missatges';

  @override
  String get sendVideo => 'Envia un vídeo';

  @override
  String sentAFile(String username) {
    return '📁 $username ha enviat un fitxer';
  }

  @override
  String sentAnAudio(String username) {
    return '🎤 $username ha enviat un àudio';
  }

  @override
  String sentAPicture(String username) {
    return '🖼️ $username ha enviat una imatge';
  }

  @override
  String sentASticker(String username) {
    return '😊 $username ha enviat un adhesiu';
  }

  @override
  String sentAVideo(String username) {
    return '🎥 $username ha enviat un vídeo';
  }

  @override
  String sentCallInformations(String senderName) {
    return '$senderName ha enviat informació de trucada';
  }

  @override
  String get setAsCanonicalAlias => 'Defineix com a àlies principal';

  @override
  String get setChatDescription => 'Posa una descripció de xat';

  @override
  String get setStatus => 'Defineix l’estat';

  @override
  String get settings => 'Paràmetres';

  @override
  String get share => 'Comparteix';

  @override
  String sharedTheLocation(String username) {
    return '$username n’ha compartit la ubicació';
  }

  @override
  String get shareLocation => 'Comparteix la ubicació';

  @override
  String get showPassword => 'Mostra la contrasenya';

  @override
  String get presencesToggle =>
      'Mostra els missatges d\'estat d\'altres usuàrïis';

  @override
  String get skip => 'Omet';

  @override
  String get sourceCode => 'Codi font';

  @override
  String get spaceIsPublic => 'L’espai és públic';

  @override
  String get spaceName => 'Nom de l’espai';

  @override
  String startedACall(String senderName) {
    return '$senderName ha iniciat una trucada';
  }

  @override
  String get status => 'Estat';

  @override
  String get statusExampleMessage => 'Com us sentiu avui?';

  @override
  String get submit => 'Envia';

  @override
  String get synchronizingPleaseWait => 'S’està sincronitzant… Espereu.';

  @override
  String synchronizingPleaseWaitCounter(String percentage) {
    return ' S\'està sincronitzant... ($percentage%)';
  }

  @override
  String get systemTheme => 'Sistema';

  @override
  String get theyDontMatch => 'No coincideixen';

  @override
  String get theyMatch => 'Coincideixen';

  @override
  String get title => 'FluffyChat';

  @override
  String get tooManyRequestsWarning =>
      'Massa sol·licituds. Torna-ho a provar més tard!';

  @override
  String get transferFromAnotherDevice =>
      'Transfereix des d’un altre dispositiu';

  @override
  String get tryToSendAgain => 'Intenta tornar a enviar';

  @override
  String get unavailable => 'No disponible';

  @override
  String unbannedUser(String username, String targetName) {
    return '$username ha aixecat el veto a $targetName';
  }

  @override
  String get unblockDevice => 'Desbloqueja dispositiu';

  @override
  String get unknownDevice => 'Dispositiu desconegut';

  @override
  String get unknownEncryptionAlgorithm =>
      'L’algorisme de xifratge és desconegut';

  @override
  String unknownEvent(String type) {
    return 'Esdeveniment desconegut \'$type\'';
  }

  @override
  String get unmuteChat => 'Deixa de silenciar el xat';

  @override
  String get unpin => 'Deixa de fixar';

  @override
  String userAndOthersAreTyping(String username, int count) {
    return '$username i $count més estan escrivint…';
  }

  @override
  String userAndUserAreTyping(String username, String username2) {
    return '$username i $username2 estan escrivint…';
  }

  @override
  String userIsTyping(String username) {
    return '$username està escrivint…';
  }

  @override
  String userLeftTheChat(String username) {
    return '🚪 $username ha marxat del xat';
  }

  @override
  String get username => 'Nom d’usuàriï';

  @override
  String userSentUnknownEvent(String username, String type) {
    return '$username ha enviat un esdeveniment $type';
  }

  @override
  String get unverified => 'No verificat';

  @override
  String get verified => 'Verificat';

  @override
  String get verify => 'Verifica';

  @override
  String get verifyStart => 'Inicia la verificació';

  @override
  String get verifySuccess => 'T\'has verificat correctament!';

  @override
  String get verifyTitle => 'Verificant un altre compte';

  @override
  String get videoCall => 'Videotrucada';

  @override
  String get visibilityOfTheChatHistory => 'Visibilitat de l’historial del xat';

  @override
  String get visibleForAllParticipants => 'Visible per a tots els participants';

  @override
  String get visibleForEveryone => 'Visible per a tothom';

  @override
  String get voiceMessage => 'Missatge de veu';

  @override
  String get waitingPartnerAcceptRequest =>
      'S’està esperant que l’altre accepti la sol·licitud…';

  @override
  String get waitingPartnerEmoji =>
      'S’està esperant que l’altre accepti l’emoji…';

  @override
  String get waitingPartnerNumbers =>
      'S’està esperant que l’altre accepti els nombres…';

  @override
  String get warning => 'Atenció!';

  @override
  String get weSentYouAnEmail =>
      'Us hem enviat un missatge de correu electrònic';

  @override
  String get whoCanPerformWhichAction => 'Qui pot efectuar quina acció';

  @override
  String get whoIsAllowedToJoinThisGroup => 'Qui pot unir-se a aquest grup';

  @override
  String get whyDoYouWantToReportThis => 'Per què voleu denunciar això?';

  @override
  String get wipeChatBackup =>
      'Voleu suprimir la còpia de seguretat dels xats per a crear una clau de recuperació nova?';

  @override
  String get withTheseAddressesRecoveryDescription =>
      'Amb aquestes adreces, si ho necessiteu, podeu recuperar la vostra contrasenya.';

  @override
  String get writeAMessage => 'Escriviu un missatge…';

  @override
  String get yes => 'Sí';

  @override
  String get you => 'Vós';

  @override
  String get youAreNoLongerParticipatingInThisChat =>
      'Ja no participeu en aquest xat';

  @override
  String get youHaveBeenBannedFromThisChat => 'T\'han vetat en aquest xat';

  @override
  String get yourPublicKey => 'La vostra clau pública';

  @override
  String get messageInfo => 'Informació del missatge';

  @override
  String get time => 'Temps';

  @override
  String get messageType => 'Tipus de missatge';

  @override
  String get sender => 'Remitent';

  @override
  String get openGallery => 'Obre la galeria';

  @override
  String get removeFromSpace => 'Esborra de l\'espai';

  @override
  String get start => 'Comença';

  @override
  String get pleaseEnterRecoveryKeyDescription =>
      'Per desbloquejar els missatges antics, introdueix la clau de recuperació que vas generar en una sessió anterior. La clau de recuperació NO és la teva contrasenya.';

  @override
  String get openChat => 'Obre el xat';

  @override
  String get markAsRead => 'Marca com a llegit';

  @override
  String get reportUser => 'Denuncia l\'usuàrïi';

  @override
  String get dismiss => 'Ignora-ho';

  @override
  String reactedWith(String sender, String reaction) {
    return '$sender ha reaccionat amb $reaction';
  }

  @override
  String get pinMessage => 'Fixa a la sala';

  @override
  String get confirmEventUnpin =>
      'Vols desfixar l\'esdeveniment permanentment?';

  @override
  String get emojis => 'Emojis';

  @override
  String get placeCall => 'Truca';

  @override
  String get voiceCall => 'Videotrucada';

  @override
  String get unsupportedAndroidVersion =>
      'Aquesta versió d\'Android és incompatible';

  @override
  String get unsupportedAndroidVersionLong =>
      'Aquesta funcionalitat només funciona amb versions d\'Android més noves.';

  @override
  String get videoCallsBetaWarning =>
      'Tingues en compte que les trucades de vídeo estan encara en beta. Pot ser que no funcioni bé o que falli en alguna plataforma.';

  @override
  String get experimentalVideoCalls => 'Trucades de vídeo experimentals';

  @override
  String get youRejectedTheInvitation => 'Has rebutjat la invitació';

  @override
  String get youJoinedTheChat => 'T\'has afegit al xat';

  @override
  String get youAcceptedTheInvitation => '👍 Has acceptat la invitació';

  @override
  String youBannedUser(String user) {
    return 'Has vetat a $user';
  }

  @override
  String youHaveWithdrawnTheInvitationFor(String user) {
    return 'Has rebutjat la invitació de $user';
  }

  @override
  String youInvitedBy(String user) {
    return '📩 $user t\'ha convidat';
  }

  @override
  String invitedBy(String user) {
    return '📩 Convidadi per $user';
  }

  @override
  String youInvitedUser(String user) {
    return '📩 Has convidat a $user';
  }

  @override
  String youKicked(String user) {
    return '👞 Has expulsat a $user';
  }

  @override
  String youKickedAndBanned(String user) {
    return '🙅 Has expulsat i vetat a $user';
  }

  @override
  String youUnbannedUser(String user) {
    return 'Has aixecat el veto a $user';
  }

  @override
  String hasKnocked(String user) {
    return '🚪 $user pica a la porta';
  }

  @override
  String get usersMustKnock => 'Lis membres han de picar a la porta';

  @override
  String get noOneCanJoin => 'Ningú s\'hi pot ficar';

  @override
  String get knock => 'Pica';

  @override
  String get users => 'Usuàrïis';

  @override
  String get unlockOldMessages => 'Desbloqueja els missatges antics';

  @override
  String get storeInSecureStorageDescription =>
      'Desa la clau de recuperació en l\'emmagatzematge segur d\'aquest dispositiu.';

  @override
  String get saveKeyManuallyDescription =>
      'Per desar aquesta clau manualment, pica l\'eina de compartir o copia-la al porta-retalls.';

  @override
  String get storeInAndroidKeystore => 'Desa en la Android KeyStore';

  @override
  String get storeInAppleKeyChain => 'Desa en la Apple KeyChain';

  @override
  String get storeSecurlyOnThisDevice =>
      'Desa de forma segura en aquest dispositiu';

  @override
  String countFiles(int count) {
    return '$count arxius';
  }

  @override
  String get user => 'Usuàrïi';

  @override
  String get custom => 'Personalitzat';

  @override
  String get foregroundServiceRunning =>
      'Aquesta notificació apareix quan el servei de primer pla està corrent.';

  @override
  String get screenSharingTitle => 'compartició de pantalla';

  @override
  String get screenSharingDetail =>
      'Estàs compartint la teva pantalla a FluffyChat';

  @override
  String get whyIsThisMessageEncrypted =>
      'Per què no es pot llegir aquest missatge?';

  @override
  String get noKeyForThisMessage =>
      'Això pot passar si el missatge es va enviar abans que haguessis iniciat sessió al teu compte des d\'aquest dispositiu.\n\nTambé pot ser que l\'emissor hagi bloquejat el teu dispositiu o que la connexió a internet anés malament.\n\nQue pots llegir el missatge des d\'una altra sessió? Si és així, llavors pots transferir-lo! Ves a Paràmetres → Dispositius i assegura\'t que els teus dispositius s\'ha verificat mútuament. Quan obris la sala la propera vegada i totes dues sessions estiguin executant-se, en primer pla, llavors les claus es trasnsmetran automàticament.\n\nVols evitar perdre les claus en tancar la sessió o en canviar de dispositiu? Llavors assegura\'t que has activat la còpia de seguretat del xat als paràmetres.';

  @override
  String get newGroup => 'Grup nou';

  @override
  String get newSpace => 'Espai nou';

  @override
  String get allSpaces => 'Tots els espais';

  @override
  String get hidePresences => 'Amagar la llista de Status?';

  @override
  String get doNotShowAgain => 'No ho tornis a mostrar';

  @override
  String wasDirectChatDisplayName(String oldDisplayName) {
    return 'Xat buit ( era $oldDisplayName)';
  }

  @override
  String get newSpaceDescription =>
      'Els espais et permeten consolidar els teus xats i construir comunitats públiques o privades.';

  @override
  String get encryptThisChat => 'Xifra aquest xat';

  @override
  String get disableEncryptionWarning =>
      'Per motius de seguretat, un cop activat, no es pot desactivar el xifratge.';

  @override
  String get sorryThatsNotPossible => 'Aquesta acció no és possible';

  @override
  String get deviceKeys => 'Claus del dispositiu:';

  @override
  String get reopenChat => 'Reobre el xat';

  @override
  String get noBackupWarning =>
      'Compte! Si no actives la còpia de seguretat dels xats, perdràs accés als teus missatges xifrats. És molt recomanable activar-ho abans de tancar la sessió.';

  @override
  String get noOtherDevicesFound => 'No s\'han trobat més dispositius';

  @override
  String fileIsTooBigForServer(String max) {
    return 'No s\'ha pogut enviar! El servidor només accepta adjunts de fins a $max.';
  }

  @override
  String fileHasBeenSavedAt(String path) {
    return 'S\'ha desat l\'arxiu a $path';
  }

  @override
  String get jumpToLastReadMessage => 'Salta a l\'últim missatge llegit';

  @override
  String get readUpToHere => 'Llegit fins aquí';

  @override
  String get jump => 'Salta';

  @override
  String get openLinkInBrowser => 'Obre l\'enllaç en un navegador';

  @override
  String get reportErrorDescription =>
      '😭 Oh no. Hi ha hagut algun error. Si vols, pots informar d\'aquest bug a l\'equip de desenvolupament.';

  @override
  String get report => 'informa';

  @override
  String get setColorTheme => 'Tria el color del tema:';

  @override
  String get invite => 'Convida';

  @override
  String get inviteGroupChat => '📨 Invitació de grup';

  @override
  String get invalidInput => 'L\'entrada no és vàlida!';

  @override
  String wrongPinEntered(int seconds) {
    return 'Pin incorrecte! Torna-ho a provar en $seconds segons...';
  }

  @override
  String get pleaseEnterANumber => 'Introdueix un número major que 0';

  @override
  String get archiveRoomDescription =>
      'Aquest xat serà arxivat. Els altres contactes del grup ho veuran com si haguessis abandonat el xat.';

  @override
  String get roomUpgradeDescription =>
      'El xat serà recreat amb una versió de sala nova. Totis lis participants seran notificadis que han de canviar al nou xat. Pots llegir més sobre les versions de sala a https://spec.matrix.org/latest/rooms/';

  @override
  String get removeDevicesDescription =>
      'Tancaràs la sessió d\'aquest dispositiu i no hi podràs rebre més missatges.';

  @override
  String get banUserDescription =>
      'Es vetarà li usuàriï al xat i no podrà tornar-hi a entrar fins que se li aixequi el veto.';

  @override
  String get unbanUserDescription =>
      'L\'usuàrïi ja pot tornar a entrar al xat.';

  @override
  String get kickUserDescription =>
      'Li usuàrïi ha estat expulsadi però no vetadi. Als xats públics, pot tornar-hi a entrar en qualsevol moment.';

  @override
  String get makeAdminDescription =>
      'Un cop hagis fet admin aquesta persona ja no podràs desfer-ho, ja que llavors tindrà els mateixos permisos que tu.';

  @override
  String get pushNotificationsNotAvailable =>
      'Les notificacions push no estan disponibles';

  @override
  String get learnMore => 'Llegeix-ne més';

  @override
  String get yourGlobalUserIdIs => 'La teva ID global és: ';

  @override
  String noUsersFoundWithQuery(String query) {
    return 'No s\'ha trobat cap usuàrïi amb \"$query\". Revisa si ho has escrit malament.';
  }

  @override
  String get knocking => 'S\'està picant';

  @override
  String chatCanBeDiscoveredViaSearchOnServer(String server) {
    return 'El xat es pot descobrir amb la cerca de $server';
  }

  @override
  String get searchChatsRooms => 'Cerca #sales, @usuariïs...';

  @override
  String get nothingFound => 'No s\'ha trobat res...';

  @override
  String get groupName => 'Nom del grup';

  @override
  String get createGroupAndInviteUsers => 'Crea un grup i convida-hi usuàrïis';

  @override
  String get groupCanBeFoundViaSearch =>
      'El grup es pot trobar per la cerca general';

  @override
  String get wrongRecoveryKey =>
      'Malauradament, aquesta clau de recuperació no és la correcta.';

  @override
  String get commandHint_sendraw => 'Envia un json pelat';

  @override
  String get databaseMigrationTitle => 'La base de dades ha estat optimitzada';

  @override
  String get databaseMigrationBody => 'Espereu un moment, si us plau.';

  @override
  String get leaveEmptyToClearStatus =>
      'Per esborrar el teu estat, deixa-ho en blanc.';

  @override
  String get select => 'Tria';

  @override
  String get searchForUsers => 'Cerca @usuariïs...';

  @override
  String get pleaseEnterYourCurrentPassword =>
      'Fica la teva contrasenya actual';

  @override
  String get newPassword => 'Contrasenya nova';

  @override
  String get pleaseChooseAStrongPassword => 'Tria una contrasenya forta';

  @override
  String get passwordsDoNotMatch => 'Les contrasenyes no coincideixen';

  @override
  String get passwordIsWrong => 'La contrasenya introduïda és incorrecta';

  @override
  String get publicChatAddresses => 'Adreces públiques del xat';

  @override
  String get createNewAddress => 'Crea una adreça nova';

  @override
  String get joinSpace => 'Fica\'t a l\'espai';

  @override
  String get publicSpaces => 'Espais públics';

  @override
  String get addChatOrSubSpace => 'Afegeix un xat o un subespai';

  @override
  String get thisDevice => 'Aquest dispositiu:';

  @override
  String get initAppError =>
      'S\'ha produït un error mentre s\'inicialitzava l\'aplicació';

  @override
  String searchIn(String chat) {
    return 'Cerca al xat \"$chat\"...';
  }

  @override
  String get searchMore => 'Cerca més...';

  @override
  String get gallery => 'Galeria';

  @override
  String get files => 'Arxius';

  @override
  String sessionLostBody(String url, String error) {
    return 'S\'ha perdut la teva sessió. Si us plau, comunica aquest error a l\'equip de desenvolupament a $url. El missatge d\'error és: $error';
  }

  @override
  String restoreSessionBody(String url, String error) {
    return 'L\'aplicació provarà de restaurar la teva sessió des de la còpia de seguretat. Si us plau, comunica aquest error a l\'equi pde desenvolupament a $url. El missatge d\'error és $error';
  }

  @override
  String get sendReadReceipts => 'Envia informes de tecleig';

  @override
  String get sendTypingNotificationsDescription =>
      'Lis altris participants d\'un xat poden veure quan estàs teclejant un missatge nou.';

  @override
  String get sendReadReceiptsDescription =>
      'Lis altris participants d\'un xat poden veure quan has llegit un missatge.';

  @override
  String get formattedMessages => 'Missatges amb format';

  @override
  String get formattedMessagesDescription =>
      'Mostra contingut amb format enriquit com text en cursiva, fent servir markdown.';

  @override
  String get verifyOtherUser => '🔐 Verifica uni altri usuàrïi';

  @override
  String get verifyOtherUserDescription =>
      'Si verifiques aquesti usuàrïi, podràs estar seguri de a qui estàs escrivint. . 💪\n\nQuan inicies una verificació, l\'altra persona i tu veureu un missatge emergent a l\'app. Us sortiran un seguit d\'emojis o números a cada pantalla, que haureu de comparar.\n\nLa millor manera de fer-ho és quedar en persona o fer una vídeo-trucada. 👭';

  @override
  String get verifyOtherDevice => '🔐 Verifica un altre dispositiu';

  @override
  String get verifyOtherDeviceDescription =>
      'Quan verifiques un altre dispositiu, aquests poden intercanviar claus, així que es millora la seguretat total. 💪 Quan comences una verificació, apareixerà un missatge emergent a tots dos dispositius. A cadascun hi apareixerà un seguit d\'emojis o de números que hauràs de comparar. El millor és tenir tots dos dispositius a mà abans d\'iniciar la verificació. 🤳';

  @override
  String acceptedKeyVerification(String sender) {
    return '$sender ha acceptat la verificació de claus';
  }

  @override
  String canceledKeyVerification(String sender) {
    return '$sender ha canceŀlat la verificació de claus';
  }

  @override
  String completedKeyVerification(String sender) {
    return '$sender ha comletat la verificació de claus';
  }

  @override
  String isReadyForKeyVerification(String sender) {
    return '$sender està a punt per verificar les claus';
  }

  @override
  String requestedKeyVerification(String sender) {
    return '$sender ha soŀlicitat verificar claus';
  }

  @override
  String startedKeyVerification(String sender) {
    return '$sender ha iniciat la verificació de claus';
  }

  @override
  String get transparent => 'Transparent';

  @override
  String get incomingMessages => 'Missatge d\'entrada';

  @override
  String get stickers => 'Enganxines';

  @override
  String get discover => 'Descobreix';

  @override
  String get commandHint_ignore => 'Ignora el compte de matrix especificat';

  @override
  String get commandHint_unignore =>
      'Deixa d\'ignorar el compt de matrix especificat';

  @override
  String unreadChatsInApp(String appname, String unread) {
    return '$appname: $unread converses pendents';
  }

  @override
  String get noDatabaseEncryption =>
      'No es pot xifrar la base de dades en aquesta plataforma';

  @override
  String thereAreCountUsersBlocked(Object count) {
    return 'Ara mateix hi ha $count usuàriïs bloquejadis.';
  }

  @override
  String get restricted => 'Restringit';

  @override
  String get knockRestricted => 'No es pot picar a la porta';

  @override
  String goToSpace(Object space) {
    return 'Ves a l\'espai $space';
  }

  @override
  String get markAsUnread => 'Marca com a no llegit';

  @override
  String userLevel(int level) {
    return '$level - Usuàriï';
  }

  @override
  String moderatorLevel(int level) {
    return '$level - Moderadori';
  }

  @override
  String adminLevel(int level) {
    return '$level - Admin';
  }

  @override
  String get changeGeneralChatSettings => 'Canvia les opcions generals de xat';

  @override
  String get inviteOtherUsers => 'Convida més gent a la conversa';

  @override
  String get changeTheChatPermissions => 'Canvia els permisos del xat';

  @override
  String get changeTheVisibilityOfChatHistory =>
      'Canvia la visibilitat de l\'historial de conversa';

  @override
  String get changeTheCanonicalRoomAlias =>
      'Canvia l\'adreça principal del xat';

  @override
  String get sendRoomNotifications => 'Envia notificacions @room';

  @override
  String get changeTheDescriptionOfTheGroup => 'Canvia la descripció del xat';

  @override
  String get chatPermissionsDescription =>
      'Defineix quin nivell de permisos cal per cada acció en aquest xat. Els nivells 0, 50 i 100 normalment representen usuàriïs, mods i admins, però es pot canviar.';

  @override
  String updateInstalled(String version) {
    return '🎉 S\'ha actualitzat a la versió $version!';
  }

  @override
  String get changelog => 'Registre de canvis';

  @override
  String get sendCanceled => 'S\'ha canceŀlat l\'enviament';

  @override
  String get loginWithMatrixId => 'Entra amb l\'id de Matrix';

  @override
  String get doesNotSeemToBeAValidHomeserver =>
      'No sembla un servidor compatible. Pot ser que la URL estigui malament?';

  @override
  String get calculatingFileSize => 'S\'està calculant la mida de l\'arxiu...';

  @override
  String get prepareSendingAttachment =>
      'S\'està preparant per enviar l\'adjunt...';

  @override
  String get sendingAttachment => 'S\'està enviant l\'adjunt...';

  @override
  String get generatingVideoThumbnail =>
      'S\'està generant la miniatura del vídeo...';

  @override
  String get compressVideo => 'S\'està comprimint el vídeo...';

  @override
  String sendingAttachmentCountOfCount(int index, int length) {
    return 'S\'està enviant l\'adjunt $index de $length...';
  }

  @override
  String serverLimitReached(int seconds) {
    return 'S\'ha arribat al límit del servidor! Esperant $seconds segons...';
  }

  @override
  String get oneOfYourDevicesIsNotVerified =>
      'Un dels teus dispositius no està verificat';

  @override
  String get noticeChatBackupDeviceVerification =>
      'Nota: quan connectes tots els dispositius al backup del xat, es verifiquen automàticament.';

  @override
  String get continueText => 'Continua';

  @override
  String get welcomeText =>
      'Hola hola! 👋 Això és FluffyChat. Pots iniciar sessió en qualsevol servidor compatible amb https://matrix.org. I llavors xatejar amb qualsevol. És una xarxa enorme de missatgeria descentralitzada !';

  @override
  String get blur => 'Difumina:';

  @override
  String get opacity => 'Opacitat:';

  @override
  String get setWallpaper => 'Tria imatge de fons';

  @override
  String get manageAccount => 'Gestiona el compte';

  @override
  String get noContactInformationProvided =>
      'El servidor no ofereix cap informació de contacte vàlida';

  @override
  String get contactServerAdmin => 'Contacta l\'admin del servidor';

  @override
  String get contactServerSecurity =>
      'Contacta l\'equip de seguretat del servidor';

  @override
  String get supportPage => 'Pàgina de suport';

  @override
  String get serverInformation => 'Informació del servidor:';

  @override
  String get name => 'Nom';

  @override
  String get version => 'Versió';

  @override
  String get website => 'Lloc web';

  @override
  String get compress => 'Comprimeix';

  @override
  String get boldText => 'Text en negreta';

  @override
  String get italicText => 'Text en cursiva';

  @override
  String get strikeThrough => 'Text ratllat';

  @override
  String get pleaseFillOut => 'Emplena';

  @override
  String get invalidUrl => 'URL invàlida';

  @override
  String get addLink => 'Afegeix un enllaç';

  @override
  String get unableToJoinChat =>
      'No s\'ha pogut entrar al xat. Pot ser que l\'altri participant hagi tancat la conversa.';

  @override
  String get previous => 'Anterior';

  @override
  String get otherPartyNotLoggedIn =>
      'L\'altra persona no està en línia ara mateix i per tant no pot rebre missatges!';

  @override
  String appWantsToUseForLogin(String server) {
    return 'Fes servir \'$server\' per iniciar sessió';
  }

  @override
  String get appWantsToUseForLoginDescription =>
      'Consenteixes que l\'app i la web comparteixen informació sobre tu.';

  @override
  String get open => 'Obre';

  @override
  String get waitingForServer => 'S\'està esperant el servidor...';

  @override
  String get newChatRequest => '📩 Soŀlicitud de missatge';

  @override
  String get contentNotificationSettings =>
      'Opcions de notificació de continguts';

  @override
  String get generalNotificationSettings => 'Opcions de notificacions generals';

  @override
  String get roomNotificationSettings => 'Opcions de notificacions de sales';

  @override
  String get userSpecificNotificationSettings =>
      'Opcions de notificacions d\'usuàriï';

  @override
  String get otherNotificationSettings => 'Altres opcions de notificacions';

  @override
  String get notificationRuleContainsUserName => 'Conté el nom d\'usuàriï';

  @override
  String get notificationRuleContainsUserNameDescription =>
      'Notifica l\'usuàriï quan un missatge contingui el seu nom.';

  @override
  String get notificationRuleMaster => 'Silencia totes les notificacions';

  @override
  String get notificationRuleMasterDescription =>
      'Ignora totes les altres regles i deshabilita totes les notificacions.';

  @override
  String get notificationRuleSuppressNotices =>
      'Elimina els missatges automàtics';

  @override
  String get notificationRuleSuppressNoticesDescription =>
      'No envia notificacions relacionades amb usuàriïs automàtics com els bots.';

  @override
  String get notificationRuleInviteForMe => 'Invitació per a mi';

  @override
  String get notificationRuleInviteForMeDescription =>
      'Notifica l\'usuàriï quan és convidadi a una sala.';

  @override
  String get notificationRuleMemberEvent => 'Canvis de membres';

  @override
  String get notificationRuleMemberEventDescription =>
      'Ignora les notificacions quan entra o surt algú d\'una sala.';

  @override
  String get notificationRuleIsUserMention => 'Mencions';

  @override
  String get notificationRuleIsUserMentionDescription =>
      'Notifica quan mencionin l\'usuàriï en un missatge.';

  @override
  String get notificationRuleContainsDisplayName => 'Conté el nom visible';

  @override
  String get notificationRuleContainsDisplayNameDescription =>
      'Notifica l\'usuàriï quan un missatge contingui el seu nom per mostrar.';

  @override
  String get notificationRuleIsRoomMention => 'Menció de sala';

  @override
  String get notificationRuleIsRoomMentionDescription =>
      'Notifica l\'usuàriï quan es s\'esmenti la sala.';

  @override
  String get notificationRuleRoomnotif => 'Notificació de sala';

  @override
  String get notificationRuleRoomnotifDescription =>
      'Notifica l\'usuàriï quan un missatge contingui \'@room\'.';

  @override
  String get notificationRuleTombstone => 'Làpida';

  @override
  String get notificationRuleTombstoneDescription =>
      'Notifica l\'usuàriï dels missatges de desactivació de sales.';

  @override
  String get notificationRuleReaction => 'Reacció';

  @override
  String get notificationRuleReactionDescription =>
      'Ignora les notificacions sobre reaccions.';

  @override
  String get notificationRuleRoomServerAcl =>
      'Regles ACL del servidor d\'una sala';

  @override
  String get notificationRuleRoomServerAclDescription =>
      'Ignora les notificacions sobre les regles d\'accés (ACL) del servidor d\'una sala.';

  @override
  String get notificationRuleSuppressEdits => 'Elimina les edicions';

  @override
  String get notificationRuleSuppressEditsDescription =>
      'Ignora les notificacions per missatges editats.';

  @override
  String get notificationRuleCall => 'Trucada';

  @override
  String get notificationRuleCallDescription =>
      'Notifica l\'usuàriï de trucades.';

  @override
  String get notificationRuleEncryptedRoomOneToOne => 'Converses xifrades';

  @override
  String get notificationRuleEncryptedRoomOneToOneDescription =>
      'Notifica l\'usuàriï de missatges en sales xifrades un a un, converses de dues persones.';

  @override
  String get notificationRuleRoomOneToOne => 'Converses';

  @override
  String get notificationRuleRoomOneToOneDescription =>
      'Notifica l\'usuàriï de missatges en converses de dues persones, sales un a un.';

  @override
  String get notificationRuleMessage => 'Missatge';

  @override
  String get notificationRuleMessageDescription =>
      'Notifica l\'usuàriï sobre missatges generals.';

  @override
  String get notificationRuleEncrypted => 'Xifrat';

  @override
  String get notificationRuleEncryptedDescription =>
      'Notifica l\'usuàriï de missatges en sales xifrades.';

  @override
  String get notificationRuleJitsi => 'Jitsi';

  @override
  String get notificationRuleJitsiDescription =>
      'Notifica l\'usuàriï sobre activitat del giny de Jitsi.';

  @override
  String get notificationRuleServerAcl => 'Ignora canvis en ACL de servidor';

  @override
  String get notificationRuleServerAclDescription =>
      'Ignora les notificacions per canvis en les regles d\'accés (ACL) de servidor.';

  @override
  String unknownPushRule(String rule) {
    return 'No es coneix la regla push \'$rule\'';
  }

  @override
  String sentVoiceMessage(String sender, String duration) {
    return '🎙️ $duration - Missatge de veu de $sender';
  }

  @override
  String get deletePushRuleCanNotBeUndone =>
      'Si esborres aquesta opció de notificació no ho podràs tornar a canviar.';

  @override
  String get more => 'Més';

  @override
  String get shareKeysWith => 'Comparteix les claus amb...';

  @override
  String get shareKeysWithDescription =>
      'Quins dispositius vols que puguin llegir els teus missatges xifrats?';

  @override
  String get allDevices => 'Tots els dispositius';

  @override
  String get crossVerifiedDevicesIfEnabled =>
      'Els dispositius verificats mútuament, si està activat';

  @override
  String get crossVerifiedDevices => 'Els dispositius verificats mútuament';

  @override
  String get verifiedDevicesOnly => 'Només els dispositius verificats';

  @override
  String get takeAPhoto => 'Fes una foto';

  @override
  String get recordAVideo => 'Grava un vídeo';

  @override
  String get optionalMessage => '(Opcional) missatge...';

  @override
  String get notSupportedOnThisDevice => 'No suportat en aquest dispositiu';

  @override
  String get enterNewChat => 'Entra al nou xat';

  @override
  String get approve => 'Aprova';

  @override
  String get youHaveKnocked => 'T\'han picat a la porta';

  @override
  String get pleaseWaitUntilInvited =>
      'Ara espera fins que algú de la sala t\'hi deixi entrar.';

  @override
  String get commandHint_logout => 'Tanca la sessió per aquest dispositiu';

  @override
  String get commandHint_logoutall => 'Tanca totes les sessions actives';

  @override
  String get displayNavigationRail => 'Mostra la barra de navegació al mòbil';

  @override
  String get customReaction => 'Reacció personalitzada';

  @override
  String get moreEvents => 'Altres esdeveniments';

  @override
  String get declineInvitation => 'Rebutja la invitació';

  @override
  String get noMessagesYet => 'No hi ha cap missatge';

  @override
  String get longPressToRecordVoiceMessage =>
      'Deixa picat per gravar un missatge de veu.';

  @override
  String get pause => 'Pausa';

  @override
  String get resume => 'Continua';

  @override
  String get removeFromSpaceDescription =>
      'S\'esborrarà de l\'espai el xat, però encara apareixerà a la llista de xats.';

  @override
  String countChats(int chats) {
    return '$chats xats';
  }

  @override
  String spaceMemberOf(String spaces) {
    return 'Membre dels espais $spaces';
  }

  @override
  String spaceMemberOfCanKnock(String spaces) {
    return 'Membre dels espais $spaces poden picar a porta';
  }

  @override
  String startedAPoll(String username) {
    return '$username ha creat una enquesta.';
  }

  @override
  String get poll => 'Enquesta';

  @override
  String get startPoll => 'Comença una enquesta';

  @override
  String get endPoll => 'Acaba l\'enquesta';

  @override
  String get answersVisible => 'Respostes visibles';

  @override
  String get pollQuestion => 'Pregunta de l\'enquesta';

  @override
  String get answerOption => 'Opció de resposta';

  @override
  String get addAnswerOption => 'Afegeix una opció';

  @override
  String get allowMultipleAnswers => 'Permet múltiples respostes';

  @override
  String get pollHasBeenEnded => 'Ha acabat l\'enquesta';

  @override
  String countVotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vots',
      one: 'Un vot',
    );
    return '$_temp0';
  }

  @override
  String get answersWillBeVisibleWhenPollHasEnded =>
      'Les respostes seran visibles quan s\'acabi l\'enquesta';

  @override
  String get replyInThread => 'Respon en un fil';

  @override
  String countReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count respostes',
      one: 'Una resposta',
    );
    return '$_temp0';
  }

  @override
  String get thread => 'Fil';

  @override
  String get backToMainChat => 'Torna al xat principal';

  @override
  String get saveChanges => 'Desa els canvis';

  @override
  String get createSticker => 'Crea un sticker o un emoji';

  @override
  String get useAsSticker => 'Agafa com a sticker';

  @override
  String get useAsEmoji => 'Agafa com a emoji';

  @override
  String get stickerPackNameAlreadyExists =>
      'Ja existeix aquest nom per un pack de stickers';

  @override
  String get newStickerPack => 'Nou pack de stickers';

  @override
  String get stickerPackName => 'Nom del pack de stickers';

  @override
  String get attribution => 'Atribució';

  @override
  String get skipChatBackup => 'Omet la còpia de seguretat del xat';

  @override
  String get skipChatBackupWarning =>
      'N\'estàs seguri? Si no actives la còpia de seguretat pots perdre accés als teus missatges si canvies de dispositiu.';

  @override
  String get loadingMessages => 'S\'estan carregant més missatges';

  @override
  String get setupChatBackup => 'Activa la còpia de seguretat del xat';

  @override
  String get noMoreResultsFound => 'No s\'han trobat més resultats';

  @override
  String chatSearchedUntil(String time) {
    return 'S\'ha cercat fins a $time';
  }

  @override
  String get federationBaseUrl => 'URL base de federació';

  @override
  String get clientWellKnownInformation => 'Informació coneguda del client:';

  @override
  String get baseUrl => 'URL base';

  @override
  String get identityServer => 'Servidor d\'identitats:';

  @override
  String versionWithNumber(String version) {
    return 'Versió: $version';
  }

  @override
  String get logs => 'Registres';

  @override
  String get advancedConfigs => 'Avançat';

  @override
  String get advancedConfigurations => 'Configuracions avançades';

  @override
  String get signIn => 'Obre sessió';

  @override
  String get createNewAccount => 'Crea un compte nou';

  @override
  String get signUpGreeting =>
      'El FluffyChat és descentralitzat! Tria un servidor on vulguis crear-t\'hi un compte, i som-hi!';

  @override
  String get signInGreeting =>
      'Si ja tens un compte a Matrix, benvingudi! Tria el teu servidor i inicia-hi sessió.';

  @override
  String get appIntro =>
      'Pots xatejar amb lis tevis amiguis amb Fluffychat. És una app de missatgeria [matrix] descentralitzada! Llegeix-ne més a https://matrix.org si vols, o inicia sessió.';

  @override
  String get theProcessWasCanceled => 'S\'ha canceŀlat el procés.';

  @override
  String get join => 'Entra';

  @override
  String get searchOrEnterHomeserverAddress =>
      'Cerca o introdueix l\'adreça del teu servidor';

  @override
  String get matrixId => 'ID de Matrix';

  @override
  String get setPowerLevel => 'Concedeix permisos';

  @override
  String get makeModerator => 'Fes moderadori';

  @override
  String get makeAdmin => 'Fes admin';

  @override
  String get removeModeratorRights => 'Treu els drets de moderadori';

  @override
  String get removeAdminRights => 'Treu els drets d\'admin';

  @override
  String get powerLevel => 'Nivell de permisos';

  @override
  String get setPowerLevelDescription =>
      'Els nivells de permisos defineixen què pot fer uni membre d\'aquesta sala, i es defineix per un número entre 0 i 100.';

  @override
  String get owner => 'Propietàriï';

  @override
  String get mute => 'Silencia';

  @override
  String get createNewChat => 'Crea un nou xat';

  @override
  String get reset => 'Reseteja';

  @override
  String get supportFluffyChat => 'Dona suport a FluffyChat';

  @override
  String get support => 'Aporta';

  @override
  String get fluffyChatSupportBannerMessage =>
      'El FluffyChat necessita la teva ajuda!\n❤️❤️❤️\nFluffyChat serà sempre gratuït, però el seu desenvolupament i allotjament costa diners.\nEl futur del projecte depèn del suport de persones com tu.';

  @override
  String get skipSupportingFluffyChat => 'Ignora el suport a FluffyChat';

  @override
  String get iDoNotWantToSupport => 'No vull donar suport';

  @override
  String get iAlreadySupportFluffyChat => 'Ja estic donant-hi suport';

  @override
  String get setLowPriority => 'Estableix una prioritat baixa';

  @override
  String get unsetLowPriority => 'Restableix la prioritat';

  @override
  String get removeCallFromChat => 'Treu la trucada del xat';

  @override
  String get removeCallFromChatDescription =>
      'Vols treure la trucada del xat per a totis lis membres?';

  @override
  String get removeCallForEveryone => 'Treu la trucada per tothom';

  @override
  String get startVoiceCall => 'Inicia una trucada';

  @override
  String get startVideoCall => 'Fes una videotrucada';

  @override
  String get joinVoiceCall => 'Fica\'t a la trucada';

  @override
  String get joinVideoCall => 'Fica\'t a la videotrucada';

  @override
  String get live => 'En directe';

  @override
  String get playSoundOnNotification => 'Notificacions sonores';

  @override
  String get addTag => 'Add tag';

  @override
  String get removeTag => 'Remove tag';

  @override
  String get tagName => 'Tag name';

  @override
  String get createNewTag => 'Create new tag';
}
