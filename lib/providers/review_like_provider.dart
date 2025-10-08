import 'package:flutter/foundation.dart';
import 'package:irondex/providers/auth_provider.dart';
import 'package:irondex/services/review_repository.dart';

class ReviewLikeProvider with ChangeNotifier {
  ReviewLikeProvider({AuthProvider? authProvider, ReviewRepository? repository})
    : _authProvider = authProvider,
      _repository = repository,
      _currentUserId = authProvider?.currentUser?.id;

  AuthProvider? _authProvider;
  ReviewRepository? _repository;
  String? _currentUserId;

  final Set<String> _likedReviewIds = <String>{};

  bool _isFetching = false;
  bool _initialized = false;

  bool get isInitialized => _initialized;

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
      _initialized = false;
    }

    if (userChanged) {
      _currentUserId = newUserId;
      if (newUserId == null) {
        _likedReviewIds.clear();
        _initialized = false;
        notifyListeners();
        return;
      }
    }

    if (!_initialized && !_isFetching && _currentUserId != null) {
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

    if (_isFetching) {
      return;
    }

    _isFetching = true;
    try {
      final likes = await repository.fetchLikedReviewIds();
      _likedReviewIds
        ..clear()
        ..addAll(likes);
      _initialized = true;
      notifyListeners();
    } finally {
      _isFetching = false;
    }
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
