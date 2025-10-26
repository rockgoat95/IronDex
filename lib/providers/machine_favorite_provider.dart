import 'package:irondex/providers/auth_provider.dart';
import 'package:irondex/providers/base_remote_state_provider.dart';
import 'package:irondex/services/repositories/machine_repository.dart';

class MachineFavoriteProvider extends BaseRemoteStateProvider {
  MachineFavoriteProvider({
    AuthProvider? authProvider,
    MachineRepository? repository,
  }) : _authProvider = authProvider,
       _repository = repository,
       _currentUserId = authProvider?.currentUser?.id;

  AuthProvider? _authProvider;
  MachineRepository? _repository;
  String? _currentUserId;

  final Set<String> _favoriteMachineIds = <String>{};

  Set<String> get favorites => Set.unmodifiable(_favoriteMachineIds);

  void updateDependencies({
    required AuthProvider authProvider,
    required MachineRepository repository,
  }) {
    final newUserId = authProvider.currentUser?.id;
    final userChanged = newUserId != _currentUserId;
    final repositoryChanged = repository != _repository;

    _authProvider = authProvider;
    _repository = repository;

    if (repositoryChanged) {
      resetInitialization();
    }

    if (userChanged) {
      _currentUserId = newUserId;
      if (newUserId == null) {
        _favoriteMachineIds.clear();
        resetInitialization(notify: true);
        return;
      }
      resetInitialization();
    }

    if (!isInitialized && !isFetching && _currentUserId != null) {
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

    await executeFetch(() async {
      final favorites = await repository.fetchFavoriteMachineIds();
      _favoriteMachineIds
        ..clear()
        ..addAll(favorites);
      notifyListeners();
    });
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
