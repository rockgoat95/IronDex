import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 공통 머신 쿼리 빌더 - 중복 제거용
PostgrestFilterBuilder _buildMachineQuery({
  String? brandId,
  List<String>? bodyParts,
  String? machineType,
  required String selectClause,
}) {
  var query = Supabase.instance.client
      .schema('catalog')
      .from('machines')
      .select(selectClause)
      .eq('status', 'approved'); // 승인된 머신만

  // 필터 적용
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
  final response = await Supabase.instance.client
      .schema('catalog')
      .from('brands')
      .select('id, name, logo_url');

  final data = List<Map<String, dynamic>>.from(response);
  if (kDebugMode) {
    debugPrint('[Supabase] fetchBrands count=${data.length}');
  }

  return data;
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
  final data = List<Map<String, dynamic>>.from(response);
  if (kDebugMode) {
    debugPrint(
      '[Supabase] fetchMachines count=${data.length} filters='
      '{brandId: $brandId, bodyParts: $bodyParts, machineType: $machineType}',
    );
    if (data.isNotEmpty) {
      debugPrint('[Supabase] fetchMachines first=${data.first}');
    }
  }

  return data; // 이미 List<Map<String, dynamic>>
}

// 한 번의 쿼리로 필터링된 리뷰를 직접 가져오기 (성능 개선)
Future<List<Map<String, dynamic>>> fetchMachineReviews({
  int offset = 0,
  int limit = 100,
  String? brandId,
  String? machineId,
  List<String>? bodyParts,
  String? type,
}) async {
  var query = Supabase.instance.client
      .schema('reviews')
      .from('machine_reviews')
      .select('''
        id,
        user_id,
        rating,
        like_count,
        comment,
        image_urls,
        created_at,
        user:core.users (
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

  // 승인된 머신만
  query = query.eq('machine.status', 'approved');

  // 특정 머신 ID가 지정된 경우 우선 적용
  if (machineId != null && machineId.isNotEmpty) {
    query = query.eq('machine_id', machineId);
  } else {
    // 필터들 적용
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
      .order('like_count', ascending: false) // 리뷰 like_count 순으로 정렬
      .range(offset, offset + limit - 1);

  final data = List<Map<String, dynamic>>.from(response);
  if (kDebugMode) {
    debugPrint(
      '[Supabase] fetchMachineReviews count=${data.length} filters='
      '{brandId: $brandId, machineId: $machineId, bodyParts: $bodyParts, type: $type}',
    );
    if (data.isNotEmpty) {
      debugPrint('[Supabase] fetchMachineReviews first=${data.first}');
    }
  }

  return data;
}
