import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:irondex/models/catalog/machine.dart';
import 'package:irondex/providers/machine_favorite_provider.dart';
import 'package:irondex/services/repositories/machine_repository.dart';
import 'package:irondex/widgets/common/cards/machine_card.dart';
import 'package:provider/provider.dart';

class MachineList extends StatefulWidget {
  const MachineList({
    super.key,
    this.brandId,
    this.bodyParts,
    this.machineType,
    this.searchQuery,
    this.onMachineTap,
    this.parentScrollController,
    this.standalone = false,
  });

  final String? brandId;
  final List<String>? bodyParts;
  final String? machineType;
  final String? searchQuery;
  final ValueChanged<Machine>? onMachineTap;
  final ScrollController? parentScrollController;
  final bool standalone;

  @override
  State<MachineList> createState() => _MachineListState();
}

class _MachineListState extends State<MachineList> {
  static const int _pageSize = 10;

  List<Machine> _machines = <Machine>[];
  bool _isInitialLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _offset = 0;
  ScrollController? _attachedScrollController;
  ScrollController? _ownedScrollController;

  @override
  void initState() {
    super.initState();
    if (widget.standalone) {
      _initializeStandaloneController(widget.parentScrollController);
    }
    _loadMachines(reset: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MachineFavoriteProvider>().refreshFavorites();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.standalone) {
      return;
    }
    _attachScrollController(
      widget.parentScrollController ?? PrimaryScrollController.maybeOf(context),
    );
  }

  @override
  void didUpdateWidget(MachineList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.standalone) {
      if (oldWidget.parentScrollController != widget.parentScrollController) {
        _initializeStandaloneController(widget.parentScrollController);
      }
    } else {
      if (oldWidget.parentScrollController != widget.parentScrollController) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _attachScrollController(
            widget.parentScrollController ??
                PrimaryScrollController.maybeOf(context),
          );
        });
      }
    }
    if (oldWidget.brandId != widget.brandId ||
        oldWidget.bodyParts != widget.bodyParts ||
        oldWidget.machineType != widget.machineType ||
        oldWidget.searchQuery != widget.searchQuery) {
      _loadMachines(reset: true);
    }
  }

  @override
  void dispose() {
    _detachScrollController();
    super.dispose();
  }

  void _initializeStandaloneController(ScrollController? controller) {
    _detachScrollController();
    if (controller != null) {
      _attachedScrollController = controller;
      _attachedScrollController?.addListener(_handleScroll);
    } else {
      _ownedScrollController = ScrollController();
      _ownedScrollController!.addListener(_handleScroll);
      _attachedScrollController = _ownedScrollController;
    }
  }

  void _attachScrollController(ScrollController? controller) {
    if (widget.standalone) {
      return;
    }
    if (controller == _attachedScrollController) {
      return;
    }

    _detachScrollController();
    _attachedScrollController = controller;
    _attachedScrollController?.addListener(_handleScroll);
  }

  void _detachScrollController() {
    _attachedScrollController?.removeListener(_handleScroll);
    if (_ownedScrollController != null) {
      _ownedScrollController!.dispose();
      _ownedScrollController = null;
    }
    _attachedScrollController = null;
  }

  void _handleScroll() {
    final controller = _attachedScrollController;
    if (controller == null || !controller.hasClients) {
      return;
    }

    final position = controller.position;
    _maybeLoadMore(position.pixels, position.maxScrollExtent);
  }

  void _maybeLoadMore(double pixels, double maxScrollExtent) {
    if (pixels >= maxScrollExtent - 200 &&
        _hasMore &&
        !_isLoadingMore &&
        !_isInitialLoading) {
      _loadMachines();
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

    final repository = context.read<MachineRepository>();

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
          _machines = List<Machine>.from(result);
        } else {
          _machines = List<Machine>.from(_machines)..addAll(result);
        }
        _offset += result.length;
        _hasMore = result.length == _pageSize;
        _isInitialLoading = false;
        _isLoadingMore = false;
      });
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[MachineList] _loadMachines error=$error');
      }
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

    if (widget.standalone) {
      return CustomScrollView(
        controller: _attachedScrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 16),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                final m = _machines[index];
                return _MachineTile(
                  machine: m,
                  favoritesProvider: favoritesProvider,
                  onTap: widget.onMachineTap,
                );
              }, childCount: _machines.length),
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

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _maybeLoadMore(
          notification.metrics.pixels,
          notification.metrics.maxScrollExtent,
        );
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
              childAspectRatio: 0.7,
            ),
            itemBuilder: (context, index) {
              final m = _machines[index];
              return _MachineTile(
                machine: m,
                favoritesProvider: favoritesProvider,
                onTap: widget.onMachineTap,
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

class _MachineTile extends StatelessWidget {
  const _MachineTile({
    required this.machine,
    required this.favoritesProvider,
    required this.onTap,
  });

  final Machine machine;
  final MachineFavoriteProvider favoritesProvider;
  final ValueChanged<Machine>? onTap;

  @override
  Widget build(BuildContext context) {
    final brand = machine.brand;
    final brandName = brand?.resolvedName(preferKorean: false) ?? '';
    final machineId = machine.id;
    final hasValidId = machineId.isNotEmpty;
    final isFavorite = hasValidId && favoritesProvider.isFavorite(machineId);

    return GestureDetector(
      onTap: () => onTap?.call(machine),
      child: MachineCard(
        name: machine.name,
        imageUrl: machine.imageUrl ?? '',
        brandName: brandName,
        brandLogoUrl: brand?.logoUrl ?? '',
        score: machine.score,
        reviewCnt: machine.reviewCount,
        isFavorite: isFavorite,
        onFavoriteToggle: hasValidId
            ? () async {
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
                    const SnackBar(content: Text('찜 처리 중 오류가 발생했습니다.')),
                  );
                }
              }
            : null,
      ),
    );
  }
}
