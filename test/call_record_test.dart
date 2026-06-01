import 'package:flutter_test/flutter_test.dart';
import 'package:zuri_call/features/home/call_record.dart';

void main() {
  test('serializes call metadata for local persistence', () {
    final startedAt = DateTime.utc(2026, 5, 31, 18, 30);
    final record = CallRecord.fromDialpad(
      number: '+1 (206) 555-0142',
      name: 'Maya Kim',
      startedAt: startedAt,
    );

    final restored = CallRecord.fromJson(record.toJson());

    expect(restored.name, 'Maya Kim');
    expect(restored.phone, '+1 (206) 555-0142');
    expect(restored.startedAt, startedAt);
    expect(restored.direction, CallDirection.outgoing);
    expect(restored.status, CallStatus.completed);
    expect(restored.durationSeconds, 0);
    expect(restored.metadata, 'Outgoing • Completed');
  });

  test('serializes cancelled outgoing calls', () {
    final record = CallRecord.fromDialpad(
      number: '+1 (206) 555-0142',
      startedAt: DateTime.utc(2026, 5, 31, 18, 30),
      status: CallStatus.cancelled,
    );

    final restored = CallRecord.fromJson(record.toJson());

    expect(restored.status, CallStatus.cancelled);
    expect(restored.metadata, 'Outgoing • Cancelled');
  });
}
