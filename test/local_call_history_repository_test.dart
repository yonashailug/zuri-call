import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuri_call/core/storage/zuri_database.dart';
import 'package:zuri_call/features/home/call_history_repository.dart';
import 'package:zuri_call/features/home/call_record.dart';

void main() {
  late ZuriDatabase database;
  late LocalCallHistoryRepository repository;

  setUp(() {
    database = ZuriDatabase(NativeDatabase.memory());
    repository = LocalCallHistoryRepository(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  test('saves and loads recent calls newest first', () async {
    final olderCall = CallRecord.fromDialpad(
      number: '+1 (206) 555-0142',
      name: 'Maya Kim',
      startedAt: DateTime.utc(2026, 6, 1, 12),
      durationSeconds: 45,
    );
    final newerCall = CallRecord.fromDialpad(
      number: '+1 (503) 555-0278',
      name: 'Jordan Rivera',
      startedAt: DateTime.utc(2026, 6, 1, 13),
      status: CallStatus.cancelled,
    );

    await repository.saveRecentCalls([olderCall, newerCall]);

    final restoredCalls = await repository.loadRecentCalls();
    expect(restoredCalls, hasLength(2));
    expect(restoredCalls.first.name, 'Jordan Rivera');
    expect(restoredCalls.first.status, CallStatus.cancelled);
    expect(restoredCalls.last.name, 'Maya Kim');
    expect(restoredCalls.last.durationSeconds, 45);
  });

  test('replaces stored calls when saving', () async {
    await repository.saveRecentCalls([
      CallRecord.fromDialpad(
        number: '+1 (206) 555-0142',
        startedAt: DateTime.utc(2026, 6, 1, 12),
      ),
    ]);

    await repository.saveRecentCalls([
      CallRecord.fromDialpad(
        number: '+1 (503) 555-0278',
        name: 'Jordan Rivera',
        startedAt: DateTime.utc(2026, 6, 1, 13),
      ),
    ]);

    final restoredCalls = await repository.loadRecentCalls();
    expect(restoredCalls, hasLength(1));
    expect(restoredCalls.single.name, 'Jordan Rivera');
  });

  test('keeps only the latest fifty calls', () async {
    final calls = [
      for (var index = 0; index < 55; index++)
        CallRecord.fromDialpad(
          number: '+1 (206) 555-${index.toString().padLeft(4, '0')}',
          startedAt: DateTime.utc(2026, 6, 1).add(Duration(minutes: index)),
        ),
    ];

    await repository.saveRecentCalls(calls);

    final restoredCalls = await repository.loadRecentCalls();
    expect(restoredCalls, hasLength(50));
    expect(restoredCalls.first.phone, '+1 (206) 555-0054');
    expect(restoredCalls.last.phone, '+1 (206) 555-0005');
  });
}
