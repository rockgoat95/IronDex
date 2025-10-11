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
      final escaped = trimmedQuery
          .replaceAll('\\', '\\\\')
          .replaceAll('%', '\\%')
          .replaceAll('_', '\\_');
      final pattern = '%$escaped%';
      query = query.or('name.ilike.$pattern,brand.name.ilike.$pattern');
    }

    return query;
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
        brand:brands (
          name,
          logo_url
        )
      ''',
    );

    final response = await query.range(offset, offset + limit - 1);
    final data = List<Map<String, dynamic>>.from(response);
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

  Future<List<Map<String, dynamic>>> fetchMachineReviews({
    int offset = 0,
    int limit = 100,
    String? brandId,
    String? machineId,
    List<String>? bodyParts,
    String? type,
  }) async {
    var query = _client.schema('reviews').from('machine_reviews').select('''
          id,
          user_id,
          rating,
          like_count,
          title,
          comment,
          image_urls,
          created_at,
          user:core.users (
            username
          ),
          machine:catalog.machines!inner (
            id,
            name,
            image_url,
            brand_id,
            body_parts,
            type,
            status,
            brand:catalog.brands (
              id,
              name,
              logo_url
            )
          )
        ''');

    query = query.eq('machine.status', 'approved');

    if (machineId != null && machineId.isNotEmpty) {
      query = query.eq('machine_id', machineId);
    } else {
      if (brandId != null && brandId.isNotEmpty) {
        query = query.eq('machine.brand_id', brandId);
      }

      if (bodyParts != null && bodyParts.isNotEmpty) {
        query = query.overlaps('machine.body_parts', bodyParts);
      }

      if (type != null && type.isNotEmpty) {
        query = query.eq('machine.type', type);
      }
    }

    final response = await query
        .order('like_count', ascending: false)
        .range(offset, offset + limit - 1);

    final data = List<Map<String, dynamic>>.from(response);
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

    final data = response
        .map<String>((row) => row['machine_review_id'].toString())
        .toSet();
    if (kDebugMode) {
      debugPrint('[ReviewRepository] fetchLikedReviewIds count=${data.length}');
    }

    return data;
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
}
