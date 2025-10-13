import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class ReviewRepository {
  ReviewRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  static const _reviewBucket = 'review_images';

  PostgrestFilterBuilder _buildMachineQuery({
    String? brandId,
    List<String>? bodyParts,
    String? machineType,
    String? searchQuery,
    required String selectClause,
  }) {
    var query = _client
        .schema('catalog')
        .from('machines')
        .select(selectClause)
        .eq('status', 'approved');

    if (brandId != null && brandId.isNotEmpty) {
      query = query.eq('brand_id', brandId);
    }

    if (bodyParts != null && bodyParts.isNotEmpty) {
      query = query.overlaps('body_parts', bodyParts);
    }

    if (machineType != null && machineType.isNotEmpty) {
      query = query.eq('type', machineType);
    }

    final trimmedQuery = searchQuery?.trim();
    if (trimmedQuery != null && trimmedQuery.isNotEmpty) {
      String escape(String value) => value
          .replaceAll('\\', '\\\\')
          .replaceAll('%', '\\%')
          .replaceAll('_', '\\_');

      final tokens = trimmedQuery
          .split(RegExp(r'\s+'))
          .where((token) => token.isNotEmpty)
          .toList();

      if (tokens.length <= 1) {
        final pattern = '%${escape(trimmedQuery)}%';
        query = query.ilike('search_text', pattern);
      } else {
        final uniqueTokens = tokens.toSet();
        for (final token in uniqueTokens) {
          final tokenPattern = '%${escape(token)}%';
          query = query.ilike('search_text', tokenPattern);
        }
      }
    }

    return query;
  }

  Map<String, dynamic> _mapMachineRow(Map<String, dynamic> machine) {
    final brand = <String, dynamic>{
      'id': machine['brand_id'],
      'name': machine['brand_name'],
      'name_kor': machine['brand_name_kor'],
      'logo_url': machine['brand_logo_url'],
    }..removeWhere((_, value) => value == null);

    return <String, dynamic>{...machine, if (brand.isNotEmpty) 'brand': brand};
  }

  Future<List<Map<String, dynamic>>> fetchBrands() async {
    final response = await _client
        .schema('catalog')
        .from('brands')
        .select('id, name, logo_url');
    final data = List<Map<String, dynamic>>.from(response);
    if (kDebugMode) {
      debugPrint('[ReviewRepository] fetchBrands count=${data.length}');
    }
    return data;
  }

  Future<List<Map<String, dynamic>>> fetchMachines({
    String? brandId,
    List<String>? bodyParts,
    String? machineType,
    String? searchQuery,
    int offset = 0,
    int limit = 20,
  }) async {
    final query = _buildMachineQuery(
      brandId: brandId,
      bodyParts: bodyParts,
      machineType: machineType,
      searchQuery: searchQuery,
      selectClause: '''
        id,
        name,
        status,
        image_url,
        review_cnt,
        score,
        body_parts,
        type,
        brand_id,
        brand_name,
        brand_name_kor,
        brand_logo_url
      ''',
    );

    final response = await query.range(offset, offset + limit - 1);
    final rows = List<Map<String, dynamic>>.from(response);
    final data = rows.map(_mapMachineRow).toList();

    if (kDebugMode) {
      debugPrint(
        '[ReviewRepository] fetchMachines count=${data.length} '
        'filters={brandId: $brandId, bodyParts: $bodyParts, machineType: $machineType, searchQuery: $searchQuery}',
      );
      if (data.isNotEmpty) {
        debugPrint('[ReviewRepository] fetchMachines first=${data.first}');
      }
    }
    return data;
  }

  Future<List<Map<String, dynamic>>> searchMachines(
    String keyword, {
    int limit = 20,
  }) async {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) {
      return const <Map<String, dynamic>>[];
    }

    final query = _buildMachineQuery(
      selectClause: '''
        id,
        name,
        status,
        image_url,
        review_cnt,
        score,
        body_parts,
        type,
        brand_id,
        brand_name,
        brand_name_kor,
        brand_logo_url
      ''',
      searchQuery: trimmed,
    );

    final response = await query.range(0, limit - 1);
    final rows = List<Map<String, dynamic>>.from(response);
    return rows.map(_mapMachineRow).toList();
  }

  Future<List<Map<String, dynamic>>> fetchMachineReviews({
    int offset = 0,
    int limit = 100,
    String? brandId,
    String? machineId,
    List<String>? bodyParts,
    String? type,
  }) async {
    var query = _client
        .schema('reviews')
        .from('machine_reviews_view')
        .select('*');

    if (machineId != null && machineId.isNotEmpty) {
      query = query.eq('machine_id', machineId);
    } else {
      if (brandId != null && brandId.isNotEmpty) {
        query = query.eq('machine_brand_id', brandId);
      }
      if (type != null && type.isNotEmpty) {
        query = query.eq('machine_type', type);
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
      final brand = <String, dynamic>{
        'id': row['brand_id'] ?? row['machine_brand_id'],
        'name': row['brand_name'] ?? '',
        'logo_url': row['brand_logo_url'] ?? '',
      }..removeWhere((key, value) => value == null);

      final machine = <String, dynamic>{
        'id': row['machine_id'],
        'name': row['machine_name'] ?? row['name'] ?? '',
        'image_url': row['machine_image_url'] ?? row['image_url'] ?? '',
        'brand_id': row['machine_brand_id'] ?? row['brand_id'],
        'body_parts': row['machine_body_parts'] ?? row['body_parts'],
        'type': row['machine_type'] ?? row['type'],
        'brand': brand,
      }..removeWhere((key, value) => value == null);

      final user = <String, dynamic>{
        'username': row['username'] ?? row['user_username'] ?? '',
      };

      return <String, dynamic>{
        'id': row['id'],
        'user_id': row['user_id'],
        'rating': row['rating'],
        'like_count': row['like_count'],
        'title': row['title'],
        'comment': row['comment'],
        'image_urls': row['image_urls'] ?? row['img_urls'] ?? const <dynamic>[],
        'img_urls': row['img_urls'] ?? row['image_urls'] ?? const <dynamic>[],
        'created_at': row['created_at'],
        'machine': machine,
        'user': user,
      };
    }).toList();

    if (kDebugMode) {
      debugPrint(
        '[ReviewRepository] fetchMachineReviews count=${data.length} '
        'filters={brandId: $brandId, machineId: $machineId, bodyParts: $bodyParts, type: $type}',
      );
      if (data.isNotEmpty) {
        debugPrint(
          '[ReviewRepository] fetchMachineReviews first=${data.first}',
        );
      }
    }

    return data;
  }

  Future<Set<String>> fetchLikedReviewIds() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      return <String>{};
    }

    final response = await _client
        .schema('reviews')
        .from('machine_review_likes')
        .select('machine_review_id')
        .eq('user_id', userId);

    final liked = response
        .map<String>((row) => row['machine_review_id'].toString())
        .toSet();

    if (kDebugMode) {
      debugPrint(
        '[ReviewRepository] fetchLikedReviewIds count=${liked.length}',
      );
    }

    return liked;
  }

  Future<void> addReviewLike(String reviewId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await _client.schema('reviews').from('machine_review_likes').upsert({
      'user_id': userId,
      'machine_review_id': reviewId,
    }, onConflict: 'user_id,machine_review_id');
    if (kDebugMode) {
      debugPrint('[ReviewRepository] addReviewLike reviewId=$reviewId');
    }
  }

  Future<void> removeReviewLike(String reviewId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await _client
        .schema('reviews')
        .from('machine_review_likes')
        .delete()
        .eq('user_id', userId)
        .eq('machine_review_id', reviewId);
    if (kDebugMode) {
      debugPrint('[ReviewRepository] removeReviewLike reviewId=$reviewId');
    }
  }

  Future<Set<String>> fetchFavoriteMachineIds() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      return <String>{};
    }

    final response = await _client
        .schema('catalog')
        .from('machine_favorites')
        .select('machine_id')
        .eq('user_id', userId);
    final data = response
        .map<String>((row) => row['machine_id'].toString())
        .toSet();
    if (kDebugMode) {
      debugPrint(
        '[ReviewRepository] fetchFavoriteMachineIds count=${data.length}',
      );
    }

    return data;
  }

  Future<void> addFavoriteMachine(String machineId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await _client.schema('catalog').from('machine_favorites').upsert({
      'user_id': userId,
      'machine_id': machineId,
    }, onConflict: 'user_id,machine_id');
    if (kDebugMode) {
      debugPrint('[ReviewRepository] addFavoriteMachine machineId=$machineId');
    }
  }

  Future<void> removeFavoriteMachine(String machineId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await _client
        .schema('catalog')
        .from('machine_favorites')
        .delete()
        .eq('user_id', userId)
        .eq('machine_id', machineId);
    if (kDebugMode) {
      debugPrint(
        '[ReviewRepository] removeFavoriteMachine machineId=$machineId',
      );
    }
  }

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

        await _client.storage
            .from(_reviewBucket)
            .uploadBinary(objectPath, fileBytes);

        uploadedPaths.add(objectPath);
        final publicUrl = _client.storage
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

      await _client.schema('reviews').from('machine_reviews').insert(payload);

      if (kDebugMode) {
        debugPrint(
          '[ReviewRepository] createReview machineId=$machineId userId=$userId '
          'images=${uploadedUrls.length}',
        );
      }
    } catch (error) {
      if (uploadedPaths.isNotEmpty) {
        try {
          await _client.storage.from(_reviewBucket).remove(uploadedPaths);
        } catch (_) {
          // ignore cleanup errors
        }
      }
      rethrow;
    }
  }

  Future<bool> hasUserReviewForMachine({
    required String machineId,
    required String userId,
  }) async {
    final response = await _client
        .schema('reviews')
        .from('machine_reviews')
        .select('id')
        .eq('machine_id', machineId)
        .eq('user_id', userId)
        .limit(1);

    return response.isNotEmpty;
  }

  Future<void> deleteReview(String reviewId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final records = await _client
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

    await _client
        .schema('reviews')
        .from('machine_reviews')
        .delete()
        .eq('id', reviewId);

    if (storagePaths.isNotEmpty) {
      try {
        await _client.storage.from(_reviewBucket).remove(storagePaths);
      } catch (error, stackTrace) {
        if (kDebugMode) {
          debugPrint(
            '[ReviewRepository] deleteReview cleanup failed reviewId=$reviewId error=$error stack=$stackTrace',
          );
        }
      }
    }

    if (kDebugMode) {
      debugPrint('[ReviewRepository] deleteReview reviewId=$reviewId');
    }
  }

  String? _extractStoragePathFromUrl(String urlOrPath) {
    if (urlOrPath.isEmpty) {
      return null;
    }

    if (!urlOrPath.contains('://')) {
      return urlOrPath;
    }

    final marker = '/$_reviewBucket/';
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
