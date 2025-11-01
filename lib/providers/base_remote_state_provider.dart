import 'package:flutter/foundation.dart';

abstract class BaseRemoteStateProvider extends ChangeNotifier {
  bool _isInitialized = false;
  bool _isFetching = false;

  bool get isInitialized => _isInitialized;
  bool get isFetching => _isFetching;

  @protected
  Future<void> executeFetch(
    Future<void> Function() operation, {
    bool markInitialized = true,
  }) async {
    if (_isFetching) {
      return;
    }

    _isFetching = true;
    try {
      await operation();
      if (markInitialized) {
        _isInitialized = true;
      }
    } finally {
      _isFetching = false;
    }
  }

  @protected
  void resetInitialization({bool notify = false}) {
    _isInitialized = false;
    if (notify) {
      notifyListeners();
    }
  }

  @protected
  void markInitialized() {
    _isInitialized = true;
  }
}
