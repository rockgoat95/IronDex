import 'package:supabase_flutter/supabase_flutter.dart';

Future<List<Map<String, dynamic>>> searchMachines(
  String query, {
  int limit = 10,
  int offset = 0,
}) async {
  if (query.isEmpty) return [];

  // 검색어 전처리
  final cleanQuery = query.toLowerCase().trim();

  final response = await Supabase.instance.client
      .from('machines_search')
      .select('''
        id,
        name,
        brand_name,
        body_parts,
        movements,
        image_url,
        logo_url
      ''')
      .filter('search_tsv', 'fts', cleanQuery)
      .range(offset, offset + limit - 1); // limit + offset 구현

  return List<Map<String, dynamic>>.from(response);
}
