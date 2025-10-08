import 'package:supabase_flutter/supabase_flutter.dart';

class ReviewRepository {
  ReviewRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  PostgrestFilterBuilder _buildMachineQuery({
    String? brandId,
    List<String>? bodyParts,
    String? machineType,
    required String selectClause,
  }) {
    var query = _client
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

    return query;
  }

  Future<List<Map<String, dynamic>>> fetchBrands() async {
    final response = await _client.from('brands').select('id, name, logo_url');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchMachines({
    String? brandId,
    List<String>? bodyParts,
    String? machineType,
  }) async {
    final query = _buildMachineQuery(
      brandId: brandId,
      bodyParts: bodyParts,
      machineType: machineType,
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

    final response = await query;
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchMachineReviews({
    int offset = 0,
    int limit = 100,
    String? brandId,
    String? machineId,
    List<String>? bodyParts,
    String? type,
  }) async {
    var query = _client.from('machine_reviews').select('''
          id,
          user_id,
          rating,
          like_count,
          comment,
          image_urls,
          created_at,
          user:users (
            username
          ),
          machine:machines!inner (
            id,
            name,
            image_url,
            brand_id,
            body_parts,
            type,
            status,
            brand:brands (
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

    return List<Map<String, dynamic>>.from(response);
  }
}
