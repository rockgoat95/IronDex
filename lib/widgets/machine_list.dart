import 'package:flutter/material.dart';
import '../supabase/meta.dart';
import 'machine_card.dart';

class MachineList extends StatefulWidget {
  const MachineList({super.key});

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

  Future<void> fetch() async {
    final result = await fetchMachines();
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
