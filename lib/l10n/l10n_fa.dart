// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class L10nFa extends L10n {
  L10nFa([String locale = 'fa']) : super(locale);

  @override
  String get alwaysUse24HourFormat => 'false';

  @override
  String get repeatPassword => 'تکرار گذرواژه';

  @override
  String get notAnImage => 'یک فایل تصویری نیست.';

  @override
  String get ignoreUser => 'چشم‌پوشی از کاربر';

  @override
  String get remove => 'برداشتن';

  @override
  String get importNow => 'اکنون وارد کنید';

  @override
  String get importEmojis => 'وارد کردن شکلک‌ها';

  @override
  String get importFromZipFile => 'وارد کردن از پرونده زیپ';

  @override
  String get exportEmotePack => 'صادر کردن بسته شکلک به‌صورت زیپ';

  @override
  String get replace => 'جایگزین کردن';

  @override
  String get about => 'درباره';

  @override
  String aboutHomeserver(String homeserver) {
    return 'درباره $homeserver';
  }

  @override
  String get accept => 'پذیرش';

  @override
  String acceptedTheInvitation(String username) {
    return '👍 $username دعوت را پذیرفت';
  }

  @override
  String get account => 'حساب';

  @override
  String activatedEndToEndEncryption(String username) {
    return '🔐 $username رمزنگاری سراسری را فعال کرد';
  }

  @override
  String get addEmail => 'افزودن رایانامه';

  @override
  String get confirmMatrixId =>
      'برای پاک کردن حساب، لطفاً هویت ماتریکس خود را بپذیرید.';

  @override
  String supposedMxid(String mxid) {
    return 'گمان میرود $mxid باشد';
  }

  @override
  String get addToSpace => 'به فضا افزودن';

  @override
  String get admin => 'مدیر';

  @override
  String get alias => 'نام مستعار';

  @override
  String get all => 'همه';

  @override
  String get allChats => 'همه چت ها';

  @override
  String get commandHint_roomupgrade => 'ارتقای این اتاق به نگارش مشخص‌شده';

  @override
  String get commandHint_googly => 'فرستادن چند چشم گوگولی';

  @override
  String get commandHint_cuddle => 'فرستادن آغوش';

  @override
  String get commandHint_hug => 'فرستادن بغل';

  @override
  String googlyEyesContent(String senderName) {
    return '$senderName برای شما چشم‌های گوگولی می‌فرستد';
  }

  @override
  String cuddleContent(String senderName) {
    return '$senderName شما را در آغوش می‌گیرد';
  }

  @override
  String hugContent(String senderName) {
    return '$senderName شما را بغل می‌کند';
  }

  @override
  String answeredTheCall(String senderName) {
    return '$senderName به تماس پاسخ داد';
  }

  @override
  String get anyoneCanJoin => 'هرکسی می‌تواند بپیوندد';

  @override
  String get appLock => 'قفل برنامه';

  @override
  String get appLockDescription =>
      'قفل کردن برنامه با رمز کوتاه هنگام عدم استفاده';

  @override
  String get archive => 'بایگانی';

  @override
  String get areGuestsAllowedToJoin => 'آیا مهمانان اجازه پیوستن دارند؟';

  @override
  String get areYouSure => 'مطمئن هستید؟';

  @override
  String get areYouSureYouWantToLogout => 'مطمئن هستید می‌خواهید خارج شوید؟';

  @override
  String get askSSSSSign =>
      'لطفاً عبارت عبور یا کلید بازیابی حافظه امن را وارد کنید تا شخص دیگری را امضا کنید.';

  @override
  String askVerificationRequest(String username) {
    return 'آیا درخواست بازبینی $username را می‌پذیرید؟';
  }

  @override
  String get autoplayImages => 'پخش خودکار شکلک‌ها و برچسب‌های متحرک';

  @override
  String badServerLoginTypesException(
    String serverVersions,
    String supportedVersions,
    Object suportedVersions,
  ) {
    return 'سرور از این نوع ورود پشتیبانی می‌کند:\n$serverVersions\nاما برنامه تنها از این‌ها پشتیبانی می‌کند:\n$supportedVersions';
  }

  @override
  String get sendTypingNotifications => 'فرستادن آگاه‌سازهای نوشتن';

  @override
  String get swipeRightToLeftToReply => 'کشیدن از راست به چپ برای پاسخ';

  @override
  String get sendOnEnter => 'فرستادن با کلید Enter';

  @override
  String get noMoreChatsFound => 'چت دیگری پیدا نشد...';

  @override
  String get noChatsFoundHere =>
      'اینجا هنوز چتی پیدا نشد. با استفاده از دکمه زیر چت جدیدی با کسی شروع کنید. ⤵️';

  @override
  String get unread => 'خوانده‌نشده';

  @override
  String get space => 'فضا';

  @override
  String get spaces => 'فضاها';

  @override
  String get banFromChat => 'بن کردن از چت';

  @override
  String get banned => 'محروم‌شده';

  @override
  String bannedUser(String username, String targetName) {
    return '$username کاربر $targetName را محروم کرد';
  }

  @override
  String get blockDevice => 'مسدود کردن دستگاه';

  @override
  String get blocked => 'مسدود‌شده';

  @override
  String get cancel => 'رد کردن';

  @override
  String cantOpenUri(String uri) {
    return 'نمی‌توان پیوند $uri را باز کرد';
  }

  @override
  String get changeDeviceName => 'تغییر نام دستگاه';

  @override
  String changedTheChatAvatar(String username) {
    return '$username نماد چت را تغییر داد';
  }

  @override
  String changedTheChatDescription(Object username) {
    return '‮‭‭‮‭‬‫$username توضیحات چت را تغییر داد';
  }

  @override
  String changedTheChatDescriptionTo(String username, String description) {
    return '$username توضیح چت را به \'$description\' تغییر داد';
  }

  @override
  String changedTheChatName(Object username) {
    return '$username نام چت را تغییر داد';
  }

  @override
  String changedTheChatNameTo(String username, String chatname) {
    return '$username نام چت را به \'$chatname\' تغییر داد';
  }

  @override
  String changedTheChatPermissions(String username) {
    return '$username دسترسی‌های چت را تغییر داد';
  }

  @override
  String changedTheDisplaynameTo(String username, String displayname) {
    return '$username نام نمایشی را به \'$displayname\' تغییر داد';
  }

  @override
  String changedTheGuestAccessRules(String username) {
    return '$username قوانین دسترسی مهمان را تغییر داد';
  }

  @override
  String changedTheGuestAccessRulesTo(String username, String rules) {
    return '$username قوانین دسترسی مهمان را به $rules تغییر داد';
  }

  @override
  String changedTheHistoryVisibility(String username) {
    return '$username ویژگی دیدن تاریخچه را تغییر داد';
  }

  @override
  String changedTheHistoryVisibilityTo(String username, String rules) {
    return '$username ویژگی دیدن تاریخچه را به $rules تغییر داد';
  }

  @override
  String changedTheJoinRules(String username) {
    return '$username قوانین پیوستن را تغییر داد';
  }

  @override
  String changedTheJoinRulesTo(String username, String joinRules) {
    return '$username قوانین پیوستن را به $joinRules تغییر داد';
  }

  @override
  String changedTheProfileAvatar(String username) {
    return '$username نماد نمایه را تغییر داد';
  }

  @override
  String changedTheRoomAliases(String username) {
    return '$username نام‌های مستعار اتاق را تغییر داد';
  }

  @override
  String changedTheRoomInvitationLink(String username) {
    return '$username پیوند دعوت را تغییر داد';
  }

  @override
  String get changePassword => 'تغییر گذرواژه';

  @override
  String get changeTheHomeserver => 'تغییر سرور خانگی';

  @override
  String get changeTheme => 'تغییر پوسته';

  @override
  String get changeTheNameOfTheGroup => 'تغییر نام گروه';

  @override
  String get changeYourAvatar => 'تغییر نماد نمایه';

  @override
  String get channelCorruptedDecryptError => 'رمزنگاری مخدوش شده است';

  @override
  String get chat => 'چت';

  @override
  String get yourChatBackupHasBeenSetUp => 'پشتیبان چت شما تنظیم شد.';

  @override
  String get chatBackup => 'پشتیبان چت';

  @override
  String get chatBackupDescription =>
      'پیام‌های شما با کلید بازیابی محافظت می‌شوند. حتماً آن را نزد خود نگه دارید.';

  @override
  String get chatDetails => 'جزئیات چت';

  @override
  String get chats => 'چت ها';

  @override
  String get chooseAStrongPassword => 'یک گذرواژه قوی انتخاب کنید';

  @override
  String get clearArchive => 'پاک کردن بایگانی';

  @override
  String get close => 'بستن';

  @override
  String get commandHint_markasdm =>
      'علامت‌گذاری به‌عنوان اتاق پیام مستقیم با شناسه ماتریکس';

  @override
  String get commandHint_markasgroup => 'علامت‌گذاری به‌عنوان گروه';

  @override
  String get commandHint_ban => 'محروم کردن کاربر مشخص‌شده از این اتاق';

  @override
  String get commandHint_clearcache => 'پاک کردن حافظه نهان';

  @override
  String get commandHint_create =>
      'ساختن یک چت گروهی خالی\nاز «--no-encryption» برای غیرفعال کردن رمزنگاری استفاده کنید';

  @override
  String get commandHint_discardsession => 'رد کردن نشست';

  @override
  String get commandHint_dm =>
      'شروع یک چت مستقیم\nاز «--no-encryption» برای غیرفعال کردن رمزنگاری استفاده کنید';

  @override
  String get commandHint_html => 'فرستادن متن با قالب HTML';

  @override
  String get commandHint_invite => 'دعوت از کاربر مشخص‌شده به این اتاق';

  @override
  String get commandHint_join => 'پیوستن به اتاق مشخص‌شده';

  @override
  String get commandHint_kick => 'بیرون کردن کاربر مشخص‌شده از این اتاق';

  @override
  String get commandHint_leave => 'ترک این اتاق';

  @override
  String get commandHint_me => 'توصیف خود';

  @override
  String get commandHint_myroomavatar =>
      'تنظیم نماد نمایه برای این اتاق (با mxc-uri)';

  @override
  String get commandHint_myroomnick => 'تنظیم نام نمایشی برای این اتاق';

  @override
  String get commandHint_op => 'تنظیم سطح دسترسی کاربر مشخص‌شده (پیش‌فرض: ۵۰)';

  @override
  String get commandHint_plain => 'فرستادن متن بدون قالب';

  @override
  String get commandHint_react => 'فرستادن پاسخ به‌عنوان واکنش';

  @override
  String get commandHint_send => 'فرستادن متن';

  @override
  String get commandHint_unban => 'رد محرومیت کاربر مشخص‌شده از این اتاق';

  @override
  String get commandInvalid => 'دستور نامعتبر';

  @override
  String commandMissing(String command) {
    return '$command یک دستور نیست.';
  }

  @override
  String get compareEmojiMatch => 'لطفاً شکلک‌ها را مقایسه کنید';

  @override
  String get compareNumbersMatch => 'لطفاً اعداد را مقایسه کنید';

  @override
  String get configureChat => 'تنظیمات چت';

  @override
  String get contactHasBeenInvitedToTheGroup => 'مخاطب به گروه دعوت شد';

  @override
  String get contentHasBeenReported => 'محتوا به مدیران سرور گزارش شد';

  @override
  String get copiedToClipboard => 'به بریده‌دان رونوشت شد';

  @override
  String get copy => 'رونوشت';

  @override
  String get copyToClipboard => 'رونوشت به بریده‌دان';

  @override
  String couldNotDecryptMessage(String error) {
    return 'نمی‌توان پیام را رمزگشایی کرد: $error';
  }

  @override
  String get checkList => 'فهرست بررسی';

  @override
  String countParticipants(int count) {
    return '$count شرکت‌کننده';
  }

  @override
  String countInvited(int count) {
    return '$count دعوت‌شده';
  }

  @override
  String get create => 'ساختن';

  @override
  String createdTheChat(String username) {
    return '💬 $username چت را ساخت';
  }

  @override
  String get createGroup => 'ساختن گروه';

  @override
  String get createNewSpace => 'فضای جدید';

  @override
  String get currentlyActive => 'اکنون فعال';

  @override
  String get darkTheme => 'تیره';

  @override
  String dateAndTimeOfDay(String date, String timeOfDay) {
    return '$date، $timeOfDay';
  }

  @override
  String get deactivateAccountWarning =>
      'این کار حساب شما را غیرفعال می‌کند. این کنش برگشت‌ناپذیر است! آیا مطمئن هستید؟';

  @override
  String get defaultPermissionLevel => 'سطح دسترسی پیش‌فرض';

  @override
  String get delete => 'پاک کردن';

  @override
  String get deleteAccount => 'پاک کردن حساب';

  @override
  String get deleteMessage => 'پاک کردن پیام';

  @override
  String get device => 'دستگاه';

  @override
  String get deviceId => 'شناسه دستگاه';

  @override
  String get devices => 'دستگاه‌ها';

  @override
  String get directChats => 'چت های مستقیم';

  @override
  String get displaynameHasBeenChanged => 'نام نمایشی تغییر کرد';

  @override
  String get downloadFile => 'بارگیری پرونده';

  @override
  String get edit => 'ویرایش';

  @override
  String get editBlockedServers => 'ویرایش سرورهای مسدود';

  @override
  String get chatPermissions => 'دسترسی‌های چت';

  @override
  String get editDisplayname => 'ویرایش نام نمایشی';

  @override
  String get editRoomAliases => 'ویرایش نام‌های مستعار اتاق';

  @override
  String get editRoomAvatar => 'ویرایش نماد اتاق';

  @override
  String get emoteExists => 'شکلک از پیش وجود دارد!';

  @override
  String get emoteInvalid => 'کد کوتاه شکلک نامعتبر است!';

  @override
  String get emoteKeyboardNoRecents =>
      'شکلک‌هایی که به تازگی استفاده‌شده اینجا نمایش داده میشوند...';

  @override
  String get emotePacks => 'بسته‌های شکلک برای اتاق';

  @override
  String get emoteSettings => 'تنظیمات شکلک';

  @override
  String get globalChatId => 'شناسه سراسری چت';

  @override
  String get accessAndVisibility => 'دسترسی و قابلیت دید';

  @override
  String get accessAndVisibilityDescription =>
      'چه کسی اجازه پیوستن به این چت را دارد و چت چگونه قابل پیدا شدن است.';

  @override
  String get calls => 'تماس‌ها';

  @override
  String get customEmojisAndStickers => 'شکلک‌ها و برچسب‌های سفارشی';

  @override
  String get customEmojisAndStickersBody =>
      'افزودن یا اشتراک گذاری ایموجی ها یا استیکر های سفارشی که در هر چت قابل استفاده‌اند.';

  @override
  String get emoteShortcode => 'کد کوتاه شکلک';

  @override
  String get emptyChat => 'چت خالی';

  @override
  String get enableEmotesGlobally => 'فعال کردن بسته شکلک به‌صورت سراسری';

  @override
  String get enableEncryption => 'فعال کردن رمزنگاری';

  @override
  String get enableEncryptionWarning =>
      'نمی‌توانید رمزنگاری را غیرفعال کنید. آیا مطمئن هستید؟';

  @override
  String get encrypted => 'رمزنگاری‌شده';

  @override
  String get encryption => 'رمزنگاری';

  @override
  String get encryptionNotEnabled => 'رمزنگاری فعال نیست';

  @override
  String endedTheCall(String senderName) {
    return '$senderName به تماس پایان داد';
  }

  @override
  String get enterAnEmailAddress => 'یک نشانی رایانامه وارد کنید';

  @override
  String get homeserver => 'سرور خانگی';

  @override
  String errorObtainingLocation(String error) {
    return 'خطا در به‌دست آوردن مکان: $error';
  }

  @override
  String get everythingReady => 'همه‌چیز آماده است!';

  @override
  String get extremeOffensive => 'بسیار توهین‌آمیز';

  @override
  String get fileName => 'نام پرونده';

  @override
  String get fluffychat => 'فلافی‌چت';

  @override
  String get fontSize => 'اندازه قلم';

  @override
  String get forward => 'هدایت';

  @override
  String get fromJoining => 'از پیوستن';

  @override
  String get fromTheInvitation => 'از دعوت';

  @override
  String get group => 'گروه';

  @override
  String get chatDescription => 'توضیحات چت';

  @override
  String get chatDescriptionHasBeenChanged => 'توضیحات چت تغییر کرد';

  @override
  String get groupIsPublic => 'گروه عمومی است';

  @override
  String get groups => 'گروه‌ها';

  @override
  String groupWith(String displayname) {
    return 'گروه با $displayname';
  }

  @override
  String get guestsAreForbidden => 'مهمان‌ها ممنوع هستند';

  @override
  String get guestsCanJoin => 'مهمان‌ها می‌توانند بپیوندند';

  @override
  String hasWithdrawnTheInvitationFor(String username, String targetName) {
    return '$username دعوت $targetName را پس گرفت';
  }

  @override
  String get help => 'کمک';

  @override
  String get hideRedactedEvents => 'پنهان کردن رویدادهای ویرایش‌شده';

  @override
  String get hideRedactedMessages => 'پنهان کردن پیام‌های ویرایش‌شده';

  @override
  String get hideRedactedMessagesBody =>
      'اگر کسی پیامی را ویرایش کند، دیگر نمیتوان آن پیام را در چت دید.';

  @override
  String get hideInvalidOrUnknownMessageFormats =>
      'پنهان کردن قالب‌های پیام نامعتبر یا ناشناخته';

  @override
  String get howOffensiveIsThisContent => 'این محتوا چقدر توهین‌آمیز است؟';

  @override
  String get id => 'شناسه';

  @override
  String get block => 'مسدود کردن';

  @override
  String get blockedUsers => 'کاربران مسدود‌شده';

  @override
  String get blockListDescription =>
      'میتوانید کاربرانی که مزاحم شما هستند را مسدود کنید. از کاربران موجود در فهرست مسدود شخصی، پیام یا دعوت به اتاق دریافت نخواهید کرد.';

  @override
  String get blockUsername => 'چشم‌پوشی از نام کاربری';

  @override
  String get iHaveClickedOnLink => 'روی پیوند کلیک کردم';

  @override
  String get incorrectPassphraseOrKey =>
      'عبارت عبور یا کلید بازیابی نادرست است';

  @override
  String get inoffensive => 'بی‌ضرر';

  @override
  String get inviteContact => 'دعوت از مخاطب';

  @override
  String inviteContactToGroup(String groupName) {
    return 'دعوت مخاطب به $groupName';
  }

  @override
  String get noChatDescriptionYet => 'هنوز توضیحات چتی نوشته نشده است.';

  @override
  String get tryAgain => 'تلاش دوباره';

  @override
  String get invalidServerName => 'نام سرور نامعتبر';

  @override
  String get invited => 'دعوت‌شده';

  @override
  String get redactMessageDescription =>
      'پیام برای همه شرکت‌کنندگان در این گفتگو ویرایش خواهد شد. این کار برگشت‌ناپذیر است.';

  @override
  String get optionalRedactReason => '(اختیاری) دلیل ویرایش این پیام...';

  @override
  String invitedUser(String username, String targetName) {
    return '📩 $username از $targetName دعوت کرد';
  }

  @override
  String get invitedUsersOnly => 'فقط کاربران دعوت‌شده';

  @override
  String inviteText(String username, String link) {
    return '$username شما را به فلافی‌چت دعوت کرد.\n۱. به fluffychat.im بروید و برنامه را نصب کنید\n۲. ثبت‌نام کنید یا وارد شوید\n۳. پیوند دعوت را باز کنید:\n $link';
  }

  @override
  String get isTyping => 'در حال نوشتن…';

  @override
  String joinedTheChat(String username) {
    return '👋 $username به چت پیوست';
  }

  @override
  String get joinRoom => 'پیوستن به اتاق';

  @override
  String kicked(String username, String targetName) {
    return '👞 $username کاربر $targetName را بیرون کرد';
  }

  @override
  String kickedAndBanned(String username, String targetName) {
    return '🙅 $username کاربر $targetName را بیرون و محروم کرد';
  }

  @override
  String get kickFromChat => 'بیرون کردن از چت';

  @override
  String lastActiveAgo(String localizedTimeShort) {
    return 'آخرین فعالیت: $localizedTimeShort';
  }

  @override
  String get leave => 'ترک کردن';

  @override
  String get leftTheChat => 'چت را ترک کرد';

  @override
  String get lightTheme => 'روشن';

  @override
  String loadCountMoreParticipants(int count) {
    return 'بارگیری $count شرکت‌کننده دیگر';
  }

  @override
  String get dehydrate => 'صدور نشست و پاک کردن دستگاه';

  @override
  String get dehydrateWarning =>
      'این کنش برگشت‌ناپذیر است. مطمئن شوید پرونده پشتیبان را به‌صورت امن ذخیره می‌کنید.';

  @override
  String get hydrate => 'بازیابی از پرونده پشتیبان';

  @override
  String get loadingPleaseWait => 'در حال بارگذاری… لطفاً صبر کنید.';

  @override
  String get loadMore => 'بارگذاری بیشتر…';

  @override
  String get locationDisabledNotice =>
      'مکان‌یاب غیرفعال است. لطفاً آن را فعال کنید تا بتوانید مکان خود را هم‌رسانی کنید.';

  @override
  String get locationPermissionDeniedNotice =>
      'دسترسی به مکان رد شد. برای هم‌رسانی مکان، لطفاً دسترسی بدهید.';

  @override
  String get login => 'ورود';

  @override
  String logInTo(String homeserver) {
    return 'ورود به $homeserver';
  }

  @override
  String get logout => 'خروج';

  @override
  String get mention => 'نام‌بردن';

  @override
  String get messages => 'پیام‌ها';

  @override
  String get messagesStyle => 'پیام‌ها:';

  @override
  String get moderator => 'ناظر';

  @override
  String get muteChat => 'بی‌صدا کردن چت';

  @override
  String get needPantalaimonWarning =>
      'لطفاً توجه کنید که برای رمزنگاری سرتاسر به Pantalaimon نیاز دارید.';

  @override
  String get newChat => 'چت جدید';

  @override
  String get newMessageInFluffyChat => '💬 پیام جدید در فلافی‌چت';

  @override
  String get newVerificationRequest => 'درخواست بازبینی جدید!';

  @override
  String get next => 'بعدی';

  @override
  String get no => 'خیر';

  @override
  String get noConnectionToTheServer => 'بدون اتصال به سرور';

  @override
  String get noEmotesFound => 'شکلکی پیدا نشد. 😕';

  @override
  String get noEncryptionForPublicRooms =>
      'رمزنگاری را تنها زمانی می‌توانید فعال کنید که اتاق عمومی نباشد.';

  @override
  String get noGoogleServicesWarning =>
      'به نظر می‌رسد دستگاه شما سرویس‌های گوگل ندارد. این انتخاب خوبی برای حریم خصوصی است! برای دریافت آگاه‌سازها در فلافی‌چت، پیشنهاد می‌کنیم از https://ntfy.sh استفاده کنید. با ntfy یا یک فراهم‌کننده UnifiedPush می‌توانید آگاه‌سازهای امن دریافت کنید. می‌توانید ntfy را از Play Store یا F-Droid بارگیری کنید.';

  @override
  String noMatrixServer(String server1, String server2) {
    return '$server1 سرور ماتریکس نیست، از $server2 استفاده شود؟';
  }

  @override
  String get shareInviteLink => 'هم‌رسانی پیوند دعوت';

  @override
  String get scanQrCode => 'پویش کد QR';

  @override
  String get none => 'هیچ';

  @override
  String get noPasswordRecoveryDescription =>
      'هنوز روشی برای بازیابی گذرواژه خود اضافه نکرده‌اید.';

  @override
  String get noPermission => 'بدون دسترسی';

  @override
  String get noRoomsFound => 'اتاقی پیدا نشد…';

  @override
  String get notifications => 'آگاه‌سازها';

  @override
  String numUsersTyping(int count) {
    return '$count کاربر در حال نوشتن…';
  }

  @override
  String get obtainingLocation => 'در حال به‌دست آوردن مکان…';

  @override
  String get offensive => 'توهین‌آمیز';

  @override
  String get offline => 'آفلاین';

  @override
  String get ok => 'خوب';

  @override
  String get online => 'آنلاین';

  @override
  String get onlineKeyBackupEnabled => 'پشتیبان‌گیری آنلاین کلید فعال است';

  @override
  String get oopsPushError => 'اوه! خطایی در تنظیم آگاه‌سازها رخ داد.';

  @override
  String get oopsSomethingWentWrong => 'اوه، مشکلی پیش آمد…';

  @override
  String get openAppToReadMessages => 'برای خواندن پیام‌ها، برنامه را باز کنید';

  @override
  String get openCamera => 'باز کردن دوربین';

  @override
  String get oneClientLoggedOut => 'یکی از برنامه‌های شما از سیستم خارج شد';

  @override
  String get addAccount => 'افزودن حساب';

  @override
  String get editBundlesForAccount => 'ویرایش بسته‌های این حساب';

  @override
  String get addToBundle => 'افزودن به بسته';

  @override
  String get removeFromBundle => 'برداشتن از بسته';

  @override
  String get bundleName => 'نام بسته';

  @override
  String get enableMultiAccounts =>
      '(آزمایشی) فعال کردن چند حساب در این دستگاه';

  @override
  String get openInMaps => 'باز کردن در نقشه';

  @override
  String get link => 'پیوند';

  @override
  String get serverRequiresEmail =>
      'برای ثبت‌نام، این سرور باید نشانی رایانامه شما را تأیید کند.';

  @override
  String get or => 'یا';

  @override
  String get participant => 'شرکت‌کننده';

  @override
  String get passphraseOrKey => 'عبارت عبور یا کلید بازیابی';

  @override
  String get password => 'گذرواژه';

  @override
  String get passwordForgotten => 'فراموشی گذرواژه';

  @override
  String get passwordHasBeenChanged => 'گذرواژه تغییر کرد';

  @override
  String get overview => 'دید کلی';

  @override
  String get passwordRecoverySettings => 'تنظیمات بازیابی گذرواژه';

  @override
  String get passwordRecovery => 'بازیابی گذرواژه';

  @override
  String get pickImage => 'انتخاب تصویر';

  @override
  String get pin => 'سنجاق کردن';

  @override
  String play(String fileName) {
    return 'پخش $fileName';
  }

  @override
  String get pleaseChooseAPasscode => 'لطفاً یک رمز کوتاه انتخاب کنید';

  @override
  String get pleaseClickOnLink =>
      'لطفاً روی پیوند در رایانامه کلیک کنید و ادامه دهید.';

  @override
  String get pleaseEnter4Digits =>
      'لطفاً ۴ رقم وارد کنید یا خالی بگذارید تا قفل برنامه غیرفعال شود.';

  @override
  String get pleaseEnterYourPassword => 'لطفاً گذرواژه خود را وارد کنید';

  @override
  String get pleaseEnterYourPin => 'لطفاً رمز کوتاه خود را وارد کنید';

  @override
  String get pleaseEnterYourUsername => 'لطفاً نام کاربری خود را وارد کنید';

  @override
  String get pleaseFollowInstructionsOnWeb =>
      'لطفاً دستورالعمل‌های وبگاه را دنبال کنید و روی بعدی بزنید.';

  @override
  String get privacy => 'حریم خصوصی';

  @override
  String get publicRooms => 'اتاق‌های عمومی';

  @override
  String get pushRules => 'قوانین آگاه‌ساز';

  @override
  String get reason => 'دلیل';

  @override
  String get recording => 'در حال ضبط';

  @override
  String redactedBy(String username) {
    return 'ویرایش‌شده به‌دست $username';
  }

  @override
  String get directChat => 'چت مستقیم';

  @override
  String redactedByBecause(String username, String reason) {
    return 'ویرایش‌شده به‌دست $username زیرا: «$reason»';
  }

  @override
  String redactedAnEvent(String username) {
    return '$username یک رویداد را ویرایش کرد';
  }

  @override
  String get redactMessage => 'ویرایش پیام';

  @override
  String get register => 'ثبت‌نام';

  @override
  String get reject => 'رد کردن';

  @override
  String rejectedTheInvitation(String username) {
    return '$username دعوت را رد کرد';
  }

  @override
  String get removeAllOtherDevices => 'پاک کردن همه دستگاه‌های دیگر';

  @override
  String removedBy(String username) {
    return 'پاک‌شده توسط $username';
  }

  @override
  String get unbanFromChat => 'لغو محرومیت از چت';

  @override
  String get removeYourAvatar => 'برداشتن نماد نمایه';

  @override
  String get replaceRoomWithNewerVersion => 'جایگزینی اتاق با نگارش جدیدتر';

  @override
  String get reply => 'پاسخ';

  @override
  String get reportMessage => 'گزارش پیام';

  @override
  String get requestPermission => 'درخواست دسترسی';

  @override
  String get roomHasBeenUpgraded => 'اتاق ارتقا یافت';

  @override
  String get roomVersion => 'نگارش اتاق';

  @override
  String get saveFile => 'ذخیره پرونده';

  @override
  String get search => 'جستجو';

  @override
  String get security => 'امنیت';

  @override
  String get recoveryKey => 'کلید بازیابی';

  @override
  String get recoveryKeyLost => 'کلید بازیابی گم شد؟';

  @override
  String get send => 'فرستادن';

  @override
  String get sendAMessage => 'فرستادن پیام';

  @override
  String get sendAsText => 'فرستادن به‌عنوان متن';

  @override
  String get sendAudio => 'فرستادن صدا';

  @override
  String get sendFile => 'فرستادن پرونده';

  @override
  String get sendImage => 'فرستادن تصویر';

  @override
  String sendImages(int count) {
    return 'فرستادن $count تصویر';
  }

  @override
  String get sendMessages => 'فرستادن پیام‌ها';

  @override
  String get sendVideo => 'فرستادن ویدئو';

  @override
  String sentAFile(String username) {
    return '📁 $username یک پرونده فرستاد';
  }

  @override
  String sentAnAudio(String username) {
    return '🎤 $username یک صدا فرستاد';
  }

  @override
  String sentAPicture(String username) {
    return '🖼️ $username یک تصویر فرستاد';
  }

  @override
  String sentASticker(String username) {
    return '😊 $username یک برچسب فرستاد';
  }

  @override
  String sentAVideo(String username) {
    return '🎥 $username یک ویدئو فرستاد';
  }

  @override
  String sentCallInformations(String senderName) {
    return '$senderName اطلاعات تماس را فرستاد';
  }

  @override
  String get setAsCanonicalAlias => 'تنظیم به‌عنوان نام مستعار اصلی';

  @override
  String get setChatDescription => 'تنظیم توضیحات چت';

  @override
  String get setStatus => 'تنظیم وضعیت';

  @override
  String get settings => 'تنظیمات';

  @override
  String get share => 'هم‌رسانی';

  @override
  String sharedTheLocation(String username) {
    return '$username وضعیت مکانی خود را به اشتراک گذاشت';
  }

  @override
  String get shareLocation => 'هم‌رسانی مکان';

  @override
  String get showPassword => 'نمایش گذرواژه';

  @override
  String get presencesToggle => 'نمایش پیام‌های وضعیت از دیگر کاربران';

  @override
  String get skip => 'رد کردن';

  @override
  String get sourceCode => 'کد منبع';

  @override
  String get spaceIsPublic => 'فضا عمومی است';

  @override
  String get spaceName => 'نام فضا';

  @override
  String startedACall(String senderName) {
    return '$senderName تماس را آغاز کرد';
  }

  @override
  String get status => 'وضعیت';

  @override
  String get statusExampleMessage => 'امروز حالتان چطور است؟';

  @override
  String get submit => 'ارسال';

  @override
  String get synchronizingPleaseWait => 'در حال همگام‌سازی... لطفا صبر کنید.';

  @override
  String synchronizingPleaseWaitCounter(String percentage) {
    return ' در حال همگام‌سازی... ($percentage%)';
  }

  @override
  String get systemTheme => 'سامانه';

  @override
  String get theyDontMatch => 'هم‌خوانی ندارند';

  @override
  String get theyMatch => 'هم‌خوانی دارند';

  @override
  String get title => 'فلافی‌چت';

  @override
  String get tooManyRequestsWarning =>
      'درخواست‌های بیش از حد. لطفاً بعداً دوباره تلاش کنید!';

  @override
  String get transferFromAnotherDevice => 'انتقال از دستگاهی دیگر';

  @override
  String get tryToSendAgain => 'تلاش دوباره برای فرستادن';

  @override
  String get unavailable => 'در دسترس نیست';

  @override
  String unbannedUser(String username, String targetName) {
    return '$username محرومیت $targetName را برداشت';
  }

  @override
  String get unblockDevice => 'باز کردن دستگاه';

  @override
  String get unknownDevice => 'دستگاه ناشناس';

  @override
  String get unknownEncryptionAlgorithm => 'الگوریتم رمزنگاری ناشناخته';

  @override
  String unknownEvent(String type) {
    return 'رویداد ناشناخته \'$type\'';
  }

  @override
  String get unmuteChat => 'فعال کردن صدای چت';

  @override
  String get unpin => 'برداشتن سنجاق';

  @override
  String userAndOthersAreTyping(String username, int count) {
    return '$username و $count نفر دیگر در حال تایپ کردن…';
  }

  @override
  String userAndUserAreTyping(String username, String username2) {
    return '$username و $username2 در حال نوشتن…';
  }

  @override
  String userIsTyping(String username) {
    return '$username در حال نوشتن…';
  }

  @override
  String userLeftTheChat(String username) {
    return '👋 $username چت را ترک کرد';
  }

  @override
  String get username => 'نام کاربری';

  @override
  String userSentUnknownEvent(String username, String type) {
    return '$username یک رویداد $type فرستاد';
  }

  @override
  String get unverified => 'تأییدنشده';

  @override
  String get verified => 'تاییدشده';

  @override
  String get verify => 'بازبینی';

  @override
  String get verifyStart => 'آغاز بازبینی';

  @override
  String get verifySuccess => 'بازبینی با موفقیت انجام شد!';

  @override
  String get verifyTitle => 'در حال تایید حساب دیگر';

  @override
  String get videoCall => 'تماس تصویری';

  @override
  String get visibilityOfTheChatHistory => 'قابلیت دیدن تاریخچه چت';

  @override
  String get visibleForAllParticipants => 'قابل‌دید برای همه شرکت‌کنندگان';

  @override
  String get visibleForEveryone => 'قابل‌دید برای همه';

  @override
  String get voiceMessage => 'پیام صوتی';

  @override
  String get waitingPartnerAcceptRequest =>
      'در انتظار پذیرش درخواست توسط دیگری…';

  @override
  String get waitingPartnerEmoji => 'در انتظار پذیرش شکلک توسط دیگری…';

  @override
  String get waitingPartnerNumbers => 'در انتظار پذیرش اعداد توسط دیگری…';

  @override
  String get warning => 'هشدار!';

  @override
  String get weSentYouAnEmail => 'یک رایانامه برای شما فرستادیم';

  @override
  String get whoCanPerformWhichAction => 'چه کسی می‌تواند چه کاری انجام دهد';

  @override
  String get whoIsAllowedToJoinThisGroup =>
      'چه کسی اجازه پیوستن به این گروه را دارد';

  @override
  String get whyDoYouWantToReportThis => 'چرا می‌خواهید گزارش دهید؟';

  @override
  String get wipeChatBackup =>
      'برای ایجاد کلید بازیابی جدید، پشتیبان چت خود را پاک می‌کنید؟';

  @override
  String get withTheseAddressesRecoveryDescription =>
      'با این آدرس‌ها می‌توانید رمز خود را بازیابی کنید.';

  @override
  String get writeAMessage => 'نوشتن پیام…';

  @override
  String get yes => 'بله';

  @override
  String get you => 'شما';

  @override
  String get youAreNoLongerParticipatingInThisChat =>
      'شما دیگر در این چت شرکت نمی‌کنید';

  @override
  String get youHaveBeenBannedFromThisChat => 'شما از این چت محروم شده‌اید';

  @override
  String get yourPublicKey => 'کلید عمومی شما';

  @override
  String get messageInfo => 'اطلاعات پیام';

  @override
  String get time => 'زمان';

  @override
  String get messageType => 'نوع پیام';

  @override
  String get sender => 'فرستنده';

  @override
  String get openGallery => 'بازکردن گالری';

  @override
  String get removeFromSpace => 'حذف از فضا';

  @override
  String get start => 'آغاز';

  @override
  String get pleaseEnterRecoveryKeyDescription =>
      'برای گشودن قفل پیام‌های قدیمیتان، لطفا کلید بازیابی‌ای که در یک نشست پیشین تولید شده را وارد کنید. کلید بازیابی شما، رمز عبور شما نیست.';

  @override
  String get openChat => 'باز کردن چت';

  @override
  String get markAsRead => 'علامت‌گذاشتن به عنوان خوانده شده';

  @override
  String get reportUser => 'گزارش دادن کاربر';

  @override
  String get dismiss => 'رد کردن';

  @override
  String reactedWith(String sender, String reaction) {
    return '$sender با $reaction واکنش نشان داد';
  }

  @override
  String get pinMessage => 'سنجاق کردن به اتاق';

  @override
  String get confirmEventUnpin =>
      'آیا از برداشتن سنجاق رویداد به صورت دائمی مطمئن هستید؟';

  @override
  String get emojis => 'شکلک‌ها';

  @override
  String get placeCall => 'برقراری تماس';

  @override
  String get voiceCall => 'تماس صوتی';

  @override
  String get unsupportedAndroidVersion => 'نسخه اندروید پشتیبانی‌نشده';

  @override
  String get unsupportedAndroidVersionLong =>
      'این ویژگی به نسخه تازه‌تری از اندروید نیاز دارد. لطفا به‌روزرسانی یا پشتیبانی لینیج‌اواس(LineageOS) را بررسی کنید.';

  @override
  String get videoCallsBetaWarning =>
      'لطفا توجه داشته باشید که تماس‌های تصویری در حال حاضر آزمایشی هستند. ممکن است طبق انتظار کار نکنند یا روی همه پلتفرم‌ها اصلا کار نکنند.';

  @override
  String get experimentalVideoCalls => 'تماس‌های تصویری آزمایشی';

  @override
  String get youRejectedTheInvitation => 'شما دعوت را رد کردید';

  @override
  String get youJoinedTheChat => 'شما به چت پیوستید';

  @override
  String get youAcceptedTheInvitation => '👍 شما دعوت را پذیرفتید';

  @override
  String youBannedUser(String user) {
    return 'شما $user را محروم کردید';
  }

  @override
  String youHaveWithdrawnTheInvitationFor(String user) {
    return 'شما دعوت $user را پس‌گرفتید';
  }

  @override
  String youInvitedBy(String user) {
    return '📩 شما توسط $user دعوت شده‌اید';
  }

  @override
  String invitedBy(String user) {
    return '📩 دعوت‌شده توسط $user';
  }

  @override
  String youInvitedUser(String user) {
    return '📩 شما $user را دعوت کردید';
  }

  @override
  String youKicked(String user) {
    return '👞 شما $user را بیرون کردید';
  }

  @override
  String youKickedAndBanned(String user) {
    return '🙅 شما $user را بیرون و محروم کردید';
  }

  @override
  String youUnbannedUser(String user) {
    return 'شما محرومیت $user را برداشتید';
  }

  @override
  String hasKnocked(String user) {
    return '🚪 $user در زده است';
  }

  @override
  String get usersMustKnock => 'کاربران باید در بزنند';

  @override
  String get noOneCanJoin => 'هیچ‌کس نمیتواند بپیوندد';

  @override
  String get knock => 'در زدن';

  @override
  String get users => 'کاربرها';

  @override
  String get unlockOldMessages => 'گشودن پیام‌های قدیمی';

  @override
  String get storeInSecureStorageDescription =>
      'کلید بازیابی را در محل ذخیره‌سازی امن این دستگاه ذخیره کنید.';

  @override
  String get saveKeyManuallyDescription =>
      'این کلید را با استفاده از هم‌رسانی یا بریده‌دان به‌طور دستی ذخیره کنید.';

  @override
  String get storeInAndroidKeystore => 'ذخیره در Android KeyStore';

  @override
  String get storeInAppleKeyChain => 'ذخیره در Apple KeyChain';

  @override
  String get storeSecurlyOnThisDevice => 'ذخیره امن در این دستگاه';

  @override
  String countFiles(int count) {
    return '$count پرونده';
  }

  @override
  String get user => 'کاربر';

  @override
  String get custom => 'سفارشی';

  @override
  String get foregroundServiceRunning =>
      'این آگاه‌ساز زمانی ظاهر می‌شود که خدمت پیش‌زمینه فعال است.';

  @override
  String get screenSharingTitle => 'هم‌رسانی صفحه‌نمایش';

  @override
  String get screenSharingDetail =>
      'شما در حال هم‌رسانی صفحه‌نمایش خود در فلافی‌چت هستید';

  @override
  String get whyIsThisMessageEncrypted => 'چرا این پیام خوانا نیست؟';

  @override
  String get noKeyForThisMessage =>
      'اگر پیام پیش از ورود به حساب در این دستگاه فرستاده شده باشد، این مشکل ممکن است رخ دهد.\n\nهمچنین ممکن است فرستنده دستگاه شما را مسدود کرده باشد یا مشکلی در اتصال اینترنت وجود داشته باشد.\n\nآیا می‌توانید پیام را در نشست دیگری بخوانید؟ در این صورت، می‌توانید آن را منتقل کنید! به تنظیمات > دستگاه‌ها بروید و مطمئن شوید دستگاه‌هایتان یکدیگر را بازبینی کرده‌اند. هنگام باز کردن دوباره اتاق و فعال بودن هر دو نشست، کلیدها به‌صورت خودکار منتقل می‌شوند.\n\nآیا نمی‌خواهید هنگام خروج یا تغییر دستگاه کلیدها را گم کنید؟ مطمئن شوید پشتیبان چت را در تنظیمات فعال کرده‌اید.';

  @override
  String get newGroup => 'گروه جدید';

  @override
  String get newSpace => 'فضای جدید';

  @override
  String get allSpaces => 'همه فضاها';

  @override
  String get hidePresences => 'پنهان کردن فهرست وضعیت؟';

  @override
  String get doNotShowAgain => 'دوباره نمایش نده';

  @override
  String wasDirectChatDisplayName(String oldDisplayName) {
    return 'چت خالی (قبلا $oldDisplayName بود)';
  }

  @override
  String get newSpaceDescription =>
      'فضاها امکان یکپارچه‌سازی چت ها و ساخت جوامع خصوصی یا عمومی را فراهم می‌کنند.';

  @override
  String get encryptThisChat => 'رمزنگاری این چت';

  @override
  String get disableEncryptionWarning =>
      'به دلایل امنیتی نمی‌توانید رمزنگاری را در چتی که فعال شده غیرفعال کنید.';

  @override
  String get sorryThatsNotPossible => 'متأسفیم... این ممکن نیست';

  @override
  String get deviceKeys => 'کلیدهای دستگاه:';

  @override
  String get reopenChat => 'باز کردن دوباره چت';

  @override
  String get noBackupWarning =>
      'هشدار! بدون فعال کردن پشتیبان چت، دسترسی به پیام‌های رمزنگاری‌شده خود را از دست خواهید داد. پیشنهاد می‌شود پیش از خروج، پشتیبان چت را فعال کنید.';

  @override
  String get noOtherDevicesFound => 'دستگاه دیگری پیدا نشد';

  @override
  String fileIsTooBigForServer(String max) {
    return 'نمیتوان فرستاد! سرور تنها از پیوست های تا $max پشتیبانی میکند.';
  }

  @override
  String fileHasBeenSavedAt(String path) {
    return 'پرونده در $path ذخیره شد';
  }

  @override
  String get jumpToLastReadMessage => 'پرش به آخرین پیام خوانده‌شده';

  @override
  String get readUpToHere => 'خوانده‌شده تا اینجا';

  @override
  String get jump => 'پرش';

  @override
  String get openLinkInBrowser => 'بازکردن پیوند در مرورگر';

  @override
  String get reportErrorDescription =>
      'اوه نه. اشتباهی رخ داد. اگر تمایل دارید، می‌توانید این اشکال را با توسعه‌دهندگان گزارش دهید.';

  @override
  String get report => 'گزارش';

  @override
  String get setColorTheme => 'تنظیم پوسته رنگی:';

  @override
  String get invite => 'دعوت';

  @override
  String get inviteGroupChat => '📨 دعوت به چت گروهی';

  @override
  String get invalidInput => 'ورودی نامعتبر!';

  @override
  String wrongPinEntered(int seconds) {
    return 'رمز کوتاه نادرست وارد شد! $seconds ثانیه دیگر دوباره تلاش کنید...';
  }

  @override
  String get pleaseEnterANumber => 'لطفاً عددی بزرگ‌تر از ۰ وارد کنید';

  @override
  String get archiveRoomDescription =>
      'چت به بایگانی خواهد رفت. کاربران دیگر میتوانند ببینند که شما چت را ترک کرده‌اید.';

  @override
  String get roomUpgradeDescription =>
      'چت با نگارش جدید اتاق بازسازی خواهد شد. به همه شرکت‌کنندگان آگاهی‌رسانی میشود که باید به چت جدید بروند. داده‌های بیشتر درباره نگارش‌های اتاق در https://spec.matrix.org/latest/rooms/';

  @override
  String get removeDevicesDescription =>
      'از این دستگاه خارج خواهید شد و دیگر نمیتوانید پیام دریافت کنید.';

  @override
  String get banUserDescription =>
      'کاربر از چت محروم خواهد شد و تا زمانی که محرومیت برداشته نشود، نمیتواند دوباره وارد چت شود.';

  @override
  String get unbanUserDescription =>
      'کاربر در صورت تلاش دوباره میتواند وارد چت شود.';

  @override
  String get kickUserDescription =>
      'کاربر از چت بیرون میشود اما محروم نمیشود. در چت های عمومی، کاربر میتواند هر زمان دوباره بپیوندد.';

  @override
  String get makeAdminDescription =>
      'پس از مدیر کردن این کاربر، ممکن است نتوانید این کار را لغو کنید، زیرا آن‌ها همان دسترسی‌های شما را خواهند داشت.';

  @override
  String get pushNotificationsNotAvailable =>
      'آگاه‌سازهای فشاری در دسترس نیستند';

  @override
  String get learnMore => 'بیشتر بدانید';

  @override
  String get yourGlobalUserIdIs => 'شناسه کاربری سراسری شما: ';

  @override
  String noUsersFoundWithQuery(String query) {
    return 'متأسفانه کاربری با «$query» پیدا نشد. لطفاً بررسی کنید که آیا اشتباه نوشتاری دارید.';
  }

  @override
  String get knocking => 'در زدن';

  @override
  String chatCanBeDiscoveredViaSearchOnServer(String server) {
    return 'چت با جستجو در $server قابل کشف است';
  }

  @override
  String get searchChatsRooms => 'جستجو برای #چت ها، @کاربران...';

  @override
  String get nothingFound => 'چیزی پیدا نشد...';

  @override
  String get groupName => 'نام گروه';

  @override
  String get createGroupAndInviteUsers => 'ساختن گروه و دعوت کاربران';

  @override
  String get groupCanBeFoundViaSearch => 'گروه با جستجو قابل یافتن است';

  @override
  String get wrongRecoveryKey =>
      'متأسفیم... به نظر میرسد این کلید بازیابی درست نباشد.';

  @override
  String get commandHint_sendraw => 'فرستادن json خام';

  @override
  String get databaseMigrationTitle => 'پایگاه داده بهینه‌سازی شد';

  @override
  String get databaseMigrationBody =>
      'لطفاً صبر کنید. این ممکن است لحظه‌ای طول بکشد.';

  @override
  String get leaveEmptyToClearStatus => 'برای پاک کردن وضعیت، خالی بگذارید.';

  @override
  String get select => 'انتخاب';

  @override
  String get searchForUsers => 'جستجو برای @کاربران...';

  @override
  String get pleaseEnterYourCurrentPassword =>
      'لطفاً گذرواژه کنونی خود را وارد کنید';

  @override
  String get newPassword => 'گذرواژه جدید';

  @override
  String get pleaseChooseAStrongPassword => 'لطفاً یک گذرواژه قوی انتخاب کنید';

  @override
  String get passwordsDoNotMatch => 'گذرواژه‌ها هم‌خوانی ندارند';

  @override
  String get passwordIsWrong => 'گذرواژه واردشده نادرست است';

  @override
  String get publicChatAddresses => 'آدرس های چت عمومی';

  @override
  String get createNewAddress => 'ساختن نشانی جدید';

  @override
  String get joinSpace => 'پیوستن به فضا';

  @override
  String get publicSpaces => 'فضاهای عمومی';

  @override
  String get addChatOrSubSpace => 'افزودن چت یا زیرفضا';

  @override
  String get thisDevice => 'این دستگاه:';

  @override
  String get initAppError => 'خطایی هنگام آغاز برنامه رخ داد';

  @override
  String searchIn(String chat) {
    return 'جستجو در چت «$chat»...';
  }

  @override
  String get searchMore => 'جستجوی بیشتر...';

  @override
  String get gallery => 'نگارخانه';

  @override
  String get files => 'پرونده‌ها';

  @override
  String sessionLostBody(String url, String error) {
    return 'نشست شما گم شده است. لطفاً این خطا را به توسعه‌دهندگان در $url گزارش دهید. پیام خطا: $error';
  }

  @override
  String restoreSessionBody(String url, String error) {
    return 'برنامه اکنون سعی میکند نشست شما را از پشتیبان بازیابی کند. لطفاً این خطا را به توسعه‌دهندگان در $url گزارش دهید. پیام خطا: $error';
  }

  @override
  String get sendReadReceipts => 'فرستادن رسیدهای خواندن';

  @override
  String get sendTypingNotificationsDescription =>
      'دیگر شرکت‌کنندگان در چت میتوانند ببینند که شما در حال تایپ پیام جدید هستید.';

  @override
  String get sendReadReceiptsDescription =>
      'دیگر شرکت‌کنندگان در چت میتوانند ببینند که شما پیام را خوانده‌اید.';

  @override
  String get formattedMessages => 'پیام‌های قالب‌بندی‌شده';

  @override
  String get formattedMessagesDescription =>
      'نمایش محتوای پیام غنی مانند متن پررنگ با استفاده از مارک‌داون.';

  @override
  String get verifyOtherUser => '🔐 بازبینی کاربر دیگر';

  @override
  String get verifyOtherUserDescription =>
      'اگر کاربر دیگری را بازبینی کنید، میتوانید مطمئن شوید که واقعاً با چه کسی در حال نوشتن هستید. 💪\n\nهنگام شروع بازبینی، شما و کاربر دیگر پنجره‌ای در برنامه خواهید دید. در آنجا مجموعه‌ای از شکلک‌ها یا اعداد را مشاهده میکنید که باید با یکدیگر مقایسه کنید.\n\nبهترین راه برای این کار دیدار حضوری یا شروع تماس تصویری است. 👭';

  @override
  String get verifyOtherDevice => '🔐 بازبینی دستگاه دیگر';

  @override
  String get verifyOtherDeviceDescription =>
      'هنگام بازبینی دستگاه دیگر، آن دستگاه‌ها میتوانند کلیدها را تبادل کنند و امنیت کلی شما را افزایش دهند. 💪 هنگام شروع بازبینی، پنجره‌ای در برنامه روی هر دو دستگاه ظاهر میشود. در آنجا مجموعه‌ای از شکلک‌ها یا اعداد را مشاهده میکنید که باید با یکدیگر مقایسه کنید. بهتر است پیش از شروع بازبینی، هر دو دستگاه در دسترس باشند. 🤳';

  @override
  String acceptedKeyVerification(String sender) {
    return '$sender بازبینی کلید را پذیرفت';
  }

  @override
  String canceledKeyVerification(String sender) {
    return '$sender بازبینی کلید را رد کرد';
  }

  @override
  String completedKeyVerification(String sender) {
    return '$sender بازبینی کلید را کامل کرد';
  }

  @override
  String isReadyForKeyVerification(String sender) {
    return '$sender برای بازبینی کلید آماده است';
  }

  @override
  String requestedKeyVerification(String sender) {
    return '$sender درخواست بازبینی کلید کرد';
  }

  @override
  String startedKeyVerification(String sender) {
    return '$sender بازبینی کلید را آغاز کرد';
  }

  @override
  String get transparent => 'شفاف';

  @override
  String get incomingMessages => 'پیام‌های دریافتی';

  @override
  String get stickers => 'برچسب‌ها';

  @override
  String get discover => 'کشف';

  @override
  String get commandHint_ignore => 'چشم‌پوشی از شناسه ماتریکس داده‌شده';

  @override
  String get commandHint_unignore => 'لغو چشم‌پوشی از شناسه ماتریکس داده‌شده';

  @override
  String unreadChatsInApp(String appname, String unread) {
    return '$appname: $unread چت خوانده‌نشده';
  }

  @override
  String get noDatabaseEncryption =>
      'رمزنگاری پایگاه داده در این سکو پشتیبانی نمیشود';

  @override
  String thereAreCountUsersBlocked(Object count) {
    return 'اکنون $count کاربر مسدود شده‌اند.';
  }

  @override
  String get restricted => 'محدودشده';

  @override
  String get knockRestricted => 'در زدن محدود';

  @override
  String goToSpace(Object space) {
    return 'رفتن به فضا: $space';
  }

  @override
  String get markAsUnread => 'علامت‌گذاری به‌عنوان خوانده‌نشده';

  @override
  String userLevel(int level) {
    return '$level - کاربر';
  }

  @override
  String moderatorLevel(int level) {
    return '$level - ناظر';
  }

  @override
  String adminLevel(int level) {
    return '$level - مدیر';
  }

  @override
  String get changeGeneralChatSettings => 'تغییر تنظیمات عمومی چت';

  @override
  String get inviteOtherUsers => 'دعوت کاربران دیگر به این چت';

  @override
  String get changeTheChatPermissions => 'تغییر دسترسی‌های چت';

  @override
  String get changeTheVisibilityOfChatHistory => 'تغییر قابلیت دید تاریخچه چت';

  @override
  String get changeTheCanonicalRoomAlias => 'تغییر نشانی اصلی چت عمومی';

  @override
  String get sendRoomNotifications => 'فرستادن آگاه‌سازهای @room';

  @override
  String get changeTheDescriptionOfTheGroup => 'تغییر توضیح چت';

  @override
  String get chatPermissionsDescription =>
      'مشخص کنید کدام سطح دسترسی برای اقدامات خاصی در این چت لازم است. سطح‌های دسترسی ۰، ۵۰ و ۱۰۰ معمولاً نشان‌دهنده کاربران، ناظران و مدیران هستند، اما هر درجه‌بندی ممکن است.';

  @override
  String updateInstalled(String version) {
    return '🎉 به‌روزرسانی $version نصب شد!';
  }

  @override
  String get changelog => 'فهرست تغییرات';

  @override
  String get sendCanceled => 'فرستادن رد شد';

  @override
  String get loginWithMatrixId => 'ورود با شناسه ماتریکس';

  @override
  String get doesNotSeemToBeAValidHomeserver =>
      'به نظر نمیرسد سرور خانگی سازگاری داشته باشد. نشانی اشتباه است؟';

  @override
  String get calculatingFileSize => 'در حال محاسبه اندازه پرونده...';

  @override
  String get prepareSendingAttachment => 'آماده‌سازی برای فرستادن پیوست...';

  @override
  String get sendingAttachment => 'در حال فرستادن پیوست...';

  @override
  String get generatingVideoThumbnail => 'در حال تولید تصویر کوچک ویدئو...';

  @override
  String get compressVideo => 'در حال فشرده‌سازی ویدئو...';

  @override
  String sendingAttachmentCountOfCount(int index, int length) {
    return 'در حال فرستادن پیوست $index از $length...';
  }

  @override
  String serverLimitReached(int seconds) {
    return 'محدودیت سرور رسیده است! $seconds ثانیه صبر کنید...';
  }

  @override
  String get oneOfYourDevicesIsNotVerified =>
      'یکی از دستگاه‌های شما بازبینی نشده است';

  @override
  String get noticeChatBackupDeviceVerification =>
      'توجه: وقتی همه دستگاه‌های خود را به پشتیبان چت متصل کنید، به‌صورت خودکار بازبینی میشوند.';

  @override
  String get continueText => 'ادامه';

  @override
  String get welcomeText =>
      'درود درود 👋 این فلافی‌چت است. میتوانید به هر سرور خانگی سازگار با https://matrix.org وارد شوید و با هر کسی چت کنید. این یک شبکه پیام‌رسانی غیرمتمرکز بزرگ است!';

  @override
  String get blur => 'محو کردن:';

  @override
  String get opacity => 'شفافیت:';

  @override
  String get setWallpaper => 'تنظیم کاغذدیواری';

  @override
  String get manageAccount => 'مدیریت حساب';

  @override
  String get noContactInformationProvided =>
      'سرور هیچ اطلاعات تماس معتبری نمیدهد';

  @override
  String get contactServerAdmin => 'تماس با مدیر سرور';

  @override
  String get contactServerSecurity => 'تماس با امنیت سرور';

  @override
  String get supportPage => 'صفحه پشتیبانی';

  @override
  String get serverInformation => 'درباره سرور:';

  @override
  String get name => 'نام';

  @override
  String get version => 'نگارش';

  @override
  String get website => 'وبگاه';

  @override
  String get compress => 'فشرده‌سازی';

  @override
  String get boldText => 'متن درشت';

  @override
  String get italicText => 'متن کج';

  @override
  String get strikeThrough => 'خط‌خورده';

  @override
  String get pleaseFillOut => 'لطفاً پر کنید';

  @override
  String get invalidUrl => 'نشانی نامعتبر';

  @override
  String get addLink => 'افزودن پیوند';

  @override
  String get unableToJoinChat =>
      'ناتوانی در پیوستن به چت. شاید طرف مقابل گفتگو را بسته است.';

  @override
  String get previous => 'پیشین';

  @override
  String get otherPartyNotLoggedIn =>
      'طرف مقابل اکنون وارد نشده است و بنابراین نمیتواند پیام دریافت کند!';

  @override
  String appWantsToUseForLogin(String server) {
    return 'برای ورود از \'$server\' استفاده کنید';
  }

  @override
  String get appWantsToUseForLoginDescription =>
      'شما بدین‌وسیله به برنامه و وبگاه اجازه میدهید اطلاعات شما را هم‌رسانی کنند.';

  @override
  String get open => 'باز کردن';

  @override
  String get waitingForServer => 'در انتظار سرور...';

  @override
  String get newChatRequest => '📩 درخواست چت جدید';

  @override
  String get contentNotificationSettings => 'تنظیمات آگاه‌ساز محتوا';

  @override
  String get generalNotificationSettings => 'تنظیمات آگاه‌ساز عمومی';

  @override
  String get roomNotificationSettings => 'تنظیمات آگاه‌ساز اتاق';

  @override
  String get userSpecificNotificationSettings => 'تنظیمات آگاه‌ساز خاص کاربر';

  @override
  String get otherNotificationSettings => 'سایر تنظیمات آگاه‌ساز';

  @override
  String get notificationRuleContainsUserName => 'دارای نام کاربری';

  @override
  String get notificationRuleContainsUserNameDescription =>
      'وقتی پیامی حاوی نام کاربری باشد، کاربر را آگاه میکند.';

  @override
  String get notificationRuleMaster => 'بی‌صدا کردن همه آگاه‌سازها';

  @override
  String get notificationRuleMasterDescription =>
      'از قوانین دیگر چشم‌پوشی میکند و همه آگاه‌سازها را غیرفعال میکند.';

  @override
  String get notificationRuleSuppressNotices => 'سرکوب پیام‌های خودکار';

  @override
  String get notificationRuleSuppressNoticesDescription =>
      'آگاه‌سازهای کارخواه‌های خودکار مانند ربات‌ها را سرکوب میکند.';

  @override
  String get notificationRuleInviteForMe => 'دعوت برای من';

  @override
  String get notificationRuleInviteForMeDescription =>
      'وقتی کاربر به اتاقی دعوت میشود، او را آگاه میکند.';

  @override
  String get notificationRuleMemberEvent => 'رویداد عضویت';

  @override
  String get notificationRuleMemberEventDescription =>
      'آگاه‌سازهای رویدادهای عضویت را سرکوب میکند.';

  @override
  String get notificationRuleIsUserMention => 'نام‌بردن از کاربر';

  @override
  String get notificationRuleIsUserMentionDescription =>
      'وقتی در پیامی مستقیماً از کاربر نام برده میشود، او را آگاه میکند.';

  @override
  String get notificationRuleContainsDisplayName => 'دارای نام نمایشی';

  @override
  String get notificationRuleContainsDisplayNameDescription =>
      'وقتی پیامی حاوی نام نمایشی کاربر باشد، کاربر را آگاه میکند.';

  @override
  String get notificationRuleIsRoomMention => 'نام‌بردن از اتاق';

  @override
  String get notificationRuleIsRoomMentionDescription =>
      'وقتی نام اتاق ذکر میشود، کاربر را آگاه میکند.';

  @override
  String get notificationRuleRoomnotif => 'آگاه‌ساز اتاق';

  @override
  String get notificationRuleRoomnotifDescription =>
      'وقتی پیامی حاوی \'@room\' باشد، کاربر را آگاه میکند.';

  @override
  String get notificationRuleTombstone => 'سنگ قبر';

  @override
  String get notificationRuleTombstoneDescription =>
      'کاربر را از پیام‌های غیرفعال‌سازی اتاق آگاه میکند.';

  @override
  String get notificationRuleReaction => 'واکنش';

  @override
  String get notificationRuleReactionDescription =>
      'آگاه‌سازهای واکنش‌ها را سرکوب میکند.';

  @override
  String get notificationRuleRoomServerAcl => 'ACL سرور اتاق';

  @override
  String get notificationRuleRoomServerAclDescription =>
      'آگاه‌سازهای فهرست‌های کنترل دسترسی سرور اتاق (ACL) را سرکوب میکند.';

  @override
  String get notificationRuleSuppressEdits => 'سرکوب ویرایش‌ها';

  @override
  String get notificationRuleSuppressEditsDescription =>
      'آگاه‌سازهای پیام‌های ویرایش‌شده را سرکوب میکند.';

  @override
  String get notificationRuleCall => 'تماس';

  @override
  String get notificationRuleCallDescription =>
      'درباره تماس‌ها کاربر را آگاه میکند.';

  @override
  String get notificationRuleEncryptedRoomOneToOne =>
      'اتاق رمزنگاری‌شده یک‌به‌یک';

  @override
  String get notificationRuleEncryptedRoomOneToOneDescription =>
      'کاربر را از پیام‌ها در اتاق‌های رمزنگاری‌شده یک‌به‌یک آگاه میکند.';

  @override
  String get notificationRuleRoomOneToOne => 'اتاق یک‌به‌یک';

  @override
  String get notificationRuleRoomOneToOneDescription =>
      'کاربر را از پیام‌ها در اتاق‌های یک‌به‌یک آگاه میکند.';

  @override
  String get notificationRuleMessage => 'پیام';

  @override
  String get notificationRuleMessageDescription =>
      'کاربر را از پیام‌های عمومی آگاه میکند.';

  @override
  String get notificationRuleEncrypted => 'رمزنگاری‌شده';

  @override
  String get notificationRuleEncryptedDescription =>
      'کاربر را از پیام‌ها در اتاق‌های رمزنگاری‌شده آگاه میکند.';

  @override
  String get notificationRuleJitsi => 'جیتسی';

  @override
  String get notificationRuleJitsiDescription =>
      'کاربر را از رویدادهای ابزارک جیتسی آگاه میکند.';

  @override
  String get notificationRuleServerAcl => 'سرکوب رویدادهای ACL سرور';

  @override
  String get notificationRuleServerAclDescription =>
      'آگاه‌سازهای رویدادهای ACL سرور را سرکوب میکند.';

  @override
  String unknownPushRule(String rule) {
    return 'قانون ناشناخته آگاه‌ساز \'$rule\'';
  }

  @override
  String sentVoiceMessage(String sender, String duration) {
    return '🎙️ $duration - پیام صوتی از $sender';
  }

  @override
  String get deletePushRuleCanNotBeUndone =>
      'اگر این تنظیم آگاه‌ساز را پاک کنید، این کار برگشت‌ناپذیر است.';

  @override
  String get more => 'بیشتر';

  @override
  String get shareKeysWith => 'هم‌رسانی کلیدها با...';

  @override
  String get shareKeysWithDescription =>
      'کدام دستگاه‌ها باید مورد اعتماد باشند تا بتوانند پیام‌های شما را در چت های رمزنگاری‌شده بخوانند؟';

  @override
  String get allDevices => 'همه دستگاه‌ها';

  @override
  String get crossVerifiedDevicesIfEnabled =>
      'دستگاه‌های بازبینی‌شده متقابل اگر فعال باشد';

  @override
  String get crossVerifiedDevices => 'دستگاه‌های بازبینی‌شده متقابل';

  @override
  String get verifiedDevicesOnly => 'فقط دستگاه‌های بازبینی‌شده';

  @override
  String get takeAPhoto => 'گرفتن عکس';

  @override
  String get recordAVideo => 'ضبط ویدئو';

  @override
  String get optionalMessage => '(اختیاری) پیام...';

  @override
  String get notSupportedOnThisDevice => 'در این دستگاه پشتیبانی نمیشود';

  @override
  String get enterNewChat => 'ورود به چت جدید';

  @override
  String get approve => 'پذیرفتن';

  @override
  String get youHaveKnocked => 'شما در زده‌اید';

  @override
  String get pleaseWaitUntilInvited =>
      'لطفاً اکنون صبر کنید تا کسی از اتاق شما را دعوت کند.';

  @override
  String get commandHint_logout => 'خروج از دستگاه کنونی';

  @override
  String get commandHint_logoutall => 'خروج از همه دستگاه‌های فعال';

  @override
  String get displayNavigationRail => 'نمایش نوار ناوبری در تلفن همراه';

  @override
  String get customReaction => 'واکنش سفارشی';

  @override
  String get moreEvents => 'رویدادهای بیشتر';

  @override
  String get declineInvitation => 'رد کردن دعوت';

  @override
  String get noMessagesYet => 'پیامی وجود ندارد';

  @override
  String get longPressToRecordVoiceMessage =>
      'برای ضبط پیام صوتی، انگشت خود را نگه دارید.';

  @override
  String get pause => 'توقف';

  @override
  String get resume => 'ادامه';

  @override
  String get removeFromSpaceDescription =>
      'این چت از این فضا حذف خواهد شد اما همچنان در لیست چت های شما نمایش داده میشود.';

  @override
  String countChats(int chats) {
    return '$chats چت';
  }

  @override
  String spaceMemberOf(String spaces) {
    return 'عضو فضای $spaces';
  }

  @override
  String spaceMemberOfCanKnock(String spaces) {
    return 'عضو فضای $spaces میتواند در بزند';
  }

  @override
  String startedAPoll(String username) {
    return '$username یک نظرسنجی را آغاز کرد.';
  }

  @override
  String get poll => 'نظرسنجی';

  @override
  String get startPoll => 'آغاز نظرسنجی';

  @override
  String get endPoll => 'پایان نظرسنجی';

  @override
  String get answersVisible => 'پاسخ ها قابل رویت';

  @override
  String get pollQuestion => 'سوال نظرسنجی';

  @override
  String get answerOption => 'گزینه جواب';

  @override
  String get addAnswerOption => 'اضافه کردن گزینه جواب';

  @override
  String get allowMultipleAnswers => 'اجازه دادن چند جواب';

  @override
  String get pollHasBeenEnded => 'این نظرسنجی پایان یافته است';

  @override
  String countVotes(int count) {
    return '$count رای دیگر';
  }

  @override
  String get answersWillBeVisibleWhenPollHasEnded =>
      'پاسخ ها وقتی نظرسنجی به پایان برسد نمایش داده خواهند شد';

  @override
  String get replyInThread => 'پاسخ در رشته';

  @override
  String countReplies(int count) {
    return '$count پاسخ دیگر';
  }

  @override
  String get thread => 'رشته';

  @override
  String get backToMainChat => 'بازگشت به چت اصلی';

  @override
  String get saveChanges => 'ذخیره تغییرات';

  @override
  String get createSticker => 'ساخت استیکر یا ایموجی';

  @override
  String get useAsSticker => 'استفاده به عنوان استیکر';

  @override
  String get useAsEmoji => 'استفاده به عنوان ایموجی';

  @override
  String get stickerPackNameAlreadyExists => 'نام استیکرپک تکراری است';

  @override
  String get newStickerPack => 'استیکر پک جدید';

  @override
  String get stickerPackName => 'نام استیکر پک';

  @override
  String get attribution => 'نسبت دادن';

  @override
  String get skipChatBackup => 'صرف نظر از پشتیبان گیری چت';

  @override
  String get skipChatBackupWarning =>
      'آیا مطمئنید؟ بدون فعال کردن پشتیبان گیری چت ممکن است در صورت تغییر دستگاه دسترسی خود به پیام هایتان را از دست بدهید.';

  @override
  String get loadingMessages => 'در حال بارگذاری پیام ها';

  @override
  String get setupChatBackup => 'فعالسازی پشتیبان گیری چت';

  @override
  String get noMoreResultsFound => 'نتایج دیگری یافت نشد';

  @override
  String chatSearchedUntil(String time) {
    return 'چت تا $time جستجو شد';
  }

  @override
  String get federationBaseUrl => 'پایه آدرس فدریشن';

  @override
  String get clientWellKnownInformation => 'اطلاعات Client-Well-Known:';

  @override
  String get baseUrl => 'پایه آدرس';

  @override
  String get identityServer => 'سرور احراز هویت:';

  @override
  String versionWithNumber(String version) {
    return 'ورژن: $version';
  }

  @override
  String get logs => 'لاگ ها';

  @override
  String get advancedConfigs => 'تنظیمات پیشرفته';

  @override
  String get advancedConfigurations => 'تنظیمات پیشرفته';

  @override
  String get signIn => 'ورود';

  @override
  String get createNewAccount => 'ساخت حساب جدید';

  @override
  String get signUpGreeting =>
      'فلافی چت غیرمتمرکز است! یک سرور که میخواهید در آن حسابتان را بسازید را انتخاب کنید و شروع کنید!';

  @override
  String get signInGreeting =>
      'از قبل در ماتریکس حساب کاربری دارید؟ خوش برگشتید! سرور خانه خود را انتخاب و لاگین کنید.';

  @override
  String get appIntro =>
      'فلافی چت یک پیامرسان امن غیرمتمرکز ماتریکس است که با آن میتوانید با دوستانتان چت کنید! برای اطلاعات بیشتر میتوانید به https://matrix.org مراجعه کنید یا اینکه صرفا ثبت نام کنید.';

  @override
  String get theProcessWasCanceled => 'فرآیند لغو شد.';

  @override
  String get join => 'عضویت';

  @override
  String get searchOrEnterHomeserverAddress =>
      'جستجو یا وارد کردن آدرس سرور خانه';

  @override
  String get matrixId => 'شناسه ماتریکس';

  @override
  String get setPowerLevel => 'انتخاب سطح قدرت';

  @override
  String get makeModerator => 'انتخاب به عنوان ناظر';

  @override
  String get makeAdmin => 'انتخاب به عنوان مدیر';

  @override
  String get removeModeratorRights => 'حذف دسترسی های نظارتی';

  @override
  String get removeAdminRights => 'حذف دسترسی های مدیریتی';

  @override
  String get powerLevel => 'سطح قدرت';

  @override
  String get setPowerLevelDescription =>
      'سطح قدرت مشخص میکند که یک کاربر قادر به انجام چه کارهایی در این اتاق است. معمولا یک عدد بین ۰ تا ۱۰۰ می باشد.';

  @override
  String get owner => 'صاحب';

  @override
  String get mute => 'ساکت';

  @override
  String get createNewChat => 'ساخت چت جدید';

  @override
  String get reset => 'ریست کردن';

  @override
  String get supportFluffyChat => 'حمایت از فلافی چت';

  @override
  String get support => 'پشتیبانی';

  @override
  String get fluffyChatSupportBannerMessage =>
      'فلافی چت به کمک شما نیاز دارد!\n❤️❤️❤️\nفلافی چت همواره رایگان خواهد بود، اما توسعه و نگهداری از آن هزینه بر است.\nآینده این پروژه در گرو حمایت افرادی مثل شماست.';

  @override
  String get skipSupportingFluffyChat => 'رد کردن حمایت از فلافی چت';

  @override
  String get iDoNotWantToSupport => 'نمیخواهم حمایت کنم';

  @override
  String get iAlreadySupportFluffyChat => 'از قبل از فلافی چت حمایت میکنم';

  @override
  String get setLowPriority => 'تنظیم اولویت پایین';

  @override
  String get unsetLowPriority => 'لغو تنظیم اولویت پایین';

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
