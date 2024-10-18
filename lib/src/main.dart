/*
 * Copyright (C) Roman Rikhter <teledurak@gmail.com>, 2024
 * This program comes with ABSOLUTELY NO WARRANTY;
 * This is free software, and you are welcome to redistribute it under certain conditions;
 *
 * See /LICENSE for more details.
 */

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watchgram/src/app.dart';
import 'package:watchgram/src/common/cubits/colors.dart';
import 'package:watchgram/src/common/cubits/current_account.dart';
import 'package:watchgram/src/common/cubits/scaling.dart';
import 'package:watchgram/src/common/cubits/text.dart';
import 'package:watchgram/src/common/settings/entries.dart';
import 'package:watchgram/src/common/settings/manager.dart';
import 'package:watchgram/src/common/tdlib/client/management/rx/client.dart';

class HandyGram extends StatefulWidget {
  const HandyGram({super.key});

  @override
  State<HandyGram> createState() => _HandyGramState();
}

class _HandyGramState extends State<HandyGram> {
  final AppLifecycleListener _listener = AppLifecycleListener(
    binding: WidgetsBinding.instance,
    onDetach: () => TdlibReceiveManager.instance.dispose(),
    onInactive: () => CurrentAccount.providers.options.set("online", false),
    onResume: () => CurrentAccount.providers.options.set("online", true),
  );

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: CurrentAccount.instance,
        ),
        BlocProvider<Scaling>(create: (context) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            final mq = MediaQuery.of(context);
            Scaling.instance.setSystemScreenResolution(
              mq.size,
              mq.devicePixelRatio,
            );
          });
          Scaling.instance.userScale = Settings().get(SettingsEntries.uiScale);
          return Scaling.instance;
        }),
        BlocProvider<TextStyles>(create: (context) {
          TextStyles.instance.scale = Settings().get(SettingsEntries.textScale);
          return TextStyles.instance;
        }),
        BlocProvider<ColorStyles>(create: (context) {
          try {
            ColorStyles.instance.accentColor =
                Settings().get(SettingsEntries.colorSchemeId);
          } catch (_) {
            /// Fall back to default value
            ColorStyles.instance.accentColor =
                SettingsEntries.colorSchemeId.defaultValue!;
            Settings().put(
              SettingsEntries.colorSchemeId,
              SettingsEntries.colorSchemeId.defaultValue!,
            );
          }
          return ColorStyles.instance;
        }),
      ],
      child: const HandyGramApp(),
    );
  }
}
