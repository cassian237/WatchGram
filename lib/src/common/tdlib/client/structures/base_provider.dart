/*
 * Copyright (C) Roman Rikhter <teledurak@gmail.com>, 2024
 * This program comes with ABSOLUTELY NO WARRANTY;
 * This is free software, and you are welcome to redistribute it under certain conditions;
 *
 * See /LICENSE for more details.
 */

import 'dart:async';

import 'package:watchgram/src/common/tdlib/client/structures/tdlib_toolbox.dart';

/// Base TDLib Data Provider layer class
abstract class TdlibDataProvider {
  /// Attach provider to TdlibClient
  FutureOr<void> attach(final TdlibToolbox toolbox) {}

  /// Detach provider from TdlibClient
  FutureOr<void> detach(final TdlibToolbox toolbox) {}

  /// This function is run when TDLib has received sendTdlibParameters
  FutureOr<void> onTdlibReady() {}

  /// This function is run when TDLib has sent authorizationStateReady
  FutureOr<void> onAuthorized() {}
}
