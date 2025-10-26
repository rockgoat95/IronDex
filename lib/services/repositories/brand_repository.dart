import 'package:irondex/models/catalog/brand.dart';

abstract class BrandRepository {
  const BrandRepository();

  Future<List<Brand>> fetchBrands();
}
