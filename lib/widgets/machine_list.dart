import 'package:flutter/material.dart';
import '../supabase/meta.dart';
import 'machine_card.dart';

class MachineList extends StatefulWidget {
  final List<String>? bodyParts;
  final List<String>? movements;
  final String? machineType;
  
  const MachineList({
    super.key,
    this.bodyParts,
    this.movements,
    this.machineType,
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
  }

  @override
  void didUpdateWidget(MachineList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 필터가 변경되면 다시 가져오기
    if (oldWidget.bodyParts != widget.bodyParts ||
        oldWidget.movements != widget.movements ||
        oldWidget.machineType != widget.machineType) {
      fetch();
    }
  }

  Future<void> fetch() async {
    setState(() {
      loading = true;
    });
    
    final result = await fetchMachines(
      bodyParts: widget.bodyParts,
      movements: widget.movements,
      machineType: widget.machineType,
    );
    
    setState(() {
      machines = result;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: machines.length,
        itemBuilder: (context, index) {
          final m = machines[index];
          final brand = m['brand'] ?? {};
          return MachineCard(
            name: m['name'] ?? '',
            imageUrl: m['image_url'] ?? '',
            brandName: brand['name'] ?? '',
            brandLogoUrl: brand['logo_url'] ?? '',
            score: m['score'] != null ? double.tryParse(m['score'].toString()) : null,
            reviewCnt: m['review_cnt'] is int ? m['review_cnt'] as int : 0,
          );
        },
      ),
    );
  }
}
