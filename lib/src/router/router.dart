/*
 * Copyright (C) Roman Rikhter <teledurak@gmail.com>, 2024
 * This program comes with ABSOLUTELY NO WARRANTY;
 * This is free software, and you are welcome to redistribute it under certain conditions;
 *
 * See /LICENSE for more details.
 */

import 'package:handy_tdlib/api.dart' as td;
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:watchgram/src/common/tdlib/client/management/user_manager.dart';
import 'package:watchgram/src/components/messages/content/photo/photo_viewer.dart';
import 'package:watchgram/src/pages/bootstrap/bootstrap.dart';
import 'package:watchgram/src/pages/chat/chat.dart';
import 'package:watchgram/src/pages/chat_send/chat_send.dart';
import 'package:watchgram/src/pages/home/home.dart';
import 'package:watchgram/src/pages/home/settings/main.dart';
import 'package:watchgram/src/pages/home/settings/pages/account.dart';
import 'package:watchgram/src/pages/home/settings/pages/interface.dart';
import 'package:watchgram/src/pages/home/settings/pages/messaging.dart';
import 'package:watchgram/src/pages/home/settings/pages/notifications.dart';
import 'package:watchgram/src/pages/home/settings/pages/storage.dart';
import 'package:watchgram/src/pages/proxy/list/proxy_list.dart';
import 'package:watchgram/src/pages/proxy/single/proxy.dart';
import 'package:watchgram/src/pages/setup/setup.dart';
import 'package:watchgram/src/pages/setup/stages/authorization/authorization.dart';
import 'package:watchgram/src/pages/setup/stages/instruction.dart';

Page _addSwipeToBack(GoRouterState state, Widget child) => CupertinoPage(
      child: child,
      key: ValueKey("${state.pageKey.value}-wrapper"),
    );

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) =>
          _addSwipeToBack(state, const BootstrapPage()),
      routes: [
        GoRoute(
          path: 'authorization',
          pageBuilder: (context, state) => _addSwipeToBack(
            state,
            AuthorizationPage(
              user: state.extra as TdlibUserManager,
              destinationRoute: state.uri.queryParameters['destination'],
            ),
          ),
        ),
        GoRoute(
          path: "proxy",
          pageBuilder: (context, state) => _addSwipeToBack(
            state,
            ProxyPage(
              id: state.uri.queryParameters["id"] != null
                  ? int.parse(state.uri.queryParameters["id"]!)
                  : null,
            ),
          ),
        ),
        GoRoute(
          path: "proxy_list",
          pageBuilder: (context, state) =>
              _addSwipeToBack(state, const ProxyListPage()),
        ),
        GoRoute(
          path: "home",
          pageBuilder: (context, state) => _addSwipeToBack(
            state,
            HomePage(
              openChatId: int.tryParse(
                state.uri.queryParameters["openChatId"] ?? '',
              ),
              openUserId: int.tryParse(
                state.uri.queryParameters["openUserId"] ?? '',
              ),
            ),
          ),
        ),
        GoRoute(
          path: "settings",
          pageBuilder: (context, state) =>
              _addSwipeToBack(state, const SettingsMain()),
          routes: [
            GoRoute(
              path: "account",
              pageBuilder: (context, state) =>
                  _addSwipeToBack(state, const SettingsAccountView()),
            ),
            GoRoute(
              path: "interface",
              pageBuilder: (context, state) =>
                  _addSwipeToBack(state, const SettingsInterfaceView()),
            ),
            GoRoute(
              path: "messaging",
              pageBuilder: (context, state) =>
                  _addSwipeToBack(state, const SettingsMessagingView()),
            ),
            GoRoute(
              path: "notifications",
              pageBuilder: (context, state) =>
                  _addSwipeToBack(state, const SettingsNotificationsView()),
            ),
            GoRoute(
              path: "storage",
              pageBuilder: (context, state) =>
                  _addSwipeToBack(state, const SettingsStorageView()),
            ),
          ],
        ),
        GoRoute(
          path: "chat",
          pageBuilder: (context, state) => _addSwipeToBack(
            state,
            ChatPage(
              id: int.tryParse(state.uri.queryParameters["id"] ?? '') ?? -1,
              focusOnMessageId: int.tryParse(
                state.uri.queryParameters["focusOnMessageId"] ?? '',
              ),
            ),
          ),
          routes: [
            GoRoute(
              path: "send",
              pageBuilder: (context, state) => _addSwipeToBack(
                state,
                ChatSendPage(
                  chatId: int.parse(
                    state.uri.queryParameters["chatId"] ?? '',
                  ),
                  viewId: state.uri.queryParameters["viewId"],
                  replyToMessageId: int.tryParse(
                    state.uri.queryParameters["replyToMessageId"] ?? '',
                  ),
                ),
              ),
            ),
          ],
        ),
        GoRoute(
          path: "setup",
          pageBuilder: (context, state) =>
              _addSwipeToBack(state, const SetupPage()),
          routes: [
            GoRoute(
              path: "qr_instruction",
              pageBuilder: (context, state) =>
                  _addSwipeToBack(state, const QrInstructionPage()),
            )
          ],
        ),
        GoRoute(
          path: "photo/viewer",
          pageBuilder: (context, state) => _addSwipeToBack(
            state,
            PhotoViewer(photo: state.extra as td.Photo),
          ),
        ),
      ],
    ),
  ],
  initialLocation: '/',
);
