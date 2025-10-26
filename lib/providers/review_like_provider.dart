import 'package:irondex/providers/auth_provider.dart';
import 'package:irondex/providers/base_remote_state_provider.dart';
import 'package:irondex/services/repositories/review_repository.dart';

class ReviewLikeProvider extends BaseRemoteStateProvider {
  ReviewLikeProvider({AuthProvider? authProvider, ReviewRepository? repository})
    : _authProvider = authProvider,
      _repository = repository,
      _currentUserId = authProvider?.currentUser?.id;

  AuthProvider? _authProvider;
  ReviewRepository? _repository;
  String? _currentUserId;

  final Set<String> _likedReviewIds = <String>{};

  Set<String> get likedReviews => Set.unmodifiable(_likedReviewIds);

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
      resetInitialization();
    }

    if (userChanged) {
      _currentUserId = newUserId;
      if (newUserId == null) {
        _likedReviewIds.clear();
        resetInitialization(notify: true);
        return;
      }
      resetInitialization();
    }

    if (!isInitialized && !isFetching && _currentUserId != null) {
      refreshLikes();
    }
  }

  bool isLiked(String? reviewId) {
    if (reviewId == null) {
      return false;
    }
    return _likedReviewIds.contains(reviewId);
  }

  Future<void> refreshLikes() async {
    final repository = _repository;
    final userId = _authProvider?.currentUser?.id;

    if (repository == null || userId == null) {
      return;
    }

    await executeFetch(() async {
      final likes = await repository.fetchLikedReviewIds();
      _likedReviewIds
        ..clear()
        ..addAll(likes);
      notifyListeners();
    });
  }

  Future<bool> toggleLike(String reviewId) async {
    final repository = _repository;
    final userId = _authProvider?.currentUser?.id;

    if (repository == null || userId == null) {
      throw StateError('USER_NOT_LOGGED_IN');
    }

    final currentlyLiked = _likedReviewIds.contains(reviewId);

    if (currentlyLiked) {
      await repository.removeReviewLike(reviewId);
      _likedReviewIds.remove(reviewId);
      notifyListeners();
      return false;
    } else {
      await repository.addReviewLike(reviewId);
      _likedReviewIds.add(reviewId);
      notifyListeners();
      return true;
    }
  }
}
