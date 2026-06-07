import 'package:drift/drift.dart';

import '../../core/storage/zuri_database.dart';
import 'call_record.dart';

abstract class CallHistoryRepository {
  Future<List<CallRecord>> loadRecentCalls();

  Future<void> saveRecentCalls(List<CallRecord> calls);
}

class LocalCallHistoryRepository implements CallHistoryRepository {
  LocalCallHistoryRepository({
    ZuriDatabase? database,
  }) : _database = database ?? ZuriDatabase.production();

  static const _maxRecentCalls = 50;

  final ZuriDatabase _database;

  @override
  Future<List<CallRecord>> loadRecentCalls() async {
    final rows = await (_database.select(_database.callRecords)
          ..orderBy([
            (table) => OrderingTerm(
                  expression: table.startedAt,
                  mode: OrderingMode.desc,
                ),
          ])
          ..limit(_maxRecentCalls))
        .get();

    return rows.map(_callFromRow).toList();
  }

  @override
  Future<void> saveRecentCalls(List<CallRecord> calls) async {
    final normalizedCalls = [...calls]
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

    await _database.transaction(() async {
      await _database.delete(_database.callRecords).go();
      await _database.batch((batch) {
        batch.insertAll(
          _database.callRecords,
          normalizedCalls.take(_maxRecentCalls).map(_callToCompanion),
        );
      });
    });
  }

  CallRecord _callFromRow(CallRecordRow row) {
    return CallRecord(
      name: row.name,
      phone: row.phone,
      startedAt: row.startedAt,
      direction: CallDirection.fromJson(row.direction),
      status: CallStatus.fromJson(row.status),
      durationSeconds: row.durationSeconds,
    );
  }

  CallRecordsCompanion _callToCompanion(CallRecord call) {
    return CallRecordsCompanion.insert(
      name: call.name,
      phone: call.phone,
      startedAt: call.startedAt.toUtc(),
      direction: call.direction.value,
      status: call.status.value,
      durationSeconds: Value(call.durationSeconds),
    );
  }
}
