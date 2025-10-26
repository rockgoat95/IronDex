import 'dart:io';

import 'package:irondex/models/reviews/review.dart';

abstract class ReviewRepository {
  const ReviewRepository();

  Future<List<Review>> fetchMachineReviews({
    int offset = 0,
    int limit = 100,
    String? brandId,
    String? machineId,
    List<String>? bodyParts,
    String? machineType,
  });

  Future<Set<String>> fetchLikedReviewIds();

  Future<void> addReviewLike(String reviewId);

  Future<void> removeReviewLike(String reviewId);

  Future<void> createReview({
    required String machineId,
    required String userId,
    required String title,
    required String comment,
    required double rating,
    List<File>? imageFiles,
  });

  Future<bool> hasUserReviewForMachine({
    required String machineId,
    required String userId,
  });

  Future<void> deleteReview(String reviewId);
}
