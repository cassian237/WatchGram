/*
 * Copyright (C) Roman Rikhter <teledurak@gmail.com>, 2024
 * This program comes with ABSOLUTELY NO WARRANTY;
 * This is free software, and you are welcome to redistribute it under certain conditions;
 *
 * See /LICENSE for more details.
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:handy_tdlib/api.dart';
import 'package:watchgram/src/common/tdlib/client/structures/base_provider.dart';
import 'package:watchgram/src/common/tdlib/client/structures/tdlib_toolbox.dart';
import 'package:meta/meta.dart';

abstract class TdlibDataEventsProvider extends TdlibDataProvider
    with ChangeNotifier {
  /// Attached TDLib toolbox
  @protected
  late final TdlibToolbox box;

  /// Updates stream subcription
  @protected
  late final StreamSubscription subscription;

  /// Attach TdlibToolbox to this provider. Child must call super.attach();
  @mustCallSuper
  @override
  FutureOr<void> attach(final TdlibToolbox toolbox) {
    box = toolbox;
    subscription = box.updatesStream.listen(updatesListener);
  }

  /// Detach TdlibToolbox from this provider. Child must call super.attach();
  @mustCallSuper
  @override
  FutureOr<void> detach(final TdlibToolbox toolbox) {
    subscription.cancel();
  }

  /// TDLib updates listener
  @mustBeOverridden
  @visibleForOverriding
  FutureOr<void> updatesListener(final TdObject update);
}
