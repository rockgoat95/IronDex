import 'package:flutter/material.dart';
import 'brand_item.dart';

class BrandGrid extends StatelessWidget {
  final List<Map<String, dynamic>> brands;
  const BrandGrid({super.key, required this.brands});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        height: 100,
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            childAspectRatio: 0.9,
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
  }
}
