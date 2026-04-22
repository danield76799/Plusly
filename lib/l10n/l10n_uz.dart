// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class L10nUz extends L10n {
  L10nUz([String locale = 'uz']) : super(locale);

  @override
  String get alwaysUse24HourFormat => 'true';

  @override
  String get repeatPassword => 'Parolni takrorlang';

  @override
  String get notAnImage => 'Rasm fayli emas.';

  @override
  String get ignoreUser => 'Foydalanuvchini e’tiborsiz qoldirish';

  @override
  String get remove => 'O‘chirish';

  @override
  String get importNow => 'Hozir import qilish';

  @override
  String get importEmojis => 'Emojilarni import qilish';

  @override
  String get importFromZipFile => '.zip faylidan import qilish';

  @override
  String get exportEmotePack =>
      'Emotsiyalar to‘plamini .zip fayl ko‘rinishida eksport qilish';

  @override
  String get replace => 'Almashtirmoq';

  @override
  String get about => 'Biz haqimizda';

  @override
  String aboutHomeserver(String homeserver) {
    return '$homeserver haqida';
  }

  @override
  String get accept => 'Qabul qilmoq';

  @override
  String acceptedTheInvitation(String username) {
    return '👍 $username taklifni qabul qildi';
  }

  @override
  String get account => 'Hisob';

  @override
  String activatedEndToEndEncryption(String username) {
    return '🔐 $username shifrlashni yakunlash uchun faollashtirdi';
  }

  @override
  String get addEmail => 'Email qo‘shish';

  @override
  String get confirmMatrixId =>
      'Hisobingizni o‘chirish uchun Matrix ID hisobingizni tasdiqlang.';

  @override
  String supposedMxid(String mxid) {
    return 'Bu $mxid bo‘lishi kerak';
  }

  @override
  String get addToSpace => 'Maydonga qo‘shish';

  @override
  String get admin => 'Admin';

  @override
  String get alias => 'taxallus';

  @override
  String get all => 'Hammasi';

  @override
  String get allChats => 'Hamma suhbatlar';

  @override
  String get commandHint_roomupgrade =>
      'Bu guruhni berilgan guruh versiyasiga yangilang';

  @override
  String get commandHint_googly => 'G‘ilay ko‘zlarini yuboring';

  @override
  String get commandHint_cuddle => 'Erkalash yuborish';

  @override
  String get commandHint_hug => 'Quchoqlash yuborish';

  @override
  String googlyEyesContent(String senderName) {
    return '$senderName sizga gʻilay ko‘zlarini yubormoqda';
  }

  @override
  String cuddleContent(String senderName) {
    return '$senderName sizni erkalamoqda';
  }

  @override
  String hugContent(String senderName) {
    return '$senderName sizni quchoqlamoqda';
  }

  @override
  String answeredTheCall(String senderName) {
    return '$senderName chaqiruvga javob berdi';
  }

  @override
  String get anyoneCanJoin => 'Har kim qo‘shilishi mumkin';

  @override
  String get appLock => 'Ilova qulfi';

  @override
  String get appLockDescription =>
      'PIN kod ishlatilmayotganida ilovani qulflash';

  @override
  String get archive => 'Arxiv';

  @override
  String get areGuestsAllowedToJoin =>
      'Mehmon foydalanuvchilarga qo‘shilishga ruxsat berilganmi';

  @override
  String get areYouSure => 'Ishonchingiz komilmi?';

  @override
  String get areYouSureYouWantToLogout =>
      'Haqiqatan ham hisobingizdan chiqamoqchimisiz?';

  @override
  String get askSSSSSign =>
      'Narigi foydalanuvchini imzolash uchun xavfsiz do‘kon parol iborasi yoki tiklash kalitini kiriting.';

  @override
  String askVerificationRequest(String username) {
    return '${username}dan ushbu tasdiqlash so‘rovi qabul qilinsinmi?';
  }

  @override
  String get autoplayImages =>
      'Animatsiyali stikerlar va emojilarni avtomatik ijro etish';

  @override
  String badServerLoginTypesException(
    String serverVersions,
    String supportedVersions,
    Object suportedVersions,
  ) {
    return 'Homeserver quyidagi kirish turlarini qo\'llab-quvvatlaydi:\n$serverVersions\nLekin bu ilova faqat quyidagi turlarni qo\'llab-quvvatlaydi:\n$supportedVersions';
  }

  @override
  String get sendTypingNotifications => 'Yozish bildirishnomalarini yuborish';

  @override
  String get swipeRightToLeftToReply =>
      'Javob berish uchun o‘ngdan chapga suring';

  @override
  String get sendOnEnter => 'Enterda yuborish';

  @override
  String get noMoreChatsFound => 'Boshqa chatlar topilmadi...';

  @override
  String get noChatsFoundHere =>
      'Bu yerda hali chat topilmadi. Quyidagi tugmadan foydalanib, kimdir bilan yangi suhbat boshlang. ⤵️';

  @override
  String get unread => 'Oʻqilmagan';

  @override
  String get space => 'Boʻshliq';

  @override
  String get spaces => 'Boʻshliqlar';

  @override
  String get banFromChat => 'Suhbatdan taqiqlash';

  @override
  String get banned => 'Taqiqlangan';

  @override
  String bannedUser(String username, String targetName) {
    return '$username taqiqladi $targetName(ni)';
  }

  @override
  String get blockDevice => 'Qurilmani bloklash';

  @override
  String get blocked => 'Bloklandi';

  @override
  String get cancel => 'Bekor qilish';

  @override
  String cantOpenUri(String uri) {
    return '$uri URIni ochib boʻlmadi';
  }

  @override
  String get changeDeviceName => 'Qurilma nomini oʻzgartirish';

  @override
  String changedTheChatAvatar(String username) {
    return '$username suhbat avatarini oʻzgartirdi';
  }

  @override
  String changedTheChatDescription(Object username) {
    return '$username chat tavsifini o‘zgartirdi';
  }

  @override
  String changedTheChatDescriptionTo(String username, String description) {
    return '$username suhbat tavsifini \'$description\'ga oʻzgartirdi';
  }

  @override
  String changedTheChatName(Object username) {
    return '$username chat nomini o‘zgartirdi';
  }

  @override
  String changedTheChatNameTo(String username, String chatname) {
    return '$username suhbat nomini: \'$chatname\'ga oʻzgartirdi';
  }

  @override
  String changedTheChatPermissions(String username) {
    return '$username suhbat ruxsatnomalarini oʻzgartirdi';
  }

  @override
  String changedTheDisplaynameTo(String username, String displayname) {
    return '$username oʻzining nomini \'$displayname\'ga oʻzgartirdi';
  }

  @override
  String changedTheGuestAccessRules(String username) {
    return '$username mehmon kirish qoidalarini oʻzgartirdi';
  }

  @override
  String changedTheGuestAccessRulesTo(String username, String rules) {
    return '$username mehmon kirish qoidalarini: ${rules}ga oʻzgartirdi';
  }

  @override
  String changedTheHistoryVisibility(String username) {
    return '$username tarix koʻrinishini oʻzgartirdi';
  }

  @override
  String changedTheHistoryVisibilityTo(String username, String rules) {
    return '$username tarix koʻrinishini: ${rules}ga oʻzgartirdi';
  }

  @override
  String changedTheJoinRules(String username) {
    return '$username qoʻshilish qoidalarini oʻzgartirdi';
  }

  @override
  String changedTheJoinRulesTo(String username, String joinRules) {
    return '$username qoʻshilish qoidalarini: ${joinRules}ga oʻzgartirdi';
  }

  @override
  String changedTheProfileAvatar(String username) {
    return '$username avatarini oʻzgartirdi';
  }

  @override
  String changedTheRoomAliases(String username) {
    return '$username xona taxalluslarini oʻzgartirdi';
  }

  @override
  String changedTheRoomInvitationLink(String username) {
    return '$username taklif havolasini oʻzgartirdi';
  }

  @override
  String get changePassword => 'Parolni o‘zgartirish';

  @override
  String get changeTheHomeserver => 'Homeserverni almashtirish';

  @override
  String get changeTheme => 'Uslubingizni o‘zgartiring';

  @override
  String get changeTheNameOfTheGroup => 'Guruh nomini o‘zgartirish';

  @override
  String get changeYourAvatar => 'Avataringizni almashtiring';

  @override
  String get channelCorruptedDecryptError => 'Shifrlash buzilgan';

  @override
  String get chat => 'Suhbat';

  @override
  String get yourChatBackupHasBeenSetUp => 'Suhbat zaxirangiz sozlandi.';

  @override
  String get chatBackup => 'Suhbat zaxirasi';

  @override
  String get chatBackupDescription =>
      'Eski xabarlaringiz tiklash kaliti bilan himoyalangan. Uni yo‘qotib qo‘ymasligingizga ishonch hosil qiling.';

  @override
  String get chatDetails => 'Suhbat tafsilotlari';

  @override
  String get chats => 'Suhbatlar';

  @override
  String get chooseAStrongPassword => 'Kuchli parol tanlang';

  @override
  String get clearArchive => 'Arxivni tozalash';

  @override
  String get close => 'Yopish';

  @override
  String get commandHint_markasdm =>
      'Matrix identifikatorini berish uchun shaxsiy xabar guruhi sifatida belgilang';

  @override
  String get commandHint_markasgroup => 'Guruh sifatida belgilash';

  @override
  String get commandHint_ban => 'Bu guruhdan berilgan foydalanuvchini bloklash';

  @override
  String get commandHint_clearcache => 'Kesh tozalash';

  @override
  String get commandHint_create =>
      'Boʻsh guruh suhbati yarating\nShifrlashni oʻchirish uchun --no-encryption dan foydalaning';

  @override
  String get commandHint_discardsession => 'Seansni bekor qilish';

  @override
  String get commandHint_dm =>
      'Jonli suhbatni boshlash\nShifrlashni o‘chirish uchun --no-encryption dan foydalaning';

  @override
  String get commandHint_html => 'HTML formatidagi matnni yuborish';

  @override
  String get commandHint_invite =>
      'Berilgan foydalanuvchini ushbu guruhga taklif qiling';

  @override
  String get commandHint_join => 'Berilgan guruhga qoʻshilish';

  @override
  String get commandHint_kick => 'Berilgan foydalanuvchini guruhdan oʻchirish';

  @override
  String get commandHint_leave => 'Guruhni tark etish';

  @override
  String get commandHint_me => 'Oʻzingizni tariflang';

  @override
  String get commandHint_myroomavatar =>
      'Bu guruh uchun rasmingizni sozlang (mxc-uri tomonidan)';

  @override
  String get commandHint_myroomnick => 'Bu guruh uchun displey nomini sozlang';

  @override
  String get commandHint_op =>
      'Berilgan foydalanuvchi quvvat darajasini oʻrnating (standart: 50)';

  @override
  String get commandHint_plain => 'Formatlanmagan matnni yuboring';

  @override
  String get commandHint_react => 'Javobni reaksiya sifatida yuboring';

  @override
  String get commandHint_send => 'Matn yuborish';

  @override
  String get commandHint_unban =>
      'Berilgan foydalanuvchini bu guruhdan blokdan chiqazish';

  @override
  String get commandInvalid => 'Buyruq yaroqsiz';

  @override
  String commandMissing(String command) {
    return '$command komanda emas.';
  }

  @override
  String get compareEmojiMatch => 'Iltimos emojilarni taqqoslang';

  @override
  String get compareNumbersMatch => 'Iltimos raqamlarni taqqoslang';

  @override
  String get configureChat => 'Suhbatni sozlash';

  @override
  String get contactHasBeenInvitedToTheGroup =>
      'Kontakt guruhga taklif qilindi';

  @override
  String get contentHasBeenReported =>
      'Kontent server administratorlariga xabar qilindi';

  @override
  String get copiedToClipboard => 'Buferga nusxalandi';

  @override
  String get copy => 'Nusxalash';

  @override
  String get copyToClipboard => 'Buferga nusxalash';

  @override
  String couldNotDecryptMessage(String error) {
    return 'Xabarni shifrlab boʻlmadi: $error';
  }

  @override
  String get checkList => 'Tekshirish roʻyxati';

  @override
  String countParticipants(int count) {
    return '$count qatnashuvchilar';
  }

  @override
  String countInvited(int count) {
    return '$count taklif qilindi';
  }

  @override
  String get create => 'Yaratish';

  @override
  String createdTheChat(String username) {
    return '💬 $username suhbat yaratdi';
  }

  @override
  String get createGroup => 'Guruh yaratish';

  @override
  String get createNewSpace => 'Yangi maydon';

  @override
  String get currentlyActive => 'Hozirda faol';

  @override
  String get darkTheme => 'Qorongʻi';

  @override
  String dateAndTimeOfDay(String date, String timeOfDay) {
    return '$date, $timeOfDay';
  }

  @override
  String get deactivateAccountWarning =>
      'Bu sizning foydalanuvchi hisobingizni oʻchirib qoʻyadi. Buni qaytarib boʻlmaydi! Ishonchingiz komilmi?';

  @override
  String get defaultPermissionLevel =>
      'Yangi foydalanuvchilar uchun standart ruxsat darajasi';

  @override
  String get delete => 'Oʻchirish';

  @override
  String get deleteAccount => 'Hisobni oʻchirish';

  @override
  String get deleteMessage => 'Xabarni oʻchirish';

  @override
  String get device => 'Qurilma';

  @override
  String get deviceId => 'Qurilma ID';

  @override
  String get devices => 'Qurilmalar';

  @override
  String get directChats => 'Shaxsiy suhbatlar';

  @override
  String get displaynameHasBeenChanged => 'Displey nomi o‘zgartirildi';

  @override
  String get downloadFile => 'Faylni yuklab olish';

  @override
  String get edit => 'Tahrirlash';

  @override
  String get editBlockedServers => 'Bloklangan serverlarni tahrirlash';

  @override
  String get chatPermissions => 'Suhbat ruxsatlari';

  @override
  String get editDisplayname => 'Displey nomini tahrirlash';

  @override
  String get editRoomAliases => 'Xona taxalluslarini tahrirlash';

  @override
  String get editRoomAvatar => 'Xona avatarini tahrirlash';

  @override
  String get emoteExists => 'Emotsiya allaqachon mavjud!';

  @override
  String get emoteInvalid => 'Noto‘g‘ri emotsiya kodi!';

  @override
  String get emoteKeyboardNoRecents =>
      'Yaqinda ishlatilgan emotsiyalar shu yerda chiqadi...';

  @override
  String get emotePacks => 'Guruh uchun Emote toʻplamlar';

  @override
  String get emoteSettings => 'Emote Sozlamalari';

  @override
  String get globalChatId => 'Ommaviy suhbat IDʼsi';

  @override
  String get accessAndVisibility => 'Kirish va koʻrinish';

  @override
  String get accessAndVisibilityDescription =>
      'Bu suhbatga kim qoʻshilishi mumkin va suhbatni qanday topish mumkin.';

  @override
  String get calls => 'Qoʻngʻiroqlar';

  @override
  String get customEmojisAndStickers => 'Maxsus emojilar va stikerlar';

  @override
  String get customEmojisAndStickersBody =>
      'Istalgan suhbatda ishlatilishi mumkin boʻlgan maxsus emojilar yoki stikerlarni qoʻshing yoki ulashing.';

  @override
  String get emoteShortcode => 'Emote qisqa kodi';

  @override
  String get emptyChat => 'Boʻsh suhbat';

  @override
  String get enableEmotesGlobally => 'Emote paketini global miqyosda yoqish';

  @override
  String get enableEncryption => 'Shifrlashni yoqish';

  @override
  String get enableEncryptionWarning =>
      'Siz endi shifrlashni oʻchira olmaysiz. Ishonchingiz komilmi?';

  @override
  String get encrypted => 'Shifrlangan';

  @override
  String get encryption => 'Shifrlash';

  @override
  String get encryptionNotEnabled => 'Shifrlash yoqilmagan';

  @override
  String endedTheCall(String senderName) {
    return '$senderName chaqiruvni tugatdi';
  }

  @override
  String get enterAnEmailAddress => 'Email manzilini kiriting';

  @override
  String get homeserver => 'Uy serveri';

  @override
  String errorObtainingLocation(String error) {
    return 'Joylashuv axboroti olinmadi: $error';
  }

  @override
  String get everythingReady => 'Hammasi tayyor!';

  @override
  String get extremeOffensive => 'O‘ta haqoratomuz';

  @override
  String get fileName => 'Fayl nomi';

  @override
  String get fluffychat => 'FluffyChat';

  @override
  String get fontSize => 'Shrift oʻlchami';

  @override
  String get forward => 'Yuborvorish';

  @override
  String get fromJoining => 'Qoʻshilishdan';

  @override
  String get fromTheInvitation => 'Taklifnomadan';

  @override
  String get group => 'Guruh';

  @override
  String get chatDescription => 'Suhbat tavsifi';

  @override
  String get chatDescriptionHasBeenChanged => 'Suhbat tavsifi oʻzgartirildi';

  @override
  String get groupIsPublic => 'Guruh ommaviy';

  @override
  String get groups => 'Guruhlar';

  @override
  String groupWith(String displayname) {
    return '$displayname bilan guruh';
  }

  @override
  String get guestsAreForbidden => 'Mehmonlarga kirish taqiqlangan';

  @override
  String get guestsCanJoin => 'Mehmonlar qoʻshila oladi';

  @override
  String hasWithdrawnTheInvitationFor(String username, String targetName) {
    return '$username $targetName uchun taklifnomani qaytarib oldi';
  }

  @override
  String get help => 'Yordam';

  @override
  String get hideRedactedEvents => 'Tahrirlangan tadbirlarni yashirish';

  @override
  String get hideRedactedMessages => 'Oʻchirilgan xabarlarni yashirish';

  @override
  String get hideRedactedMessagesBody =>
      'Agar kimdir xabarni oʻchirsa, bu xabar endi suhbatda koʻrinmaydi.';

  @override
  String get hideInvalidOrUnknownMessageFormats =>
      'Notoʻgʻri yoki nomaʼlum xabar formatlarini yashirish';

  @override
  String get howOffensiveIsThisContent => 'Bu kontent qanchalik haqoratli?';

  @override
  String get id => 'ID';

  @override
  String get block => 'Bloklash';

  @override
  String get blockedUsers => 'Bloklangan foydalanuvchilar';

  @override
  String get blockListDescription =>
      'Sizni bezovta qilayotgan foydalanuvchilarni bloklashingiz mumkin. Shaxsiy bloklash roʻyxatingizdagi foydalanuvchilardan hech qanday xabar yoki guruhga taklifnomalarni qabul qila olmaysiz.';

  @override
  String get blockUsername => 'Foydalanuvchi nomini eʻtiborsiz qoldirish';

  @override
  String get iHaveClickedOnLink => 'Men havolani bosdim';

  @override
  String get incorrectPassphraseOrKey => 'Notoʻgʻri parol yoki tiklash kaliti';

  @override
  String get inoffensive => 'Zararsiz';

  @override
  String get inviteContact => 'Kontaktni taklif qilish';

  @override
  String inviteContactToGroup(String groupName) {
    return 'Kontaktni $groupName ga taklif qiling';
  }

  @override
  String get noChatDescriptionYet => 'Hali suhbat tavsifi yaratilmagan.';

  @override
  String get tryAgain => 'Qayta urinib koʻrish';

  @override
  String get invalidServerName => 'Server nomi notoʻgʻri';

  @override
  String get invited => 'Taklif qilindi';

  @override
  String get redactMessageDescription =>
      'Xabar ushbu suhbatdagi barcha ishtirokchilar uchun oʻchiriladi. Buni bekor qilib boʻlmaydi.';

  @override
  String get optionalRedactReason =>
      '(Ixtiyoriy) Ushbu xabarni oʻchirish sababi...';

  @override
  String invitedUser(String username, String targetName) {
    return '📩 $username ${targetName}ni taklif qildi';
  }

  @override
  String get invitedUsersOnly => 'Faqat taklif qilingan foydalanuvchilar';

  @override
  String inviteText(String username, String link) {
    return '$username sizni FluffyChat’ga taklif qildi.\n1. fluffychat.im saytiga tashrif buyuring va ilovani oʻrnating.\n2. Roʻyxatdan oʻting yoki tizimga kiring.\n3. Taklif havolasini oching:\n$link';
  }

  @override
  String get isTyping => 'yozmoqda…';

  @override
  String joinedTheChat(String username) {
    return '👋 $username suhbatga qoʻshildi';
  }

  @override
  String get joinRoom => 'Guruhga qoʻshilish';

  @override
  String kicked(String username, String targetName) {
    return '👞 $username ${targetName}ni tepdi';
  }

  @override
  String kickedAndBanned(String username, String targetName) {
    return '🙅 $username ${targetName}ni tepdi va blokladi';
  }

  @override
  String get kickFromChat => 'Suhbatdan tepish';

  @override
  String lastActiveAgo(String localizedTimeShort) {
    return 'Oxirgi faol: $localizedTimeShort';
  }

  @override
  String get leave => 'Chiqish';

  @override
  String get leftTheChat => 'Suhbatni tark etdi';

  @override
  String get lightTheme => 'Yorugʻlik';

  @override
  String loadCountMoreParticipants(int count) {
    return 'Yana $count ishtirokchini yuklang';
  }

  @override
  String get dehydrate => 'Sessiyani eksport qilish va qurilmani oʻchirish';

  @override
  String get dehydrateWarning =>
      'Bu amalni bekor qilib boʻlmaydi. Zaxira faylini xavfsiz saqlang.';

  @override
  String get hydrate => 'Zaxira faylidan tiklash';

  @override
  String get loadingPleaseWait => 'Yuklanmoqda… Iltimos, kuting.';

  @override
  String get loadMore => 'Koʻproq yuklash…';

  @override
  String get locationDisabledNotice =>
      'Joylashuv xizmatlari oʻchirib qoʻyilgan. Joylashuvingizni ulashish uchun ularni yoqing.';

  @override
  String get locationPermissionDeniedNotice =>
      'Joylashuvga ruxsat berilmadi. Iltimos, ularga joylashuvingizni ulashishga ruxsat bering.';

  @override
  String get login => 'Kirish';

  @override
  String logInTo(String homeserver) {
    return '$homeserver ga kirish';
  }

  @override
  String get logout => 'Chiqish';

  @override
  String get mention => 'Qayd etmoq';

  @override
  String get messages => 'Xabarlar';

  @override
  String get messagesStyle => 'Xabarlar:';

  @override
  String get moderator => 'Moderator';

  @override
  String get muteChat => 'Suhbatni ovozsizlantirish';

  @override
  String get needPantalaimonWarning =>
      'Iltimos, hozircha Pantalaimon boshdan-oyoq shifrlashdan foydalanishi kerakligini yodda tuting.';

  @override
  String get newChat => 'Yangi suhbat';

  @override
  String get newMessageInFluffyChat => '💬 FluffyChat yangi xabarlar';

  @override
  String get newVerificationRequest => 'Yangi tasdiqlash so\'rovi!';

  @override
  String get next => 'Keyingi';

  @override
  String get no => 'Yoʻq';

  @override
  String get noConnectionToTheServer => 'Serverga ulanish yoʻq';

  @override
  String get noEmotesFound => 'Hech qanday emoteʼlar topilmadi 😕';

  @override
  String get noEncryptionForPublicRooms =>
      'Shifrlashni faqat guruh endi hamma uchun ochiq bo\'lmay qolgandan keyingina faollashtirishingiz mumkin.';

  @override
  String get noGoogleServicesWarning =>
      'Firebase Cloud Messaging qurilmangizda mavjud emasga o\'xshaydi. Push-bildirishnomalarni olishda davom etish uchun ntfy-ni o\'rnatishingizni tavsiya qilamiz. NTFY yoki boshqa Unified Push provayderi yordamida siz ma\'lumotlar xavfsizligini ta\'minlash orqali push-bildirishnomalarni olishingiz mumkin. Siz ntfy-ni PlayStore yoki F-Droid-dan yuklab olishingiz mumkin.';

  @override
  String noMatrixServer(String server1, String server2) {
    return '$server1 matrix serveri emas, buning o\'rniga $server2 dan foydalanilsinmi?';
  }

  @override
  String get shareInviteLink => 'Taklifnoma havolasini ulashish';

  @override
  String get scanQrCode => 'QR kodini skanerlang';

  @override
  String get none => 'Hech biri';

  @override
  String get noPasswordRecoveryDescription =>
      'Siz hali parolingizni tiklash usulini qoʻshmadingiz.';

  @override
  String get noPermission => 'Ruxsat yoʻq';

  @override
  String get noRoomsFound => 'Hech qanday guruhlar topilmadi…';

  @override
  String get notifications => 'Bildirishnomalar';

  @override
  String numUsersTyping(int count) {
    return '$count foydalanuvchilar yozmoqda…';
  }

  @override
  String get obtainingLocation => 'Joylashuv aniqlanmoqda…';

  @override
  String get offensive => 'Haqoratomuz';

  @override
  String get offline => 'Oflayn';

  @override
  String get ok => 'Hop';

  @override
  String get online => 'Onlayn';

  @override
  String get onlineKeyBackupEnabled => 'Onlayn kalit zaxira nusxasi yoqilgan';

  @override
  String get oopsPushError =>
      'Afsuski, push-bildirishnomalarni sozlashda xatolik yuz berdi.';

  @override
  String get oopsSomethingWentWrong => 'Voy, nimadir notoʻgʻri ketdi…';

  @override
  String get openAppToReadMessages => 'Xabarlarni oʻqish uchun ilovani oching';

  @override
  String get openCamera => 'Kamerani ochish';

  @override
  String get oneClientLoggedOut => 'Mijozlaringizdan biri tizimdan chiqdi';

  @override
  String get addAccount => 'Hisob qoʻshish';

  @override
  String get editBundlesForAccount => 'Bu hisob uchun toʻplamlarni tahrirlash';

  @override
  String get addToBundle => 'Toʻplamga qoʻshish';

  @override
  String get removeFromBundle => 'Bu toʻplamdan oʻchirish';

  @override
  String get bundleName => 'Toʻplam nomi';

  @override
  String get enableMultiAccounts =>
      '(BETA) Ushbu qurilmada bir nechta hisoblarni yoqish';

  @override
  String get openInMaps => 'Xaritalarda ochish';

  @override
  String get link => 'Havola';

  @override
  String get serverRequiresEmail =>
      'Ushbu server roʻyxatdan oʻtish uchun elektron pochta manzilingizni tasdiqlashi kerak.';

  @override
  String get or => 'Yoki';

  @override
  String get participant => 'Qatnashuvchi';

  @override
  String get passphraseOrKey => 'parol yoki tiklash kaliti';

  @override
  String get password => 'Parol';

  @override
  String get passwordForgotten => 'Parol unitilgan';

  @override
  String get passwordHasBeenChanged => 'Parol oʻzgartirildi';

  @override
  String get overview => 'Umumiy ma\'lumot';

  @override
  String get passwordRecoverySettings => 'Parolni qayta tiklash sozlamalari';

  @override
  String get passwordRecovery => 'Parolni qayta tiklash';

  @override
  String get pickImage => 'Rasm tanlash';

  @override
  String get pin => 'Toʻgʻnash';

  @override
  String play(String fileName) {
    return '${fileName}ni oʻynash';
  }

  @override
  String get pleaseChooseAPasscode => 'Iltimos, kirish kodini tanlang';

  @override
  String get pleaseClickOnLink =>
      'Iltimos, elektron pochtadagi havolani bosing va keyin davom eting.';

  @override
  String get pleaseEnter4Digits =>
      'Ilova qulfini oʻchirish uchun 4 ta raqamni kiriting yoki boʻsh qoldiring.';

  @override
  String get pleaseEnterYourPassword => 'Iltimos parolingizni kiriting';

  @override
  String get pleaseEnterYourPin => 'Iltimos PIN kodingizni kiriting';

  @override
  String get pleaseEnterYourUsername => 'Iltimos foydalanuvchi nomini kiriting';

  @override
  String get pleaseFollowInstructionsOnWeb =>
      'Iltimos, veb-saytdagi koʻrsatmalarga amal qiling va keyingisini bosing.';

  @override
  String get privacy => 'Maxfiylik';

  @override
  String get publicRooms => 'Ommaviy guruhlar';

  @override
  String get pushRules => 'Push qoidalari';

  @override
  String get reason => 'Sabab';

  @override
  String get recording => 'Yozilmoqda';

  @override
  String redactedBy(String username) {
    return '$username tomonidan tahrirlangan';
  }

  @override
  String get directChat => 'Shaxsiy suhbat';

  @override
  String redactedByBecause(String username, String reason) {
    return '$username tomonidan tahrirlandi, sababi: \"$reason\"';
  }

  @override
  String redactedAnEvent(String username) {
    return '$username tadbirni oʻchirib tashladi';
  }

  @override
  String get redactMessage => 'Xabarni tahrirlash';

  @override
  String get register => 'Roʻyxatdan oʻtish';

  @override
  String get reject => 'Rad qilish';

  @override
  String rejectedTheInvitation(String username) {
    return '$username taklifni rad qildi';
  }

  @override
  String get removeAllOtherDevices => 'Qolgan barcha qurilmalarni oʻchirish';

  @override
  String removedBy(String username) {
    return '$username tomonidan oʻchirildi';
  }

  @override
  String get unbanFromChat => 'Suhbat blokidan chiqazish';

  @override
  String get removeYourAvatar => 'Avatarni oʻchirish';

  @override
  String get replaceRoomWithNewerVersion =>
      'Guruhni yangiroq versiya bilan almashtirish';

  @override
  String get reply => 'Javob yozish';

  @override
  String get reportMessage => 'Xabar berish';

  @override
  String get requestPermission => 'Ruxsat soʻrash';

  @override
  String get roomHasBeenUpgraded => 'Xona takomillashtirildi';

  @override
  String get roomVersion => 'Guruh versiyasi';

  @override
  String get saveFile => 'Fayl saqlash';

  @override
  String get search => 'Qidiruv';

  @override
  String get security => 'Xavfsizlik';

  @override
  String get recoveryKey => 'Tiklash kaliti';

  @override
  String get recoveryKeyLost => 'Tiklash kaliti yo‘qolib qoldimi?';

  @override
  String get send => 'Yuborish';

  @override
  String get sendAMessage => 'Xabar yuborish';

  @override
  String get sendAsText => 'Matn sifatida yuborish';

  @override
  String get sendAudio => 'Audio yuborish';

  @override
  String get sendFile => 'Faylni yuborish';

  @override
  String get sendImage => 'Rasm yuborish';

  @override
  String sendImages(int count) {
    return '$count ta rasm yuborish';
  }

  @override
  String get sendMessages => 'Xabarlar yuborish';

  @override
  String get sendVideo => 'Video yuborish';

  @override
  String sentAFile(String username) {
    return '📁 $username fayl yubordi';
  }

  @override
  String sentAnAudio(String username) {
    return '🎤 $username audio yubordi';
  }

  @override
  String sentAPicture(String username) {
    return '️ 🖼️ $username rasm yubordi';
  }

  @override
  String sentASticker(String username) {
    return '😊 $username stiker yubordi';
  }

  @override
  String sentAVideo(String username) {
    return '🎥 $username video yubordi';
  }

  @override
  String sentCallInformations(String senderName) {
    return '$senderName chaqiruv axborotini yubordi';
  }

  @override
  String get setAsCanonicalAlias => 'Asosiy taxallus sifatida belgilash';

  @override
  String get setChatDescription => 'Suhbat tavsifini sozlash';

  @override
  String get setStatus => 'Holatni sozlash';

  @override
  String get settings => 'Sozlamalar';

  @override
  String get share => 'Bo‘lishmoq';

  @override
  String sharedTheLocation(String username) {
    return '$username joylashuvini ulashdi';
  }

  @override
  String get shareLocation => 'Joylashuvni ulashish';

  @override
  String get showPassword => 'Parolni ko‘rsatish';

  @override
  String get presencesToggle =>
      'Boshqa foydalanuvchilarning holat xabarlarini ko‘rsatish';

  @override
  String get skip => 'Tashlab ketish';

  @override
  String get sourceCode => 'Manba kodi';

  @override
  String get spaceIsPublic => 'Guruh ochiq';

  @override
  String get spaceName => 'Guruh nomi';

  @override
  String startedACall(String senderName) {
    return '$senderName chaqiruv boshladi';
  }

  @override
  String get status => 'Holati';

  @override
  String get statusExampleMessage => 'Bugun ahvolingiz qalay?';

  @override
  String get submit => 'Yuborish';

  @override
  String get synchronizingPleaseWait => 'Sinxronlanmoqda... Iltimos, kuting.';

  @override
  String synchronizingPleaseWaitCounter(String percentage) {
    return ' Sinxronlanmoqda... ($percentage%)';
  }

  @override
  String get systemTheme => 'Tizim';

  @override
  String get theyDontMatch => 'Mos emas';

  @override
  String get theyMatch => 'Mos keladi';

  @override
  String get title => 'FluffyChat';

  @override
  String get tooManyRequestsWarning =>
      'Talablar soni oshib ketdi. Keyinroq qayta urining!';

  @override
  String get transferFromAnotherDevice => 'Boshqa qurilmadan uzatish';

  @override
  String get tryToSendAgain => 'Qayta yuborishga urining';

  @override
  String get unavailable => 'Mavjud emas';

  @override
  String unbannedUser(String username, String targetName) {
    return '$username ${targetName}ni blokdan chiqardi';
  }

  @override
  String get unblockDevice => 'Qurilmani blokdan chiqarish';

  @override
  String get unknownDevice => 'Notanish qurilma';

  @override
  String get unknownEncryptionAlgorithm => 'Noma’lum shifrlash algoritmi';

  @override
  String unknownEvent(String type) {
    return 'Noma’lum hodisa $type';
  }

  @override
  String get unmuteChat => 'Suhbatni ovozli qilish';

  @override
  String get unpin => 'Olib tashlash';

  @override
  String userAndOthersAreTyping(String username, int count) {
    return '$username va yana $count kishi yozmoqda…';
  }

  @override
  String userAndUserAreTyping(String username, String username2) {
    return '$username va $username2 yozmoqda…';
  }

  @override
  String userIsTyping(String username) {
    return '$username yozmoqda…';
  }

  @override
  String userLeftTheChat(String username) {
    return '🚪 $username suhbatni tark etdi';
  }

  @override
  String get username => 'Foydalanuvchi nomi';

  @override
  String userSentUnknownEvent(String username, String type) {
    return '$username $type tadbirini yubordi';
  }

  @override
  String get unverified => 'Tasdiqlanmagan';

  @override
  String get verified => 'Tasdiqlangan';

  @override
  String get verify => 'Tasdiqlash';

  @override
  String get verifyStart => 'Tasdiqlashni boshlash';

  @override
  String get verifySuccess => 'Siz tasdiqladingiz!';

  @override
  String get verifyTitle => 'Boshqa hisob tasdiqlanmoqda';

  @override
  String get videoCall => 'Video chaqiruv';

  @override
  String get visibilityOfTheChatHistory => 'Suhbat tarixining ko‘rinishi';

  @override
  String get visibleForAllParticipants => 'Barcha ishtirokchilarga ko‘rinadi';

  @override
  String get visibleForEveryone => 'Hammaga ko‘rinadigan';

  @override
  String get voiceMessage => 'Ovozli xabar';

  @override
  String get waitingPartnerAcceptRequest =>
      'Hamkor so‘rovni qabul qilishi kutilmoqda…';

  @override
  String get waitingPartnerEmoji => 'Hamkor emoji qabul qilishini kutmoqda…';

  @override
  String get waitingPartnerNumbers =>
      'Hamkor raqamlarni qabul qilishi kutilmoqda…';

  @override
  String get warning => 'Ogohlantirish!';

  @override
  String get weSentYouAnEmail => 'Sizga xat yubordik';

  @override
  String get whoCanPerformWhichAction => 'Kim qaysi amalni bajarishi mumkin';

  @override
  String get whoIsAllowedToJoinThisGroup => 'Bu guruhga kim qo‘shilishi mumkin';

  @override
  String get whyDoYouWantToReportThis =>
      'Nima uchun bu haqda xabar bermoqchisiz?';

  @override
  String get wipeChatBackup =>
      'Yangi tiklash kalitini yaratish uchun suhbat zaxirasi tozalansinmi?';

  @override
  String get withTheseAddressesRecoveryDescription =>
      'Ushbu manzillar yordamida parolingizni tiklashingiz mumkin.';

  @override
  String get writeAMessage => 'Xabar yozish…';

  @override
  String get yes => 'Ha';

  @override
  String get you => 'Siz';

  @override
  String get youAreNoLongerParticipatingInThisChat =>
      'Siz ortiq bu suhbatda qatnashmayapsiz';

  @override
  String get youHaveBeenBannedFromThisChat => 'Bu suhbatdan bloklandingiz';

  @override
  String get yourPublicKey => 'Ochiq kalitingiz';

  @override
  String get messageInfo => 'Xabar axboroti';

  @override
  String get time => 'Vaqt';

  @override
  String get messageType => 'Xabar turi';

  @override
  String get sender => 'Yuboruvchi';

  @override
  String get openGallery => 'Galereyani ochish';

  @override
  String get removeFromSpace => 'Guruhdan olib tashlash';

  @override
  String get start => 'Boshlash';

  @override
  String get pleaseEnterRecoveryKeyDescription =>
      'Eski xabarlaringizni qulfdan chiqarish uchun, iltimos, avvalgi seansdan yaratilgan tiklash kalitingizni kiriting. Sizning tiklash kalitingiz parolingiz EMAS.';

  @override
  String get openChat => 'Suhbatni ochish';

  @override
  String get markAsRead => 'Oʻqilgan sifatida belgilash';

  @override
  String get reportUser => 'Foydalanuvchi haqida xabar berish';

  @override
  String get dismiss => 'Rad qilmoq';

  @override
  String reactedWith(String sender, String reaction) {
    return '$sender $reaction bilan reaksiya bildirdi';
  }

  @override
  String get pinMessage => 'Xonaga mahkamlash';

  @override
  String get confirmEventUnpin =>
      'Tadbirni butunlay olib tashlashga ishonchingiz komilmi?';

  @override
  String get emojis => 'Emojilar';

  @override
  String get placeCall => 'Qoʻngʻiroq qilish';

  @override
  String get voiceCall => 'Ovozli qoʻngʻiroq';

  @override
  String get unsupportedAndroidVersion =>
      'Qoʻllab-quvvatlanmaydigan Android versiyasi';

  @override
  String get unsupportedAndroidVersionLong =>
      'Bu funksiya Androidning yangi versiyasini talab qiladi. Iltimos, yangilanishlar yoki Lineage OS qoʻllab-quvvatlashini tekshiring.';

  @override
  String get videoCallsBetaWarning =>
      'Iltimos, video qoʻngʻiroqlar hozirda beta-versiyada ekanligini unutmang. Ular kutilganidek ishlamasligi yoki barcha platformalarda umuman ishlamasligi mumkin.';

  @override
  String get experimentalVideoCalls => 'Tajriba video qoʻngʻiroqlar';

  @override
  String get youRejectedTheInvitation => 'Taklifni rad etdingiz';

  @override
  String get youJoinedTheChat => 'Siz suhbatga qoʻshildingiz';

  @override
  String get youAcceptedTheInvitation => '👍 Taklifni qabul qildingiz';

  @override
  String youBannedUser(String user) {
    return 'Siz ${user}ni blokladingiz';
  }

  @override
  String youHaveWithdrawnTheInvitationFor(String user) {
    return 'Siz $user uchun taklifnomani bekor qildingiz';
  }

  @override
  String youInvitedBy(String user) {
    return '📩 Sizni $user taklif qildi';
  }

  @override
  String invitedBy(String user) {
    return '📩 $user taklif qilgan';
  }

  @override
  String youInvitedUser(String user) {
    return '📩 Siz ${user}ni taklif qildingiz';
  }

  @override
  String youKicked(String user) {
    return '👞 Siz ${user}ni chiqarib yubordingiz';
  }

  @override
  String youKickedAndBanned(String user) {
    return '🙅 Siz ${user}ni chiqardingiz va blokladingiz';
  }

  @override
  String youUnbannedUser(String user) {
    return '${user}ni blokdan chiqardingiz';
  }

  @override
  String hasKnocked(String user) {
    return '🚪 $user taqillatdi';
  }

  @override
  String get usersMustKnock => 'Foydalanuvchilar taqillatishi kerak';

  @override
  String get noOneCanJoin => 'Hech kim qoʻshila olmaydi';

  @override
  String get knock => 'Taqillating';

  @override
  String get users => 'Foydalanuvchilar';

  @override
  String get unlockOldMessages => 'Eski xabarlarni qulfdan chiqaring';

  @override
  String get storeInSecureStorageDescription =>
      'Qayta tiklash kalitini ushbu qurilmaning xavfsiz xotirasida saqlang.';

  @override
  String get saveKeyManuallyDescription =>
      'Tizim ulashish dialog oynasi yoki buferni ishga tushirish orqali ushbu kalitni qoʻlda saqlang.';

  @override
  String get storeInAndroidKeystore => 'Android KeyStoreʼda saqlang';

  @override
  String get storeInAppleKeyChain => 'Apple KeyChainʼda saqlang';

  @override
  String get storeSecurlyOnThisDevice => 'Ushbu qurilmada xavfsiz saqlang';

  @override
  String countFiles(int count) {
    return '$count fayllar';
  }

  @override
  String get user => 'Foydalanuvchi';

  @override
  String get custom => 'Maxsus';

  @override
  String get foregroundServiceRunning =>
      'Bu bildirishnoma old plan xizmati ishlab turgan paytda paydo bo‘ladi.';

  @override
  String get screenSharingTitle => 'Ekranni ulashish';

  @override
  String get screenSharingDetail =>
      'Siz ekraningizni FuffyChat’da ulashmoqdasiz';

  @override
  String get whyIsThisMessageEncrypted =>
      'Nima uchun bu xabarni oʻqib boʻlmaydi?';

  @override
  String get noKeyForThisMessage =>
      'Bu xabar siz ushbu qurilmada hisobingizga kirishdan oldin yuborilgan boʻlsa sodir boʻlishi mumkin.\n\nShuningdek, joʻnatuvchi qurilmangizni bloklagan yoki internet ulanishida biron bir muammo yuzaga kelgan boʻlishi mumkin.\n\nXabarni boshqa sessiyada oʻqiy olasizmi? Keyin xabarni undan uzatishingiz mumkin! Sozlamalar > Qurilmalar boʻlimiga oʻting va qurilmalaringiz bir-birini tasdiqlaganligiga ishonch hosil qiling. Keyingi safar xonani ochganingizda va ikkala sessiya ham oldinda boʻlganda, kalitlar avtomatik ravishda uzatiladi.\n\nTizimdan chiqishda yoki qurilmalarni almashtirishda kalitlarni yoʻqotishni xohlamaysizmi? Sozlamalarda suhbatning zaxira nusxasini yoqganingizga ishonch hosil qiling.';

  @override
  String get newGroup => 'Yangi guruh';

  @override
  String get newSpace => 'Yangi maydon';

  @override
  String get allSpaces => 'Barcha maydonlar';

  @override
  String get hidePresences => 'Holat roʻyxati yashirilsinmi?';

  @override
  String get doNotShowAgain => 'Qaytib koʻrsatilmasin';

  @override
  String wasDirectChatDisplayName(String oldDisplayName) {
    return 'Boʻsh suhbat ($oldDisplayName edi)';
  }

  @override
  String get newSpaceDescription =>
      'Maydonlar sizga suhbatlaringizni birlashtirish va shaxsiy yoki ommaviy hamjamiyatlarni yaratish imkonini beradi.';

  @override
  String get encryptThisChat => 'Bu suhbatni shifrlash';

  @override
  String get disableEncryptionWarning =>
      'Xavfsizlik nuqtai nazaridan, agar u ilgari yoqilgan boʻlsa, suhbatda shifrlashni oʻchirib qoʻyolmaysiz.';

  @override
  String get sorryThatsNotPossible => 'Kechirasiz... bu mumkin emas';

  @override
  String get deviceKeys => 'Qurilma kalitlari:';

  @override
  String get reopenChat => 'Suhbatni qayta ochish';

  @override
  String get noBackupWarning =>
      'Diqqat! Suhbatni zaxiralashni yoqmasangiz, shifrlangan xabarlaringizga kirish huquqini yoʻqotasiz. Tizimdan chiqishdan oldin chatni zaxiralashni yoqishingiz tavsiya etiladi.';

  @override
  String get noOtherDevicesFound => 'Boshqa qurilma topilmadi';

  @override
  String fileIsTooBigForServer(String max) {
    return 'Yuborish imkonsiz! Server faqat $max hajmgacha bo‘lgan ilovalarni qo‘llab-quvvatlaydi.';
  }

  @override
  String fileHasBeenSavedAt(String path) {
    return 'Fayl ${path}da saqlandi';
  }

  @override
  String get jumpToLastReadMessage => 'Oxirgi o‘qilgan xabarga o‘tish';

  @override
  String get readUpToHere => 'Bu yerga qadar o‘qish';

  @override
  String get jump => 'Sakrash';

  @override
  String get openLinkInBrowser => 'Havolani brauzerda ochish';

  @override
  String get reportErrorDescription =>
      '😭 Voy yo‘q. Nimadir xato ketdi. Agar xohlasangiz, bu xato haqida dasturchilarga xabar berishingiz mumkin.';

  @override
  String get report => 'hisobot';

  @override
  String get setColorTheme => 'Rang mavzusini sozlash:';

  @override
  String get invite => 'Taklif qilish';

  @override
  String get inviteGroupChat => '📨 Guruh suhbatiga taklif';

  @override
  String get invalidInput => 'Xato kiritildi!';

  @override
  String wrongPinEntered(int seconds) {
    return 'PIN noto‘g‘ri kiritildi! $seconds soniyadan keyin qayta urining...';
  }

  @override
  String get pleaseEnterANumber => '0 dan katta son kiriting';

  @override
  String get archiveRoomDescription =>
      'Suhbat arxivga koʻchiriladi. Boshqa foydalanuvchilar sizning suhbatdan chiqqaningizni koʻra oladilar.';

  @override
  String get roomUpgradeDescription =>
      'Keyin suhbat yangi guruh versiyasi bilan qayta yaratiladi. Barcha ishtirokchilarga yangi suhbatga oʻtishlari kerakligi haqida xabar beriladi. Guruh versiyalari haqida koʻproq maʼlumotni https://spec.matrix.org/latest/rooms/ manzilida topishingiz mumkin';

  @override
  String get removeDevicesDescription =>
      'Bu qurilmadan chiqarilasiz va ortiq xabarlarni qabul qila olmaysiz.';

  @override
  String get banUserDescription =>
      'Foydalanuvchi suhbatdan bloklanadi va blokdan chiqarilmaguncha suhbatga qayta kira olmaydi.';

  @override
  String get unbanUserDescription =>
      'Foydalanuvchi qayta suhbatga kira oladi agar ular urinib koʻrishsa.';

  @override
  String get kickUserDescription =>
      'Foydalanuvchi suhbatdan chiqarib yuboriladi, ammo taqiqlanmaydi. Ommaviy chatlarda foydalanuvchi istalgan vaqtda qayta qoʻshilishi mumkin.';

  @override
  String get makeAdminDescription =>
      'Bu foydalanuvchini admini qilsangiz, uni bekor qila olmasligingiz mumkin, chunki u siz bilan bir xil ruxsatlarga ega bo‘ladi.';

  @override
  String get pushNotificationsNotAvailable =>
      'Push-bildirishnomalar mavjud emas';

  @override
  String get learnMore => 'Batafsil';

  @override
  String get yourGlobalUserIdIs => 'Global foydalanuvchi ID raqamingiz: ';

  @override
  String noUsersFoundWithQuery(String query) {
    return 'Afsuski, \"$query\" soʻrovi bilan foydalanuvchi topilmadi. Iltimos, xato qilganingizni tekshiring.';
  }

  @override
  String get knocking => 'Taqillatmoqda';

  @override
  String chatCanBeDiscoveredViaSearchOnServer(String server) {
    return 'Suhbatni $server saytidagi qidiruv orqali topish mumkin';
  }

  @override
  String get searchChatsRooms => 'Qidiruv #chats, @users...';

  @override
  String get nothingFound => 'Hech nima topilmadi...';

  @override
  String get groupName => 'Guruh nomi';

  @override
  String get createGroupAndInviteUsers =>
      'Guruh yaratish va foydalanuvchilarni taklif qilish';

  @override
  String get groupCanBeFoundViaSearch =>
      'Guruh qidiruv orqali topilishi mumkin';

  @override
  String get wrongRecoveryKey =>
      'Kechirasiz... bu toʻgʻri tiklash kaliti emasga oʻxshaydi.';

  @override
  String get commandHint_sendraw => 'Xom jsonni yuborish';

  @override
  String get databaseMigrationTitle => 'Maʼlumotlar bazasi optimallashtirilgan';

  @override
  String get databaseMigrationBody =>
      'Iltimos, kuting. Bu biroz vaqt olishi mumkin.';

  @override
  String get leaveEmptyToClearStatus =>
      'Holatingizni tozalash uchun boʻsh qoldiring.';

  @override
  String get select => 'Tanlash';

  @override
  String get searchForUsers => '@users ni qidiring...';

  @override
  String get pleaseEnterYourCurrentPassword =>
      'Iltimos, joriy maxfiy soʻzingizni kiriting';

  @override
  String get newPassword => 'Yangi maxfiy soʻz';

  @override
  String get pleaseChooseAStrongPassword =>
      'Iltimos kuchli maxfiy soʻz tanlang';

  @override
  String get passwordsDoNotMatch => 'Maxfiy soʻzlar mos kelmadi';

  @override
  String get passwordIsWrong => 'Siz kiritgan maxfiy soʻz xato';

  @override
  String get publicChatAddresses => 'Ommaviy suhbat manzillari';

  @override
  String get createNewAddress => 'Yangi manzil yarating';

  @override
  String get joinSpace => 'Maydonga qoʻshiling';

  @override
  String get publicSpaces => 'Ommaviy maydonlar';

  @override
  String get addChatOrSubSpace => 'Suhbat yoki sub-maydon qoʻshing';

  @override
  String get thisDevice => 'Ushbu qurilma:';

  @override
  String get initAppError => 'Ilovani ishga tushirishda xatolik yuz berdi';

  @override
  String searchIn(String chat) {
    return 'Suhbat \"$chat\"da qidiring...';
  }

  @override
  String get searchMore => 'Koʻproq qidirish...';

  @override
  String get gallery => 'Galereya';

  @override
  String get files => 'Fayllar';

  @override
  String sessionLostBody(String url, String error) {
    return 'Seansingiz yoʻqoldi. Iltimos, ushbu xato haqida $url manzilidagi dasturchilarga xabar bering. Xato xabari: $error';
  }

  @override
  String restoreSessionBody(String url, String error) {
    return 'Ilova endi seansingizni zaxira nusxasidan tiklashga harakat qiladi. Iltimos, ushbu xato haqida $url manzilidagi dasturchilarga xabar bering. Xato xabari: $error';
  }

  @override
  String get sendReadReceipts => 'Oʻqilganlik haqida xabarnomalarni yuborish';

  @override
  String get sendTypingNotificationsDescription =>
      'Suhbatdagi boshqa ishtirokchilar siz yangi xabar yozayotganingizni koʻrishlari mumkin.';

  @override
  String get sendReadReceiptsDescription =>
      'Suhbatdagi boshqa ishtirokchilar sizning xabarni qachon oʻqiganingizni koʻrishlari mumkin.';

  @override
  String get formattedMessages => 'Formatlangan xabarlar';

  @override
  String get formattedMessagesDescription =>
      'Markdown yordamida qalin matn kabi boy xabar mazmunini koʻrsating.';

  @override
  String get verifyOtherUser => '🔐 Boshqa foydalanuvchini tasdiqlang';

  @override
  String get verifyOtherUserDescription =>
      'Agar siz boshqa foydalanuvchini tasdiqlasangiz, aslida kimga yozayotganingizni bilishingizga amin boʻlishingiz mumkin. 💪\n\nTekshiruvni boshlaganingizda, siz va boshqa foydalanuvchi ilovada qalqib chiquvchi oynani koʻrasiz. Keyin u yerda siz bir-biringiz bilan taqqoslashingiz kerak boʻlgan bir qator emojilar yoki raqamlarni koʻrasiz.\n\nBuning eng yaxshi usuli - uchrashish yoki video qoʻngʻiroqni boshlash. 👭';

  @override
  String get verifyOtherDevice => '🔐 Boshqa qurilmani tasdiqlang';

  @override
  String get verifyOtherDeviceDescription =>
      'Boshqa qurilmani tasdiqlaganingizda, bu qurilmalar kalitlarni almashishi mumkin, bu umumiy xavfsizligingizni oshiradi. 💪 Tasdiqlashni boshlaganingizda, ikkala qurilmada ham ilovada qalqib chiquvchi oyna paydo bo‘ladi. U yerda siz bir-biri bilan taqqoslashingiz kerak bo‘lgan emojilar yoki raqamlar qatorini ko‘rasiz. Tasdiqlashni boshlashdan oldin ikkala qurilma ham yoningizda bo‘lgani ma’qul. ✓';

  @override
  String acceptedKeyVerification(String sender) {
    return '$sender kalit tekshiruvini qabul qildi';
  }

  @override
  String canceledKeyVerification(String sender) {
    return '$sender kalit tekshiruvini bekor qildi';
  }

  @override
  String completedKeyVerification(String sender) {
    return '$sender kalitni tasdiqlashni yakunladi';
  }

  @override
  String isReadyForKeyVerification(String sender) {
    return '$sender kalitni tasdiqlash uchun tayyor';
  }

  @override
  String requestedKeyVerification(String sender) {
    return '$sender kalitni tasdiqlash talabini yubordi';
  }

  @override
  String startedKeyVerification(String sender) {
    return '$sender kalit tekshiruvini so‘radi';
  }

  @override
  String get transparent => 'Shaffof';

  @override
  String get incomingMessages => 'Kiruvchi xabarlar';

  @override
  String get stickers => 'Stikerlar';

  @override
  String get discover => 'Kashf etish';

  @override
  String get commandHint_ignore => 'Berilgan matriks ID e’tiborga olinmasin';

  @override
  String get commandHint_unignore =>
      'Berilgan matriks IDni e’tiborsiz qoldirish';

  @override
  String unreadChatsInApp(String appname, String unread) {
    return '$appname: $unread ta oʻqilmagan suhbatlar';
  }

  @override
  String get noDatabaseEncryption =>
      'Bu platformada ma’lumotlar bazasini shifrlash ishlamaydi';

  @override
  String thereAreCountUsersBlocked(Object count) {
    return 'Hozirda $count ta foydalanuvchi bloklangan.';
  }

  @override
  String get restricted => 'Cheklangan';

  @override
  String get knockRestricted => 'Taqillatish cheklangan';

  @override
  String goToSpace(Object space) {
    return 'Maydonga o‘tish: $space';
  }

  @override
  String get markAsUnread => 'Ochilmagan deb belgilash';

  @override
  String userLevel(int level) {
    return '$level - Foydalanuvchi';
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
  String get changeGeneralChatSettings =>
      'Umumiy suhbat sozlamalarini oʻzgartirish';

  @override
  String get inviteOtherUsers =>
      'Boshqa foydalanuvchilarni bu suhbatga taklif qilish';

  @override
  String get changeTheChatPermissions => 'Suhbat ruxsatnomalarini oʻzgartirish';

  @override
  String get changeTheVisibilityOfChatHistory =>
      'Suhbat tarix koʻrinishini oʻzgartirish';

  @override
  String get changeTheCanonicalRoomAlias =>
      'Asosiy umumiy suhbat manzilini oʻzgartirish';

  @override
  String get sendRoomNotifications => '@room bildirishnomalarini yuborish';

  @override
  String get changeTheDescriptionOfTheGroup => 'Suhbat tavsifini oʻzgartirish';

  @override
  String get chatPermissionsDescription =>
      'Ushbu suhbatda muayyan harakatlar uchun qaysi quvvat darajasi zarurligini aniqlang. 0, 50 va 100 quvvat darajalari odatda foydalanuvchilar, moderatorlar va administratorlarni ifodalaydi, ammo har qanday gradatsiya mumkin.';

  @override
  String updateInstalled(String version) {
    return '🎉 $version versiyasiga yangilandi!';
  }

  @override
  String get changelog => 'O‘zgarishlar jurnali';

  @override
  String get sendCanceled => 'Yuborish bekor qilindi';

  @override
  String get loginWithMatrixId => 'Matriks-ID bilan kirish';

  @override
  String get doesNotSeemToBeAValidHomeserver =>
      'Uy serveri mos emasga o‘xshaydi. URL xato kiritilganmi?';

  @override
  String get calculatingFileSize => 'Fayl hajmi hisoblanmoqda...';

  @override
  String get prepareSendingAttachment =>
      'Yuborish uchun biriktirmani tayyorlang...';

  @override
  String get sendingAttachment => 'Biriktirish yuborilmoqda...';

  @override
  String get generatingVideoThumbnail => 'Video eskizi yaratilmoqda...';

  @override
  String get compressVideo => 'Video siqilmoqda...';

  @override
  String sendingAttachmentCountOfCount(int index, int length) {
    return 'Biriktirma yuborilmoqda: $index of $length...';
  }

  @override
  String serverLimitReached(int seconds) {
    return 'Server limiti tugadi! $seconds soniya kutilmoqda...';
  }

  @override
  String get oneOfYourDevicesIsNotVerified =>
      'Qurilmalaringizdan biri tasdiqlanmagan';

  @override
  String get noticeChatBackupDeviceVerification =>
      'Eslatma: Barcha qurilmalaringizni suhbat zaxira nusxasiga ulaganingizda, ular avtomatik ravishda tasdiqlanadi.';

  @override
  String get continueText => 'Davom etish';

  @override
  String get welcomeText =>
      'Hey Hey 👋 Bu FluffyChat. Siz https://matrix.org bilan mos keladigan istalgan uy serveriga kirishingiz mumkin. Va keyin istalgan kishi bilan suhbatlashishingiz mumkin. Bu ulkan markazlashtirilmagan xabar almashish tarmog\'i!';

  @override
  String get blur => 'Xiralashtirish:';

  @override
  String get opacity => 'Noaniqlik:';

  @override
  String get setWallpaper => 'Fon rasmini sozlash';

  @override
  String get manageAccount => 'Hisobni boshqarish';

  @override
  String get noContactInformationProvided =>
      'Server hech qanday yaroqli kontakt axborotini taqdim etmaydi';

  @override
  String get contactServerAdmin => 'Server administratori bilan bog‘lanish';

  @override
  String get contactServerSecurity => 'Aloqa serveri xavfsizligi';

  @override
  String get supportPage => 'Yordam sahifasi';

  @override
  String get serverInformation => 'Server haqida ma’lumot:';

  @override
  String get name => 'Nomi';

  @override
  String get version => 'Versiya';

  @override
  String get website => 'Sayt';

  @override
  String get compress => 'Siqmoq';

  @override
  String get boldText => 'Qalin matn';

  @override
  String get italicText => 'Qiya matn';

  @override
  String get strikeThrough => 'O‘tish joyi';

  @override
  String get pleaseFillOut => 'Iltimos, to‘ldiring';

  @override
  String get invalidUrl => 'Yaroqsiz url';

  @override
  String get addLink => 'Havola kiritish';

  @override
  String get unableToJoinChat =>
      'Chatga qoʻshilib boʻlmadi. Ehtimol, boshqa tomon suhbatni allaqachon yopib qoʻygan.';

  @override
  String get previous => 'Avvalgi';

  @override
  String get otherPartyNotLoggedIn =>
      'Narigi tomon hozirda hisobingizga kirmagan va shuning uchun xabarlarni qabul qila olmaydi!';

  @override
  String appWantsToUseForLogin(String server) {
    return 'Hisobga kirish \'$server\' ishlating';
  }

  @override
  String get appWantsToUseForLoginDescription =>
      'Siz bu bilan ilova va veb-saytga siz haqingizdagi axborotni ulashishga ruxsat berasiz.';

  @override
  String get open => 'Ochish';

  @override
  String get waitingForServer => 'Server kutilmoqda...';

  @override
  String get newChatRequest => '📩 Yangi suhbat uchun soʻrov';

  @override
  String get contentNotificationSettings =>
      'Kontent bildirishnomasi sozlamalari';

  @override
  String get generalNotificationSettings => 'Umumiy bildirishnoma sozlamalari';

  @override
  String get roomNotificationSettings => 'Xona bildirishnomasi sozlamalari';

  @override
  String get userSpecificNotificationSettings =>
      'Foydalanuvchiga xos bildirishnoma sozlamalari';

  @override
  String get otherNotificationSettings => 'Boshqa bildirishnoma sozlamalari';

  @override
  String get notificationRuleContainsUserName =>
      'Foydalanuvchi nomini ichiga oladi';

  @override
  String get notificationRuleContainsUserNameDescription =>
      'Xabarda foydalanuvchi nomi mavjud bo‘lsa, foydalanuvchiga xabar beradi.';

  @override
  String get notificationRuleMaster =>
      'Barcha bildirishnomalarni ovozsiz qilish';

  @override
  String get notificationRuleMasterDescription =>
      'Boshqa barcha qoidalarni bekor qiladi va barcha bildirishnomalarni faolsizlantiradi.';

  @override
  String get notificationRuleSuppressNotices =>
      'Avtomatlashtirilgan xabarlarni o‘chirish';

  @override
  String get notificationRuleSuppressNoticesDescription =>
      'Botlar kabi avtomatlashtirilgan mijozlardan kelgan bildirishnomalarni to‘xtatadi.';

  @override
  String get notificationRuleInviteForMe => 'Men uchun taklif qilish';

  @override
  String get notificationRuleInviteForMeDescription =>
      'Foydalanuvchi xonaga taklif qilinganda unga xabar beradi.';

  @override
  String get notificationRuleMemberEvent => 'A’zo tadbirlari';

  @override
  String get notificationRuleMemberEventDescription =>
      'Obuna tadbirlari uchun bildirishnomalarni o‘chiradi.';

  @override
  String get notificationRuleIsUserMention => 'Foydalanuvchi zikri';

  @override
  String get notificationRuleIsUserMentionDescription =>
      'Foydalanuvchi xabarida to‘g‘ridan-to‘g‘ri tilga olinganida unga xabar beradi.';

  @override
  String get notificationRuleContainsDisplayName =>
      'Tarkibida displey nomi bor';

  @override
  String get notificationRuleContainsDisplayNameDescription =>
      'Xabarda foydalanuvchining displey nomi mavjudligi haqida foydalanuvchiga xabar beradi.';

  @override
  String get notificationRuleIsRoomMention => 'Xonaga eslatma';

  @override
  String get notificationRuleIsRoomMentionDescription =>
      'Xona zikri mavjudligida foydalanuvchiga xabar beradi.';

  @override
  String get notificationRuleRoomnotif => 'Xona bildirishnomasi';

  @override
  String get notificationRuleRoomnotifDescription =>
      'Xabar tarkibida @room bo‘lsa, foydalanuvchiga xabar beradi.';

  @override
  String get notificationRuleTombstone => 'Qabrtosh';

  @override
  String get notificationRuleTombstoneDescription =>
      'Xonani faolsizlantirish xabarlari haqida foydalanuvchiga xabar beradi.';

  @override
  String get notificationRuleReaction => 'Reaksiya';

  @override
  String get notificationRuleReactionDescription =>
      'Munosabat bildirishnomalarini o‘chiradi.';

  @override
  String get notificationRuleRoomServerAcl => 'Guruh serveri ACL';

  @override
  String get notificationRuleRoomServerAclDescription =>
      'Guruh serveriga kirishni boshqarish ro‘yxatlari (ACL) uchun bildirishnomalarni bostiradi.';

  @override
  String get notificationRuleSuppressEdits => 'Tahrirlarni bostirish';

  @override
  String get notificationRuleSuppressEditsDescription =>
      'Tahrirlangan xabarlar uchun bildirishnomalarni o‘chiradi.';

  @override
  String get notificationRuleCall => 'Chaqiruv';

  @override
  String get notificationRuleCallDescription =>
      'Chaqiruvlar haqida foydalanuvchiga xabar beradi.';

  @override
  String get notificationRuleEncryptedRoomOneToOne =>
      'Shifrlangan birga-bir guruh';

  @override
  String get notificationRuleEncryptedRoomOneToOneDescription =>
      'Shifrlangan birga-bir guruhlardagi xabarlar haqida foydalanuvchiga xabar beradi.';

  @override
  String get notificationRuleRoomOneToOne => 'Birga-bir guruh';

  @override
  String get notificationRuleRoomOneToOneDescription =>
      'Birga-bir guruhlardagidagi xabarlar haqida foydalanuvchiga xabar beradi.';

  @override
  String get notificationRuleMessage => 'Xabar';

  @override
  String get notificationRuleMessageDescription =>
      'Foydalanuvchiga umumiy xabarlar haqida xabar beradi.';

  @override
  String get notificationRuleEncrypted => 'Shifrlangan';

  @override
  String get notificationRuleEncryptedDescription =>
      'Shifrlangan guruhlardagi xabarlar haqida foydalanuvchiga xabar beradi.';

  @override
  String get notificationRuleJitsi => 'Jitsi';

  @override
  String get notificationRuleJitsiDescription =>
      'Jitsi vidjet hodisalari haqida foydalanuvchiga xabar beradi.';

  @override
  String get notificationRuleServerAcl => 'Server ACL hodisalarini bostirish';

  @override
  String get notificationRuleServerAclDescription =>
      'Server ACL hodisalari uchun bildirishnomalarni o‘chiradi.';

  @override
  String unknownPushRule(String rule) {
    return 'Noma’lum push qoidasi \'$rule\'';
  }

  @override
  String sentVoiceMessage(String sender, String duration) {
    return '️ 🎙️$duration - ${sender}dan ovozli xabar';
  }

  @override
  String get deletePushRuleCanNotBeUndone =>
      'Agar ushbu bildirishnoma sozlamasini o‘chirib tashlasangiz, buni bekor qilib bo‘lmaydi.';

  @override
  String get more => 'Yana';

  @override
  String get shareKeysWith => 'Kalitlarni ulashish...';

  @override
  String get shareKeysWithDescription =>
      'Shifrlangan suhbatlarda xabarlaringizni oʻqishlari uchun qaysi qurilmalarga ishonish kerak?';

  @override
  String get allDevices => 'Barcha qurilmalar';

  @override
  String get crossVerifiedDevicesIfEnabled =>
      'Agar yoqilgan bo‘lsa, tasdiqlangan qurilmalarni kesib o‘tish';

  @override
  String get crossVerifiedDevices => 'O‘zaro tekshirilgan qurilmalar';

  @override
  String get verifiedDevicesOnly => 'Faqat tasdiqlangan qurilmalar';

  @override
  String get takeAPhoto => 'Suratga olish';

  @override
  String get recordAVideo => 'Video yozib olish';

  @override
  String get optionalMessage => '(Ixtiyoriy) xabar...';

  @override
  String get notSupportedOnThisDevice => 'Bu qurilmada ishlamaydi';

  @override
  String get enterNewChat => 'Yangi suhbatga kirish';

  @override
  String get approve => 'Tasdiqlash';

  @override
  String get youHaveKnocked => 'Siz taqillatdingiz';

  @override
  String get pleaseWaitUntilInvited =>
      'Iltimos, hozir kutib turing, xonadan kimdir sizni taklif qilguncha.';

  @override
  String get commandHint_logout => 'Joriy qurilmadan chiqish';

  @override
  String get commandHint_logoutall => 'Barcha faol qurilmalardan chiqish';

  @override
  String get displayNavigationRail =>
      'Mobilda navigatsiya temir yo‘lini ko‘rsatish';

  @override
  String get customReaction => 'Maxsus reaksiya';

  @override
  String get moreEvents => 'Boshqa hodisalar';

  @override
  String get declineInvitation => 'Taklifni rad etish';

  @override
  String get noMessagesYet => 'Hozircha xabarlar yo‘q';

  @override
  String get longPressToRecordVoiceMessage =>
      'Ovozli xabarni yozib olish uchun uzoq bosing.';

  @override
  String get pause => 'Pauza';

  @override
  String get resume => 'Davom etish';

  @override
  String get removeFromSpaceDescription =>
      'Suhbat maydondan olib tashlanadi, lekin hali ham suhbatlarlar ro‘yxatida chiqadi.';

  @override
  String countChats(int chats) {
    return '$chats suhbatlar';
  }

  @override
  String spaceMemberOf(String spaces) {
    return '$spaces maydoni a’zosi';
  }

  @override
  String spaceMemberOfCanKnock(String spaces) {
    return '$spaces maydoni a’zosi eshikni taqillatishi mumkin';
  }

  @override
  String startedAPoll(String username) {
    return '$username so‘rovnoma boshladi.';
  }

  @override
  String get poll => 'So‘rov';

  @override
  String get startPoll => 'So‘rovni boshlash';

  @override
  String get endPoll => 'So‘rovnomani yakunlash';

  @override
  String get answersVisible => 'Javoblar ko‘rinadi';

  @override
  String get pollQuestion => 'So‘rovnoma savoli';

  @override
  String get answerOption => 'Javob varianti';

  @override
  String get addAnswerOption => 'Javob variantini kiritish';

  @override
  String get allowMultipleAnswers => 'Bir nechta javobga ruxsat berish';

  @override
  String get pollHasBeenEnded => 'So‘rovnoma yakunlandi';

  @override
  String countVotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta ovoz',
      one: 'Bir ovoz',
    );
    return '$_temp0';
  }

  @override
  String get answersWillBeVisibleWhenPollHasEnded =>
      'So‘rovnoma tugaganida javoblar chiqadi';

  @override
  String get replyInThread => 'Sahifada javob berish';

  @override
  String countReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta javob',
      one: 'Bitta javob',
    );
    return '$_temp0';
  }

  @override
  String get thread => 'Sahifa';

  @override
  String get backToMainChat => 'Asosiy suhbatga qaytish';

  @override
  String get saveChanges => 'O‘zgarishlarni saqlash';

  @override
  String get createSticker => 'Stiker yoki emoji yaratish';

  @override
  String get useAsSticker => 'Stiker sifatida ishlatish';

  @override
  String get useAsEmoji => 'Emoji sifatida ishlatish';

  @override
  String get stickerPackNameAlreadyExists =>
      'Stiker paketi nomi allaqachon mavjud';

  @override
  String get newStickerPack => 'Yangi stikerlar paketi';

  @override
  String get stickerPackName => 'Stiker paketi nomi';

  @override
  String get attribution => 'Atributsiya';

  @override
  String get skipChatBackup => 'Chat zaxirasini tashlab ketish';

  @override
  String get skipChatBackupWarning =>
      'Ishonchingiz komilmi? Chat zaxirasini yoqmasdan qurilmangizni almashtirsangiz, xabarlaringizga kira olmay qolishingiz mumkin.';

  @override
  String get loadingMessages => 'Xabarlar yuklanmoqda';

  @override
  String get setupChatBackup => 'Chat zaxirasini sozlash';

  @override
  String get noMoreResultsFound => 'Boshqa natijalar topilmadi';

  @override
  String chatSearchedUntil(String time) {
    return 'Chat $time gacha qidirildi';
  }

  @override
  String get federationBaseUrl => 'Federatsiya bazasi URL manzili';

  @override
  String get clientWellKnownInformation =>
      'Mijozlarga yaxshi tanish ma’lumotlar:';

  @override
  String get baseUrl => 'Asosiy URL';

  @override
  String get identityServer => 'Identifikatsiya serveri:';

  @override
  String versionWithNumber(String version) {
    return 'Versiya: $version';
  }

  @override
  String get logs => 'Jurnallar';

  @override
  String get advancedConfigs => 'Kengaytirilgan konfiguratsiyalar';

  @override
  String get advancedConfigurations => 'Kengaytirilgan sozlamalar';

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
