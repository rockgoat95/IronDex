import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:irondex/models/free_weight.dart';
import 'package:irondex/services/repositories/free_weight_repository.dart';
import 'package:irondex/utils/body_part_formatter.dart';
import 'package:irondex/widgets/common/cards/machine_card.dart';
import 'package:provider/provider.dart';

class FreeWeightList extends StatefulWidget {
  const FreeWeightList({
    super.key,
    required this.scrollController,
    this.bodyParts,
    this.searchQuery,
    this.onFreeWeightTap,
  });

  final ScrollController scrollController;
  final List<String>? bodyParts;
  final String? searchQuery;
  final ValueChanged<FreeWeight>? onFreeWeightTap;

  @override
  State<FreeWeightList> createState() => _FreeWeightListState();
}

class _FreeWeightListState extends State<FreeWeightList> {
  static const int _pageSize = 20;

  List<FreeWeight> _items = <FreeWeight>[];
  bool _isInitialLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _offset = 0;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_handleScroll);
    _loadFreeWeights(reset: true);
  }

  @override
  void didUpdateWidget(FreeWeightList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController.removeListener(_handleScroll);
      widget.scrollController.addListener(_handleScroll);
    }

    final bodyPartsChanged = !_listEquals(
      oldWidget.bodyParts,
      widget.bodyParts,
    );

    if (bodyPartsChanged || oldWidget.searchQuery != widget.searchQuery) {
      _loadFreeWeights(reset: true);
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_handleScroll);
    super.dispose();
  }

  void _handleScroll() {
    if (!_hasMore || _isLoadingMore || _isInitialLoading) {
      return;
    }

    final position = widget.scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 160) {
      _loadFreeWeights();
    }
  }

  Future<void> _loadFreeWeights({bool reset = false}) async {
    if (!mounted) {
      return;
    }

    if (reset) {
      setState(() {
        _isInitialLoading = true;
        _isLoadingMore = false;
        _hasMore = true;
        _offset = 0;
        _items = <FreeWeight>[];
      });
    } else {
      if (!_hasMore || _isLoadingMore) {
        return;
      }
      setState(() {
        _isLoadingMore = true;
      });
    }

    final repository = context.read<FreeWeightRepository>();

    try {
      final fetched = await repository.fetchFreeWeights(
        bodyParts: widget.bodyParts,
        searchQuery: widget.searchQuery,
        offset: _offset,
        limit: _pageSize,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        if (reset) {
          _items = List<FreeWeight>.from(fetched);
        } else {
          _items = List<FreeWeight>.from(_items)..addAll(fetched);
        }
        _offset += fetched.length;
        _hasMore = fetched.length == _pageSize;
        _isInitialLoading = false;
        _isLoadingMore = false;
      });
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[FreeWeightList] load error=$error');
        debugPrintStack(stackTrace: stackTrace);
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _isInitialLoading = false;
        _isLoadingMore = false;
        _hasMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load free-weight exercises.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_items.isEmpty) {
      return const Center(
        child: Text(
          'No free-weight exercises found.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return CustomScrollView(
      controller: widget.scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 16),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate((context, index) {
              final item = _items[index];
              return _FreeWeightTile(
                freeWeight: item,
                onTap: widget.onFreeWeightTap,
              );
            }, childCount: _items.length),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.7,
            ),
          ),
        ),
        if (_isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }

  bool _listEquals(List<String>? a, List<String>? b) {
    if (identical(a, b)) {
      return true;
    }
    if (a == null || b == null) {
      return a == b;
    }
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }
}

class _FreeWeightTile extends StatelessWidget {
  const _FreeWeightTile({required this.freeWeight, this.onTap});

  final FreeWeight freeWeight;
  final ValueChanged<FreeWeight>? onTap;

  @override
  Widget build(BuildContext context) {
    final formattedName = formatDisplayName(freeWeight.name);
    final card = MachineCard(
      name: formattedName,
      imageUrl: freeWeight.imageUrl ?? '',
      brandName: 'Free Weight',
      brandLogoUrl: '',
      bodyParts: freeWeight.bodyParts,
      score: null,
      reviewCnt: null,
      onFavoriteToggle: null,
    );

    if (onTap == null) {
      return card;
    }

    return GestureDetector(
      onTap: () => onTap!(
        FreeWeight(
          id: freeWeight.id,
          name: formattedName,
          imageUrl: freeWeight.imageUrl,
          bodyParts: freeWeight.bodyParts,
        ),
      ),
      child: card,
    );
  }
}
