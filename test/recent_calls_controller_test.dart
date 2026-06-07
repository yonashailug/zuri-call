import 'package:flutter_test/flutter_test.dart';
import 'package:zuri_call/features/home/application/recent_calls_controller.dart';
import 'package:zuri_call/features/home/call_history_repository.dart';
import 'package:zuri_call/features/home/call_record.dart';

void main() {
  test('restores persisted calls', () async {
    final call = CallRecord.fromDialpad(
      number: '+1 (206) 555-0142',
      name: 'Maya Kim',
      startedAt: DateTime.utc(2026, 6, 1),
    );
    final controller = RecentCallsController(
      repository: _MemoryCallHistoryRepository(initialCalls: [call]),
    );
    addTearDown(controller.dispose);

    await controller.restore();

    expect(controller.calls, [call]);
    expect(controller.isLoading, isFalse);
  });

  test('records and deletes calls through repository', () async {
    final repository = _MemoryCallHistoryRepository();
    final controller = RecentCallsController(repository: repository);
    final call = CallRecord.fromDialpad(
      number: '+1 (206) 555-0142',
      name: 'Maya Kim',
      startedAt: DateTime.utc(2026, 6, 1),
    );
    addTearDown(controller.dispose);

    await controller.record(call);

    expect(controller.calls, [call]);
    expect(repository.savedCalls, [call]);

    await controller.delete(call);

    expect(controller.calls, isEmpty);
    expect(repository.savedCalls, isEmpty);
  });
}

class _MemoryCallHistoryRepository implements CallHistoryRepository {
  _MemoryCallHistoryRepository({List<CallRecord> initialCalls = const []})
      : _calls = [...initialCalls];

  final List<CallRecord> _calls;
  List<CallRecord> savedCalls = const [];

  @override
  Future<List<CallRecord>> loadRecentCalls() async {
    return [..._calls];
  }

  @override
  Future<void> saveRecentCalls(List<CallRecord> calls) async {
    savedCalls = [...calls];
  }
}
