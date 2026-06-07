import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:zuri_call/features/calling/application/call_session_controller.dart';
import 'package:zuri_call/features/calling/call_service.dart';
import 'package:zuri_call/features/home/call_record.dart';

void main() {
  test('moves to connected when call service connects', () async {
    final service = _ControlledCallService();
    final controller = CallSessionController(
      request: _request(),
      callService: service,
    );
    addTearDown(controller.dispose);
    addTearDown(service.close);

    controller.start();
    service.emit(ActiveCallStatus.connected);
    await Future<void>.delayed(Duration.zero);

    expect(controller.state.status, ActiveCallStatus.connected);
    expect(controller.state.isConnected, isTrue);
    expect(controller.state.supportingStatusText, '0:00');
  });

  test('ending before connection creates a cancelled call', () {
    final controller = CallSessionController(
      request: _request(),
      callService: _ControlledCallService(),
    );
    addTearDown(controller.dispose);

    controller.endCall();

    expect(controller.state.status, ActiveCallStatus.ended);
    expect(controller.state.endedCall?.status, CallStatus.cancelled);
    expect(controller.state.endedCall?.phone, '+1 (206) 555-0142');
  });

  test('hold clears transient audio controls', () {
    final controller = CallSessionController(
      request: _request(),
      callService: _ControlledCallService(),
    );
    addTearDown(controller.dispose);

    controller.toggleMute();
    controller.toggleSpeaker();
    controller.toggleKeypad();
    controller.toggleHold();

    expect(controller.state.isHoldOn, isTrue);
    expect(controller.state.isMuted, isFalse);
    expect(controller.state.isSpeakerOn, isFalse);
    expect(controller.state.isKeypadOpen, isFalse);
  });

  test('failed service status creates failed call without ended summary',
      () async {
    final service = _ControlledCallService();
    final controller = CallSessionController(
      request: _request(),
      callService: service,
    );
    addTearDown(controller.dispose);
    addTearDown(service.close);

    controller.start();
    service.emit(ActiveCallStatus.failed);
    await Future<void>.delayed(Duration.zero);

    expect(controller.state.status, ActiveCallStatus.failed);
    expect(controller.state.failedCall?.status, CallStatus.failed);
    expect(controller.state.endedCall, isNull);
    expect(controller.state.supportingStatusText, 'Unable to connect');
  });
}

OutgoingCallRequest _request() {
  return OutgoingCallRequest(
    phone: '+1 (206) 555-0142',
    name: 'Maya Kim',
    startedAt: DateTime.utc(2026, 6, 1),
  );
}

class _ControlledCallService implements CallService {
  final StreamController<ActiveCallStatus> _controller =
      StreamController<ActiveCallStatus>();

  @override
  Stream<ActiveCallStatus> startOutgoingCall(OutgoingCallRequest request) {
    return _controller.stream;
  }

  void emit(ActiveCallStatus status) {
    _controller.add(status);
  }

  Future<void> close() {
    return _controller.close();
  }
}
