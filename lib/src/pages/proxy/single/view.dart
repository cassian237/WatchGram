/*
 * Copyright (C) Roman Rikhter <teledurak@gmail.com>, 2024
 * This program comes with ABSOLUTELY NO WARRANTY;
 * This is free software, and you are welcome to redistribute it under certain conditions;
 *
 * See /LICENSE for more details.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handy_tdlib/api.dart' as td;
import 'package:watchgram/src/common/cubits/scaling.dart';
import 'package:watchgram/src/common/cubits/text.dart';
import 'package:watchgram/src/common/misc/localizations.dart';
import 'package:watchgram/src/components/controls/checkbox.dart';
import 'package:watchgram/src/components/controls/tile_button.dart';
import 'package:watchgram/src/components/fields/text_field.dart';
import 'package:watchgram/src/components/list/listview.dart';
import 'package:watchgram/src/components/picker/picker.dart';
import 'package:watchgram/src/components/scaled_sizes.dart';
import 'package:watchgram/src/components/text/header.dart';
import 'package:watchgram/src/pages/proxy/single/bloc.dart';

class ProxyView extends StatefulWidget {
  const ProxyView({super.key});

  @override
  State<ProxyView> createState() => _ProxyViewState();
}

enum _ProxyType {
  http,
  socks5,
  mtproto,
}

class _Ready with ChangeNotifier {
  bool ready = false;

  void check({
    required String server,
    required String port,
    required _ProxyType type,
    required String secret,
  }) {
    if (server.isEmpty) return _notify(false);
    if (port.isEmpty || int.tryParse(port) == null) return _notify(false);
    if (type == _ProxyType.mtproto && secret.isEmpty) return _notify(false);
    _notify(true);
  }

  void _notify(bool val) {
    if (ready == val) return;
    ready = val;
    notifyListeners();
  }
}

class _ProxyViewState extends State<ProxyView> {
  final serverController = TextEditingController(),
      portController = TextEditingController(),
      passwordController = TextEditingController(),
      usernameController = TextEditingController(),
      secretController = TextEditingController();
  bool insecure = false;
  _ProxyType type = _ProxyType.http;
  _Ready ready = _Ready();

  bool filled = false;

  void _checkIsReady() {
    ready.check(
      server: serverController.text,
      port: portController.text,
      secret: secretController.text,
      type: type,
    );
  }

  void _readyListener() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    serverController.addListener(_checkIsReady);
    portController.addListener(_checkIsReady);
    usernameController.addListener(_checkIsReady);
    passwordController.addListener(_checkIsReady);
    secretController.addListener(_checkIsReady);
    ready.addListener(_readyListener);
  }

  @override
  void dispose() {
    serverController.dispose();
    portController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    secretController.dispose();
    ready.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<ProxyBloc>().state;
    if (state is ProxyEditing && !filled) {
      filled = true;
      final server = state.server.split(':');
      serverController.text = server.firstOrNull ?? "";
      portController.text = state.port.toString();
      switch (state.type) {
        case td.ProxyTypeHttp(
            httpOnly: final httpOnly,
            username: final username,
            password: final password,
          ):
          type = _ProxyType.http;
          insecure = httpOnly;
          passwordController.text = password;
          usernameController.text = username;
        case td.ProxyTypeMtproto(secret: final secret):
          type = _ProxyType.mtproto;
          secretController.text = secret;
        case td.ProxyTypeSocks5(
            password: final password,
            username: final username,
          ):
          type = _ProxyType.socks5;
          usernameController.text = username;
          passwordController.text = password;
      }
      ready.ready = true;
    }
    return Scaffold(
      body: state is ProxyLoading
          ? Center(
              child: SizedBox(
                height: 50 * Scaling.factor,
                width: 50 * Scaling.factor,
                child: const CircularProgressIndicator(),
              ),
            )
          : HandyListView(
              bottomPadding: false,
              children: [
                PageHeader(
                  title: state is ProxyCreating
                      ? l10n.createProxy
                      : l10n.editProxy,
                ),
                HandyTextField(
                  controller: serverController,
                  title: l10n.proxyServer,
                  autocorrect: false,
                ),
                SizedBox(height: Paddings.betweenSimilarElements),
                HandyTextField(
                  controller: portController,
                  title: l10n.proxyPort,
                  autocorrect: false,
                ),
                SizedBox(height: Paddings.betweenSimilarElements),
                ValuePicker<_ProxyType>(
                  values: [
                    ValuePickable(
                      title: l10n.proxyTypeHTTP,
                      value: _ProxyType.http,
                    ),
                    ValuePickable(
                      title: l10n.proxyTypeMTProto,
                      value: _ProxyType.mtproto,
                    ),
                    ValuePickable(
                      title: l10n.proxyTypeSOCKS5,
                      value: _ProxyType.socks5,
                    ),
                  ],
                  title: l10n.proxyType,
                  pickerHint: l10n.proxyTypePickerTitle,
                  currentValue: type,
                  onSelected: (v) => setState(() {
                    type = v;
                    _checkIsReady();
                  }),
                ),
                if (type == _ProxyType.http) ...[
                  SizedBox(height: Paddings.betweenSimilarElements),
                  HandyCheckbox(
                    text: Text(
                      l10n.proxyInsecure,
                      style: TextStyles.active.titleMedium,
                    ),
                    useSwitch: true,
                    value: insecure,
                    onChanged: (v) => setState(() => insecure = v),
                  ),
                ],
                SizedBox(height: Paddings.betweenSimilarElements),
                if (type == _ProxyType.mtproto) ...[
                  HandyTextField(
                    controller: secretController,
                    title: l10n.proxySecret,
                    autocorrect: false,
                    obscureText: true,
                  ),
                ] else ...[
                  HandyTextField(
                    controller: usernameController,
                    title: l10n.proxyUser,
                    autocorrect: false,
                  ),
                  SizedBox(height: Paddings.betweenSimilarElements),
                  HandyTextField(
                    controller: passwordController,
                    title: l10n.proxyPassword,
                    autocorrect: false,
                    obscureText: true,
                  ),
                ],
                SizedBox(height: Paddings.beforeSmallButton),
                if (state is ProxyEditing) ...[
                  TileButton(
                    big: false,
                    text: l10n.removeButton,
                    style: TileButtonStyles.basic,
                    onTap: () =>
                        context.read<ProxyBloc>().add(const ProxyDelete()),
                  ),
                  SizedBox(height: Paddings.betweenSimilarElements),
                ],
                TileButton(
                  big: false,
                  text: (state is ProxyEditing)
                      ? l10n.doneButton
                      : l10n.createButton,
                  onTap: ready.ready
                      ? () => context.read<ProxyBloc>().add(ProxyCommit(
                          port: int.parse(portController.text),
                          server: serverController.text,
                          type: switch (type) {
                            _ProxyType.http => td.ProxyTypeHttp(
                                httpOnly: insecure,
                                password: passwordController.text,
                                username: usernameController.text,
                              ),
                            _ProxyType.mtproto => td.ProxyTypeMtproto(
                                secret: secretController.text,
                              ),
                            _ProxyType.socks5 => td.ProxyTypeSocks5(
                                password: passwordController.text,
                                username: usernameController.text,
                              )
                          }))
                      : null,
                ),
              ],
            ),
    );
  }
}
