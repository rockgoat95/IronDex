import 'package:flutter/material.dart';
import 'brand_item.dart';
import '../../supabase/fetcher.dart';

class BrandGrid extends StatefulWidget {
  final String? selectedBrandId;
  final Function(String?) onBrandSelected;

  const BrandGrid({
    super.key,
    this.selectedBrandId,
    required this.onBrandSelected,
  });

  @override
  State<BrandGrid> createState() => _BrandGridState();
}

class _BrandGridState extends State<BrandGrid> {
  late Future<List<Map<String, dynamic>>> _brandsFuture;
  bool _isExpanded = false;

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
          return const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return const Text('브랜드 정보를 불러올 수 없습니다');
        }
        final brands = snapshot.data ?? [];

        // Calculate the number of rows needed when expanded
        final crossAxisCount = _isExpanded ? 5 : 6;
        final itemCount = _isExpanded ? brands.length + 1 : (brands.length > 5 ? 6 : brands.length);
        final rowCount = (itemCount / crossAxisCount).ceil();
        
        // Animate the container height based on expanded state
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: _isExpanded ? rowCount * 100.0 : 100.0, // Adjust height based on rows
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: _isExpanded ? 0.85 : 0.7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              // Handle the more/less button
              if (!_isExpanded && index == 5) {
                return GestureDetector(
                  onTap: () => setState(() => _isExpanded = true),
                  child: const BrandItem(name: '더보기', isPlusButton: true),
                );
              }
              if (_isExpanded && index == brands.length) {
                 return GestureDetector(
                  onTap: () => setState(() => _isExpanded = false),
                  child: const BrandItem(name: '접기', isPlusButton: true, isUpIcon: true),
                );
              }

              if (index >= brands.length) {
                return Container();
              }

              final brand = brands[index];
              final brandId = brand['id']?.toString();
              final isSelected = widget.selectedBrandId == brandId;

              return GestureDetector(
                onTap: () {
                  widget.onBrandSelected(isSelected ? null : brandId);
                },
                child: BrandItem(
                  name: brand['name'] ?? '',
                  image: brand['logo_url'],
                  isSelected: isSelected,
                ),
              );
            },
          ),
        );
      },
    );
  }
}