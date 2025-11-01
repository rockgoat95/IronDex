import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:irondex/models/catalog/brand.dart';
import 'package:irondex/models/catalog/machine.dart';
import 'package:irondex/models/reviews/review.dart';
import 'package:irondex/models/reviews/review_user.dart';
import 'package:irondex/services/core/supabase_service.dart';
import 'package:irondex/services/repositories/review_repository.dart';
import 'package:uuid/uuid.dart';

class SupabaseReviewRepository extends SupabaseService
    implements ReviewRepository {
  SupabaseReviewRepository({super.client});

  static const _reviewBucket = 'review_images';

  @override
  Future<List<Review>> fetchMachineReviews({
    int offset = 0,
    int limit = 100,
    String? brandId,
    String? machineId,
    List<String>? bodyParts,
    String? machineType,
  }) async {
    var query = client
        .schema('reviews')
        .from('machine_reviews_view')
        .select('*');

    if (machineId != null && machineId.isNotEmpty) {
      query = query.eq('machine_id', machineId);
    } else {
      if (brandId != null && brandId.isNotEmpty) {
        query = query.eq('machine_brand_id', brandId);
      }

      if (machineType != null && machineType.isNotEmpty) {
        query = query.eq('machine_type', machineType);
      }

      if (bodyParts != null && bodyParts.isNotEmpty) {
        query = query.overlaps('machine_body_parts', bodyParts);
      }
    }

    final response = await query
        .order('like_count', ascending: false)
        .range(offset, offset + limit - 1);

    final rows = List<Map<String, dynamic>>.from(response);

    final data = rows.map((row) {
      final brand = Brand(
        id: (row['brand_id'] ?? row['machine_brand_id'])?.toString() ?? '',
        name: row['brand_name']?.toString() ?? '',
        logoUrl: row['brand_logo_url']?.toString(),
      );

      final machine = Machine(
        id: row['machine_id']?.toString() ?? '',
        name: (row['machine_name'] ?? row['name'] ?? '').toString(),
        imageUrl:
            row['machine_image_url']?.toString() ??
            row['image_url']?.toString(),
        bodyParts: _parseBodyParts(
          row['machine_body_parts'] ?? row['body_parts'],
        ),
        type: row['machine_type']?.toString() ?? row['type']?.toString(),
        brand: brand,
        reviewCount: row['review_cnt'] is num
            ? (row['review_cnt'] as num).toInt()
            : null,
        score: row['score'] is num ? (row['score'] as num).toDouble() : null,
      );

      final user = ReviewUser(
        username: (row['username'] ?? row['user_username'] ?? '').toString(),
      );

      final imageList = row['image_urls'] ?? row['img_urls'];
      final images = imageList is List
          ? imageList.whereType<String>().toList()
          : const <String>[];

      final createdAt = row['created_at']?.toString();

      return Review(
        id: row['id']?.toString() ?? '',
        userId: row['user_id']?.toString() ?? '',
        rating: row['rating'] is num ? (row['rating'] as num).toDouble() : 0,
        likeCount: row['like_count'] is num
            ? (row['like_count'] as num).toInt()
            : 0,
        title: row['title']?.toString(),
        comment: row['comment']?.toString(),
        imageUrls: images,
        createdAt: createdAt != null ? DateTime.tryParse(createdAt) : null,
        machine: machine,
        user: user,
      );
    }).toList();

    if (kDebugMode) {
      debugPrint(
        '[SupabaseReviewRepository] fetchMachineReviews count=${data.length} '
        'filters={brandId: $brandId, machineId: $machineId, bodyParts: $bodyParts, '
        'machineType: $machineType}',
      );

      if (data.isNotEmpty) {
        debugPrint(
          '[SupabaseReviewRepository] fetchMachineReviews first=${data.first}',
        );
      }
    }

    return data;
  }

  List<String> _parseBodyParts(dynamic value) {
    if (value == null) {
      return const <String>[];
    }

    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }

    if (value is String && value.isNotEmpty) {
      return value
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    return const <String>[];
  }

  @override
  Future<Set<String>> fetchLikedReviewIds() async {
    final userId = client.auth.currentUser?.id;

    if (userId == null) {
      return <String>{};
    }

    final response = await client
        .schema('reviews')
        .from('machine_review_likes')
        .select('machine_review_id')
        .eq('user_id', userId);

    final liked = response
        .map<String>((row) => row['machine_review_id'].toString())
        .toSet();

    if (kDebugMode) {
      debugPrint(
        '[SupabaseReviewRepository] fetchLikedReviewIds count=${liked.length}',
      );
    }

    return liked;
  }

  @override
  Future<void> addReviewLike(String reviewId) async {
    final userId = client.auth.currentUser?.id;

    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await client.schema('reviews').from('machine_review_likes').upsert({
      'user_id': userId,
      'machine_review_id': reviewId,
    }, onConflict: 'user_id,machine_review_id');

    if (kDebugMode) {
      debugPrint('[SupabaseReviewRepository] addReviewLike reviewId=$reviewId');
    }
  }

  @override
  Future<void> removeReviewLike(String reviewId) async {
    final userId = client.auth.currentUser?.id;

    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await client
        .schema('reviews')
        .from('machine_review_likes')
        .delete()
        .eq('user_id', userId)
        .eq('machine_review_id', reviewId);

    if (kDebugMode) {
      debugPrint(
        '[SupabaseReviewRepository] removeReviewLike reviewId=$reviewId',
      );
    }
  }

  @override
  Future<void> createReview({
    required String machineId,
    required String userId,
    required String title,
    required String comment,
    required double rating,
    List<File>? imageFiles,
  }) async {
    final uuid = const Uuid();
    final List<String> uploadedUrls = [];
    final List<String> uploadedPaths = [];
    final files = imageFiles ?? const <File>[];

    try {
      for (final file in files) {
        final extension = file.path.contains('.')
            ? file.path.split('.').last
            : 'jpg';
        final objectPath = '$machineId/${uuid.v4()}.$extension';
        final fileBytes = await file.readAsBytes();

        await client.storage
            .from(_reviewBucket)
            .uploadBinary(objectPath, fileBytes);

        uploadedPaths.add(objectPath);
        final publicUrl = client.storage
            .from(_reviewBucket)
            .getPublicUrl(objectPath);
        uploadedUrls.add(publicUrl);
      }

      final payload = <String, dynamic>{
        'machine_id': machineId,
        'user_id': userId,
        'title': title,
        'comment': comment,
        'rating': rating,
        'image_urls': uploadedUrls.isEmpty
            ? const <dynamic>[]
            : List<dynamic>.from(uploadedUrls),
      };

      await client.schema('reviews').from('machine_reviews').insert(payload);

      if (kDebugMode) {
        debugPrint(
          '[SupabaseReviewRepository] createReview machineId=$machineId userId=$userId '
          'images=${uploadedUrls.length}',
        );
      }
    } catch (error) {
      if (uploadedPaths.isNotEmpty) {
        try {
          await client.storage.from(_reviewBucket).remove(uploadedPaths);
        } catch (_) {
          // ignore cleanup errors
        }
      }
      rethrow;
    }
  }

  @override
  Future<bool> hasUserReviewForMachine({
    required String machineId,
    required String userId,
  }) async {
    final response = await client
        .schema('reviews')
        .from('machine_reviews')
        .select('id')
        .eq('machine_id', machineId)
        .eq('user_id', userId)
        .limit(1);

    return response.isNotEmpty;
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    final userId = client.auth.currentUser?.id;

    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final records = await client
        .schema('reviews')
        .from('machine_reviews')
        .select('id,user_id,image_urls')
        .eq('id', reviewId)
        .limit(1);

    if (records.isEmpty) {
      throw Exception('리뷰를 찾을 수 없습니다.');
    }

    final review = Map<String, dynamic>.from(records.first);
    final authorId = review['user_id']?.toString();

    if (authorId == null || authorId != userId) {
      throw Exception('리뷰를 삭제할 권한이 없습니다.');
    }

    final imageUrls = review['image_urls'] is List
        ? (review['image_urls'] as List).whereType<String>().toList()
        : const <String>[];

    final storagePaths = imageUrls
        .map(_extractStoragePathFromUrl)
        .whereType<String>()
        .toList();

    await client
        .schema('reviews')
        .from('machine_reviews')
        .delete()
        .eq('id', reviewId);

    if (storagePaths.isNotEmpty) {
      try {
        await client.storage.from(_reviewBucket).remove(storagePaths);
      } catch (error, stackTrace) {
        if (kDebugMode) {
          debugPrint(
            '[SupabaseReviewRepository] deleteReview cleanup failed reviewId=$reviewId '
            'error=$error stack=$stackTrace',
          );
        }
      }
    }

    if (kDebugMode) {
      debugPrint('[SupabaseReviewRepository] deleteReview reviewId=$reviewId');
    }
  }

  String? _extractStoragePathFromUrl(String urlOrPath) {
    if (urlOrPath.isEmpty) {
      return null;
    }

    if (!urlOrPath.contains('://')) {
      return urlOrPath;
    }

    const marker = '/$_reviewBucket/';
    final index = urlOrPath.indexOf(marker);

    if (index == -1) {
      return null;
    }

    final start = index + marker.length;

    if (start >= urlOrPath.length) {
      return null;
    }

    return urlOrPath.substring(start);
  }
}
