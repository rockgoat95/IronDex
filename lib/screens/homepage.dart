import 'package:flutter/material.dart';

import '../constants/filter_constants.dart';
import '../widgets/homepage/body_part_chips.dart';
import '../widgets/homepage/brand_list.dart';
import '../widgets/homepage/detail_filter_modal.dart';
import '../widgets/homepage/machine_list.dart';
import '../widgets/homepage/review_list.dart';
import 'writing_review.dart';

class Home extends StatefulWidget {
  final String title;
  const Home({super.key, required this.title});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // 필터 상태
  String? selectedBrandId;
  List<String>? selectedBodyParts;
  List<String>? selectedMovements;
  String? selectedMachineType;
  String? selectedMachineId; // 특정 머신 선택

  // 브랜드 필터 변경
  void _onBrandSelected(String? brandId) {
    setState(() {
      selectedBrandId = brandId;
      selectedMachineId = null; // 브랜드 변경시 머신 선택 해제
    });
  }

  // 머신 선택 변경
  void _onMachineSelected(String? machineId) {
    setState(() {
      selectedMachineId = machineId;
    });
  }

  // 부위 필터 변경
  void _onBodyPartsChanged(List<String>? bodyParts) {
    setState(() {
      selectedBodyParts = bodyParts;

      // 부위 변경시 관련없는 움직임 제거
      if (selectedMovements != null && bodyParts != null) {
        // 선택된 부위들에 대한 가능한 움직임들 계산
        Set<String> availableMovements = {};
        for (String bodyPart in bodyParts) {
          availableMovements.addAll(
            FilterConstants.bodyPartMovements[bodyPart] ?? [],
          );
        }

        // 기존 선택된 움직임 중 관련없는 것들 제거
        selectedMovements = selectedMovements!
            .where((movement) => availableMovements.contains(movement))
            .toList();

        if (selectedMovements!.isEmpty) {
          selectedMovements = null;
        }
      } else if (bodyParts == null) {
        // 부위가 모두 해제되면 움직임도 초기화
        selectedMovements = null;
      }
    });
  }

  // 세부 필터 변경
  void _onDetailFilterChanged(List<String>? movements, String? machineType) {
    setState(() {
      selectedMovements = movements;
      selectedMachineType = machineType;
    });
  }

  // 세부 필터 모달 표시
  void _showDetailFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DetailFilterModal(
        selectedBodyParts: selectedBodyParts,
        selectedMovements: selectedMovements,
        selectedMachineType: selectedMachineType,
        onDetailFilterChanged: _onDetailFilterChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(177, 226, 226, 226),
        elevation: 1,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('lib/logo/image.png', height: 32),
            const SizedBox(width: 8),
            const Text(
              'Iron Dex',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            child: ListView(
              children: [
                const SizedBox(height: 12),
                BrandGrid(
                  selectedBrandId: selectedBrandId,
                  onBrandSelected: _onBrandSelected,
                ),
                BodyPartChips(
                  selectedBodyParts: selectedBodyParts,
                  onBodyPartsChanged: _onBodyPartsChanged,
                ),
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Machine',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                MachineList(
                  brandId: selectedBrandId,
                  bodyParts: selectedBodyParts,
                  movements: selectedMovements,
                  machineType: selectedMachineType,
                  selectedMachineId: selectedMachineId,
                  onMachineSelected: _onMachineSelected,
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Review',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ReviewList(
                  brandId: selectedBrandId,
                  bodyParts: selectedBodyParts,
                  movements: selectedMovements,
                  machineType: selectedMachineType,
                  selectedMachineId: selectedMachineId,
                ),
              ],
            ),
          ),
          // 좌측 하단 필터 버튼
          Positioned(
            bottom: 16,
            left: 16,
            child: FloatingActionButton.small(
              heroTag: "filter_button",
              onPressed: _showDetailFilterModal,
              backgroundColor: Colors.white,
              foregroundColor: Colors.grey.shade600,
              child: const Icon(Icons.tune),
            ),
          ),
          // 우측 하단 리뷰 작성 버튼
          Positioned(
            bottom: 16,
            right: 16,
            child: Tooltip(
              message: "리뷰 작성",
              child: FloatingActionButton.small(
                heroTag: "review_button",
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
        ],
      ),
    );
  }
}
