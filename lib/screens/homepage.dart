import 'package:flutter/material.dart';
import '../widgets/brand_list.dart';
import '../widgets/review_list.dart';
import '../widgets/machine_list.dart';
import '../widgets/filter_chips.dart';

class Home extends StatefulWidget {
  final String title;
  const Home({super.key, required this.title});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // 필터 상태
  List<String>? selectedBodyParts;
  List<String>? selectedMovements;
  String? selectedMachineType;

  // 필터 변경 콜백
  void _onFilterChanged(List<String>? bodyParts, List<String>? movements, String? machineType) {
    setState(() {
      selectedBodyParts = bodyParts;
      selectedMovements = movements;
      selectedMachineType = machineType;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            const SizedBox(height: 24),
            const BrandGrid(),
            const SizedBox(height: 12),
            FilterChips(
              selectedBodyParts: selectedBodyParts,
              selectedMovements: selectedMovements,
              selectedMachineType: selectedMachineType,
              onFilterChanged: _onFilterChanged,
            ),
            MachineList(
              bodyParts: selectedBodyParts,
              movements: selectedMovements,
              machineType: selectedMachineType,
            ),
            const SizedBox(height: 24),
            const Expanded(child: ReviewList()),
          ],
        ),
      ),
    );
  }
}