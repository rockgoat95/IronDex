import 'package:supabase_flutter/supabase_flutter.dart';

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
  var query = Supabase.instance.client
      .from('machines')
      .select('''
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
    ''')
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

  final response = await query;
  return response; // 이미 List<Map<String, dynamic>>
}

Future<List<Map<String, dynamic>>> fetchMachineReviews({
  int offset = 0,
  int limit = 100,
  String? brandId,
  String? machineId,
  List<String>? bodyParts,
  List<String>? movements,
  String? type,
}) async {
  print('fetchMachineReviews called with: brandId=$brandId, machineId=$machineId, bodyParts=$bodyParts, movements=$movements, type=$type');
  
  // 브랜드 필터가 있는 경우 먼저 해당 브랜드의 머신들을 찾기
  List<String>? machineIds;
  if (brandId != null) {
    print('Finding machines for brand: $brandId');
    final machinesResponse = await Supabase.instance.client
        .from('machines')
        .select('id')
        .eq('brand_id', brandId);
    
    machineIds = machinesResponse.map<String>((m) => m['id'].toString()).toList();
    print('Found machine IDs for brand: $machineIds');
  }
  
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
        machine:machines (
          id,
          name,
          image_url,
          brand_id,
          body_parts,
          type,
          movements,
          brand:brands (
            id,
            name,
            logo_url
          )
        )
      ''');
  
  // 브랜드로 필터링 (머신 ID 리스트 사용)
  if (machineIds != null && machineIds.isNotEmpty) {
    print('Applying machine_id filter: $machineIds');
    query = query.inFilter('machine_id', machineIds);
  } else if (brandId != null) {
    // 해당 브랜드의 머신이 없으면 빈 결과 반환
    print('No machines found for brand, returning empty result');
    return [];
  }
  
  if (machineId != null) {
    query = query.eq('machine_id', machineId);
  }
  
  if (bodyParts != null && bodyParts.isNotEmpty) {
    query = query.overlaps('machine.body_parts', bodyParts);
  }
  
  if (movements != null && movements.isNotEmpty) {
    query = query.overlaps('machine.movements', movements);
  }
  
  if (type != null) {
    query = query.eq('machine.type', type);
  }
  
  final response = await query
      .order('like_count', ascending: false) // 리뷰 like_count 순으로 정렬
      .range(offset, offset + limit - 1);
  
  print('fetchMachineReviews result count: ${response.length}');
  return response;
}