/*
 * Copyright (C) Roman Rikhter <teledurak@gmail.com>, 2024
 * This program comes with ABSOLUTELY NO WARRANTY;
 * This is free software, and you are welcome to redistribute it under certain conditions;
 *
 * See /LICENSE for more details.
 */

import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:handy_tdlib/api.dart' as td;
import 'package:watchgram/src/common/exceptions/tdlib_core_exception.dart';
import 'package:watchgram/src/common/log/log.dart';
import 'package:watchgram/src/common/settings/entries.dart';
import 'package:watchgram/src/common/settings/manager.dart';
import 'package:watchgram/src/common/tdlib/client/management/multi_manager.dart';
import 'package:watchgram/src/common/tdlib/client/management/rx/client.dart';
import 'package:watchgram/src/common/tdlib/client/management/user_manager.dart';
import 'package:watchgram/src/common/tdlib/client/structures/base_service.dart';
import 'package:watchgram/src/common/tdlib/client/structures/tdlib_toolbox.dart';
import 'package:watchgram/src/common/tdlib/providers/templates/attachable_box.dart';
import 'package:watchgram/src/common/tdlib/runner/runner.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

enum FirebaseStatus {
  loading,
  unsupported,
  noPermissions,
  error,
  running,
}

class TdlibFirebaseService extends TdlibService with AttachableBox {
  static const String tag = "TdlibFirebaseService";

  StreamSubscription? _tokenSub;

  static FirebaseStatus status = FirebaseStatus.loading;
  static final StreamController<FirebaseStatus> _statuses =
      StreamController.broadcast();
  static final Stream<FirebaseStatus> statuses = _statuses.stream;

  @pragma('vm:entry-point')
  static Future<void> backgroundHandler(RemoteMessage message) async {
    const tag = "TdlibFirebaseService-BG";
    WidgetsFlutterBinding.ensureInitialized();

    l.d(tag, "Received FCM message ${message.toMap().toString()}", true);

    await Settings.start();

    if (!Settings().get(SettingsEntries.enableNotifications)) {
      l.d(tag, "Notifications are disabled", true);
      return;
    }

    late final TdlibUserManager? user;
    try {
      user = await TdlibRunner.fromFirebase(message);
      if (user == null) {
        l.e(tag, "Couldn't start TDLib", true);
        await TdlibReceiveManager.instance.dispose();
        await _showNewMessageNotification();
        return;
      }
    } catch (e, st) {
      l.e(tag, "Failed to init user: $e\n$st");
      await _showNewMessageNotification();
      return;
    }

    try {
      return user.services.notifications.handleBackgroundPush();
    } catch (e, st) {
      l.e(tag, "Failed to handle push: $e\n$st");
      await _showNewMessageNotification();
      return;
    }
  }

  static Future<void> _showNewMessageNotification() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    // Initialisation pour Android
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Définir les détails de la notification
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'new_message_channel', // ID du canal
      'New message', // Nom du canal
      channelDescription: 'Notifications for new messages',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    // Afficher la notification
    await flutterLocalNotificationsPlugin.show(
      0, // ID de la notification
      'New message', // Titre de la notification
      'You received a new message', // Corps de la notification
      platformChannelSpecifics,
      payload: 'new_message',
    );
  }

  /// Get payload from Firebase notification.
  static String getPayload(RemoteMessage message) {
    final payload = <String, dynamic>{
      "google.sent_time": message.sentTime?.millisecondsSinceEpoch,
    };
    final sound = message.notification?.android?.sound;
    if (sound != null) {
      payload["google.notification.sound"] = sound;
    }
    payload.addAll(message.data);
    return jsonEncode(payload);
  }

  Future<void> _foregroundHandler(RemoteMessage message) {
    final payload = getPayload(message);
    return box!.user.services.notifications.handleForegroundPush(payload);
  }

  Future<void> _registerFCM() async {
    if (!await FirebaseMessaging.instance.isSupported()) {
      l.e(tag, "Firebase is unsupported on this device");
      status = FirebaseStatus.unsupported;
      return;
    }

    final permissions = await FirebaseMessaging.instance.requestPermission();
    if (permissions.authorizationStatus == AuthorizationStatus.denied ||
        permissions.authorizationStatus == AuthorizationStatus.notDetermined) {
      l.w(tag, "User had denied app to send notifications");
      status = FirebaseStatus.noPermissions;
      return;
    }
    l.d(
      tag,
      "Notifications permission: ${permissions.authorizationStatus.name}",
    );

    String? token = await FirebaseMessaging.instance.getToken();
    if (token == null) {
      l.e(tag, "Failed to get Firebase token");
      status = FirebaseStatus.error;
      return;
    }

    _tokenSub = FirebaseMessaging.instance.onTokenRefresh.listen(
      _onFCMTokenChange,
    );

    _registerFCMToken(token);
  }

  void _onFCMTokenChange(String token) async {
    try {
      l.i(tag, "FCM token was changed");
      await _registerFCMToken(token);
    } catch (e) {
      l.e(tag, "Failed to update FCM token: $e");
    }
  }

  Future<void> _registerFCMToken(String token) async {
    List<int> ids = [];
    for (final clientId in TdlibMultiManager.instance.clientIds) {
      if (clientId == box!.clientId) continue;
      final user = TdlibMultiManager.instance.fromClientId(clientId);
      if (user == null) continue;
      final td.User me;
      try {
        me = await user.providers.users.getMe();
      } on TdlibCoreException {
        // may be uninitialized yet
        return;
      }
      ids.add(me.id);
    }

    final receiver = await box!.invoke(
      td.RegisterDevice(
        deviceToken: td.DeviceTokenFirebaseCloudMessaging(
          token: token,
          encrypt: true,
        ),
        otherUserIds: ids,
      ),
      timeout: const Duration(seconds: 4),
    );

    if (receiver is td.TdError) {
      l.e(tag, "Failed to register device: ${receiver.message}");
      status = FirebaseStatus.error;
      return;
    } else if (receiver == null) {
      l.e(tag, "No PushReceiverId. Is your GCM API key right?");
      status = FirebaseStatus.error;
      return;
    } else if (receiver is! td.PushReceiverId) {
      l.e(tag, "Wrong object ${receiver.runtimeType}, expected PushReceiverId");
      status = FirebaseStatus.error;
      return;
    }

    await box!.user.services.notifications.saveReceiverId(receiver.id);
    FirebaseMessaging.onMessage.listen(_foregroundHandler);

    status = FirebaseStatus.running;
    l.d(
      tag,
      "Registered Firebase with receiver ID ${receiver.id} / token $token \nreceiver $receiver",
    );
  }

  @override
  Future<void> onAuthorized() async {
    await _registerFCM();
  }

  @override
  FutureOr<void> detach(TdlibToolbox toolbox) {
    _tokenSub?.cancel();
    return super.detach(toolbox);
  }
}
