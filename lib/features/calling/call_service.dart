enum ActiveCallStatus {
  connecting('Connecting'),
  ringing('Ringing'),
  connected('Connected'),
  ended('Ended'),
  failed('Failed');

  const ActiveCallStatus(this.label);

  final String label;
}

class OutgoingCallRequest {
  const OutgoingCallRequest({
    required this.phone,
    required this.startedAt,
    this.name,
  });

  final String phone;
  final String? name;
  final DateTime startedAt;
}

abstract class CallService {
  Stream<ActiveCallStatus> startOutgoingCall(OutgoingCallRequest request);
}

class MockCallService implements CallService {
  const MockCallService();

  @override
  Stream<ActiveCallStatus> startOutgoingCall(
      OutgoingCallRequest request) async* {
    yield ActiveCallStatus.connecting;
    await Future<void>.delayed(const Duration(milliseconds: 700));
    yield ActiveCallStatus.ringing;
    await Future<void>.delayed(const Duration(milliseconds: 900));
    yield ActiveCallStatus.connected;
  }
}
