/*
 * Copyright (C) Roman Rikhter <teledurak@gmail.com>, 2024
 * This program comes with ABSOLUTELY NO WARRANTY;
 * This is free software, and you are welcome to redistribute it under certain conditions;
 *
 * See /LICENSE for more details.
 */

import 'package:handy_tdlib/api.dart' as td;
import 'package:watchgram/src/common/misc/localizations.dart';
import 'package:watchgram/src/common/misc/strings.dart';
import 'package:watchgram/src/common/tdlib/extensions/misc/display.dart';

extension StringMessageContent on td.MessageContent {
  Future<String> get plainText async {
    final l = AppLocalizations.current;
    return switch (this) {
      td.MessageAnimatedEmoji(emoji: final emoji) => emoji,
      td.MessageAnimation() => l.gif,
      td.MessageAudio(audio: final audio) => l.audioPrefix(audio.displayTitle),
      td.MessageBasicGroupChatCreate() => l.groupWasCreated,
      td.MessageBotWriteAccessAllowed() => l.botWriteAccessAllowed,
      td.MessageCall(duration: final duration) =>
        l.callWithTime(duration.durationFromSeconds),
      td.MessageChatAddMembers(memberUserIds: final ids) =>
        l.chatMembersWereAdded(await getUserDisplayName(ids.first)),
      td.MessageChatBoost() => l.youHaveBoostedChat,
      td.MessageChatChangePhoto() => l.avatarWasChanged,
      td.MessageChatChangeTitle() => l.titleWasChanged,
      td.MessageChatDeleteMember(userId: final userId) =>
        l.userHasLeft(await getUserDisplayName(userId)),
      td.MessageChatDeletePhoto() => l.avatarWasDeleted,
      td.MessageChatJoinByLink() => l.someoneJoinedViaLink,
      td.MessageChatJoinByRequest() => l.someoneJoinedByRequest,
      td.MessageChatSetBackground() => l.bgWasChanged,
      td.MessageChatSetMessageAutoDeleteTime() => l.messageTtlChanged,
      td.MessageChatSetTheme() => l.changedTheme,
      td.MessageChatShared() => l.chatWasShared,
      td.MessageChatUpgradeFrom() => l.upgradedToSupergroup,
      td.MessageChatUpgradeTo() => l.upgradedToSupergroup,
      td.MessageContact(contact: final contact) =>
        l.contactPrefix(squashName(contact.firstName, contact.lastName)),
      td.MessageContactRegistered() => l.hasJoinedTelegram,
      td.MessageCustomServiceAction(text: final text) => text,
      td.MessageDice(emoji: final emoji) => emoji,
      td.MessageDocument(caption: final caption) =>
        caption.text.isEmpty ? l.document : l.documentPrefix(caption.text),
      td.MessageExpiredPhoto() => l.expiredPhoto,
      td.MessageExpiredVideo() => l.expiredVideo,
      td.MessageExpiredVideoNote() => l.expiredVideoNote,
      td.MessageExpiredVoiceNote() => l.expiredVoiceNote,
      td.MessageForumTopicCreated(name: final name) => l.newForumTopic(name),
      td.MessageForumTopicEdited(name: final name) => l.editedForumTopic(name),
      td.MessageForumTopicIsClosedToggled(isClosed: final closed) =>
        closed ? l.topicWasClosed : l.topicWasOpened,
      td.MessageForumTopicIsHiddenToggled(isHidden: final hidden) =>
        hidden ? l.topicWasHidden : l.topicWasShown,
      td.MessageGame(game: final game) => game.title,
      td.MessageGameScore(score: final score) => l.scoredSomeScoreInGame(score),
      td.MessageGiftedPremium(monthCount: final count) =>
        l.premiumWithMonthsCount(count),
      td.MessageInviteVideoChatParticipants() => l.videoChatInvitation,
      td.MessageInvoice(productInfo: final pi) => pi.title,
      td.MessageLocation() => l.location,
      td.MessagePassportDataSent() => l.tgPassport,
      td.MessagePaymentSuccessful() => l.paymentSuccessful,
      td.MessagePhoto(caption: final caption) =>
        caption.text.isNotEmpty ? l.photoPrefix(caption.text) : l.photo,
      td.MessagePinMessage() => l.messageWasPinned,
      td.MessagePoll(poll: final poll) => l.pollPrefix(poll.question.text),
      td.MessagePremiumGiftCode() => l.premiumGiftCode,
      td.MessageGiveaway() => l.giveaway,
      td.MessageGiveawayCompleted() => l.giveawayFinished,
      td.MessageGiveawayCreated() => l.giveaway,
      td.MessageGiveawayWinners() => l.giveawayWinners,
      td.MessageGiveawayPrizeStars() => l.giveaway,
      td.MessageProximityAlertTriggered() => l.proximityAlert,
      td.MessageScreenshotTaken() => l.screenshotWasTaken,
      td.MessageSticker(sticker: final sticker) =>
        l.stickerPlainTexted(sticker.emoji),
      td.MessageStory() => l.story,
      td.MessageSuggestProfilePhoto() => l.suggestedAvatar,
      td.MessageSupergroupChatCreate() => l.groupWasCreated,
      td.MessageText(text: final text) => text.text,
      td.MessageUsersShared() => l.sharedUsers,
      td.MessageVenue() => l.location,
      td.MessageVideo(caption: final caption) =>
        caption.text.isEmpty ? l.video : l.videoPrefix(caption.text),
      td.MessageVideoChatEnded(duration: final duration) =>
        l.videoChatWithTime(duration.durationFromSeconds),
      td.MessageVideoChatScheduled() => l.scheduledVideoChat,
      td.MessageVideoChatStarted() => l.newVideoChat,
      td.MessageVideoNote(videoNote: final vn) =>
        l.videoNoteWithTime(vn.duration.durationFromSeconds),
      td.MessageVoiceNote(voiceNote: final vn) =>
        l.voiceNoteWithTime(vn.duration.durationFromSeconds),
      td.MessageWebAppDataSent() ||
      td.MessageWebAppDataReceived() ||
      td.MessagePassportDataReceived() ||
      td.MessageUnsupported() ||
      td.MessagePaymentSuccessfulBot() =>
        l.unsupported,
      td.MessagePaidMedia() => l.paidMedia,
      td.MessagePaymentRefunded() => l.paymentRefunded,
      td.MessageGiftedStars(starCount: final starCount) =>
        l.starsWithCount(starCount)
    };
  }

  String get plainTextSync {
    final l = AppLocalizations.current;
    return switch (this) {
      td.MessageAnimatedEmoji(emoji: final emoji) => emoji,
      td.MessageAnimation() => l.gif,
      td.MessageAudio(audio: final audio) => l.audioPrefix(audio.displayTitle),
      td.MessageBasicGroupChatCreate() => l.groupWasCreated,
      td.MessageBotWriteAccessAllowed() => l.botWriteAccessAllowed,
      td.MessageCall(duration: final duration) =>
        l.callWithTime(duration.durationFromSeconds),
      td.MessageChatAddMembers() => l.chatMembersWereAdded(l.someone),
      td.MessageChatBoost() => l.youHaveBoostedChat,
      td.MessageChatChangePhoto() => l.avatarWasChanged,
      td.MessageChatChangeTitle() => l.titleWasChanged,
      td.MessageChatDeleteMember() => l.userHasLeft(l.someone),
      td.MessageChatDeletePhoto() => l.avatarWasDeleted,
      td.MessageChatJoinByLink() => l.someoneJoinedViaLink,
      td.MessageChatJoinByRequest() => l.someoneJoinedByRequest,
      td.MessageChatSetBackground() => l.bgWasChanged,
      td.MessageChatSetMessageAutoDeleteTime() => l.messageTtlChanged,
      td.MessageChatSetTheme() => l.changedTheme,
      td.MessageChatShared() => l.chatWasShared,
      td.MessageChatUpgradeFrom() => l.upgradedToSupergroup,
      td.MessageChatUpgradeTo() => l.upgradedToSupergroup,
      td.MessageContact(contact: final contact) =>
        l.contactPrefix(squashName(contact.firstName, contact.lastName)),
      td.MessageContactRegistered() => l.hasJoinedTelegram,
      td.MessageCustomServiceAction(text: final text) => text,
      td.MessageDice(emoji: final emoji) => emoji,
      td.MessageDocument(caption: final caption) =>
        caption.text.isEmpty ? l.document : l.documentPrefix(caption.text),
      td.MessageExpiredPhoto() => l.expiredPhoto,
      td.MessageExpiredVideo() => l.expiredVideo,
      td.MessageExpiredVideoNote() => l.expiredVideoNote,
      td.MessageExpiredVoiceNote() => l.expiredVoiceNote,
      td.MessageForumTopicCreated(name: final name) => l.newForumTopic(name),
      td.MessageForumTopicEdited(name: final name) => l.editedForumTopic(name),
      td.MessageForumTopicIsClosedToggled(isClosed: final closed) =>
        closed ? l.topicWasClosed : l.topicWasOpened,
      td.MessageForumTopicIsHiddenToggled(isHidden: final hidden) =>
        hidden ? l.topicWasHidden : l.topicWasShown,
      td.MessageGame(game: final game) => game.title,
      td.MessageGameScore(score: final score) => l.scoredSomeScoreInGame(score),
      td.MessageGiftedPremium(monthCount: final count) =>
        l.premiumWithMonthsCount(count),
      td.MessageInviteVideoChatParticipants() => l.videoChatInvitation,
      td.MessageInvoice(productInfo: final pi) => pi.title,
      td.MessageLocation() => l.location,
      td.MessagePassportDataSent() => l.tgPassport,
      td.MessagePaymentSuccessful() => l.paymentSuccessful,
      td.MessagePhoto(caption: final caption) =>
        caption.text.isNotEmpty ? l.photoPrefix(caption.text) : l.photo,
      td.MessagePinMessage() => l.messageWasPinned,
      td.MessagePoll(poll: final poll) => l.pollPrefix(poll.question.text),
      td.MessagePremiumGiftCode() => l.premiumGiftCode,
      td.MessageGiveaway() => l.giveaway,
      td.MessageGiveawayCompleted() => l.giveawayFinished,
      td.MessageGiveawayCreated() => l.giveaway,
      td.MessageGiveawayWinners() => l.giveawayWinners,
      td.MessageGiveawayPrizeStars() => l.giveaway,
      td.MessageProximityAlertTriggered() => l.proximityAlert,
      td.MessageScreenshotTaken() => l.screenshotWasTaken,
      td.MessageSticker(sticker: final sticker) =>
        l.stickerPlainTexted(sticker.emoji),
      td.MessageStory() => l.story,
      td.MessageSuggestProfilePhoto() => l.suggestedAvatar,
      td.MessageSupergroupChatCreate() => l.groupWasCreated,
      td.MessageText(text: final text) => text.text,
      td.MessageUsersShared() => l.sharedUsers,
      td.MessageVenue() => l.location,
      td.MessageVideo(caption: final caption) =>
        caption.text.isEmpty ? l.video : l.videoPrefix(caption.text),
      td.MessageVideoChatEnded(duration: final duration) =>
        l.videoChatWithTime(duration.durationFromSeconds),
      td.MessageVideoChatScheduled() => l.scheduledVideoChat,
      td.MessageVideoChatStarted() => l.newVideoChat,
      td.MessageVideoNote(videoNote: final vn) =>
        l.videoNoteWithTime(vn.duration.durationFromSeconds),
      td.MessageVoiceNote(voiceNote: final vn) =>
        l.voiceNoteWithTime(vn.duration.durationFromSeconds),
      td.MessageWebAppDataSent() ||
      td.MessageWebAppDataReceived() ||
      td.MessagePassportDataReceived() ||
      td.MessageUnsupported() ||
      td.MessagePaymentSuccessfulBot() =>
        l.unsupported,
      td.MessagePaidMedia() => l.paidMedia,
      td.MessagePaymentRefunded() => l.paymentRefunded,
      td.MessageGiftedStars(starCount: final starCount) =>
        l.starsWithCount(starCount)
    };
  }
}
