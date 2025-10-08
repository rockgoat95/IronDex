import 'package:flutter/foundation.dart';
import 'package:irondex/providers/auth_provider.dart';
import 'package:irondex/services/review_repository.dart';

class MachineFavoriteProvider with ChangeNotifier {
  MachineFavoriteProvider({
    AuthProvider? authProvider,
    ReviewRepository? repository,
  }) : _authProvider = authProvider,
       _repository = repository,
       _currentUserId = authProvider?.currentUser?.id;

  AuthProvider? _authProvider;
  ReviewRepository? _repository;
  String? _currentUserId;

  final Set<String> _favoriteMachineIds = <String>{};

  bool _isFetching = false;
  bool _initialized = false;

  bool get isInitialized => _initialized;

  Set<String> get favorites => Set.unmodifiable(_favoriteMachineIds);

  void updateDependencies({
    required AuthProvider authProvider,
    required ReviewRepository repository,
  }) {
    final newUserId = authProvider.currentUser?.id;
    final userChanged = newUserId != _currentUserId;
    final repositoryChanged = repository != _repository;

    _authProvider = authProvider;
    _repository = repository;

    if (repositoryChanged) {
      _initialized = false;
    }

    if (userChanged) {
      _currentUserId = newUserId;
      if (newUserId == null) {
        _favoriteMachineIds.clear();
        _initialized = false;
        notifyListeners();
        return;
      }
    }

    if (!_initialized && !_isFetching && _currentUserId != null) {
      refreshFavorites();
    }
  }

  bool isFavorite(String? machineId) {
    if (machineId == null) {
      return false;
    }
    return _favoriteMachineIds.contains(machineId);
  }

  Future<void> refreshFavorites() async {
    final repository = _repository;
    final userId = _authProvider?.currentUser?.id;

    if (repository == null || userId == null) {
      return;
    }

    if (_isFetching) {
      return;
    }

    _isFetching = true;
    try {
      final favorites = await repository.fetchFavoriteMachineIds();
      _favoriteMachineIds
        ..clear()
        ..addAll(favorites);
      _initialized = true;
      notifyListeners();
    } finally {
      _isFetching = false;
    }
  }

  Future<void> toggleFavorite(String machineId) async {
    final repository = _repository;
    final userId = _authProvider?.currentUser?.id;

    if (repository == null || userId == null) {
      throw StateError('USER_NOT_LOGGED_IN');
    }

    final isCurrentlyFavorite = _favoriteMachineIds.contains(machineId);
    if (isCurrentlyFavorite) {
      await repository.removeFavoriteMachine(machineId);
      _favoriteMachineIds.remove(machineId);
    } else {
      await repository.addFavoriteMachine(machineId);
      _favoriteMachineIds.add(machineId);
    }

    notifyListeners();
  }
}
