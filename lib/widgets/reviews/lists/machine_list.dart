import 'package:flutter/material.dart';
import 'package:irondex/providers/machine_favorite_provider.dart';
import 'package:irondex/services/review_repository.dart';
import 'package:irondex/widgets/reviews/cards/machine_card.dart';
import 'package:provider/provider.dart';

class MachineList extends StatefulWidget {
  final String? brandId;
  final List<String>? bodyParts;
  final String? machineType;
  final String? selectedMachineId;
  final String? searchQuery;
  final ValueChanged<String?>? onMachineSelected;

  const MachineList({
    super.key,
    this.brandId,
    this.bodyParts,
    this.machineType,
    this.selectedMachineId,
    this.searchQuery,
    this.onMachineSelected,
  });

  @override
  State<MachineList> createState() => _MachineListState();
}

class _MachineListState extends State<MachineList> {
  List<Map<String, dynamic>> machines = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetch();
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
        oldWidget.selectedMachineId != widget.selectedMachineId ||
        oldWidget.searchQuery != widget.searchQuery) {
      fetch();
    }
  }

  Future<void> fetch() async {
    setState(() {
      loading = true;
    });

    final repository = context.read<ReviewRepository>();

    final result = await repository.fetchMachines(
      brandId: widget.brandId,
      bodyParts: widget.bodyParts,
      machineType: widget.machineType,
      searchQuery: widget.searchQuery,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      machines = result;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = context.watch<MachineFavoriteProvider>();

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (machines.isEmpty) {
      return const Center(
        child: Text(
          'Machines are not found.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: machines.length,
        itemBuilder: (context, index) {
          final m = machines[index];
          final brand = m['brand'] ?? {};
          final machineId = m['id']?.toString();
          final isSelected = widget.selectedMachineId == machineId;
          final isFavorite = favoritesProvider.isFavorite(machineId);

          return GestureDetector(
            onTap: () {
              widget.onMachineSelected?.call(isSelected ? null : machineId);
            },
            child: MachineCard(
              name: m['name'] ?? '',
              imageUrl: m['image_url'] ?? '',
              brandName: brand['name'] ?? '',
              brandLogoUrl: brand['logo_url'] ?? '',
              score: m['score'] != null
                  ? double.tryParse(m['score'].toString())
                  : null,
              reviewCnt: m['review_cnt'] is int ? m['review_cnt'] as int : 0,
              isSelected: isSelected,
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
                          const SnackBar(content: Text('찜 처리 중 오류가 발생했습니다.')),
                        );
                      }
                    },
            ),
          );
        },
      ),
    );
  }
}
