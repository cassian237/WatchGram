/*
 * Copyright (C) Roman Rikhter <teledurak@gmail.com>, 2024
 * This program comes with ABSOLUTELY NO WARRANTY;
 * This is free software, and you are welcome to redistribute it under certain conditions;
 *
 * See /LICENSE for more details.
 */

import 'package:watchgram/src/common/log/log.dart';
import 'dart:async';
import 'package:watchgram/src/common/tdlib/client/structures/tdlib_toolbox.dart';
import 'package:watchgram/src/common/tdlib/client/td/parameters.dart';
import 'package:watchgram/src/common/tdlib/client/td/tdlib_client.dart';
import 'package:watchgram/src/common/tdlib/providers/authorization_state/authorization_states.dart';
import 'package:watchgram/src/common/tdlib/providers/providers_combine.dart';
import 'package:watchgram/src/common/tdlib/services/services_combine.dart';

class TdlibUserManager {
  static const String tag = "TdlibUserManager";

  final bool isLite, isFromPush;
  late final TdlibProvidersCombine providers = TdlibProvidersCombine(isLite);
  late final TdlibServicesCombine services = TdlibServicesCombine(isLite);

  late final TdlibClient _client;
  late final TdlibToolbox _box;

  late final TdlibParameters parameters;
  late final int clientId;

  StreamSubscription? _sub;

  final int databaseId;

  Future<void> _start([final int? predefinedClientId]) async {
    _client = await TdlibClient.start(databaseId, predefinedClientId);
    clientId = _client.clientId;

    parameters = await TdlibParameters.init(databaseId);
    _box = TdlibToolbox(
      invoke: _client.invoke,
      updatesStream: _client.updates,
      clientId: clientId,
    );

    await providers.attach(_box);
    _client.providersReady();
    await services.attach(_box);

    _sub = providers.authorizationState.states.listen(_listenToAuthState);
  }

  void _listenToAuthState(AuthorizationState state) async {
    switch (state) {
      case AuthorizationStateLoading(sentTdlibParameters: final ready):
        // td.ProcessPush automatically authorizes this client
       // if (isFromPush) break;

        if (!ready) break;
        await providers.onTdlibReady();
        await services.onTdlibReady();
      case AuthorizationStateReady():
        if (isFromPush) {
          await providers.onTdlibReady();
          await services.onTdlibReady();
        }
        await providers.onAuthorized();
        await services.onAuthorized();
      default:
        break;
    }
  }

  Future<void> destroy() async {
    await services.detach(_box);
    await providers.detach(_box);
    await _client.close();
    await _sub?.cancel();

    try {
      await providers.authorizationState
          .waitForState<AuthorizationStateClosed>(Duration(seconds: 5));
    } catch (e) {
      l.e(tag, "Failed to wait for AuthorizationStateClosed: $e");
    }
  }

  static Future<TdlibUserManager> start(int databaseId) async {
    TdlibUserManager m = TdlibUserManager._(databaseId, false, false);
    await m._start();
    return m;
  }

  static Future<TdlibUserManager> startLite({
    required int databaseId,
    required int clientId,
    required bool isFromPush,
  }) async {
    TdlibUserManager m = TdlibUserManager._(databaseId, true, isFromPush);
    await m._start(clientId);
    return m;
  }

  TdlibUserManager._(this.databaseId, this.isLite, this.isFromPush);
}
