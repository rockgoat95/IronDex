import 'dart:async';

import 'package:flutter/material.dart';
import 'package:irondex/providers/catalog_provider.dart';
import 'package:irondex/screens/reviews/machine_reviews_screen.dart';
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
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String? _searchQuery;
  final ScrollController _scrollController = ScrollController();

  CatalogProvider get _filterProvider => context.read<CatalogProvider>();

  void _onBrandSelected(String? brandId) {
    _filterProvider.selectBrand(brandId);
  }

  void _onMachineTapped(Map<String, dynamic> machine) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MachineReviewsScreen(machine: machine)),
    );
  }

  void _onBodyPartsChanged(List<String>? bodyParts) {
    _filterProvider.selectBodyParts(bodyParts);
  }

  void _onDetailFilterChanged(String? machineType) {
    _filterProvider.selectMachineType(machineType);
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      final trimmed = value.trim();
      final nextQuery = trimmed.isEmpty ? null : trimmed;
      if (_searchQuery != nextQuery) {
        setState(() {
          _searchQuery = nextQuery;
        });
      }
    });
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
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              children: [
                _buildSearchField(),
                const SizedBox(height: 16),
                _buildBrandFilters(filter),
                const SizedBox(height: 24),
                _buildMachineSection(filter),
              ],
            ),
          ),
          _buildFilterFab(),
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
          searchQuery: _searchQuery,
          onMachineTap: _onMachineTapped,
          parentScrollController: _scrollController,
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        hintText: '머신 또는 브랜드명을 검색하세요',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
      ),
      textInputAction: TextInputAction.search,
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
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
}
