import 'package:flutter/foundation.dart';

/// Lifecycle-safe async state shared by paper and AI workflows.
class OperationController extends ChangeNotifier {
  bool _disposed = false;
  bool busy = false;
  String? error;
  String? activity;
  bool get disposed => _disposed;

  void changed() {
    if (!_disposed) notifyListeners();
  }

  Future<bool> run(String label, Future<void> Function() action) async {
    if (busy || _disposed) return false;
    busy = true;
    error = null;
    activity = label;
    changed();
    try {
      await action();
      return !_disposed;
    } catch (e) {
      if (!_disposed)
        error = e.toString().replaceFirst(
              RegExp(r'^(Exception|Bad state): '),
              '',
            );
      return false;
    } finally {
      busy = false;
      activity = null;
      changed();
    }
  }

  void progress(String message) {
    activity = message;
    changed();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
