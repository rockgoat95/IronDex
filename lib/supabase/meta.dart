import 'package:supabase_flutter/supabase_flutter.dart';

Future<List<Map<String, dynamic>>> fetchBrands() async {
  final response = await Supabase.instance.client
      .from('brands')
      .select('name, logo_url');

  return response; // 이미 List<Map<String, dynamic>>
}


Future<List<Map<String, dynamic>>> fetchMachines() async {
  final response = await Supabase.instance.client
      .from('machines')
      .select('''
      name,
      status,
      image_url,
      review_cnt,
      body_parts,
      movements,
      type,
      brand:brands (
        name,
        logo_url
      )
    ''')
    .eq('status', 'approved'); // 승인된 머신만
  return response; // 이미 List<Map<String, dynamic>>
}
