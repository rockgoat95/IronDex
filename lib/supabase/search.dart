import 'package:supabase_flutter/supabase_flutter.dart';

Future<List<Map<String, dynamic>>> searchMachines(String query) async {
  if (query.isEmpty) {
    return [];
  }
  
  // 검색어를 소문자로 변환하고 공백 제거
  final cleanQuery = query.toLowerCase().trim();
  
  // 여러 키워드로 분리 (공백 기준)
  final keywords = cleanQuery.split(' ').where((k) => k.isNotEmpty).toList();
  
  // 1차: 머신 이름으로 검색
  final machineNameResults = await Supabase.instance.client
      .from('machines')
      .select('''
        id,
        name,
        image_url,
        brand:brands (
          name,
          logo_url
        )
      ''')
      .eq('status', 'approved')
      .ilike('name', '%$cleanQuery%')
      .limit(5);

  // 2차: 브랜드 이름으로 검색 (머신 이름 결과와 중복 제거)
  final brandNameResults = await Supabase.instance.client
      .from('machines')
      .select('''
        id,
        name,
        image_url,
        brand:brands (
          name,
          logo_url
        )
      ''')
      .eq('status', 'approved')
      .ilike('brand.name', '%$cleanQuery%')
      .limit(5);

  // 결과 합치기 및 중복 제거
  final allResults = <Map<String, dynamic>>[];
  final seenIds = <String>{};
  
  // 머신 이름 결과 추가 (우선순위 높음)
  for (final result in machineNameResults) {
    final id = result['id']?.toString();
    if (id != null && !seenIds.contains(id)) {
      allResults.add(result);
      seenIds.add(id);
    }
  }
  
  // 브랜드 이름 결과 추가 (중복 제거)
  for (final result in brandNameResults) {
    final id = result['id']?.toString();
    if (id != null && !seenIds.contains(id)) {
      allResults.add(result);
      seenIds.add(id);
    }
  }

  // 추가 퍼지 검색 - 키워드별로 부분 매칭
  if (keywords.length > 1 && allResults.length < 8) {
    for (final keyword in keywords) {
      if (keyword.length >= 2) { // 최소 2글자 이상
        final fuzzyResults = await Supabase.instance.client
            .from('machines')
            .select('''
              id,
              name,
              image_url,
              brand:brands (
                name,
                logo_url
              )
            ''')
            .eq('status', 'approved')
            .or('name.ilike.%$keyword%,brand.name.ilike.%$keyword%')
            .limit(3);
            
        for (final result in fuzzyResults) {
          final id = result['id']?.toString();
          if (id != null && !seenIds.contains(id) && allResults.length < 10) {
            allResults.add(result);
            seenIds.add(id);
          }
        }
      }
    }
  }

  return allResults.take(10).toList();
}
