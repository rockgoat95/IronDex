import 'package:flutter/foundation.dart';
import 'package:irondex/models/catalog/brand.dart';
import 'package:irondex/services/core/supabase_service.dart';
import 'package:irondex/services/repositories/brand_repository.dart';

class SupabaseBrandRepository extends SupabaseService
    implements BrandRepository {
  SupabaseBrandRepository({super.client});

  @override
  Future<List<Brand>> fetchBrands() async {
    final response = await client
        .schema('catalog')
        .from('brands')
        .select('id, name, logo_url');

    final data = List<Map<String, dynamic>>.from(
      response,
    ).map(Brand.fromMap).toList();

    if (kDebugMode) {
      debugPrint('[SupabaseBrandRepository] fetchBrands count=${data.length}');
    }

    return data;
  }
}
