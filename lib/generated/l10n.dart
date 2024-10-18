// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class AppLocalizations {
  AppLocalizations();

  static AppLocalizations? _current;

  static AppLocalizations get current {
    assert(_current != null,
        'No instance of AppLocalizations was loaded. Try to initialize the AppLocalizations delegate before accessing AppLocalizations.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<AppLocalizations> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = AppLocalizations();
      AppLocalizations._current = instance;

      return instance;
    });
  }

  static AppLocalizations of(BuildContext context) {
    final instance = AppLocalizations.maybeOf(context);
    assert(instance != null,
        'No instance of AppLocalizations present in the widget tree. Did you add AppLocalizations.delegate in localizationsDelegates?');
    return instance!;
  }

  static AppLocalizations? maybeOf(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// `Get Started`
  String get getStarted {
    return Intl.message(
      'Get Started',
      name: 'getStarted',
      desc: '',
      args: [],
    );
  }

  /// `Watchgram`
  String get watchgram {
    return Intl.message(
      'Watchgram',
      name: 'watchgram',
      desc: '',
      args: [],
    );
  }

  /// `Scan to Login`
  String get qrScanTitle {
    return Intl.message(
      'Scan to Login',
      name: 'qrScanTitle',
      desc: '',
      args: [],
    );
  }

  /// `Where to scan?`
  String get whereToScan {
    return Intl.message(
      'Where to scan?',
      name: 'whereToScan',
      desc: '',
      args: [],
    );
  }

  /// `1. Open Telegram on your phone\n\n2. Go to Settings > Devices > Link Desktop Device\n\n3. Scan this image to Log In`
  String get qrInstruction {
    return Intl.message(
      '1. Open Telegram on your phone\n\n2. Go to Settings > Devices > Link Desktop Device\n\n3. Scan this image to Log In',
      name: 'qrInstruction',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message(
      'Login',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Enter Password`
  String get enterPassword {
    return Intl.message(
      'Enter Password',
      name: 'enterPassword',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect password`
  String get incorrectPassword {
    return Intl.message(
      'Incorrect password',
      name: 'incorrectPassword',
      desc: '',
      args: [],
    );
  }

  /// `Select Theme`
  String get selectThemeTitle {
    return Intl.message(
      'Select Theme',
      name: 'selectThemeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Select Watch Shape`
  String get selectShapeTitle {
    return Intl.message(
      'Select Watch Shape',
      name: 'selectShapeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Some Settings`
  String get firstSettingsTitle {
    return Intl.message(
      'Some Settings',
      name: 'firstSettingsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Remove`
  String get removeButton {
    return Intl.message(
      'Remove',
      name: 'removeButton',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get doneButton {
    return Intl.message(
      'Done',
      name: 'doneButton',
      desc: '',
      args: [],
    );
  }

  /// `Create`
  String get createButton {
    return Intl.message(
      'Create',
      name: 'createButton',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get closeButton {
    return Intl.message(
      'Close',
      name: 'closeButton',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get nextButton {
    return Intl.message(
      'Next',
      name: 'nextButton',
      desc: '',
      args: [],
    );
  }

  /// `Proxy Settings`
  String get proxySettingsTitle {
    return Intl.message(
      'Proxy Settings',
      name: 'proxySettingsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Proxy Settings`
  String get proxySettingsButton {
    return Intl.message(
      'Proxy Settings',
      name: 'proxySettingsButton',
      desc:
          'Translate as short as possible, text length shouldn\'t exceed original one. You can omit "settings" part in text if needed, this is shown on a single button, anyway',
      args: [],
    );
  }

  /// `Proxy`
  String get proxySettingsMainToggle {
    return Intl.message(
      'Proxy',
      name: 'proxySettingsMainToggle',
      desc: '',
      args: [],
    );
  }

  /// `Disconnected`
  String get proxyConnectionDisconnected {
    return Intl.message(
      'Disconnected',
      name: 'proxyConnectionDisconnected',
      desc: '',
      args: [],
    );
  }

  /// `Last used: {date}`
  String proxyConnectionLastUsedDate(DateTime date) {
    final DateFormat dateDateFormat = DateFormat.MMMd(Intl.getCurrentLocale());
    final String dateString = dateDateFormat.format(date);

    return Intl.message(
      'Last used: $dateString',
      name: 'proxyConnectionLastUsedDate',
      desc: 'Translate as short as possible! Max string length here is 25',
      args: [dateString],
    );
  }

  /// `Waiting for network...`
  String get connectionWaitingForNetwork {
    return Intl.message(
      'Waiting for network...',
      name: 'connectionWaitingForNetwork',
      desc: '',
      args: [],
    );
  }

  /// `Connecting to proxy...`
  String get connectionConnectingToProxy {
    return Intl.message(
      'Connecting to proxy...',
      name: 'connectionConnectingToProxy',
      desc: '',
      args: [],
    );
  }

  /// `Connecting...`
  String get connectionConnecting {
    return Intl.message(
      'Connecting...',
      name: 'connectionConnecting',
      desc: '',
      args: [],
    );
  }

  /// `Updating...`
  String get connectionUpdating {
    return Intl.message(
      'Updating...',
      name: 'connectionUpdating',
      desc: '',
      args: [],
    );
  }

  /// `Connected`
  String get connectionConnected {
    return Intl.message(
      'Connected',
      name: 'connectionConnected',
      desc: '',
      args: [],
    );
  }

  /// `Add proxy`
  String get proxyAdd {
    return Intl.message(
      'Add proxy',
      name: 'proxyAdd',
      desc: '',
      args: [],
    );
  }

  /// `New Proxy`
  String get createProxy {
    return Intl.message(
      'New Proxy',
      name: 'createProxy',
      desc: '',
      args: [],
    );
  }

  /// `Edit Proxy`
  String get editProxy {
    return Intl.message(
      'Edit Proxy',
      name: 'editProxy',
      desc: '',
      args: [],
    );
  }

  /// `Proxy server`
  String get proxyServer {
    return Intl.message(
      'Proxy server',
      name: 'proxyServer',
      desc: '',
      args: [],
    );
  }

  /// `Proxy port`
  String get proxyPort {
    return Intl.message(
      'Proxy port',
      name: 'proxyPort',
      desc: '',
      args: [],
    );
  }

  /// `Proxy type`
  String get proxyType {
    return Intl.message(
      'Proxy type',
      name: 'proxyType',
      desc: '',
      args: [],
    );
  }

  /// `Select Proxy Type`
  String get proxyTypePickerTitle {
    return Intl.message(
      'Select Proxy Type',
      name: 'proxyTypePickerTitle',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get proxyUser {
    return Intl.message(
      'Username',
      name: 'proxyUser',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get proxyPassword {
    return Intl.message(
      'Password',
      name: 'proxyPassword',
      desc: '',
      args: [],
    );
  }

  /// `Secret`
  String get proxySecret {
    return Intl.message(
      'Secret',
      name: 'proxySecret',
      desc: '',
      args: [],
    );
  }

  /// `Insecure`
  String get proxyInsecure {
    return Intl.message(
      'Insecure',
      name: 'proxyInsecure',
      desc: '',
      args: [],
    );
  }

  /// `SOCKS5`
  String get proxyTypeSOCKS5 {
    return Intl.message(
      'SOCKS5',
      name: 'proxyTypeSOCKS5',
      desc: '',
      args: [],
    );
  }

  /// `HTTP`
  String get proxyTypeHTTP {
    return Intl.message(
      'HTTP',
      name: 'proxyTypeHTTP',
      desc: '',
      args: [],
    );
  }

  /// `MTProto`
  String get proxyTypeMTProto {
    return Intl.message(
      'MTProto',
      name: 'proxyTypeMTProto',
      desc: '',
      args: [],
    );
  }

  /// `Call`
  String get notificationSingleTitleCall {
    return Intl.message(
      'Call',
      name: 'notificationSingleTitleCall',
      desc: '',
      args: [],
    );
  }

  /// `Scheduled message`
  String get notificationSingleTitleScheduledMessage {
    return Intl.message(
      'Scheduled message',
      name: 'notificationSingleTitleScheduledMessage',
      desc: '',
      args: [],
    );
  }

  /// `Secret chat`
  String get notificationSingleTitleNewSecretChat {
    return Intl.message(
      'Secret chat',
      name: 'notificationSingleTitleNewSecretChat',
      desc: '',
      args: [],
    );
  }

  /// `{name} is calling you...`
  String notificationTextCall(String name) {
    return Intl.message(
      '$name is calling you...',
      name: 'notificationTextCall',
      desc: '',
      args: [name],
    );
  }

  /// `{name} has just created a secret chat with you!`
  String notificationTextSecretChat(String name) {
    return Intl.message(
      '$name has just created a secret chat with you!',
      name: 'notificationTextSecretChat',
      desc: '',
      args: [name],
    );
  }

  /// `GIF`
  String get gif {
    return Intl.message(
      'GIF',
      name: 'gif',
      desc: '',
      args: [],
    );
  }

  /// `Audio`
  String get audio {
    return Intl.message(
      'Audio',
      name: 'audio',
      desc: '',
      args: [],
    );
  }

  /// `Group was created`
  String get groupWasCreated {
    return Intl.message(
      'Group was created',
      name: 'groupWasCreated',
      desc: '',
      args: [],
    );
  }

  /// `Bot has been allowed to write messages`
  String get botWriteAccessAllowed {
    return Intl.message(
      'Bot has been allowed to write messages',
      name: 'botWriteAccessAllowed',
      desc: '',
      args: [],
    );
  }

  /// `Call ({time})`
  String callWithTime(String time) {
    return Intl.message(
      'Call ($time)',
      name: 'callWithTime',
      desc: '',
      args: [time],
    );
  }

  /// `Video call ({time})`
  String videoCallWithTime(String time) {
    return Intl.message(
      'Video call ($time)',
      name: 'videoCallWithTime',
      desc: '',
      args: [time],
    );
  }

  /// `{user} and others were added`
  String chatMembersWereAdded(String user) {
    return Intl.message(
      '$user and others were added',
      name: 'chatMembersWereAdded',
      desc:
          'Shown in message preview in chat lists, try to translate as short as possible',
      args: [user],
    );
  }

  /// `You've boosted chat`
  String get youHaveBoostedChat {
    return Intl.message(
      'You\'ve boosted chat',
      name: 'youHaveBoostedChat',
      desc: '',
      args: [],
    );
  }

  /// `Avatar was changed`
  String get avatarWasChanged {
    return Intl.message(
      'Avatar was changed',
      name: 'avatarWasChanged',
      desc: '',
      args: [],
    );
  }

  /// `Avatar was deleted`
  String get avatarWasDeleted {
    return Intl.message(
      'Avatar was deleted',
      name: 'avatarWasDeleted',
      desc: '',
      args: [],
    );
  }

  /// `Title was changed`
  String get titleWasChanged {
    return Intl.message(
      'Title was changed',
      name: 'titleWasChanged',
      desc: '',
      args: [],
    );
  }

  /// `{user} has left`
  String userHasLeft(String user) {
    return Intl.message(
      '$user has left',
      name: 'userHasLeft',
      desc: 'User has left a group. Try to translate as short as possible.',
      args: [user],
    );
  }

  /// `Someone joined via link`
  String get someoneJoinedViaLink {
    return Intl.message(
      'Someone joined via link',
      name: 'someoneJoinedViaLink',
      desc: '',
      args: [],
    );
  }

  /// `Someone was approved to join`
  String get someoneJoinedByRequest {
    return Intl.message(
      'Someone was approved to join',
      name: 'someoneJoinedByRequest',
      desc: '',
      args: [],
    );
  }

  /// `Background was changed`
  String get bgWasChanged {
    return Intl.message(
      'Background was changed',
      name: 'bgWasChanged',
      desc: '',
      args: [],
    );
  }

  /// `Auto-delete timer was changed`
  String get messageTtlChanged {
    return Intl.message(
      'Auto-delete timer was changed',
      name: 'messageTtlChanged',
      desc: '',
      args: [],
    );
  }

  /// `Chat was shared`
  String get chatWasShared {
    return Intl.message(
      'Chat was shared',
      name: 'chatWasShared',
      desc: '',
      args: [],
    );
  }

  /// `Upgraded to supergroup`
  String get upgradedToSupergroup {
    return Intl.message(
      'Upgraded to supergroup',
      name: 'upgradedToSupergroup',
      desc: '',
      args: [],
    );
  }

  /// `has joined Telegram!`
  String get hasJoinedTelegram {
    return Intl.message(
      'has joined Telegram!',
      name: 'hasJoinedTelegram',
      desc: '',
      args: [],
    );
  }

  /// `Document`
  String get document {
    return Intl.message(
      'Document',
      name: 'document',
      desc: '',
      args: [],
    );
  }

  /// `Expired photo`
  String get expiredPhoto {
    return Intl.message(
      'Expired photo',
      name: 'expiredPhoto',
      desc: '',
      args: [],
    );
  }

  /// `Expired video`
  String get expiredVideo {
    return Intl.message(
      'Expired video',
      name: 'expiredVideo',
      desc: '',
      args: [],
    );
  }

  /// `Expired voice message`
  String get expiredVoiceNote {
    return Intl.message(
      'Expired voice message',
      name: 'expiredVoiceNote',
      desc: '',
      args: [],
    );
  }

  /// `Expired video message`
  String get expiredVideoNote {
    return Intl.message(
      'Expired video message',
      name: 'expiredVideoNote',
      desc: '',
      args: [],
    );
  }

  /// `New "{name}" topic`
  String newForumTopic(String name) {
    return Intl.message(
      'New "$name" topic',
      name: 'newForumTopic',
      desc: '',
      args: [name],
    );
  }

  /// `Edited "{name}" topic`
  String editedForumTopic(String name) {
    return Intl.message(
      'Edited "$name" topic',
      name: 'editedForumTopic',
      desc: '',
      args: [name],
    );
  }

  /// `Topic was closed`
  String get topicWasClosed {
    return Intl.message(
      'Topic was closed',
      name: 'topicWasClosed',
      desc: '',
      args: [],
    );
  }

  /// `Topic was opened`
  String get topicWasOpened {
    return Intl.message(
      'Topic was opened',
      name: 'topicWasOpened',
      desc: '',
      args: [],
    );
  }

  /// `Topic was hidden`
  String get topicWasHidden {
    return Intl.message(
      'Topic was hidden',
      name: 'topicWasHidden',
      desc: '',
      args: [],
    );
  }

  /// `Topic was shown`
  String get topicWasShown {
    return Intl.message(
      'Topic was shown',
      name: 'topicWasShown',
      desc: '',
      args: [],
    );
  }

  /// `Scored {score} in game`
  String scoredSomeScoreInGame(int score) {
    return Intl.message(
      'Scored $score in game',
      name: 'scoredSomeScoreInGame',
      desc: 'Shown in message preview in chat lists',
      args: [score],
    );
  }

  /// `Premium ({count} {count, plural, one{month} other{months}})`
  String premiumWithMonthsCount(int count) {
    return Intl.message(
      'Premium ($count ${Intl.plural(count, one: 'month', other: 'months')})',
      name: 'premiumWithMonthsCount',
      desc: '',
      args: [count],
    );
  }

  /// `{count} Telegram {count, plural, one{Star} other{Stars}}`
  String starsWithCount(int count) {
    return Intl.message(
      '$count Telegram ${Intl.plural(count, one: 'Star', other: 'Stars')}',
      name: 'starsWithCount',
      desc: '',
      args: [count],
    );
  }

  /// `Video chat invitation`
  String get videoChatInvitation {
    return Intl.message(
      'Video chat invitation',
      name: 'videoChatInvitation',
      desc: '',
      args: [],
    );
  }

  /// `Location`
  String get location {
    return Intl.message(
      'Location',
      name: 'location',
      desc: 'in context of geography',
      args: [],
    );
  }

  /// `Payment was successful`
  String get paymentSuccessful {
    return Intl.message(
      'Payment was successful',
      name: 'paymentSuccessful',
      desc:
          'don\'t worry, it isn\'t paid Watchgram moment, it\'s the message sent after you\'ve paid an invoice in bot',
      args: [],
    );
  }

  /// `Send`
  String get send {
    return Intl.message(
      'Send',
      name: 'send',
      desc: '',
      args: [],
    );
  }

  /// `Paid media`
  String get paidMedia {
    return Intl.message(
      'Paid media',
      name: 'paidMedia',
      desc: '',
      args: [],
    );
  }

  /// `Payment was refunded`
  String get paymentRefunded {
    return Intl.message(
      'Payment was refunded',
      name: 'paymentRefunded',
      desc: '',
      args: [],
    );
  }

  /// `Photo`
  String get photo {
    return Intl.message(
      'Photo',
      name: 'photo',
      desc: '',
      args: [],
    );
  }

  /// `Video`
  String get video {
    return Intl.message(
      'Video',
      name: 'video',
      desc: '',
      args: [],
    );
  }

  /// `Voice note ({time})`
  String voiceNoteWithTime(String time) {
    return Intl.message(
      'Voice note ($time)',
      name: 'voiceNoteWithTime',
      desc: '',
      args: [time],
    );
  }

  /// `Video note ({time})`
  String videoNoteWithTime(String time) {
    return Intl.message(
      'Video note ($time)',
      name: 'videoNoteWithTime',
      desc: '',
      args: [time],
    );
  }

  /// `Video chat ({time})`
  String videoChatWithTime(String time) {
    return Intl.message(
      'Video chat ($time)',
      name: 'videoChatWithTime',
      desc: '',
      args: [time],
    );
  }

  /// `Message was pinned`
  String get messageWasPinned {
    return Intl.message(
      'Message was pinned',
      name: 'messageWasPinned',
      desc: '',
      args: [],
    );
  }

  /// `Poll`
  String get poll {
    return Intl.message(
      'Poll',
      name: 'poll',
      desc: '',
      args: [],
    );
  }

  /// `Premium gift code`
  String get premiumGiftCode {
    return Intl.message(
      'Premium gift code',
      name: 'premiumGiftCode',
      desc: '',
      args: [],
    );
  }

  /// `Giveaway`
  String get giveaway {
    return Intl.message(
      'Giveaway',
      name: 'giveaway',
      desc: '',
      args: [],
    );
  }

  /// `Giveaway winners`
  String get giveawayWinners {
    return Intl.message(
      'Giveaway winners',
      name: 'giveawayWinners',
      desc: '',
      args: [],
    );
  }

  /// `Giveaway finished`
  String get giveawayFinished {
    return Intl.message(
      'Giveaway finished',
      name: 'giveawayFinished',
      desc: '',
      args: [],
    );
  }

  /// `Proximity alert`
  String get proximityAlert {
    return Intl.message(
      'Proximity alert',
      name: 'proximityAlert',
      desc:
          'Message content. TDLib description: A user in the chat came within proximity alert range.',
      args: [],
    );
  }

  /// `Screenshot was taken`
  String get screenshotWasTaken {
    return Intl.message(
      'Screenshot was taken',
      name: 'screenshotWasTaken',
      desc: '',
      args: [],
    );
  }

  /// `{emoji} Sticker`
  String stickerPlainTexted(String emoji) {
    return Intl.message(
      '$emoji Sticker',
      name: 'stickerPlainTexted',
      desc: '',
      args: [emoji],
    );
  }

  /// `Suggested avatar`
  String get suggestedAvatar {
    return Intl.message(
      'Suggested avatar',
      name: 'suggestedAvatar',
      desc: '',
      args: [],
    );
  }

  /// `Story`
  String get story {
    return Intl.message(
      'Story',
      name: 'story',
      desc: '',
      args: [],
    );
  }

  /// `Unsupported`
  String get unsupported {
    return Intl.message(
      'Unsupported',
      name: 'unsupported',
      desc: '',
      args: [],
    );
  }

  /// `Shared users`
  String get sharedUsers {
    return Intl.message(
      'Shared users',
      name: 'sharedUsers',
      desc:
          'Message content. TDLib description: The current user shared users, which were requested by the bot.',
      args: [],
    );
  }

  /// `New video chat`
  String get newVideoChat {
    return Intl.message(
      'New video chat',
      name: 'newVideoChat',
      desc: '',
      args: [],
    );
  }

  /// `Scheduled video chat`
  String get scheduledVideoChat {
    return Intl.message(
      'Scheduled video chat',
      name: 'scheduledVideoChat',
      desc: '',
      args: [],
    );
  }

  /// `Change theme`
  String get changedTheme {
    return Intl.message(
      'Change theme',
      name: 'changedTheme',
      desc: '',
      args: [],
    );
  }

  /// `Telegram Passport`
  String get tgPassport {
    return Intl.message(
      'Telegram Passport',
      name: 'tgPassport',
      desc:
          'Almost unknown Telegram service which can help you easily share your legal data. I think this is a kind of brand name, so this thing is untranslatable',
      args: [],
    );
  }

  /// `You`
  String get you {
    return Intl.message(
      'You',
      name: 'you',
      desc: '',
      args: [],
    );
  }

  /// `Draft: `
  String get draftPrefix {
    return Intl.message(
      'Draft: ',
      name: 'draftPrefix',
      desc: 'Don\'t forget about space at the end of the string',
      args: [],
    );
  }

  /// `All chats`
  String get chatListHeaderMain {
    return Intl.message(
      'All chats',
      name: 'chatListHeaderMain',
      desc: '',
      args: [],
    );
  }

  /// `Archive`
  String get chatListHeaderArchive {
    return Intl.message(
      'Archive',
      name: 'chatListHeaderArchive',
      desc: '',
      args: [],
    );
  }

  /// `Folder`
  String get chatListHeaderFolder {
    return Intl.message(
      'Folder',
      name: 'chatListHeaderFolder',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message(
      'Error',
      name: 'error',
      desc:
          'Placeholder text used in cases when something wrong happened (for example, chat preview loading error) and we need to report that for user',
      args: [],
    );
  }

  /// `{count, plural, one{second} other{seconds}}`
  String secondsCountPlural(int count) {
    return Intl.plural(
      count,
      one: 'second',
      other: 'seconds',
      name: 'secondsCountPlural',
      desc: 'Used while printing durations',
      args: [count],
    );
  }

  /// `Contact: {name}`
  String contactPrefix(String name) {
    return Intl.message(
      'Contact: $name',
      name: 'contactPrefix',
      desc: '',
      args: [name],
    );
  }

  /// `Audio: {title}`
  String audioPrefix(String title) {
    return Intl.message(
      'Audio: $title',
      name: 'audioPrefix',
      desc: '',
      args: [title],
    );
  }

  /// `[Video] {caption}`
  String videoPrefix(String caption) {
    return Intl.message(
      '[Video] $caption',
      name: 'videoPrefix',
      desc: '',
      args: [caption],
    );
  }

  /// `[Photo] {caption}`
  String photoPrefix(String caption) {
    return Intl.message(
      '[Photo] $caption',
      name: 'photoPrefix',
      desc: '',
      args: [caption],
    );
  }

  /// `[Document] {caption}`
  String documentPrefix(String caption) {
    return Intl.message(
      '[Document] $caption',
      name: 'documentPrefix',
      desc: '',
      args: [caption],
    );
  }

  /// `[Poll] {caption}`
  String pollPrefix(String caption) {
    return Intl.message(
      '[Poll] $caption',
      name: 'pollPrefix',
      desc: '',
      args: [caption],
    );
  }

  /// `Contact`
  String get contact {
    return Intl.message(
      'Contact',
      name: 'contact',
      desc: 'In context of phone contact',
      args: [],
    );
  }

  /// `Invoice`
  String get invoice {
    return Intl.message(
      'Invoice',
      name: 'invoice',
      desc: '',
      args: [],
    );
  }

  /// `Voice note`
  String get voiceNote {
    return Intl.message(
      'Voice note',
      name: 'voiceNote',
      desc: '',
      args: [],
    );
  }

  /// `Video note`
  String get videoNote {
    return Intl.message(
      'Video note',
      name: 'videoNote',
      desc: '',
      args: [],
    );
  }

  /// `Hidden content`
  String get hiddenContent {
    return Intl.message(
      'Hidden content',
      name: 'hiddenContent',
      desc: '',
      args: [],
    );
  }

  /// `{count} forwarded {count, plural, one{message} other{messages}}`
  String forwardedMessagesPlural(int count) {
    return Intl.message(
      '$count forwarded ${Intl.plural(count, one: 'message', other: 'messages')}',
      name: 'forwardedMessagesPlural',
      desc: '',
      args: [count],
    );
  }

  /// `Album`
  String get album {
    return Intl.message(
      'Album',
      name: 'album',
      desc: '',
      args: [],
    );
  }

  /// `Calls`
  String get calls {
    return Intl.message(
      'Calls',
      name: 'calls',
      desc: '',
      args: [],
    );
  }

  /// `Messages`
  String get messages {
    return Intl.message(
      'Messages',
      name: 'messages',
      desc: '',
      args: [],
    );
  }

  /// `Secret chats`
  String get secretChats {
    return Intl.message(
      'Secret chats',
      name: 'secretChats',
      desc: '',
      args: [],
    );
  }

  /// `New secret chat has been created`
  String get notificationNewSecretChat {
    return Intl.message(
      'New secret chat has been created',
      name: 'notificationNewSecretChat',
      desc: '',
      args: [],
    );
  }

  /// `{count} unread {count, plural, one{mention} other{mentions}}`
  String notificationMentions(int count) {
    return Intl.message(
      '$count unread ${Intl.plural(count, one: 'mention', other: 'mentions')}',
      name: 'notificationMentions',
      desc: '',
      args: [count],
    );
  }

  /// `{count} unread {count, plural, one{message} other{messages}}`
  String notificationMessages(int count) {
    return Intl.message(
      '$count unread ${Intl.plural(count, one: 'message', other: 'messages')}',
      name: 'notificationMessages',
      desc: '',
      args: [count],
    );
  }

  /// `{count} incoming {count, plural, one{call} other{calls}}`
  String notificationCalls(int count) {
    return Intl.message(
      '$count incoming ${Intl.plural(count, one: 'call', other: 'calls')}',
      name: 'notificationCalls',
      desc: '',
      args: [count],
    );
  }

  /// `Other`
  String get notificationsChannelOther {
    return Intl.message(
      'Other',
      name: 'notificationsChannelOther',
      desc: '',
      args: [],
    );
  }

  /// `All notifications which do not contain messages or mentions`
  String get notificationsChannelOtherDesc {
    return Intl.message(
      'All notifications which do not contain messages or mentions',
      name: 'notificationsChannelOtherDesc',
      desc: '',
      args: [],
    );
  }

  /// `Mentions`
  String get notificationsChannelMentions {
    return Intl.message(
      'Mentions',
      name: 'notificationsChannelMentions',
      desc: '',
      args: [],
    );
  }

  /// `All your mentions from group chats`
  String get notificationsChannelMentionsDesc {
    return Intl.message(
      'All your mentions from group chats',
      name: 'notificationsChannelMentionsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Messages`
  String get notificationsChannelMessages {
    return Intl.message(
      'Messages',
      name: 'notificationsChannelMessages',
      desc: '',
      args: [],
    );
  }

  /// `All new messages in chats where you've enabled notifications (both group and personal ones)`
  String get notificationsChannelMessagesDesc {
    return Intl.message(
      'All new messages in chats where you\'ve enabled notifications (both group and personal ones)',
      name: 'notificationsChannelMessagesDesc',
      desc: '',
      args: [],
    );
  }

  /// `Channels`
  String get notificationsChannelChannels {
    return Intl.message(
      'Channels',
      name: 'notificationsChannelChannels',
      desc: '',
      args: [],
    );
  }

  /// `Groups`
  String get notificationsChannelGroups {
    return Intl.message(
      'Groups',
      name: 'notificationsChannelGroups',
      desc: '',
      args: [],
    );
  }

  /// `Private chats`
  String get notificationsChannelPrivateChats {
    return Intl.message(
      'Private chats',
      name: 'notificationsChannelPrivateChats',
      desc: '',
      args: [],
    );
  }

  /// `Saved Messages`
  String get templateTitleSavedMessages {
    return Intl.message(
      'Saved Messages',
      name: 'templateTitleSavedMessages',
      desc: '',
      args: [],
    );
  }

  /// `Replies`
  String get templateTitleRepliesBot {
    return Intl.message(
      'Replies',
      name: 'templateTitleRepliesBot',
      desc: '',
      args: [],
    );
  }

  /// `Unsupported message type:\n`
  String get messageContentUnsupported {
    return Intl.message(
      'Unsupported message type:\n',
      name: 'messageContentUnsupported',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load chat: {error}`
  String chatBlocLoadingError(String error) {
    return Intl.message(
      'Failed to load chat: $error',
      name: 'chatBlocLoadingError',
      desc: '',
      args: [error],
    );
  }

  /// `Message {id} was not found`
  String chatViewMessageNotFoundError(int id) {
    return Intl.message(
      'Message $id was not found',
      name: 'chatViewMessageNotFoundError',
      desc: '',
      args: [id],
    );
  }

  /// `Loading message...`
  String get loadingMessage {
    return Intl.message(
      'Loading message...',
      name: 'loadingMessage',
      desc: '',
      args: [],
    );
  }

  /// `Story ({time})`
  String storyWithDuration(String time) {
    return Intl.message(
      'Story ($time)',
      name: 'storyWithDuration',
      desc: '',
      args: [time],
    );
  }

  /// `Someone`
  String get someone {
    return Intl.message(
      'Someone',
      name: 'someone',
      desc: '',
      args: [],
    );
  }

  /// `Something`
  String get something {
    return Intl.message(
      'Something',
      name: 'something',
      desc: '',
      args: [],
    );
  }

  /// `Accounts`
  String get accounts {
    return Intl.message(
      'Accounts',
      name: 'accounts',
      desc: '',
      args: [],
    );
  }

  /// `Add account`
  String get addAccount {
    return Intl.message(
      'Add account',
      name: 'addAccount',
      desc: '',
      args: [],
    );
  }

  /// `Log out`
  String get logout {
    return Intl.message(
      'Log out',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `Interface`
  String get interface {
    return Intl.message(
      'Interface',
      name: 'interface',
      desc: '',
      args: [],
    );
  }

  /// `Appearance`
  String get colorScheme {
    return Intl.message(
      'Appearance',
      name: 'colorScheme',
      desc: '',
      args: [],
    );
  }

  /// `Watch screen shape`
  String get watchShape {
    return Intl.message(
      'Watch screen shape',
      name: 'watchShape',
      desc: '',
      args: [],
    );
  }

  /// `Inteface scale`
  String get uiScale {
    return Intl.message(
      'Inteface scale',
      name: 'uiScale',
      desc: '',
      args: [],
    );
  }

  /// `About app`
  String get aboutApp {
    return Intl.message(
      'About app',
      name: 'aboutApp',
      desc: '',
      args: [],
    );
  }

  /// `Storage`
  String get storage {
    return Intl.message(
      'Storage',
      name: 'storage',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `Messaging`
  String get messaging {
    return Intl.message(
      'Messaging',
      name: 'messaging',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `UX/UI designer`
  String get roleDesigner {
    return Intl.message(
      'UX/UI designer',
      name: 'roleDesigner',
      desc: '',
      args: [],
    );
  }

  /// `Founder & developer`
  String get roleFounder {
    return Intl.message(
      'Founder & developer',
      name: 'roleFounder',
      desc: '',
      args: [],
    );
  }

  /// `Crowdin translators`
  String get roleTranslatorsTitle {
    return Intl.message(
      'Crowdin translators',
      name: 'roleTranslatorsTitle',
      desc: '',
      args: [],
    );
  }

  /// `All of our translators!`
  String get roleTranslators {
    return Intl.message(
      'All of our translators!',
      name: 'roleTranslators',
      desc: '',
      args: [],
    );
  }

  /// `Version {version} ({codename})`
  String appVersion(int version, String codename) {
    return Intl.message(
      'Version $version ($codename)',
      name: 'appVersion',
      desc: '',
      args: [version, codename],
    );
  }

  /// `Powered by TDLib {version}`
  String poweredByTdlib(String version) {
    return Intl.message(
      'Powered by TDLib $version',
      name: 'poweredByTdlib',
      desc: '',
      args: [version],
    );
  }

  /// `Official channel`
  String get officialChannel {
    return Intl.message(
      'Official channel',
      name: 'officialChannel',
      desc: '',
      args: [],
    );
  }

  /// `News and updates`
  String get channelDescription {
    return Intl.message(
      'News and updates',
      name: 'channelDescription',
      desc: '',
      args: [],
    );
  }

  /// `Performance`
  String get sectionPerformance {
    return Intl.message(
      'Performance',
      name: 'sectionPerformance',
      desc: '',
      args: [],
    );
  }

  /// `Appearance`
  String get sectionAppearance {
    return Intl.message(
      'Appearance',
      name: 'sectionAppearance',
      desc: '',
      args: [],
    );
  }

  /// `Disable chat cleanup`
  String get disableChatOptimizations {
    return Intl.message(
      'Disable chat cleanup',
      name: 'disableChatOptimizations',
      desc: '',
      args: [],
    );
  }

  /// `Do not cleanup invisible messages in chats`
  String get disableChatOptimizationsDesc {
    return Intl.message(
      'Do not cleanup invisible messages in chats',
      name: 'disableChatOptimizationsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Pre-render all messages`
  String get prerenderAllMessages {
    return Intl.message(
      'Pre-render all messages',
      name: 'prerenderAllMessages',
      desc: '',
      args: [],
    );
  }

  /// `May help with jumping messages list issue`
  String get prerenderAllMessagesDesc {
    return Intl.message(
      'May help with jumping messages list issue',
      name: 'prerenderAllMessagesDesc',
      desc: '',
      args: [],
    );
  }

  /// `Disable small avatars`
  String get disableMicroAvatars {
    return Intl.message(
      'Disable small avatars',
      name: 'disableMicroAvatars',
      desc: '',
      args: [],
    );
  }

  /// `The ones nearby user names`
  String get disableMicroAvatarsDesc {
    return Intl.message(
      'The ones nearby user names',
      name: 'disableMicroAvatarsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Disable avatars`
  String get disableProfileAvatars {
    return Intl.message(
      'Disable avatars',
      name: 'disableProfileAvatars',
      desc: '',
      args: [],
    );
  }

  /// `Shown in chat lists`
  String get disableProfileAvatarsDesc {
    return Intl.message(
      'Shown in chat lists',
      name: 'disableProfileAvatarsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Other apps`
  String get storageNonWatchgram {
    return Intl.message(
      'Other apps',
      name: 'storageNonWatchgram',
      desc: '',
      args: [],
    );
  }

  /// `Free space`
  String get storageFreeSpace {
    return Intl.message(
      'Free space',
      name: 'storageFreeSpace',
      desc: '',
      args: [],
    );
  }

  /// `Watchgram data`
  String get storageWatchgramData {
    return Intl.message(
      'Watchgram data',
      name: 'storageWatchgramData',
      desc: '',
      args: [],
    );
  }

  /// `Optimize storage`
  String get optimizeStorageUsage {
    return Intl.message(
      'Optimize storage',
      name: 'optimizeStorageUsage',
      desc: '',
      args: [],
    );
  }

  /// `Optimizing...`
  String get optmizing {
    return Intl.message(
      'Optimizing...',
      name: 'optmizing',
      desc: '',
      args: [],
    );
  }

  /// `Folder is empty`
  String get folderIsEmpty {
    return Intl.message(
      'Folder is empty',
      name: 'folderIsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get runInBackground {
    return Intl.message(
      'Notifications',
      name: 'runInBackground',
      desc: '',
      args: [],
    );
  }

  /// `Enable Firebase service`
  String get runInBackgroundDesc {
    return Intl.message(
      'Enable Firebase service',
      name: 'runInBackgroundDesc',
      desc: '',
      args: [],
    );
  }

  /// `Send file`
  String get sendFile {
    return Intl.message(
      'Send file',
      name: 'sendFile',
      desc: '',
      args: [],
    );
  }

  /// `Pick a sticker`
  String get sendMediaStickerTitle {
    return Intl.message(
      'Pick a sticker',
      name: 'sendMediaStickerTitle',
      desc: '',
      args: [],
    );
  }

  /// `Pick a GIF`
  String get sendMediaGIFTitle {
    return Intl.message(
      'Pick a GIF',
      name: 'sendMediaGIFTitle',
      desc: '',
      args: [],
    );
  }

  /// `Pick a photo`
  String get sendMediaPhotoTitle {
    return Intl.message(
      'Pick a photo',
      name: 'sendMediaPhotoTitle',
      desc: '',
      args: [],
    );
  }

  /// `Record voice note`
  String get sendVoiceMessageTitle {
    return Intl.message(
      'Record voice note',
      name: 'sendVoiceMessageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Type a message`
  String get sendTextMessageTitle {
    return Intl.message(
      'Type a message',
      name: 'sendTextMessageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Group info`
  String get chatInfoGroup {
    return Intl.message(
      'Group info',
      name: 'chatInfoGroup',
      desc: '',
      args: [],
    );
  }

  /// `Bot info`
  String get chatInfoBot {
    return Intl.message(
      'Bot info',
      name: 'chatInfoBot',
      desc: '',
      args: [],
    );
  }

  /// `Channel info`
  String get chatInfoChannel {
    return Intl.message(
      'Channel info',
      name: 'chatInfoChannel',
      desc: '',
      args: [],
    );
  }

  /// `Profile info`
  String get chatInfoPersonal {
    return Intl.message(
      'Profile info',
      name: 'chatInfoPersonal',
      desc: '',
      args: [],
    );
  }

  /// `Recent stickers`
  String get recentStickers {
    return Intl.message(
      'Recent stickers',
      name: 'recentStickers',
      desc: '',
      args: [],
    );
  }

  /// `Group stickers`
  String get groupStickers {
    return Intl.message(
      'Group stickers',
      name: 'groupStickers',
      desc: '',
      args: [],
    );
  }

  /// `Media count per row`
  String get stickersCountInRow {
    return Intl.message(
      'Media count per row',
      name: 'stickersCountInRow',
      desc: '',
      args: [],
    );
  }

  /// `Used in media pickers`
  String get stickersCountInRowDesc {
    return Intl.message(
      'Used in media pickers',
      name: 'stickersCountInRowDesc',
      desc: '',
      args: [],
    );
  }

  /// `Message`
  String get notificationActionReplyHint {
    return Intl.message(
      'Message',
      name: 'notificationActionReplyHint',
      desc: '',
      args: [],
    );
  }

  /// `Mark as read`
  String get notificationActionMarkAsRead {
    return Intl.message(
      'Mark as read',
      name: 'notificationActionMarkAsRead',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'af'),
      Locale.fromSubtags(languageCode: 'ar'),
      Locale.fromSubtags(languageCode: 'be'),
      Locale.fromSubtags(languageCode: 'ca'),
      Locale.fromSubtags(languageCode: 'cs'),
      Locale.fromSubtags(languageCode: 'da'),
      Locale.fromSubtags(languageCode: 'de'),
      Locale.fromSubtags(languageCode: 'el'),
      Locale.fromSubtags(languageCode: 'es'),
      Locale.fromSubtags(languageCode: 'fi'),
      Locale.fromSubtags(languageCode: 'fr'),
      Locale.fromSubtags(languageCode: 'he'),
      Locale.fromSubtags(languageCode: 'hu'),
      Locale.fromSubtags(languageCode: 'it'),
      Locale.fromSubtags(languageCode: 'ja'),
      Locale.fromSubtags(languageCode: 'kk'),
      Locale.fromSubtags(languageCode: 'ko'),
      Locale.fromSubtags(languageCode: 'nl'),
      Locale.fromSubtags(languageCode: 'no'),
      Locale.fromSubtags(languageCode: 'pl'),
      Locale.fromSubtags(languageCode: 'pt'),
      Locale.fromSubtags(languageCode: 'ro'),
      Locale.fromSubtags(languageCode: 'ru'),
      Locale.fromSubtags(languageCode: 'sr'),
      Locale.fromSubtags(languageCode: 'sv'),
      Locale.fromSubtags(languageCode: 'tr'),
      Locale.fromSubtags(languageCode: 'uk'),
      Locale.fromSubtags(languageCode: 'vi'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
