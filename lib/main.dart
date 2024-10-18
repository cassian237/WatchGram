/*
 * Copyright (C) Roman Rikhter <teledurak@gmail.com>, 2024
 * This program comes with ABSOLUTELY NO WARRANTY;
 * This is free software, and you are welcome to redistribute it under certain conditions;
 *
 * See /LICENSE for more details.
 */

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:watchgram/firebase_options.dart';
import 'package:watchgram/src/common/misc/localizations.dart';
import 'package:watchgram/src/common/native/channel.dart';
import 'package:watchgram/src/common/settings/entries.dart';
import 'package:watchgram/src/common/settings/manager.dart';
import 'package:watchgram/src/common/tdlib/services/firebase/firebase.dart';
import 'package:watchgram/src/main.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting();

  await loadLocalizations();
  await Settings.start();
  await HandyNatives().init();

  if (Settings().get(SettingsEntries.runInBackground)) {
    FirebaseMessaging.onBackgroundMessage(
      TdlibFirebaseService.backgroundHandler,
    );
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const HandyGram());
}
