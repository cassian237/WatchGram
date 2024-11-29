/*
 * Copyright (C) Roman Rikhter <teledurak@gmail.com>, 2024
 * This program comes with ABSOLUTELY NO WARRANTY;
 * This is free software, and you are welcome to redistribute it under certain conditions;
 *
 * See /LICENSE for more details.
 */

import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watchgram/src/common/exceptions/tdlib_core_exception.dart';
import 'package:watchgram/src/common/tdlib/client/management/user_manager.dart';
import 'package:watchgram/src/common/tdlib/providers/authorization_state/authorization_state.dart';
import 'package:watchgram/src/common/tdlib/providers/authorization_state/authorization_states.dart';

import 'package:watchgram/src/common/log/log.dart';

sealed class AuthorizationBlocEvent {
  const AuthorizationBlocEvent();
}

class RequestQrCode extends AuthorizationBlocEvent {
  const RequestQrCode();
}

class CheckCode extends AuthorizationBlocEvent {
  final String code;

  const CheckCode(this.code);
}

class SetPassword extends AuthorizationBlocEvent {
  final String password;

  const SetPassword(this.password);
}

class LoginWithTestAccount extends AuthorizationBlocEvent {
  const LoginWithTestAccount();
}

sealed class AuthorizationBlocState {
  const AuthorizationBlocState();
}

class AuthorizationBlocStateRequestingQr extends AuthorizationBlocState {
  const AuthorizationBlocStateRequestingQr();
}

class AuthorizationBlocStateWaitingCode extends AuthorizationBlocState {
  const AuthorizationBlocStateWaitingCode();
}

class AuthorizationBlocStateQr extends AuthorizationBlocState {
  final String qrLink;

  const AuthorizationBlocStateQr(this.qrLink);
}

class AuthorizationBlocStateWaitingPassword extends AuthorizationBlocState {
  final String hint;

  const AuthorizationBlocStateWaitingPassword(this.hint);
}

class AuthorizationBlocStateLoadingPassword extends AuthorizationBlocState {
  final String hint;

  const AuthorizationBlocStateLoadingPassword(this.hint);
}

class AuthorizationBlocStateIncorrectPassword extends AuthorizationBlocState {
  final String hint;

  const AuthorizationBlocStateIncorrectPassword(this.hint);
}

class AuthorizationBlocStateErrorPassword extends AuthorizationBlocState {
  final String error;
  final String hint;

  const AuthorizationBlocStateErrorPassword(this.error, this.hint);
}

class AuthorizationBlocStateSuccess extends AuthorizationBlocState {
  const AuthorizationBlocStateSuccess();
}

class AuthorizationBloc
    extends Bloc<AuthorizationBlocEvent, AuthorizationBlocState> {
  static const String tag = "AuthorizationBloc";

  AuthorizationBloc(this.manager)
      : super(const AuthorizationBlocStateRequestingQr()) {
    on<RequestQrCode>(_requestQrCode);
    on<SetPassword>(_setPassword);
    on<LoginWithTestAccount>(_loginWithTestAccount);
    on<CheckCode>(_checkCode);
  }

  final TdlibUserManager manager;

  String hint = "";

  Future<void> _loginWithTestAccount(
    LoginWithTestAccount event,
    Emitter<AuthorizationBlocState> emit,
  ) async {
    final phoneNumber = '+1 781 338 5854';

    // Send the phone number to TDLib
    await _auth.setAuthenticationPhoneNumber(phoneNumber);

    await for (final state in _auth.states) {
      if (state is AuthorizationStateWaitCode) {
        l.d(tag, "AuthorizationStateWaitCode");
        emit(const AuthorizationBlocStateWaitingCode());
        break;
      } else if (state is AuthorizationStateReady) {
        emit(const AuthorizationBlocStateSuccess());
        break;
      } else if (state is AuthorizationStateClosed) {

        break;
      }
    }
  }

  Future<void> _checkCode(
    CheckCode event,
    Emitter<AuthorizationBlocState> emit,
  ) async {
    await _auth.checkAuthenticationCode(event.code);

    // Wait for the authorization state to become ready
    await for (final state in _auth.states) {
      if (state is AuthorizationStateReady) {
        emit(const AuthorizationBlocStateSuccess());
        break;
      }
    }
  }

  Future<void> _requestQrCode(
    RequestQrCode _,
    Emitter<AuthorizationBlocState> emit,
  ) async {
    // Auth may be incomplete
    if (_auth.state is AuthorizationStateWaitingPassword) {
      hint = (_auth.state as AuthorizationStateWaitingPassword).hint;
      emit(AuthorizationBlocStateWaitingPassword(hint));
      return;
    }

    // Setup was completed already
    if (_auth.state is AuthorizationStateReady) {
      emit(const AuthorizationBlocStateSuccess());
      return;
    }

    if (_auth.lastQRLink == null) {
      emit(const AuthorizationBlocStateRequestingQr());
      _auth.requestQrCode();
    } else {
      emit(AuthorizationBlocStateQr(_auth.lastQRLink!));
    }

    await for (final i in _auth.states) {
      if (i is AuthorizationStateReadyToScanQr) {
        emit(AuthorizationBlocStateQr(i.qrLink));
      }
      if (i is AuthorizationStateReady) {
        emit(const AuthorizationBlocStateSuccess());
        break;
      }
      if (i is AuthorizationStateWaitingPassword) {
        hint = i.hint;
        emit(AuthorizationBlocStateWaitingPassword(i.hint));
        break;
      }
    }
  }

  Future<void> _setPasswordReadyListener(
      Emitter<AuthorizationBlocState> emit) async {
    await for (final i in _auth.states) {
      if (i is AuthorizationStateReady) {
        emit(const AuthorizationBlocStateSuccess());
        return;
      }
    }
  }

  Future<void> _setPassword(
    SetPassword event,
    Emitter<AuthorizationBlocState> emit,
  ) async {
    emit(AuthorizationBlocStateLoadingPassword(hint));

    // Start future before setPassword to be on time with broadcast stream
    final op = CancelableOperation.fromFuture(_setPasswordReadyListener(emit));

    try {
      final isCorrect = await _auth.setPassword(event.password);
      if (!isCorrect) {
        emit(AuthorizationBlocStateIncorrectPassword(hint));
        op.cancel();
        return;
      }
    } on TdlibCoreException catch (e) {
      emit(AuthorizationBlocStateErrorPassword(e.message, hint));
    }
  }

  late final AuthorizationStateProvider _auth =
      manager.providers.authorizationState;
}
