import 'package:flutter/material.dart';
import 'package:irondex/providers/machine_favorite_provider.dart';
import 'package:irondex/services/review_repository.dart';
import 'package:irondex/widgets/reviews/cards/machine_card.dart';
import 'package:provider/provider.dart';

class MachineList extends StatefulWidget {
  final String? brandId;
  final List<String>? bodyParts;
  final String? machineType;
  final String? searchQuery;
  final ValueChanged<Map<String, dynamic>>? onMachineTap;

  const MachineList({
    super.key,
    this.brandId,
    this.bodyParts,
    this.machineType,
    this.searchQuery,
    this.onMachineTap,
  });

  @override
  State<MachineList> createState() => _MachineListState();
}

class _MachineListState extends State<MachineList> {
  static const int _pageSize = 10;

  List<Map<String, dynamic>> _machines = [];
  bool _isInitialLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _offset = 0;

  @override
  void initState() {
    super.initState();
    _loadMachines(reset: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MachineFavoriteProvider>().refreshFavorites();
    });
  }

  @override
  void didUpdateWidget(MachineList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.brandId != widget.brandId ||
        oldWidget.bodyParts != widget.bodyParts ||
        oldWidget.machineType != widget.machineType ||
        oldWidget.searchQuery != widget.searchQuery) {
      _loadMachines(reset: true);
    }
  }

  Future<void> _loadMachines({bool reset = false}) async {
    if (reset) {
      setState(() {
        _isInitialLoading = true;
        _isLoadingMore = false;
        _hasMore = true;
        _offset = 0;
        _machines = [];
      });
    } else {
      if (!_hasMore || _isLoadingMore) {
        return;
      }
      setState(() {
        _isLoadingMore = true;
      });
    }

    final repository = context.read<ReviewRepository>();

    try {
      final result = await repository.fetchMachines(
        brandId: widget.brandId,
        bodyParts: widget.bodyParts,
        machineType: widget.machineType,
        searchQuery: widget.searchQuery,
        offset: _offset,
        limit: _pageSize,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        if (reset) {
          _machines = List<Map<String, dynamic>>.from(result);
        } else {
          _machines = List<Map<String, dynamic>>.from(_machines)
            ..addAll(result);
        }
        _offset += result.length;
        _hasMore = result.length == _pageSize;
        _isInitialLoading = false;
        _isLoadingMore = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isInitialLoading = false;
        _isLoadingMore = false;
        _hasMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('머신 목록을 불러오는 중 오류가 발생했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = context.watch<MachineFavoriteProvider>();

    if (_isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_machines.isEmpty) {
      return const Center(
        child: Text(
          'Machines are not found.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 200 &&
            _hasMore &&
            !_isLoadingMore &&
            !_isInitialLoading) {
          _loadMachines();
        }
        return false;
      },
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _machines.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.78,
            ),
            itemBuilder: (context, index) {
              final m = _machines[index];
              final brand = m['brand'] ?? {};
              final machineId = m['id']?.toString();
              final isFavorite = favoritesProvider.isFavorite(machineId);

              return GestureDetector(
                onTap: () {
                  widget.onMachineTap?.call(m);
                },
                child: MachineCard(
                  name: m['name'] ?? '',
                  imageUrl: m['image_url'] ?? '',
                  brandName: brand['name'] ?? '',
                  brandLogoUrl: brand['logo_url'] ?? '',
                  score: m['score'] != null
                      ? double.tryParse(m['score'].toString())
                      : null,
                  reviewCnt: m['review_cnt'] is int
                      ? m['review_cnt'] as int
                      : 0,
                  isFavorite: isFavorite,
                  onFavoriteToggle: machineId == null
                      ? null
                      : () async {
                          try {
                            await favoritesProvider.toggleFavorite(machineId);
                          } on StateError {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('로그인 후 이용해주세요.')),
                            );
                          } catch (error) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('찜 처리 중 오류가 발생했습니다.'),
                              ),
                            );
                          }
                        },
                ),
              );
            },
          ),
          if (_isLoadingMore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
