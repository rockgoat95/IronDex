import 'package:supabase_flutter/supabase_flutter.dart';

Future<List<Map<String, dynamic>>> fetchBrands() async {
  final response = await Supabase.instance.client
      .from('brands')
      .select('name, logo_url');

  return response; // 이미 List<Map<String, dynamic>>
}