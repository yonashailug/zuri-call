import 'package:flutter/foundation.dart';

import '../data/auth_repository.dart';
import '../domain/phone_number.dart';

enum AuthStep {
  restoring,
  signedOut,
  enteringPhone,
  sendingCode,
  codeSent,
  verifyingCode,
  needsProfile,
  creatingProfile,
  authenticated,
}

class AuthState {
  const AuthState({
    this.step = AuthStep.signedOut,
    this.phoneNumber,
    this.pendingSession,
    this.session,
    this.errorMessage,
  });

  final AuthStep step;
  final PhoneNumber? phoneNumber;
  final AuthSession? pendingSession;
  final AuthSession? session;
  final String? errorMessage;

  bool get isBusy {
    return step == AuthStep.sendingCode ||
        step == AuthStep.verifyingCode ||
        step == AuthStep.creatingProfile;
  }

  AuthState copyWith({
    AuthStep? step,
    PhoneNumber? phoneNumber,
    AuthSession? pendingSession,
    AuthSession? session,
    String? errorMessage,
    bool clearError = false,
    bool clearSession = false,
  }) {
    return AuthState(
      step: step ?? this.step,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      pendingSession: pendingSession ?? this.pendingSession,
      session: clearSession ? null : session ?? this.session,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class AuthController extends ChangeNotifier {
  AuthController({required AuthRepository repository})
      : _repository = repository;

  final AuthRepository _repository;

  AuthState _state = const AuthState();

  AuthState get state => _state;

  Future<void> restoreSession() async {
    _setState(_state.copyWith(step: AuthStep.restoring, clearError: true));

    try {
      final session = await _repository.restoreSession();
      if (session == null) {
        _setState(const AuthState(step: AuthStep.signedOut));
        return;
      }

      _setState(
        AuthState(
          step: AuthStep.authenticated,
          phoneNumber: session.phoneNumber,
          session: session,
        ),
      );
    } on AuthException catch (error) {
      _setState(
        AuthState(
          step: AuthStep.signedOut,
          errorMessage: error.message,
        ),
      );
    }
  }

  Future<bool> startPhoneAuth(PhoneNumber phoneNumber) async {
    _setState(
      _state.copyWith(
        step: AuthStep.sendingCode,
        phoneNumber: phoneNumber,
        clearError: true,
      ),
    );

    try {
      await _repository.startPhoneAuth(phoneNumber);
      _setState(
        _state.copyWith(
          step: AuthStep.codeSent,
          phoneNumber: phoneNumber,
          clearError: true,
        ),
      );
      return true;
    } on AuthException catch (error) {
      _setState(
        _state.copyWith(
          step: AuthStep.enteringPhone,
          errorMessage: error.message,
        ),
      );
      return false;
    }
  }

  Future<bool> verifyCode(String code) async {
    final phoneNumber = _state.phoneNumber;
    if (phoneNumber == null) {
      _setState(
        _state.copyWith(
          step: AuthStep.enteringPhone,
          errorMessage: 'Enter your phone number first.',
        ),
      );
      return false;
    }

    _setState(
      _state.copyWith(step: AuthStep.verifyingCode, clearError: true),
    );

    try {
      final session = await _repository.verifyCode(
        phoneNumber: phoneNumber,
        code: code,
      );
      _setState(
        _state.copyWith(
          step: AuthStep.needsProfile,
          pendingSession: session,
          clearError: true,
        ),
      );
      return true;
    } on AuthException catch (error) {
      _setState(
        _state.copyWith(
          step: AuthStep.codeSent,
          errorMessage: error.message,
        ),
      );
      return false;
    }
  }

  Future<bool> createProfile(String displayName) async {
    final pendingSession = _state.pendingSession;
    if (pendingSession == null) {
      _setState(
        _state.copyWith(
          step: AuthStep.codeSent,
          errorMessage: 'Verify your code first.',
        ),
      );
      return false;
    }

    _setState(
      _state.copyWith(step: AuthStep.creatingProfile, clearError: true),
    );

    try {
      final session = await _repository.createProfile(
        session: pendingSession,
        displayName: displayName,
      );
      _setState(
        AuthState(
          step: AuthStep.authenticated,
          phoneNumber: session.phoneNumber,
          session: session,
        ),
      );
      return true;
    } on AuthException catch (error) {
      _setState(
        _state.copyWith(
          step: AuthStep.needsProfile,
          errorMessage: error.message,
        ),
      );
      return false;
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    _setState(const AuthState(step: AuthStep.signedOut));
  }

  void _setState(AuthState state) {
    _state = state;
    notifyListeners();
  }
}
