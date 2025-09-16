import 'package:supabase_flutter/supabase_flutter.dart';

// 공통 머신 쿼리 빌더 - 중복 제거용
PostgrestFilterBuilder _buildMachineQuery({
  String? brandId,
  List<String>? bodyParts,
  List<String>? movements,
  String? machineType,
  required String selectClause,
}) {
  var query = Supabase.instance.client
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
  
  if (movements != null && movements.isNotEmpty) {
    query = query.overlaps('movements', movements);
  }
  
  if (machineType != null && machineType.isNotEmpty) {
    query = query.eq('type', machineType);
  }

  return query;
}

Future<List<Map<String, dynamic>>> fetchBrands() async {
  final response = await Supabase.instance.client
      .from('brands')
      .select('id, name, logo_url');

  return response; // 이미 List<Map<String, dynamic>>
}

Future<List<Map<String, dynamic>>> fetchMachines({
  String? brandId,
  List<String>? bodyParts,
  List<String>? movements,
  String? machineType,
}) async {
  final query = _buildMachineQuery(
    brandId: brandId,
    bodyParts: bodyParts,
    movements: movements,
    machineType: machineType,
    selectClause: '''
      id,
      name,
      status,
      image_url,
      review_cnt,
      score,
      body_parts,
      movements,
      type,
      brand:brands (
        name,
        logo_url
      )
    ''',
  );

  final response = await query;
  return response; // 이미 List<Map<String, dynamic>>
}

// 한 번의 쿼리로 필터링된 리뷰를 직접 가져오기 (성능 개선)
Future<List<Map<String, dynamic>>> fetchMachineReviews({
  int offset = 0,
  int limit = 100,
  String? brandId,
  String? machineId,
  List<String>? bodyParts,
  List<String>? movements,
  String? type,
}) async {
  var query = Supabase.instance.client
      .from('machine_reviews')
      .select('''
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
          movements,
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
    
    if (movements != null && movements.isNotEmpty) {
      query = query.overlaps('machine.movements', movements);
    }
    
    if (type != null && type.isNotEmpty) {
      query = query.eq('machine.type', type);
    }
  }
  
  final response = await query
      .order('like_count', ascending: false) // 리뷰 like_count 순으로 정렬
      .range(offset, offset + limit - 1);
  
  return response;
}