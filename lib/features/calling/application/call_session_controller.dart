import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../home/call_record.dart';
import '../call_service.dart';

class CallSessionState {
  const CallSessionState({
    this.status = ActiveCallStatus.connecting,
    this.connectedAt,
    this.elapsedSeconds = 0,
    this.holdElapsedSeconds = 0,
    this.isMuted = false,
    this.isSpeakerOn = false,
    this.isHoldOn = false,
    this.isKeypadOpen = false,
    this.isCompleting = false,
    this.endedCall,
    this.failedCall,
  });

  final ActiveCallStatus status;
  final DateTime? connectedAt;
  final int elapsedSeconds;
  final int holdElapsedSeconds;
  final bool isMuted;
  final bool isSpeakerOn;
  final bool isHoldOn;
  final bool isKeypadOpen;
  final bool isCompleting;
  final CallRecord? endedCall;
  final CallRecord? failedCall;

  bool get isConnected {
    return (status == ActiveCallStatus.connected ||
            status == ActiveCallStatus.poorNetwork) &&
        !isCompleting;
  }

  String get supportingStatusText {
    if (isHoldOn) return formatDuration(elapsedSeconds);

    return switch (status) {
      ActiveCallStatus.connected => formatDuration(elapsedSeconds),
      ActiveCallStatus.poorNetwork => formatDuration(elapsedSeconds),
      ActiveCallStatus.ended => 'Call ended',
      ActiveCallStatus.failed => 'Unable to connect',
      ActiveCallStatus.ringing => 'Waiting for answer',
      ActiveCallStatus.connecting => 'Setting up secure audio',
    };
  }

  CallSessionState copyWith({
    ActiveCallStatus? status,
    DateTime? connectedAt,
    int? elapsedSeconds,
    int? holdElapsedSeconds,
    bool? isMuted,
    bool? isSpeakerOn,
    bool? isHoldOn,
    bool? isKeypadOpen,
    bool? isCompleting,
    CallRecord? endedCall,
    CallRecord? failedCall,
  }) {
    return CallSessionState(
      status: status ?? this.status,
      connectedAt: connectedAt ?? this.connectedAt,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      holdElapsedSeconds: holdElapsedSeconds ?? this.holdElapsedSeconds,
      isMuted: isMuted ?? this.isMuted,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
      isHoldOn: isHoldOn ?? this.isHoldOn,
      isKeypadOpen: isKeypadOpen ?? this.isKeypadOpen,
      isCompleting: isCompleting ?? this.isCompleting,
      endedCall: endedCall ?? this.endedCall,
      failedCall: failedCall ?? this.failedCall,
    );
  }

  static String formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final paddedSeconds = seconds.toString().padLeft(2, '0');
    return '$minutes:$paddedSeconds';
  }
}

class CallSessionController extends ChangeNotifier {
  CallSessionController({
    required OutgoingCallRequest request,
    required CallService callService,
  })  : _request = request,
        _callService = callService;

  final OutgoingCallRequest _request;
  final CallService _callService;

  StreamSubscription<ActiveCallStatus>? _callSubscription;
  Timer? _callTimer;

  CallSessionState _state = const CallSessionState();

  CallSessionState get state => _state;

  void start() {
    _callSubscription?.cancel();
    _callSubscription =
        _callService.startOutgoingCall(_request).listen(_handleStatusChanged);
  }

  void endCall() {
    final callStatus = _state.connectedAt == null
        ? CallStatus.cancelled
        : CallStatus.completed;
    _completeCall(callStatus, terminalStatus: ActiveCallStatus.ended);
  }

  void toggleMute() {
    _setState(_state.copyWith(isMuted: !_state.isMuted));
  }

  void toggleSpeaker() {
    _setState(_state.copyWith(isSpeakerOn: !_state.isSpeakerOn));
  }

  void toggleKeypad() {
    _setState(_state.copyWith(isKeypadOpen: !_state.isKeypadOpen));
  }

  void toggleHold() {
    final isHoldOn = !_state.isHoldOn;
    _setState(
      _state.copyWith(
        isHoldOn: isHoldOn,
        isMuted: isHoldOn ? false : _state.isMuted,
        isSpeakerOn: isHoldOn ? false : _state.isSpeakerOn,
        isKeypadOpen: isHoldOn ? false : _state.isKeypadOpen,
        holdElapsedSeconds: isHoldOn ? 0 : _state.holdElapsedSeconds,
      ),
    );
  }

  void useCellularFallback() {
    _setState(_state.copyWith(status: ActiveCallStatus.connected));
  }

  @override
  void dispose() {
    _callSubscription?.cancel();
    _callTimer?.cancel();
    super.dispose();
  }

  void _handleStatusChanged(ActiveCallStatus nextStatus) {
    if (_state.isCompleting) return;

    if (nextStatus == ActiveCallStatus.failed) {
      _completeCall(CallStatus.failed, terminalStatus: nextStatus);
      return;
    }

    if (nextStatus == ActiveCallStatus.ended) {
      final callStatus = _state.connectedAt == null
          ? CallStatus.cancelled
          : CallStatus.completed;
      _completeCall(callStatus, terminalStatus: nextStatus);
      return;
    }

    final connectedAt = _state.connectedAt;
    final shouldStartTimer =
        _isConnectedStatus(nextStatus) && connectedAt == null;

    _setState(
      _state.copyWith(
        status: nextStatus,
        connectedAt: shouldStartTimer ? DateTime.now() : connectedAt,
        elapsedSeconds: shouldStartTimer ? 0 : _state.elapsedSeconds,
      ),
    );

    if (shouldStartTimer) {
      _startCallTimer();
    }
  }

  void _completeCall(
    CallStatus callStatus, {
    required ActiveCallStatus terminalStatus,
  }) {
    if (_state.isCompleting) return;

    final durationSeconds = _state.elapsedSeconds;
    _callSubscription?.cancel();
    _callTimer?.cancel();

    final call = CallRecord.fromDialpad(
      number: _request.phone,
      name: _request.name,
      startedAt: _request.startedAt,
      status: callStatus,
      durationSeconds: durationSeconds,
    );

    _setState(
      _state.copyWith(
        isCompleting: true,
        status: terminalStatus,
        elapsedSeconds: durationSeconds,
        isHoldOn: false,
        endedCall: callStatus == CallStatus.failed ? null : call,
        failedCall: callStatus == CallStatus.failed ? call : null,
      ),
    );
  }

  void _startCallTimer() {
    _callTimer?.cancel();
    _callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_state.connectedAt == null || _state.isCompleting) return;

      _setState(
        _state.copyWith(
          elapsedSeconds: _state.elapsedSeconds + 1,
          holdElapsedSeconds: _state.isHoldOn
              ? _state.holdElapsedSeconds + 1
              : _state.holdElapsedSeconds,
        ),
      );
    });
  }

  void _setState(CallSessionState state) {
    _state = state;
    notifyListeners();
  }

  bool _isConnectedStatus(ActiveCallStatus status) {
    return status == ActiveCallStatus.connected ||
        status == ActiveCallStatus.poorNetwork;
  }
}
