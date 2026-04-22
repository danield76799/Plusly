// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class L10nJa extends L10n {
  L10nJa([String locale = 'ja']) : super(locale);

  @override
  String get alwaysUse24HourFormat => 'false';

  @override
  String get repeatPassword => 'パスワードを繰り返そ';

  @override
  String get notAnImage => '画像ファイルではありません。';

  @override
  String get ignoreUser => 'ユーザーを無視する';

  @override
  String get remove => '消去';

  @override
  String get importNow => '今すぐインポート';

  @override
  String get importEmojis => '絵文字をインポート';

  @override
  String get importFromZipFile => '.zipファイルからインポート';

  @override
  String get exportEmotePack => 'エモートパックを.zipでエクスポート';

  @override
  String get replace => '置き換え';

  @override
  String get about => 'このアプリについて';

  @override
  String aboutHomeserver(String homeserver) {
    return '$homeserver について';
  }

  @override
  String get accept => '承諾する';

  @override
  String acceptedTheInvitation(String username) {
    return '👍$usernameが招待を承諾しました';
  }

  @override
  String get account => 'アカウント';

  @override
  String activatedEndToEndEncryption(String username) {
    return '🔐$usernameがエンドツーエンド暗号化を有効にしました';
  }

  @override
  String get addEmail => 'Eメールを追加';

  @override
  String get confirmMatrixId => 'アカウントを削除するには、Matrix IDを確認してください。';

  @override
  String supposedMxid(String mxid) {
    return 'This should be $mxid';
  }

  @override
  String get addToSpace => 'スペースに追加';

  @override
  String get admin => '管理者';

  @override
  String get alias => 'エイリアス';

  @override
  String get all => 'すべて';

  @override
  String get allChats => 'すべて会話';

  @override
  String get commandHint_roomupgrade => 'このルームを特定のルームバージョンにアップグレード';

  @override
  String get commandHint_googly => 'ぎょろ目を送る';

  @override
  String get commandHint_cuddle => '笑顔を送る';

  @override
  String get commandHint_hug => 'ハグを送る';

  @override
  String googlyEyesContent(String senderName) {
    return '$senderNameがギョロ目を送りました';
  }

  @override
  String cuddleContent(String senderName) {
    return '$senderNameが笑顔を送りました';
  }

  @override
  String hugContent(String senderName) {
    return '$senderNameがハグしました';
  }

  @override
  String answeredTheCall(String senderName) {
    return '$senderNameは通話に出ました';
  }

  @override
  String get anyoneCanJoin => '誰でも参加できる';

  @override
  String get appLock => 'アプリのロック';

  @override
  String get appLockDescription => '未使用時にアプリをPINコードでロック';

  @override
  String get archive => 'アーカイブ';

  @override
  String get areGuestsAllowedToJoin => 'ゲストユーザーの参加を許可する';

  @override
  String get areYouSure => 'これでよろしいですか？';

  @override
  String get areYouSureYouWantToLogout => 'ログアウトしてよろしいですか？';

  @override
  String get askSSSSSign => '他の人を署名するためにはパスフレーズやリカバリーキーを入力してください。';

  @override
  String askVerificationRequest(String username) {
    return '$usernameの検証リクエストを承認しますか？';
  }

  @override
  String get autoplayImages => 'GIFを自動的に再生する';

  @override
  String badServerLoginTypesException(
    String serverVersions,
    String supportedVersions,
    Object suportedVersions,
  ) {
    return 'ホームサーバーでサポートされているログインタイプ：\n$serverVersions\nアプリがサポートしているログインタイプ：\n$supportedVersions';
  }

  @override
  String get sendTypingNotifications => '入力通知を送信';

  @override
  String get swipeRightToLeftToReply => '左にスワイプして返信';

  @override
  String get sendOnEnter => 'Enterで送信';

  @override
  String get noMoreChatsFound => 'これ以上のチャットが見つかりません…';

  @override
  String get noChatsFoundHere =>
      'ここにはまだチャットがありません。下のボタンを使ってみんなと新しいチャットを始めましょう。⤵️';

  @override
  String get unread => '未読';

  @override
  String get space => 'スペース';

  @override
  String get spaces => 'スペース';

  @override
  String get banFromChat => 'チャットからBANする';

  @override
  String get banned => 'BANされています';

  @override
  String bannedUser(String username, String targetName) {
    return '$usernameが$targetNameをBANしました';
  }

  @override
  String get blockDevice => 'デバイスをブロックする';

  @override
  String get blocked => 'ブロックしました';

  @override
  String get cancel => 'キャンセル';

  @override
  String cantOpenUri(String uri) {
    return 'URIが開けません $uri';
  }

  @override
  String get changeDeviceName => 'デバイス名を変更';

  @override
  String changedTheChatAvatar(String username) {
    return '$usernameがチャットアバターを変更しました';
  }

  @override
  String changedTheChatDescription(Object username) {
    return '$usernameがチャットの説明を変更した';
  }

  @override
  String changedTheChatDescriptionTo(String username, String description) {
    return '$usernameがチャットの説明を「$description」に変更した';
  }

  @override
  String changedTheChatName(Object username) {
    return '$usernameがチャットの名前を変更した';
  }

  @override
  String changedTheChatNameTo(String username, String chatname) {
    return '$usernameがチャットの名前を「$chatname」に変更した';
  }

  @override
  String changedTheChatPermissions(String username) {
    return '$usernameがチャットの権限を変更しました';
  }

  @override
  String changedTheDisplaynameTo(String username, String displayname) {
    return '$usernameが表示名を「$displayname」に変更した';
  }

  @override
  String changedTheGuestAccessRules(String username) {
    return '$usernameがゲストのアクセスルールを変更しました';
  }

  @override
  String changedTheGuestAccessRulesTo(String username, String rules) {
    return '$usernameがゲストのアクセスルールを$rulesに変更しました';
  }

  @override
  String changedTheHistoryVisibility(String username) {
    return '$usernameが履歴の表示設定を変更しました';
  }

  @override
  String changedTheHistoryVisibilityTo(String username, String rules) {
    return '$usernameが履歴の表示設定を$rulesに変更しました';
  }

  @override
  String changedTheJoinRules(String username) {
    return '$usernameが参加ルールを変更しました';
  }

  @override
  String changedTheJoinRulesTo(String username, String joinRules) {
    return '$usernameが参加ルールを$joinRulesに変更しました';
  }

  @override
  String changedTheProfileAvatar(String username) {
    return '$usernameがアバターを変更しました';
  }

  @override
  String changedTheRoomAliases(String username) {
    return '$usernameが部屋のエイリアスを変更しました';
  }

  @override
  String changedTheRoomInvitationLink(String username) {
    return '$usernameが招待リンクを変更しました';
  }

  @override
  String get changePassword => 'パスワードを変更';

  @override
  String get changeTheHomeserver => 'ホームサーバーの変更';

  @override
  String get changeTheme => 'スタイルを変更する';

  @override
  String get changeTheNameOfTheGroup => 'グループの名前を変更する';

  @override
  String get changeYourAvatar => 'アバタるを変化しする';

  @override
  String get channelCorruptedDecryptError => '暗号が破損しています';

  @override
  String get chat => 'チャット';

  @override
  String get yourChatBackupHasBeenSetUp => 'チャットバックアップを設定ました。';

  @override
  String get chatBackup => 'チャットのバックアップ';

  @override
  String get chatBackupDescription => '古いメッセージはリカバリーキーで保護されます。紛失しないようにご注意ください。';

  @override
  String get chatDetails => 'チャットの詳細';

  @override
  String get chats => 'チャット';

  @override
  String get chooseAStrongPassword => '強いパスワードを選択してください';

  @override
  String get clearArchive => 'アーカイブを消去';

  @override
  String get close => '閉じる';

  @override
  String get commandHint_markasdm => 'ダイレクトメッセージの部屋としてマークする';

  @override
  String get commandHint_markasgroup => 'グループとしてマーク';

  @override
  String get commandHint_ban => 'このユーザーを禁止する';

  @override
  String get commandHint_clearcache => 'キャッシュをクリアする';

  @override
  String get commandHint_create =>
      '空のグループチャットを作成\n暗号化を無効にするには、--no-encryption を使用';

  @override
  String get commandHint_discardsession => 'セッションを破棄';

  @override
  String get commandHint_dm =>
      'ダイレクトチャットを開始する\n暗号化を無効にするには、--no-encryptionを使用してください';

  @override
  String get commandHint_html => 'HTML形式のテキストを送信';

  @override
  String get commandHint_invite => '指定したユーザーをこの部屋に招待';

  @override
  String get commandHint_join => '指定した部屋に参加';

  @override
  String get commandHint_kick => '入力のユーザーをこの部屋からキックする';

  @override
  String get commandHint_leave => 'この部屋を退出';

  @override
  String get commandHint_me => 'Describe yourself';

  @override
  String get commandHint_myroomavatar => 'この部屋の写真を設定する (mxc-uriで)';

  @override
  String get commandHint_myroomnick => 'この部屋の表示名を設定する';

  @override
  String get commandHint_op => 'ユーザーの権限レベルを付与する（デフォルト：50）';

  @override
  String get commandHint_plain => '書式設定されていないテキストを送信する';

  @override
  String get commandHint_react => 'リアクションとして返信を送信する';

  @override
  String get commandHint_send => 'テキストを送信';

  @override
  String get commandHint_unban => 'このルームから禁止されたユーザーを解禁する';

  @override
  String get commandInvalid => 'コマンドが無効';

  @override
  String commandMissing(String command) {
    return '$command はコマンドではありません。';
  }

  @override
  String get compareEmojiMatch => '表示されている絵文字が他のデバイスで表示されているものと一致するか確認してください:';

  @override
  String get compareNumbersMatch => '表示されている数字が他のデバイスで表示されているものと一致するか確認してください:';

  @override
  String get configureChat => 'チャットの設定';

  @override
  String get contactHasBeenInvitedToTheGroup => '連絡先に登録された人が招待されました';

  @override
  String get contentHasBeenReported => 'サーバー管理者に通報されました';

  @override
  String get copiedToClipboard => 'クリップボードにコピーされました';

  @override
  String get copy => 'コピー';

  @override
  String get copyToClipboard => 'クリップボードにコピー';

  @override
  String couldNotDecryptMessage(String error) {
    return 'メッセージを解読できませんでした: $error';
  }

  @override
  String get checkList => 'チェックリスト';

  @override
  String countParticipants(int count) {
    return '$count名の参加者';
  }

  @override
  String countInvited(int count) {
    return '$count人を招待済み';
  }

  @override
  String get create => '作成';

  @override
  String createdTheChat(String username) {
    return '💬 $usernameがチャットを作成しました';
  }

  @override
  String get createGroup => 'グループを作成する';

  @override
  String get createNewSpace => '新しいスペース';

  @override
  String get currentlyActive => '現在アクティブです';

  @override
  String get darkTheme => 'ダーク';

  @override
  String dateAndTimeOfDay(String date, String timeOfDay) {
    return '$date, $timeOfDay';
  }

  @override
  String get deactivateAccountWarning =>
      'あなたのアカウントを無効化します。この操作は元に戻せません！よろしいですか？';

  @override
  String get defaultPermissionLevel => 'デフォルトの権限レベル';

  @override
  String get delete => '削除';

  @override
  String get deleteAccount => 'アカウントの削除';

  @override
  String get deleteMessage => 'メッセージの削除';

  @override
  String get device => 'デバイス';

  @override
  String get deviceId => 'デバイスID';

  @override
  String get devices => 'デバイス';

  @override
  String get directChats => 'ダイレクトチャット';

  @override
  String get displaynameHasBeenChanged => '表示名が変更されました';

  @override
  String get downloadFile => 'ファイルのダウンロード';

  @override
  String get edit => '編集';

  @override
  String get editBlockedServers => 'ブロックしたサーバーを編集';

  @override
  String get chatPermissions => 'チャット権限';

  @override
  String get editDisplayname => '表示名を編集';

  @override
  String get editRoomAliases => 'ルームエイリアスを編集';

  @override
  String get editRoomAvatar => '部屋のアバターを編集する';

  @override
  String get emoteExists => 'Emoteはすでに存在します！';

  @override
  String get emoteInvalid => '不正なEmoteショートコード！';

  @override
  String get emoteKeyboardNoRecents => '最近使われた絵文字がここに表示されます…';

  @override
  String get emotePacks => '部屋のEmoteパック';

  @override
  String get emoteSettings => 'Emote設定';

  @override
  String get globalChatId => 'グローバルチャットID';

  @override
  String get accessAndVisibility => 'アクセスと範囲';

  @override
  String get accessAndVisibilityDescription =>
      '誰がこのチャットに参加できて、どのように発見することができるか。';

  @override
  String get calls => '通話';

  @override
  String get customEmojisAndStickers => 'カスタム絵文字とステッカー';

  @override
  String get customEmojisAndStickersBody =>
      'どのチャットでも利用可能なカスタム絵文字やステッカーを追加・共有します。';

  @override
  String get emoteShortcode => 'Emoteショートコード';

  @override
  String get emptyChat => '空のチャット';

  @override
  String get enableEmotesGlobally => 'emoteをグローバルに有効にする';

  @override
  String get enableEncryption => '暗号化を有効にする';

  @override
  String get enableEncryptionWarning => '一度暗号化を有効にするともとに戻せません。よろしいですか？';

  @override
  String get encrypted => '暗号化';

  @override
  String get encryption => '暗号化';

  @override
  String get encryptionNotEnabled => '暗号化されていません';

  @override
  String endedTheCall(String senderName) {
    return '$senderNameは通話を切断しました';
  }

  @override
  String get enterAnEmailAddress => 'メールアドレスを入力してください';

  @override
  String get homeserver => 'ホームサーバー';

  @override
  String errorObtainingLocation(String error) {
    return '位置情報の取得中にエラーが発生しました: $error';
  }

  @override
  String get everythingReady => 'すべての準備は完了しました！';

  @override
  String get extremeOffensive => 'とても攻撃的';

  @override
  String get fileName => 'ファイル名';

  @override
  String get fluffychat => 'FluffyChat';

  @override
  String get fontSize => 'フォントサイズ';

  @override
  String get forward => '進む';

  @override
  String get fromJoining => '参加時点から閲覧可能';

  @override
  String get fromTheInvitation => '招待時点から閲覧可能';

  @override
  String get group => 'グループ';

  @override
  String get chatDescription => 'チャットの説明';

  @override
  String get chatDescriptionHasBeenChanged => 'チャットの説明が変更された';

  @override
  String get groupIsPublic => 'グループは公開されています';

  @override
  String get groups => 'グループ';

  @override
  String groupWith(String displayname) {
    return '$displaynameとグループを作成する';
  }

  @override
  String get guestsAreForbidden => 'ゲストは許可されていません';

  @override
  String get guestsCanJoin => 'ゲストが許可されています';

  @override
  String hasWithdrawnTheInvitationFor(String username, String targetName) {
    return '$targetNameの招待を$usernameが取り下げました';
  }

  @override
  String get help => 'ヘルプ';

  @override
  String get hideRedactedEvents => '編集済みイベントを非表示にする';

  @override
  String get hideRedactedMessages => '削除されたメッセージを隠す';

  @override
  String get hideRedactedMessagesBody =>
      '誰かがメッセージを削除した場合、このメッセージはそれ以降チャット内では見えなくなります。';

  @override
  String get hideInvalidOrUnknownMessageFormats => '無効であるか不明なメッセージ形式を隠す';

  @override
  String get howOffensiveIsThisContent => 'どのくらい攻撃的でしたか？';

  @override
  String get id => 'ID';

  @override
  String get block => 'ブロック';

  @override
  String get blockedUsers => 'ブロック済みのユーザー';

  @override
  String get blockListDescription =>
      '迷惑なユーザーをブロックすることができます。あなたの個人的なブロックリストに記載されたユーザーは、あらゆるメッセージやルームへの招待を受け取ることができません。';

  @override
  String get blockUsername => 'ユーザー名を無視する';

  @override
  String get iHaveClickedOnLink => 'リンクをクリックしました';

  @override
  String get incorrectPassphraseOrKey => 'パスフレーズかリカバリーキーが間違っています';

  @override
  String get inoffensive => '非攻撃的';

  @override
  String get inviteContact => '連絡先から招待する';

  @override
  String inviteContactToGroup(String groupName) {
    return '連絡先から$groupNameに招待する';
  }

  @override
  String get noChatDescriptionYet => 'チャットの説明はまだ作成されていません。';

  @override
  String get tryAgain => '再試行';

  @override
  String get invalidServerName => '無効なサーバー名';

  @override
  String get invited => '招待されました';

  @override
  String get redactMessageDescription =>
      'メッセージはこの会話のすべての参加者から削除されます。これは取り消すことができません。';

  @override
  String get optionalRedactReason => '（オプション）メッセージを削除する理由…';

  @override
  String invitedUser(String username, String targetName) {
    return '📩 $username が $targetName を招待しました';
  }

  @override
  String get invitedUsersOnly => '招待されたユーザーのみ';

  @override
  String inviteText(String username, String link) {
    return '$usernameがあなたをFluffyChatに招待しました。\n1. FluffyChatをインストール:　fluffychat.im \n2. アカウントの作成、またはサインインを行う\n3. 招待リンクを開く\n $link';
  }

  @override
  String get isTyping => 'が入力しています…';

  @override
  String joinedTheChat(String username) {
    return '👋 $username がチャットに参加しました';
  }

  @override
  String get joinRoom => '部屋に参加';

  @override
  String kicked(String username, String targetName) {
    return '👞 $username は $targetName をキックしました';
  }

  @override
  String kickedAndBanned(String username, String targetName) {
    return '🙅 $username が $targetName をキックしブロックしました';
  }

  @override
  String get kickFromChat => 'チャットからキックする';

  @override
  String lastActiveAgo(String localizedTimeShort) {
    return '最終アクティブ: $localizedTimeShort';
  }

  @override
  String get leave => '退室する';

  @override
  String get leftTheChat => '退室しました';

  @override
  String get lightTheme => 'ライト';

  @override
  String loadCountMoreParticipants(int count) {
    return 'あと$count名参加者を読み込む';
  }

  @override
  String get dehydrate => 'セッションのエクスポートとデバイスの消去';

  @override
  String get dehydrateWarning => 'この操作は元に戻せません。バックアップファイルを安全に保存してください。';

  @override
  String get hydrate => 'バックアップファイルから復元';

  @override
  String get loadingPleaseWait => '読み込み中…お待ちください。';

  @override
  String get loadMore => '更に読み込む…';

  @override
  String get locationDisabledNotice =>
      '位置情報サービスが無効になっています。位置情報を共有できるようにするには、位置情報サービスを有効にしてください。';

  @override
  String get locationPermissionDeniedNotice =>
      '位置情報の権限が拒否されました。位置情報を共有できるように許可してください。';

  @override
  String get login => 'ログイン';

  @override
  String logInTo(String homeserver) {
    return '$homeserverにログインする';
  }

  @override
  String get logout => 'ログアウト';

  @override
  String get mention => 'メンション';

  @override
  String get messages => 'メッセージ';

  @override
  String get messagesStyle => 'メッセージ:';

  @override
  String get moderator => 'モデレータ';

  @override
  String get muteChat => 'チャットのミュート';

  @override
  String get needPantalaimonWarning =>
      '現時点では、エンドツーエンドの暗号化を使用するにはPantalaimonが必要であることに注意してください。';

  @override
  String get newChat => '新規チャット';

  @override
  String get newMessageInFluffyChat => '💬 FluffyChatに新しいメッセージがあります';

  @override
  String get newVerificationRequest => '認証リクエスト！';

  @override
  String get next => '次へ';

  @override
  String get no => 'いいえ';

  @override
  String get noConnectionToTheServer => 'サーバーに接続できません';

  @override
  String get noEmotesFound => 'Emoteは見つかりませんでした😕';

  @override
  String get noEncryptionForPublicRooms => 'ルームを非公開にした後暗号化を有効にできます。';

  @override
  String get noGoogleServicesWarning =>
      'あなたのスマホにはGoogleサービスがないようですね。プライバシーを保護するための良い選択です！プッシュ通知を受け取るには https://microg.org/ または https://unifiedpush.org/ を使うことをお勧めします。';

  @override
  String noMatrixServer(String server1, String server2) {
    return '$server1 はMatrixのサーバーではありません。代わりに $server2 を使用しますか?';
  }

  @override
  String get shareInviteLink => '招待リンクを共有';

  @override
  String get scanQrCode => 'QRコードをスキャン';

  @override
  String get none => 'なし';

  @override
  String get noPasswordRecoveryDescription => 'パスワードを回復する方法をまだ追加していません。';

  @override
  String get noPermission => '権限がありません';

  @override
  String get noRoomsFound => '部屋は見つかりませんでした…';

  @override
  String get notifications => '通知';

  @override
  String numUsersTyping(int count) {
    return '$count人が入力中…';
  }

  @override
  String get obtainingLocation => '位置情報を取得しています…';

  @override
  String get offensive => '攻撃的';

  @override
  String get offline => 'オフライン';

  @override
  String get ok => 'OK';

  @override
  String get online => 'オンライン';

  @override
  String get onlineKeyBackupEnabled => 'オンライン鍵バックアップは使用されています';

  @override
  String get oopsPushError => 'おっと！残念ながら、プッシュ通知の設定中にエラーが発生しました。';

  @override
  String get oopsSomethingWentWrong => 'おっと、何かがうまくいきませんでした…';

  @override
  String get openAppToReadMessages => 'アプリを開いてメッセージを確認してください';

  @override
  String get openCamera => 'カメラを開く';

  @override
  String get oneClientLoggedOut => 'クライアントの 1つがログアウトしました';

  @override
  String get addAccount => 'アカウントを追加';

  @override
  String get editBundlesForAccount => 'このアカウントのバンドルを編集';

  @override
  String get addToBundle => 'バンドルに追加';

  @override
  String get removeFromBundle => 'このバンドルから削除';

  @override
  String get bundleName => 'バンドル名';

  @override
  String get enableMultiAccounts => '(ベータ版) このデバイスで複数のアカウントを有効にする';

  @override
  String get openInMaps => 'マップで開く';

  @override
  String get link => 'リンク';

  @override
  String get serverRequiresEmail => 'このサーバーは、登録のためにメールアドレスを検証する必要があります。';

  @override
  String get or => 'または';

  @override
  String get participant => '参加者';

  @override
  String get passphraseOrKey => 'パスフレーズかリカバリーキー';

  @override
  String get password => 'パスワード';

  @override
  String get passwordForgotten => 'パスワードを忘れた';

  @override
  String get passwordHasBeenChanged => 'パスワードが変更されました';

  @override
  String get overview => '概観';

  @override
  String get passwordRecoverySettings => 'パスワードの復元設定';

  @override
  String get passwordRecovery => 'パスワードリカバリー';

  @override
  String get pickImage => '画像を選択してください';

  @override
  String get pin => 'ピン';

  @override
  String play(String fileName) {
    return '$fileNameを再生する';
  }

  @override
  String get pleaseChooseAPasscode => 'パスコードを選んでください';

  @override
  String get pleaseClickOnLink => 'メールのリンクから進めてください。';

  @override
  String get pleaseEnter4Digits => 'アプリのロック用に4桁の数字を入力してください。空欄の場合は無効になります。';

  @override
  String get pleaseEnterYourPassword => 'パスワードを入力してください';

  @override
  String get pleaseEnterYourPin => 'PINを入力してください';

  @override
  String get pleaseEnterYourUsername => 'ユーザー名を入力してください';

  @override
  String get pleaseFollowInstructionsOnWeb => 'ウェブサイトにあるやり方を見てから次をタップしてください。';

  @override
  String get privacy => 'プライバシー';

  @override
  String get publicRooms => '公開された部屋';

  @override
  String get pushRules => 'ルールを追加する';

  @override
  String get reason => '理由';

  @override
  String get recording => '録音中';

  @override
  String redactedBy(String username) {
    return '$usernameによって削除済み';
  }

  @override
  String get directChat => 'ダイレクトチャット';

  @override
  String redactedByBecause(String username, String reason) {
    return '$usernameによって削除済み。理由:「$reason」';
  }

  @override
  String redactedAnEvent(String username) {
    return '$usernameがイベントを編集しました';
  }

  @override
  String get redactMessage => 'メッセージを書く';

  @override
  String get register => '登録';

  @override
  String get reject => '拒否';

  @override
  String rejectedTheInvitation(String username) {
    return '$usernameは招待を拒否しました';
  }

  @override
  String get removeAllOtherDevices => '他のデバイスをすべて削除';

  @override
  String removedBy(String username) {
    return '$usernameによって削除されました';
  }

  @override
  String get unbanFromChat => 'チャットからのブロックを解除する';

  @override
  String get removeYourAvatar => 'アバターを削除する';

  @override
  String get replaceRoomWithNewerVersion => '部屋を新しいバージョンに変更する';

  @override
  String get reply => '返信';

  @override
  String get reportMessage => 'メッセージを通報';

  @override
  String get requestPermission => '権限を要求する';

  @override
  String get roomHasBeenUpgraded => '部屋はアップグレードされました';

  @override
  String get roomVersion => 'ルームバージョン';

  @override
  String get saveFile => 'ファイルを保存';

  @override
  String get search => '検索';

  @override
  String get security => 'セキュリティ';

  @override
  String get recoveryKey => 'リカバリーキー';

  @override
  String get recoveryKeyLost => 'リカバリーキーを紛失した場合';

  @override
  String get send => '送信';

  @override
  String get sendAMessage => 'メッセージを送信';

  @override
  String get sendAsText => 'テキストとして送信';

  @override
  String get sendAudio => '音声の送信';

  @override
  String get sendFile => 'ファイルを送信';

  @override
  String get sendImage => '画像の送信';

  @override
  String sendImages(int count) {
    return '$countつの画像を送信';
  }

  @override
  String get sendMessages => 'メッセージを送る';

  @override
  String get sendVideo => '動画を送信';

  @override
  String sentAFile(String username) {
    return '📁 $usernameはファイルを送信しました';
  }

  @override
  String sentAnAudio(String username) {
    return '🎤 $usernameは音声を送信しました';
  }

  @override
  String sentAPicture(String username) {
    return '🖼️ $usernameは画像を送信しました';
  }

  @override
  String sentASticker(String username) {
    return '😊 $usernameはステッカーを送信しました';
  }

  @override
  String sentAVideo(String username) {
    return '🎥 $usernameは動画を送信しました';
  }

  @override
  String sentCallInformations(String senderName) {
    return '$senderNameは通話情報を送信しました';
  }

  @override
  String get setAsCanonicalAlias => 'メインエイリアスに設定';

  @override
  String get setChatDescription => 'チャットの説明を設定';

  @override
  String get setStatus => 'ステータスの設定';

  @override
  String get settings => '設定';

  @override
  String get share => '共有';

  @override
  String sharedTheLocation(String username) {
    return '$usernameは現在地を共有しました';
  }

  @override
  String get shareLocation => '位置情報の共有';

  @override
  String get showPassword => 'パスワードを表示';

  @override
  String get presencesToggle => '他のユーザーからのステータスメッセージを表示する';

  @override
  String get skip => 'スキップ';

  @override
  String get sourceCode => 'ソースコード';

  @override
  String get spaceIsPublic => 'スペースは公開されています';

  @override
  String get spaceName => 'スペース名';

  @override
  String startedACall(String senderName) {
    return '$senderNameは通話を開始しました';
  }

  @override
  String get status => 'ステータス';

  @override
  String get statusExampleMessage => 'お元気ですか？';

  @override
  String get submit => '送信';

  @override
  String get synchronizingPleaseWait => '同期中...お待ちください。';

  @override
  String synchronizingPleaseWaitCounter(String percentage) {
    return ' 同期中…（$percentage%）';
  }

  @override
  String get systemTheme => 'システム';

  @override
  String get theyDontMatch => '違います';

  @override
  String get theyMatch => '一致しています';

  @override
  String get title => 'FluffyChat';

  @override
  String get tooManyRequestsWarning => 'リクエストが多すぎます。また後で試してみてください！';

  @override
  String get transferFromAnotherDevice => '違うデバイスから移行する';

  @override
  String get tryToSendAgain => '送信し直してみる';

  @override
  String get unavailable => '不在';

  @override
  String unbannedUser(String username, String targetName) {
    return '$usernameが$targetNameのBANを解除しました';
  }

  @override
  String get unblockDevice => 'デバイスをブロック解除する';

  @override
  String get unknownDevice => '未知デバイス';

  @override
  String get unknownEncryptionAlgorithm => '未知の暗号化アルゴリズム';

  @override
  String unknownEvent(String type) {
    return '未知のイベント\'$type\'';
  }

  @override
  String get unmuteChat => 'チャットをミュート解除する';

  @override
  String get unpin => 'ピンを外す';

  @override
  String userAndOthersAreTyping(String username, int count) {
    return '$usernameと他$count名が入力しています…';
  }

  @override
  String userAndUserAreTyping(String username, String username2) {
    return '$usernameと$username2が入力しています…';
  }

  @override
  String userIsTyping(String username) {
    return '$usernameが入力しています…';
  }

  @override
  String userLeftTheChat(String username) {
    return '🚪 $usernameはチャットから退室しました';
  }

  @override
  String get username => 'ユーザー名';

  @override
  String userSentUnknownEvent(String username, String type) {
    return '$usernameは$typeイベントを送信しました';
  }

  @override
  String get unverified => '未検証';

  @override
  String get verified => '検証済み';

  @override
  String get verify => '確認';

  @override
  String get verifyStart => '確認を始める';

  @override
  String get verifySuccess => '確認が完了しました！';

  @override
  String get verifyTitle => '他のアカウントを確認中';

  @override
  String get videoCall => '音声通話';

  @override
  String get visibilityOfTheChatHistory => 'チャット履歴の表示';

  @override
  String get visibleForAllParticipants => 'すべての参加者が閲覧可能';

  @override
  String get visibleForEveryone => 'すべての人が閲覧可能';

  @override
  String get voiceMessage => 'ボイスメッセージ';

  @override
  String get waitingPartnerAcceptRequest => 'パートナーのリクエスト承諾待ちです…';

  @override
  String get waitingPartnerEmoji => 'パートナーの絵文字承諾待ちです…';

  @override
  String get waitingPartnerNumbers => 'パートナーの数字承諾待ちです…';

  @override
  String get warning => '警告！';

  @override
  String get weSentYouAnEmail => 'あなたにメールを送信しました';

  @override
  String get whoCanPerformWhichAction => '誰がどの操作を実行できるか';

  @override
  String get whoIsAllowedToJoinThisGroup => '誰がこのチャットに入れますか';

  @override
  String get whyDoYouWantToReportThis => 'これを通報する理由';

  @override
  String get wipeChatBackup => 'チャットのバックアップを消去して、新しいリカバリーキーを作りますか？';

  @override
  String get withTheseAddressesRecoveryDescription =>
      'これらのアドレスを使用すると、パスワードを回復することができます。';

  @override
  String get writeAMessage => 'メッセージを入力してください…';

  @override
  String get yes => 'はい';

  @override
  String get you => 'あなた';

  @override
  String get youAreNoLongerParticipatingInThisChat => 'あなたはもうこのチャットの参加者ではありません';

  @override
  String get youHaveBeenBannedFromThisChat => 'チャットからBANされてしまいました';

  @override
  String get yourPublicKey => 'あなたの公開鍵';

  @override
  String get messageInfo => 'メッセージの情報';

  @override
  String get time => '時間';

  @override
  String get messageType => 'メッセージの種類';

  @override
  String get sender => '送信者';

  @override
  String get openGallery => 'ギャラリーを開く';

  @override
  String get removeFromSpace => 'スペースから削除';

  @override
  String get start => '開始';

  @override
  String get pleaseEnterRecoveryKeyDescription =>
      '古いメッセージを解除するには、以前のセッションで生成されたリカバリーキーを入力してください。リカバリーキーはパスワードではありません。';

  @override
  String get openChat => 'チャットを開く';

  @override
  String get markAsRead => '既読にする';

  @override
  String get reportUser => 'ユーザーを報告';

  @override
  String get dismiss => '棄却';

  @override
  String reactedWith(String sender, String reaction) {
    return '$sender が $reaction で反応しました';
  }

  @override
  String get pinMessage => '部屋にピン留めする';

  @override
  String get confirmEventUnpin => 'イベントの固定を完全に解除してもよろしいですか？';

  @override
  String get emojis => '絵文字';

  @override
  String get placeCall => '電話をかける';

  @override
  String get voiceCall => '音声通話';

  @override
  String get unsupportedAndroidVersion => 'サポートされていないAndroidのバージョン';

  @override
  String get unsupportedAndroidVersionLong =>
      'この機能を利用するには、より新しいAndroidのバージョンが必要です。アップデートまたはLineage OSのサポートをご確認ください。';

  @override
  String get videoCallsBetaWarning =>
      'ビデオ通話は、現在ベータ版であることにご注意ください。すべてのプラットフォームで期待通りに動作しない、あるいはまったく動作しない可能性があります。';

  @override
  String get experimentalVideoCalls => '実験的なビデオ通話';

  @override
  String get youRejectedTheInvitation => '招待を拒否しました';

  @override
  String get youJoinedTheChat => 'チャットに参加しました';

  @override
  String get youAcceptedTheInvitation => '👍 招待を承諾しました';

  @override
  String youBannedUser(String user) {
    return '$user を禁止しました';
  }

  @override
  String youHaveWithdrawnTheInvitationFor(String user) {
    return '$user への招待を取り下げました';
  }

  @override
  String youInvitedBy(String user) {
    return '📩 $user から招待されました';
  }

  @override
  String invitedBy(String user) {
    return '📩 $userに招待されました';
  }

  @override
  String youInvitedUser(String user) {
    return '📩 $user を招待しました';
  }

  @override
  String youKicked(String user) {
    return '👞 $user をキックしました';
  }

  @override
  String youKickedAndBanned(String user) {
    return '🙅 $user をキックしてブロックしました';
  }

  @override
  String youUnbannedUser(String user) {
    return '$user の禁止を解除しました';
  }

  @override
  String hasKnocked(String user) {
    return '🚪 $userがノックしました';
  }

  @override
  String get usersMustKnock => 'ユーザーはノックする必要があります';

  @override
  String get noOneCanJoin => '誰も参加できません';

  @override
  String get knock => 'ノック';

  @override
  String get users => 'ユーザー';

  @override
  String get unlockOldMessages => '古いメッセージのロックを解除する';

  @override
  String get storeInSecureStorageDescription => 'このデバイスの安全なストレージにリカバリーキーを保存。';

  @override
  String get saveKeyManuallyDescription =>
      'この鍵をシステムの共有ダイアログかクリップボードから手動で保存してください。';

  @override
  String get storeInAndroidKeystore => 'Android KeyStoreに保存する';

  @override
  String get storeInAppleKeyChain => 'Apple KeyChainに保存';

  @override
  String get storeSecurlyOnThisDevice => 'このデバイスに安全に保管する';

  @override
  String countFiles(int count) {
    return '$count個のファイル';
  }

  @override
  String get user => 'ユーザー';

  @override
  String get custom => 'カスタム';

  @override
  String get foregroundServiceRunning => 'この通知は、フォアグラウンド サービスの実行中に表示されます。';

  @override
  String get screenSharingTitle => '画面共有';

  @override
  String get screenSharingDetail => 'FuffyChatで画面を共有しています';

  @override
  String get whyIsThisMessageEncrypted => 'このメッセージが読めない理由';

  @override
  String get noKeyForThisMessage =>
      'This can happen if the message was sent before you have signed in to your account at this device.\n\nIt is also possible that the sender has blocked your device or something went wrong with the internet connection.\n\nAre you able to read the message on another session? Then you can transfer the message from it! Go to Settings > Devices and make sure that your devices have verified each other. When you open the room the next time and both sessions are in the foreground, the keys will be transmitted automatically.\n\nDo you not want to lose the keys when logging out or switching devices? Make sure that you have enabled the chat backup in the settings.';

  @override
  String get newGroup => '新しいグループ';

  @override
  String get newSpace => '新しいスペース';

  @override
  String get allSpaces => 'すべてのスペース';

  @override
  String get hidePresences => 'Hide Status List?';

  @override
  String get doNotShowAgain => '今後表示しない';

  @override
  String wasDirectChatDisplayName(String oldDisplayName) {
    return '空のチャット (以前は $oldDisplayName)';
  }

  @override
  String get newSpaceDescription =>
      'Spaces allows you to consolidate your chats and build private or public communities.';

  @override
  String get encryptThisChat => 'このチャットを暗号化する';

  @override
  String get disableEncryptionWarning =>
      'セキュリティ上の理由から、以前は暗号化が有効だったチャットで暗号化を無効にすることはできません。';

  @override
  String get sorryThatsNotPossible => '申し訳ありません...それは不可能です';

  @override
  String get deviceKeys => 'デバイスキー:';

  @override
  String get reopenChat => 'チャットを再開する';

  @override
  String get noBackupWarning =>
      '警告！チャットのバックアップを有効にしないと、暗号化されたメッセージにアクセスできなくなります。ログアウトする前に、まずチャットのバックアップを有効にすることを強くお勧めします。';

  @override
  String get noOtherDevicesFound => '他のデバイスが見つかりません';

  @override
  String fileIsTooBigForServer(String max) {
    return '送信できません！このサーバーは添付数は$max個までです。';
  }

  @override
  String fileHasBeenSavedAt(String path) {
    return 'ファイルは $path に保存されています';
  }

  @override
  String get jumpToLastReadMessage => '最後に閲覧したメッセージまで移動する';

  @override
  String get readUpToHere => 'ここまで既読です';

  @override
  String get jump => '移動';

  @override
  String get openLinkInBrowser => 'リンクをブラウザで開く';

  @override
  String get reportErrorDescription =>
      '😭 おっと。問題が発生しました。必要があれば、このバグを開発者に報告することができます。';

  @override
  String get report => 'report';

  @override
  String get setColorTheme => 'カラーテーマの設定：';

  @override
  String get invite => '招待';

  @override
  String get inviteGroupChat => '📨 グループチャットへ招待する';

  @override
  String get invalidInput => '無効な入力です！';

  @override
  String wrongPinEntered(int seconds) {
    return '誤ったPINが入力されました！$seconds秒後に再試行してください…';
  }

  @override
  String get pleaseEnterANumber => '0以上の数値を入力してください';

  @override
  String get archiveRoomDescription =>
      'チャットはアーカイブに移動されます。他のユーザーはあなたが退出したチャットを見ることができます。';

  @override
  String get roomUpgradeDescription =>
      'チャットは新しい部屋バージョンで再作成されます。全参加者に新しいチャットへ切り替える必要があることが通知されます。部屋バージョンについては https://spec.matrix.org/latest/rooms/ をご覧ください';

  @override
  String get removeDevicesDescription => 'このデバイスからログアウトするとメッセージを受け取ることができません。';

  @override
  String get banUserDescription =>
      'ユーザーをチャットからBANすると、BANを解除されるまで再入室することはできません。';

  @override
  String get unbanUserDescription => 'ユーザーが再試行時に再入室することができます。';

  @override
  String get kickUserDescription =>
      'The user is kicked out of the chat but not banned. In public chats, the user can rejoin at any time.';

  @override
  String get makeAdminDescription =>
      'Once you make this user admin, you may not be able to undo this as they will then have the same permissions as you.';

  @override
  String get pushNotificationsNotAvailable => 'プッシュ通知は利用できません';

  @override
  String get learnMore => '詳しく知る';

  @override
  String get yourGlobalUserIdIs => 'あなたのグローバルユーザーID： ';

  @override
  String noUsersFoundWithQuery(String query) {
    return 'Unfortunately no user could be found with \"$query\". Please check whether you made a typo.';
  }

  @override
  String get knocking => 'ノックしています';

  @override
  String chatCanBeDiscoveredViaSearchOnServer(String server) {
    return 'Chat can be discovered via the search on $server';
  }

  @override
  String get searchChatsRooms => '#チャット，@ユーザーで検索…';

  @override
  String get nothingFound => '何も見つかりませんでした…';

  @override
  String get groupName => 'グループ名';

  @override
  String get createGroupAndInviteUsers => 'グループを作成してユーザーを招待する';

  @override
  String get groupCanBeFoundViaSearch => 'グループは検索で見つけることができます';

  @override
  String get wrongRecoveryKey =>
      'Sorry... this does not seem to be the correct recovery key.';

  @override
  String get commandHint_sendraw => '生のJSONを送信する';

  @override
  String get databaseMigrationTitle => 'データベースは最適化されています';

  @override
  String get databaseMigrationBody => 'しばらくお待ちください。この操作は時間がかかります。';

  @override
  String get leaveEmptyToClearStatus => 'Leave empty to clear your status.';

  @override
  String get select => 'Select';

  @override
  String get searchForUsers => '@ユーザー で検索…';

  @override
  String get pleaseEnterYourCurrentPassword => '現在のパスワードを入力してください';

  @override
  String get newPassword => '新しいパスワード';

  @override
  String get pleaseChooseAStrongPassword => '強力なパスワードを選択してください';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordIsWrong => 'Your entered password is wrong';

  @override
  String get publicChatAddresses => 'Public chat addresses';

  @override
  String get createNewAddress => 'Create new address';

  @override
  String get joinSpace => 'Join space';

  @override
  String get publicSpaces => 'Public spaces';

  @override
  String get addChatOrSubSpace => 'Add chat or sub space';

  @override
  String get thisDevice => 'This device:';

  @override
  String get initAppError => 'An error occured while init the app';

  @override
  String searchIn(String chat) {
    return 'Search in chat \"$chat\"...';
  }

  @override
  String get searchMore => 'Search more...';

  @override
  String get gallery => 'Gallery';

  @override
  String get files => 'Files';

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
  String get markAsUnread => '未読としてマーク';

  @override
  String userLevel(int level) {
    return '$level - ユーザー';
  }

  @override
  String moderatorLevel(int level) {
    return '$level - モデレーター';
  }

  @override
  String adminLevel(int level) {
    return '$level - 管理者';
  }

  @override
  String get changeGeneralChatSettings => '全体のチャット設定を変更する';

  @override
  String get inviteOtherUsers => '他のユーザーをこのチャットに招待する';

  @override
  String get changeTheChatPermissions => 'チャット権限を変更する';

  @override
  String get changeTheVisibilityOfChatHistory =>
      'Change the visibility of the chat history';

  @override
  String get changeTheCanonicalRoomAlias =>
      'Change the main public chat address';

  @override
  String get sendRoomNotifications => 'Send a @room notifications';

  @override
  String get changeTheDescriptionOfTheGroup => 'チャットの説明を変更する';

  @override
  String get chatPermissionsDescription =>
      'Define which power level is necessary for certain actions in this chat. The power levels 0, 50 and 100 are usually representing users, moderators and admins, but any gradation is possible.';

  @override
  String updateInstalled(String version) {
    return '🎉 アップデート $version をインストールしました！';
  }

  @override
  String get changelog => '変更履歴';

  @override
  String get sendCanceled => '送信を取り消しました';

  @override
  String get loginWithMatrixId => 'Matrix-IDでログイン';

  @override
  String get doesNotSeemToBeAValidHomeserver =>
      'Doesn\'t seem to be a compatible homeserver. Wrong URL?';

  @override
  String get calculatingFileSize => 'ファイルサイズを計算しています…';

  @override
  String get prepareSendingAttachment => '送信する添付ファイルを準備しています…';

  @override
  String get sendingAttachment => '添付ファイルを送信しています…';

  @override
  String get generatingVideoThumbnail => 'ビデオサムネイルを生成しています…';

  @override
  String get compressVideo => 'ビデオを圧縮しています…';

  @override
  String sendingAttachmentCountOfCount(int index, int length) {
    return '$length個中$index個の添付ファイルを送信しています…';
  }

  @override
  String serverLimitReached(int seconds) {
    return 'サーバーのリミットに達しました！$seconds秒お待ちください…';
  }

  @override
  String get oneOfYourDevicesIsNotVerified => 'いずれかのデバイスが認証されていません';

  @override
  String get noticeChatBackupDeviceVerification =>
      '注意：すべてのデバイスをチャットのバックアップに接続している場合、それらは自動的に認証されます。';

  @override
  String get continueText => '続ける';

  @override
  String get welcomeText =>
      'Hey Hey 👋 This is FluffyChat. You can sign in to any homeserver, which is compatible with https://matrix.org. And then chat with anyone. It\'s a huge decentralized messaging network!';

  @override
  String get blur => 'ぼかし：';

  @override
  String get opacity => '透過度：';

  @override
  String get setWallpaper => '壁紙を設定する';

  @override
  String get manageAccount => 'アカウント管理';

  @override
  String get noContactInformationProvided => 'サーバーから有効な連絡先情報が提供されていません';

  @override
  String get contactServerAdmin => 'Contact server admin';

  @override
  String get contactServerSecurity => 'Contact server security';

  @override
  String get supportPage => 'サポートページ';

  @override
  String get serverInformation => 'サーバー情報：';

  @override
  String get name => '名前';

  @override
  String get version => 'バージョン';

  @override
  String get website => 'ウェブサイト';

  @override
  String get compress => '圧縮';

  @override
  String get boldText => '太字';

  @override
  String get italicText => '斜体';

  @override
  String get strikeThrough => 'Strikethrough';

  @override
  String get pleaseFillOut => 'Please fill out';

  @override
  String get invalidUrl => '無効なURL';

  @override
  String get addLink => 'リンクを追加';

  @override
  String get unableToJoinChat =>
      'Unable to join chat. Maybe the other party has already closed the conversation.';

  @override
  String get previous => 'Previous';

  @override
  String get otherPartyNotLoggedIn =>
      'The other party is currently not logged in and therefore cannot receive messages!';

  @override
  String appWantsToUseForLogin(String server) {
    return '\'$server\' を使用してログインする';
  }

  @override
  String get appWantsToUseForLoginDescription =>
      'You hereby allow the app and website to share information about you.';

  @override
  String get open => '開く';

  @override
  String get waitingForServer => 'サーバーを待機中…';

  @override
  String get newChatRequest => '📩 新しいチャットを要求';

  @override
  String get contentNotificationSettings => 'コンテンツ通知設定';

  @override
  String get generalNotificationSettings => '全体通知設定';

  @override
  String get roomNotificationSettings => '部屋通知設定';

  @override
  String get userSpecificNotificationSettings => 'ユーザー毎の通知設定';

  @override
  String get otherNotificationSettings => 'その他の通知設定';

  @override
  String get notificationRuleContainsUserName => 'ユーザー名を含む';

  @override
  String get notificationRuleContainsUserNameDescription =>
      'ユーザー名がメッセージに含まれる場合に通知します。';

  @override
  String get notificationRuleMaster => 'すべての通知をミュート';

  @override
  String get notificationRuleMasterDescription => '全ルールを上書きして通知をすべて無効にします。';

  @override
  String get notificationRuleSuppressNotices => '自動化されたメッセージを控える';

  @override
  String get notificationRuleSuppressNoticesDescription =>
      'Botのような自動化されたクライアントからの通知を抑制します。';

  @override
  String get notificationRuleInviteForMe => 'Invite for Me';

  @override
  String get notificationRuleInviteForMeDescription => 'ユーザーが部屋に招待されたときに通知します。';

  @override
  String get notificationRuleMemberEvent => 'Member Event';

  @override
  String get notificationRuleMemberEventDescription =>
      'Suppresses notifications for membership events.';

  @override
  String get notificationRuleIsUserMention => 'ユーザーの言及';

  @override
  String get notificationRuleIsUserMentionDescription =>
      'ユーザーがメッセージ内で直接言及されたときに通知します。';

  @override
  String get notificationRuleContainsDisplayName => 'Contains Display Name';

  @override
  String get notificationRuleContainsDisplayNameDescription =>
      'Notifies the user when a message contains their display name.';

  @override
  String get notificationRuleIsRoomMention => 'Room Mention';

  @override
  String get notificationRuleIsRoomMentionDescription =>
      'Notifies the user when there is a room mention.';

  @override
  String get notificationRuleRoomnotif => 'Room Notification';

  @override
  String get notificationRuleRoomnotifDescription =>
      'Notifies the user when a message contains \'@room\'.';

  @override
  String get notificationRuleTombstone => 'Tombstone';

  @override
  String get notificationRuleTombstoneDescription =>
      'Notifies the user about room deactivation messages.';

  @override
  String get notificationRuleReaction => 'Reaction';

  @override
  String get notificationRuleReactionDescription =>
      'Suppresses notifications for reactions.';

  @override
  String get notificationRuleRoomServerAcl => 'Room Server ACL';

  @override
  String get notificationRuleRoomServerAclDescription =>
      'Suppresses notifications for room server access control lists (ACL).';

  @override
  String get notificationRuleSuppressEdits => 'Suppress Edits';

  @override
  String get notificationRuleSuppressEditsDescription =>
      'Suppresses notifications for edited messages.';

  @override
  String get notificationRuleCall => 'Call';

  @override
  String get notificationRuleCallDescription =>
      'Notifies the user about calls.';

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
    return '🎙️ $duration - Voice message from $sender';
  }

  @override
  String get deletePushRuleCanNotBeUndone =>
      'If you delete this notification setting, this can not be undone.';

  @override
  String get more => 'More';

  @override
  String get shareKeysWith => 'Share keys with...';

  @override
  String get shareKeysWithDescription =>
      'Which devices should be trusted so that they can read along your messages in encrypted chats?';

  @override
  String get allDevices => 'All devices';

  @override
  String get crossVerifiedDevicesIfEnabled =>
      'Cross verified devices if enabled';

  @override
  String get crossVerifiedDevices => 'Cross verified devices';

  @override
  String get verifiedDevicesOnly => 'Verified devices only';

  @override
  String get takeAPhoto => 'Take a photo';

  @override
  String get recordAVideo => 'Record a video';

  @override
  String get optionalMessage => '(Optional) message...';

  @override
  String get notSupportedOnThisDevice => 'Not supported on this device';

  @override
  String get enterNewChat => 'Enter new chat';

  @override
  String get approve => 'Approve';

  @override
  String get youHaveKnocked => 'You have knocked';

  @override
  String get pleaseWaitUntilInvited =>
      'Please wait now, until someone from the room invites you.';

  @override
  String get commandHint_logout => 'Logout your current device';

  @override
  String get commandHint_logoutall => 'Logout all active devices';

  @override
  String get displayNavigationRail => 'Show navigation rail on mobile';

  @override
  String get customReaction => 'Custom reaction';

  @override
  String get moreEvents => 'More events';

  @override
  String get declineInvitation => 'Decline invitation';

  @override
  String get noMessagesYet => 'No messages yet';

  @override
  String get longPressToRecordVoiceMessage =>
      'Long press to record voice message.';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get removeFromSpaceDescription =>
      'The chat will be removed from the space but still appear in your chat list.';

  @override
  String countChats(int chats) {
    return '$chats chats';
  }

  @override
  String spaceMemberOf(String spaces) {
    return 'Space member of $spaces';
  }

  @override
  String spaceMemberOfCanKnock(String spaces) {
    return 'Space member of $spaces can knock';
  }

  @override
  String startedAPoll(String username) {
    return '$username started a poll.';
  }

  @override
  String get poll => 'Poll';

  @override
  String get startPoll => 'Start poll';

  @override
  String get endPoll => 'End poll';

  @override
  String get answersVisible => 'Answers visible';

  @override
  String get pollQuestion => 'Poll question';

  @override
  String get answerOption => 'Answer option';

  @override
  String get addAnswerOption => 'Add answer option';

  @override
  String get allowMultipleAnswers => 'Allow multiple answers';

  @override
  String get pollHasBeenEnded => 'Poll has been ended';

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
      'Answers will be visible when poll has ended';

  @override
  String get replyInThread => 'Reply in thread';

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
  String get thread => 'Thread';

  @override
  String get backToMainChat => 'Back to main chat';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get createSticker => 'Create sticker or emoji';

  @override
  String get useAsSticker => 'Use as sticker';

  @override
  String get useAsEmoji => 'Use as emoji';

  @override
  String get stickerPackNameAlreadyExists => 'Sticker pack name already exists';

  @override
  String get newStickerPack => 'New sticker pack';

  @override
  String get stickerPackName => 'Sticker pack name';

  @override
  String get attribution => 'Attribution';

  @override
  String get skipChatBackup => 'Skip chat backup';

  @override
  String get skipChatBackupWarning =>
      'Are you sure? Without enabling the chat backup you may lose access to your messages if you switch your device.';

  @override
  String get loadingMessages => 'Loading messages';

  @override
  String get setupChatBackup => 'Set up chat backup';

  @override
  String get noMoreResultsFound => 'No more results found';

  @override
  String chatSearchedUntil(String time) {
    return 'Chat searched until $time';
  }

  @override
  String get federationBaseUrl => 'Federation Base URL';

  @override
  String get clientWellKnownInformation => 'Client-Well-Known Information:';

  @override
  String get baseUrl => 'Base URL';

  @override
  String get identityServer => 'Identity Server:';

  @override
  String versionWithNumber(String version) {
    return 'Version: $version';
  }

  @override
  String get logs => 'Logs';

  @override
  String get advancedConfigs => 'Advanced Configs';

  @override
  String get advancedConfigurations => 'Advanced configurations';

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
