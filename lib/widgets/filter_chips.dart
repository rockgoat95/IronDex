import 'package:flutter/material.dart';
import 'filter.dart';

class FilterChips extends StatelessWidget {
  final List<String>? selectedBodyParts;
  final List<String>? selectedMovements;
  final String? selectedMachineType;
  final Function(List<String>?, List<String>?, String?) onFilterChanged;

  const FilterChips({
    super.key,
    this.selectedBodyParts,
    this.selectedMovements,
    this.selectedMachineType,
    required this.onFilterChanged,
  });

  bool get hasActiveFilters {
    return (selectedBodyParts?.isNotEmpty == true ||
            selectedMovements?.isNotEmpty == true ||
            selectedMachineType?.isNotEmpty == true);
  }

  List<Widget> _buildActiveFilterChips() {
    List<Widget> chips = [];

    // 운동 부위 칩들
    if (selectedBodyParts != null) {
      for (String bodyPart in selectedBodyParts!) {
        chips.add(
          Chip(
            label: Text(bodyPart),
            deleteIcon: const Icon(Icons.close, size: 16),
            onDeleted: () {
              List<String> newBodyParts = List.from(selectedBodyParts!)
                ..remove(bodyPart);
              onFilterChanged(
                newBodyParts.isEmpty ? null : newBodyParts,
                selectedMovements,
                selectedMachineType,
              );
            },
            backgroundColor: Colors.blue.shade50,
            labelStyle: const TextStyle(color: Colors.blue),
          ),
        );
      }
    }

    // 운동 동작 칩들
    if (selectedMovements != null) {
      for (String movement in selectedMovements!) {
        chips.add(
          Chip(
            label: Text(movement),
            deleteIcon: const Icon(Icons.close, size: 16),
            onDeleted: () {
              List<String> newMovements = List.from(selectedMovements!)
                ..remove(movement);
              onFilterChanged(
                selectedBodyParts,
                newMovements.isEmpty ? null : newMovements,
                selectedMachineType,
              );
            },
            backgroundColor: Colors.green.shade50,
            labelStyle: const TextStyle(color: Colors.green),
          ),
        );
      }
    }

    // 머신 타입 칩
    if (selectedMachineType != null) {
      chips.add(
        Chip(
          label: Text(selectedMachineType!),
          deleteIcon: const Icon(Icons.close, size: 16),
          onDeleted: () {
            onFilterChanged(
              selectedBodyParts,
              selectedMovements,
              null,
            );
          },
          backgroundColor: Colors.orange.shade50,
          labelStyle: const TextStyle(color: Colors.orange),
        ),
      );
    }

    return chips;
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => MachineFilter(
        onFilterChanged: onFilterChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '필터',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              if (hasActiveFilters)
                TextButton(
                  onPressed: () {
                    onFilterChanged(null, null, null);
                  },
                  child: const Text('전체 삭제'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // 필터 추가 버튼
                ActionChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add,
                        size: 16,
                        color: hasActiveFilters ? Colors.blue : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        hasActiveFilters ? '필터 추가' : '필터 설정',
                        style: TextStyle(
                          color: hasActiveFilters ? Colors.blue : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  onPressed: () => _showFilterModal(context),
                  backgroundColor: hasActiveFilters ? Colors.blue.shade50 : Colors.grey.shade100,
                ),
                
                // 활성화된 필터 칩들
                if (hasActiveFilters) ...[
                  const SizedBox(width: 8),
                  ..._buildActiveFilterChips().map((chip) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: chip,
                  )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
