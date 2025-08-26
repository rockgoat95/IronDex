import 'package:supabase_flutter/supabase_flutter.dart';

Future<List<Map<String, dynamic>>> fetchBrands() async {
  final response = await Supabase.instance.client
      .from('brands')
      .select('id, name, logo_url');

  return response; // 이미 List<Map<String, dynamic>>
}


Future<List<Map<String, dynamic>>> fetchMachines({
  List<String>? bodyParts,
  List<String>? movements,
  String? machineType,
}) async {
  var query = Supabase.instance.client
      .from('machines')
      .select('''
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
  
  if (brandId != null) {
    query = query.eq('machine.brand_id', brandId);
  }
  
  if (bodyParts != null && bodyParts.isNotEmpty) {
    query = query.contains('machine.body_parts', bodyParts);
  }
  
  if (movements != null && movements.isNotEmpty) {
    query = query.contains('machine.movements', movements);
  }
  
  if (type != null) {
    query = query.eq('machine.type', type);
  }
  
  final response = await query
      .order('like_count', ascending: false) // 리뷰 like_count 순으로 정렬
      .range(offset, offset + limit - 1);
  
  return response;
}