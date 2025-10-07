import 'package:flutter/material.dart';

import '../../supabase/fetcher.dart';
import 'brand_item.dart';

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
  final ScrollController _scrollController = ScrollController();

  static const double _collapsedHeight = 100.0;
  static const double _expandedRowHeight = 84.0;
  static const int _visibleRowsWhenExpanded = 3;
  static const int _collapsedCrossAxisCount = 6;
  static const int _expandedCrossAxisCount = 5;

  @override
  void initState() {
    super.initState();
    _brandsFuture = fetchBrands();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

        if (_isExpanded) {
          return Column(
            key: const ValueKey('expanded'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: _expandedRowHeight * _visibleRowsWhenExpanded,
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  trackVisibility: true,
                  radius: const Radius.circular(8),
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.zero,
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _expandedCrossAxisCount,
                          childAspectRatio: 0.85,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                        ),
                    itemCount: brands.length,
                    itemBuilder: (context, index) {
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
                ),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => setState(() => _isExpanded = false),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 12,
                  ),
                  minimumSize: const Size.fromHeight(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  foregroundColor: Colors.grey[700],
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey.shade300, width: 1),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Icon(Icons.keyboard_arrow_up, size: 18),
                    SizedBox(width: 4),
                    Text(
                      '접기',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          );
        }

        final bool hasMoreBrands = brands.length > 5;
        final int itemCount = hasMoreBrands ? 6 : brands.length;

        return SizedBox(
          key: const ValueKey('collapsed'),
          height: _collapsedHeight,
          child: GridView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _collapsedCrossAxisCount,
              childAspectRatio: 0.7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              if (hasMoreBrands && index == 5) {
                return GestureDetector(
                  onTap: () => setState(() => _isExpanded = true),
                  child: const BrandItem(name: '더보기', isPlusButton: true),
                );
              }

              if (index >= brands.length) {
                return const SizedBox.shrink();
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
