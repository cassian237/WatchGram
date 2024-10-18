/*
 * Copyright (C) Roman Rikhter <teledurak@gmail.com>, 2024
 * This program comes with ABSOLUTELY NO WARRANTY;
 * This is free software, and you are welcome to redistribute it under certain conditions;
 *
 * See /LICENSE for more details.
 */

import 'package:handy_tdlib/api.dart';
import 'package:watchgram/src/common/exceptions/handy.dart';

class TdlibCoreException implements HandyException {
  final String message;
  final String module;
  final int? code, clientId;

  factory TdlibCoreException.fromTd(String tag, TdError error) =>
      TdlibCoreException(
        tag,
        error.message,
        clientId: error.clientId,
        code: error.code,
      );

  @override
  String toString() => "TdlibCoreException[$module] $message";

  const TdlibCoreException(
    this.module,
    this.message, {
    this.code,
    this.clientId,
  });
}
