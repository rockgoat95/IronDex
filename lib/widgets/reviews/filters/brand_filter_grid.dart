import 'package:flutter/material.dart';
import 'package:irondex/models/catalog/brand.dart';
import 'package:irondex/services/repositories/brand_repository.dart';
import 'package:irondex/widgets/common/tiles/brand_item.dart';
import 'package:provider/provider.dart';

class BrandFilterGrid extends StatefulWidget {
  final String? selectedBrandId;
  final ValueChanged<String?> onBrandSelected;

  const BrandFilterGrid({
    super.key,
    this.selectedBrandId,
    required this.onBrandSelected,
  });

  @override
  State<BrandFilterGrid> createState() => _BrandFilterGridState();
}

class _BrandFilterGridState extends State<BrandFilterGrid> {
  late Future<List<Brand>> _brandsFuture;
  bool _isExpanded = false;
  final ScrollController _scrollController = ScrollController();

  static const double _expandedRowHeight = 84.0;
  static const int _visibleRowsWhenExpanded = 3;
  static const int _collapsedCrossAxisCount = 6;
  static const int _expandedCrossAxisCount = 5;

  @override
  void initState() {
    super.initState();
    _brandsFuture = context.read<BrandRepository>().fetchBrands();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Brand>>(
      future: _brandsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return const Text('Unable to load brand information');
        }
        final brands = snapshot.data ?? <Brand>[];

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
                          childAspectRatio: 0.82,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                        ),
                    itemCount: brands.length,
                    itemBuilder: (context, index) {
                      final brand = brands[index];
                      final isSelected = widget.selectedBrandId == brand.id;

                      return GestureDetector(
                        onTap: () {
                          widget.onBrandSelected(isSelected ? null : brand.id);
                        },
                        child: BrandItem(
                          name: brand.resolvedName(),
                          image: brand.logoUrl,
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
                      'Collapse',
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

        return GridView.builder(
          key: const ValueKey('collapsed'),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _collapsedCrossAxisCount,
            childAspectRatio: 0.72,
            mainAxisSpacing: 2,
            crossAxisSpacing: 4,
          ),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            if (hasMoreBrands && index == 5) {
              return GestureDetector(
                onTap: () => setState(() => _isExpanded = true),
                child: const BrandItem(name: 'More', isPlusButton: true),
              );
            }

            if (index >= brands.length) {
              return const SizedBox.shrink();
            }

            final brand = brands[index];
            final isSelected = widget.selectedBrandId == brand.id;

            return GestureDetector(
              onTap: () {
                widget.onBrandSelected(isSelected ? null : brand.id);
              },
              child: BrandItem(
                name: brand.resolvedName(),
                image: brand.logoUrl,
                isSelected: isSelected,
              ),
            );
          },
        );
      },
    );
  }
}
