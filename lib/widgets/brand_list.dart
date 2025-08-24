import 'package:flutter/material.dart';
import 'brand_item.dart';
import '../supabase/meta.dart';

class BrandGrid extends StatefulWidget {
  const BrandGrid({super.key});

  @override
  State<BrandGrid> createState() => _BrandGridState();
}

class _BrandGridState extends State<BrandGrid> {
  late Future<List<Map<String, dynamic>>> _brandsFuture;

  @override
  void initState() {
    super.initState();
    _brandsFuture = fetchBrands();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _brandsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Text('브랜드 정보를 불러올 수 없습니다');
        }
        final brands = snapshot.data ?? [];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SizedBox(
            height: 100,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 0.75,
              ),
              itemCount: brands.length > 5 ? 5 : brands.length,
              itemBuilder: (context, index) {
                final brand = brands[index];
                return BrandItem(
                  name: brand['name'] ?? '',
                  image: brand['logo_url'],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
