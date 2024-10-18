/*
 * Copyright (C) Roman Rikhter <teledurak@gmail.com>, 2024
 * This program comes with ABSOLUTELY NO WARRANTY;
 * This is free software, and you are welcome to redistribute it under certain conditions;
 *
 * See /LICENSE for more details.
 */

import 'dart:async';

import 'package:watchgram/src/common/log/log.dart';
import 'package:watchgram/src/common/tdlib/client/structures/base_service.dart';
import 'package:watchgram/src/common/tdlib/providers/templates/attachable_box.dart';

class TdlibDefaultOptionsService extends TdlibService with AttachableBox {
  static const String tag = "TdlibDefaultOptionsService";

  late final String version;

  final Map<String, dynamic> _options = {
    // For Firebase
    "notification_group_count_max": 10,
    "notification_group_size_max": 10,

    // I'm too lazy to implement Markdown parser
    "always_parse_markdown": true,

    // P.S. they'll still be shown as thumbnails :p
    "disable_animated_emoji": false,

    // "...which significantly reduces disk usage"
    "disable_time_adjustment_protection": true,

    // Why not
    "use_storage_optimizer": true,
  };

  @override
  Future<void> onTdlibReady() async {
    l.d(tag, "Sending options...");
    version = await box?.user.providers.options.get("version");
    for (final option in _options.entries) {
      await box?.user.providers.options.set(option.key, option.value);
    }
  }
}
