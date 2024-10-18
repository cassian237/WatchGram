/*
 * Copyright (C) Roman Rikhter <teledurak@gmail.com>, 2024
 * This program comes with ABSOLUTELY NO WARRANTY;
 * This is free software, and you are welcome to redistribute it under certain conditions;
 *
 * See /LICENSE for more details.
 */

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:handy_tdlib/api.dart' as td;
import 'package:watchgram/src/common/cubits/colors.dart';
import 'package:watchgram/src/common/cubits/current_account.dart';
import 'package:watchgram/src/common/cubits/text.dart';
import 'package:watchgram/src/common/settings/entries.dart';
import 'package:watchgram/src/common/settings/manager.dart';
import 'package:watchgram/src/common/tdlib/extensions/misc/display.dart';
import 'package:watchgram/src/common/tdlib/extensions/misc/int.dart';
import 'package:watchgram/src/common/tdlib/extensions/misc/minithumbnail.dart';
import 'package:watchgram/src/common/tdlib/extensions/misc/photosize.dart';
import 'package:watchgram/src/components/scaled_sizes.dart';

class MicroAvatar extends StatefulWidget {
  const MicroAvatar({
    super.key,
    required this.sender,
  });

  final td.MessageSender sender;

  @override
  State<MicroAvatar> createState() => _MicroAvatarState();
}

class _MicroAvatarState extends State<MicroAvatar> {
  Widget? _image;

  Future<(int, dynamic)> _getByChatId(int chatId) async {
    final chat = await chatId.asChat;
    if (chat.photo == null) {
      late final td.ChatPhoto? photo;
      late final int priority;
      switch (chat.type) {
        case td.ChatTypeBasicGroup(basicGroupId: final basicGroupId):
          final info = await basicGroupId.asBasicGroupFullInfo;
          photo = info.photo;
          priority = 2;
        case td.ChatTypeSupergroup(supergroupId: final supergroupId):
          final info = await supergroupId.asSupergroupFullInfo;
          photo = info.photo;
          priority = 2;
        case td.ChatTypePrivate(userId: final userId):
        case td.ChatTypeSecret(userId: final userId):
          final info = await userId.asUserFullInfo;
          photo = info.photo;
          priority = 1;
      }
      if (photo != null) {
        return (
          priority,
          //photo.minithumbnail ?? _getSmallestPhotoId(photo.sizes),
          photo.sizes.smallest.photo.id,
        );
      }
    } else {
      //return (2, chat.photo?.minithumbnail ?? chat.photo?.small.id);
      return (2, chat.photo?.small.id);
    }

    return (-1, chat.title);
  }

  Future<dynamic> _getByUserId(int userId) async {
    final user = await userId.asUser;
    final photo = user.profilePhoto;
    if (photo != null) {
      //return photo.minithumbnail ?? photo.small.id;
      return photo.small.id;
    }
    return user.displayName;
  }

  Future<void> _getChatImage() async {
    final stuff = CurrentAccount.providers;

    dynamic photoObj;
    int? priority;
    try {
      switch (widget.sender) {
        case td.MessageSenderChat(chatId: final chatId):
          (priority, photoObj) = await _getByChatId(chatId);
        case td.MessageSenderUser(userId: final userId):
          photoObj = await _getByUserId(userId);
      }
    } catch (_) {
      photoObj = null;
    }

    switch (photoObj) {
      // No photo, chat title has been returned
      case String():
        _image = Container(
          decoration: BoxDecoration(
            color: ColorStyles.active.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              (photoObj.characters.firstOrNull ?? "?").toUpperCase(),
              style: TextStyles.active.labelLarge!.copyWith(
                color: ColorStyles.active.onPrimary,
                height: 1,
              ),
            ),
          ),
        );
      case td.Minithumbnail():
        _image = photoObj.asWidget(
          Sizes.microAvatarDiameter,
          Sizes.microAvatarDiameter / 2,
        );
      case int():
        final file = await stuff.files.download(
          fileId: photoObj,
          synchronous: true,
          priority: priority ?? 2,
        );
        _image = Image.file(
          File(file.local.path),
          width: Sizes.microAvatarDiameter,
          height: Sizes.microAvatarDiameter,
        );
      default:
        _image = Container(
          decoration: BoxDecoration(
            color: ColorStyles.active.error,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.error,
            size: Sizes.microAvatarDiameter * 0.7,
            color: ColorStyles.active.onError,
          ),
        );
    }

    if (mounted && context.mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getChatImage();
  }

  @override
  void didUpdateWidget(covariant MicroAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sender != widget.sender) {
      _getChatImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Settings().get(SettingsEntries.disableMicroAvatars)) {
      return Container();
    }

    return SizedBox.square(
      dimension: Sizes.microAvatarDiameter,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Container(
          decoration: BoxDecoration(
            color: ColorStyles.active.onSurfaceVariant,
          ),
          child: _image,
        ),
      ),
    );
  }
}
