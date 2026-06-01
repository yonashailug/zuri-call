import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'call_record.dart';

abstract class CallHistoryRepository {
  Future<List<CallRecord>> loadRecentCalls();

  Future<void> saveRecentCalls(List<CallRecord> calls);
}

class LocalCallHistoryRepository implements CallHistoryRepository {
  LocalCallHistoryRepository({
    SharedPreferencesAsync? preferences,
  }) : _preferences = preferences ?? SharedPreferencesAsync();

  static const _recentCallsKey = 'zuri.recentCalls.v1';
  static const _maxRecentCalls = 50;

  final SharedPreferencesAsync _preferences;

  @override
  Future<List<CallRecord>> loadRecentCalls() async {
    final encodedCalls = await _preferences.getString(_recentCallsKey);
    if (encodedCalls == null || encodedCalls.isEmpty) return const [];

    final decoded = jsonDecode(encodedCalls);
    if (decoded is! List) return const [];

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(CallRecord.fromJson)
        .where((call) => call.phone.trim().isNotEmpty)
        .toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  @override
  Future<void> saveRecentCalls(List<CallRecord> calls) async {
    final normalizedCalls = [...calls]
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    final payload = normalizedCalls
        .take(_maxRecentCalls)
        .map((call) => call.toJson())
        .toList();

    await _preferences.setString(_recentCallsKey, jsonEncode(payload));
  }
}
