/*
 * Copyright (C) Roman Rikhter <teledurak@gmail.com>, 2024
 * This program comes with ABSOLUTELY NO WARRANTY;
 * This is free software, and you are welcome to redistribute it under certain conditions;
 *
 * See /LICENSE for more details.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:watchgram/src/common/cubits/colors.dart';
import 'package:watchgram/src/common/cubits/text.dart';
import 'package:watchgram/src/common/misc/localizations.dart';
import 'package:watchgram/src/common/misc/vectors.dart';
import 'package:watchgram/src/components/controls/text_button.dart';
import 'package:watchgram/src/components/controls/tile_button.dart';
import 'package:watchgram/src/components/scaled_sizes.dart';
import 'package:watchgram/src/pages/setup/bloc.dart';
import 'package:vector_graphics/vector_graphics_compat.dart';
import 'package:watchgram/src/pages/setup/stages/authorization/bloc.dart';

import '../../../common/cubits/scaling.dart';
import 'authorization/views/waitcode.dart';

class SetupWelcomeStageView extends StatelessWidget {
  const SetupWelcomeStageView({super.key, this.state});

  final NetworkState? state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sz = MediaQuery.of(context).size;

    return Scaffold(
      body: BlocBuilder<SetupBloc, SetupState>(
        builder: (context, setupState) {
          return BlocConsumer<AuthorizationBloc, AuthorizationBlocState>(
            listener: (context, authState) {
              if (authState is AuthorizationBlocStateSuccess) {
                // Proceed to the next setup step
                context.read<SetupBloc>().add(const SetupEventAuthorized());
              }
            },
            builder: (context, authState) {
              if (authState is AuthorizationBlocStateWaitingCode) {
                // Show the code entry screen
                return AuthorizationCodeView();
              } else {
                // Default welcome screen UI, which uses setupState
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: sz.height * 0.3125 * Scaling.userFactor,
                              width: sz.width * 0.3125 * Scaling.userFactor,
                              child: switch (setupState) {
                                SetupStateConnecting(state: final state) => switch (state) {
                                  NetworkState.connectingToProxy ||
                                  NetworkState.connectingToServers ||
                                  NetworkState.waitingForNetwork => const Center(
                                    child: SizedBox(
                                      height: 30,
                                      width: 30,
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                },
                                _ => Image.asset(
                                  'assets/images/watchgram_nopad.png',
                                  fit: BoxFit.fill,
                                ),
                              },
                            ),
                            SizedBox(height: Paddings.betweenSimilarElements),
                            Text(
                              switch (setupState) {
                                SetupStateConnecting(state: final state) => switch (state) {
                                  NetworkState.connectingToProxy => l10n.connectionConnectingToProxy,
                                  NetworkState.connectingToServers => l10n.connectionConnecting,
                                  NetworkState.waitingForNetwork => l10n.connectionWaitingForNetwork,
                                },
                                _ => l10n.watchgram,
                              },
                              style: switch (setupState) {
                                SetupStateConnecting(state: final state) => switch (state) {
                                  NetworkState.connectingToProxy ||
                                  NetworkState.connectingToServers ||
                                  NetworkState.waitingForNetwork => TextStyles.active.labelLarge,
                                },
                                _ => TextStyles.active.titleLarge,
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: AnimatedSwitcher(
                        key: const ValueKey<String>("first_setup_get_started"),
                        duration: const Duration(milliseconds: 450),
                        switchOutCurve: Curves.easeInOut,
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return SizeTransition(
                            sizeFactor: animation,
                            child: ScaleTransition(
                              scale: animation,
                              alignment: Alignment.center,
                              child: child,
                            ),
                          );
                        },
                        child: setupState is SetupStateWelcome
                            ? Center(
                          child: TileButton(
                            text: l10n.getStarted,
                            big: false,
                            onTap: () {
                              context.read<AuthorizationBloc>().add(const RequestQrCode());
                              context.read<SetupBloc>().add(const SetupEventGetStarted());
                            },
                          ),
                        )
                            : SizedBox(key: UniqueKey()),
                      ),
                    ),
                   // HandyTextButton(
                   //   text: l10n.proxySettingsButton,
                   //   //onTap: () => GoRouter.of(context).push("/proxy_list"),
                   // ),
                    HandyTextButton(
                      text: "Log in test account",
                      onTap: () {
                        context.read<AuthorizationBloc>().add(const LoginWithTestAccount());
                      },
                    ),
                    SizedBox(height: Paddings.betweenSimilarElements),
                    SizedBox(height: Paddings.betweenSimilarElements),
                    SizedBox(height: Paddings.betweenSimilarElements),
                    SizedBox(height: Paddings.betweenSimilarElements),
                  ],
                );
              }
            },
          );
        },
      ),
    );
  }
}