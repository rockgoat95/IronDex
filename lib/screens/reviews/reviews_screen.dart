import 'package:flutter/material.dart';
import 'package:irondex/providers/catalog_provider.dart';
import 'package:irondex/screens/reviews/review_create_screen.dart';
import 'package:irondex/widgets/reviews/reviews.dart';
import 'package:provider/provider.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CatalogProvider(),
      child: const _ReviewsScreenBody(),
    );
  }
}

class _ReviewsScreenBody extends StatefulWidget {
  const _ReviewsScreenBody();

  @override
  State<_ReviewsScreenBody> createState() => _ReviewsScreenBodyState();
}

class _ReviewsScreenBodyState extends State<_ReviewsScreenBody> {
  CatalogProvider get _filterProvider => context.read<CatalogProvider>();

  void _onBrandSelected(String? brandId) {
    _filterProvider.selectBrand(brandId);
  }

  void _onMachineSelected(String? machineId) {
    _filterProvider.selectMachine(machineId);
  }

  void _onBodyPartsChanged(List<String>? bodyParts) {
    _filterProvider.selectBodyParts(bodyParts);
  }

  void _onDetailFilterChanged(String? machineType) {
    _filterProvider.selectMachineType(machineType);
  }

  void _showDetailFilterModal() {
    final filter = context.read<CatalogProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DetailFilterModal(
        selectedBodyParts: filter.selectedBodyParts,
        selectedMachineType: filter.selectedMachineType,
        onDetailFilterChanged: _onDetailFilterChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filter = context.watch<CatalogProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              children: [
                _buildBrandFilters(filter),
                const SizedBox(height: 24),
                _buildMachineSection(filter),
                const SizedBox(height: 24),
                _buildReviewSection(filter),
              ],
            ),
          ),
          _buildFilterFab(),
          _buildReviewFab(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/logo/image.png', height: 32),
          const SizedBox(width: 8),
          const Text('Iron Dex', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildBrandFilters(CatalogProvider filter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BrandFilterGrid(
          selectedBrandId: filter.selectedBrandId,
          onBrandSelected: _onBrandSelected,
        ),
        const SizedBox(height: 12),
        BodyPartChips(
          selectedBodyParts: filter.selectedBodyParts,
          onBodyPartsChanged: _onBodyPartsChanged,
        ),
      ],
    );
  }

  Widget _buildMachineSection(CatalogProvider filter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Machine'),
        const SizedBox(height: 8),
        MachineList(
          brandId: filter.selectedBrandId,
          bodyParts: filter.selectedBodyParts,
          machineType: filter.selectedMachineType,
          selectedMachineId: filter.selectedMachineId,
          onMachineSelected: _onMachineSelected,
        ),
      ],
    );
  }

  Widget _buildReviewSection(CatalogProvider filter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Review'),
        const SizedBox(height: 8),
        ReviewList(
          brandId: filter.selectedBrandId,
          bodyParts: filter.selectedBodyParts,
          machineType: filter.selectedMachineType,
          selectedMachineId: filter.selectedMachineId,
        ),
      ],
    );
  }

  Text _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildFilterFab() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FloatingActionButton.small(
          heroTag: 'filter_button',
          onPressed: _showDetailFilterModal,
          backgroundColor: Colors.white,
          foregroundColor: Colors.grey.shade600,
          child: const Icon(Icons.tune),
        ),
      ),
    );
  }

  Widget _buildReviewFab() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Tooltip(
          message: '리뷰 작성',
          child: FloatingActionButton.small(
            heroTag: 'review_button',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReviewCreateScreen(),
                ),
              );
            },
            backgroundColor: Colors.white,
            foregroundColor: Colors.grey.shade600,
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
