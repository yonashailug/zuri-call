import 'package:flutter/foundation.dart';

import '../call_history_repository.dart';
import '../call_record.dart';

class RecentCallsController extends ChangeNotifier {
  RecentCallsController({
    required CallHistoryRepository repository,
  }) : _repository = repository;

  final CallHistoryRepository _repository;
  final List<CallRecord> _calls = [];

  bool _isLoading = false;
  bool _isDisposed = false;

  List<CallRecord> get calls => List.unmodifiable(_calls);

  bool get isLoading => _isLoading;

  Future<void> restore() async {
    _isLoading = true;
    _notifyListeners();

    final restoredCalls = await _repository.loadRecentCalls();
    if (_isDisposed) return;

    _calls
      ..clear()
      ..addAll(restoredCalls);
    _isLoading = false;
    _notifyListeners();
  }

  Future<void> record(CallRecord call) async {
    _calls.insert(0, call);
    _notifyListeners();

    await _save();
  }

  Future<void> delete(CallRecord call) async {
    _calls.remove(call);
    _notifyListeners();

    await _save();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _save() {
    return _repository.saveRecentCalls(_calls);
  }

  void _notifyListeners() {
    if (!_isDisposed) notifyListeners();
  }
}
