import 'package:flutter/material.dart';
import '../constants/filter_constants.dart';

class MachineFilter extends StatefulWidget {
  final Function(List<String>?, List<String>?, String?) onFilterChanged;
  
  const MachineFilter({super.key, required this.onFilterChanged});

  @override
  State<MachineFilter> createState() => _MachineFilterState();
}

class _MachineFilterState extends State<MachineFilter> {
  List<String> selectedBodyParts = [];
  List<String> selectedMovements = [];
  String? selectedType;

  // 선택된 부위에 따른 움직임 리스트 반환
  List<String> get availableMovements {
    if (selectedBodyParts.isEmpty) {
      return FilterConstants.allMovements;
    }
    
    Set<String> movements = {};
    for (String bodyPart in selectedBodyParts) {
      movements.addAll(FilterConstants.bodyPartMovements[bodyPart] ?? []);
    }
    return movements.toList()..sort();
  }

  Widget _buildFilterSection(
    String title,
    List<String> options,
    List<String> selectedValues,
    Function(String) onTap,
    {required bool isMultiSelect}
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedValues.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) => onTap(option),
              selectedColor: Colors.blue.shade100,
              checkmarkColor: Colors.blue,
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Column(
        children: [
          // 헤더 (고정)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '필터',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 스크롤 가능한 콘텐츠 영역
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Body Parts 섹션
                  _buildFilterSection(
                    '부위',
                    FilterConstants.bodyParts,
                    selectedBodyParts,
                    (value) {
                      setState(() {
                        if (selectedBodyParts.contains(value)) {
                          selectedBodyParts.remove(value);
                        } else {
                          selectedBodyParts.add(value);
                        }
                        // 부위 변경시 관련없는 움직임 제거
                        selectedMovements.removeWhere((movement) => 
                          !availableMovements.contains(movement));
                      });
                    },
                    isMultiSelect: true,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Movements 섹션 - 부위가 선택된 경우에만 표시
                  if (selectedBodyParts.isNotEmpty) ...[
                    _buildFilterSection(
                      '동작',
                      availableMovements,
                      selectedMovements,
                      (value) {
                        setState(() {
                          if (selectedMovements.contains(value)) {
                            selectedMovements.remove(value);
                          } else {
                            selectedMovements.add(value);
                          }
                        });
                      },
                      isMultiSelect: true,
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  // Type 섹션
                  _buildFilterSection(
                    '머신 타입',
                    FilterConstants.machineTypes,
                    selectedType != null ? [selectedType!] : [],
                    (value) {
                      setState(() {
                        selectedType = selectedType == value ? null : value;
                      });
                    },
                    isMultiSelect: false,
                  ),
                  
                  // 하단 여백
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          
          // 하단 버튼들 (고정)
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      selectedBodyParts.clear();
                      selectedMovements.clear();
                      selectedType = null;
                    });
                  },
                  child: const Text('초기화'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onFilterChanged(
                      selectedBodyParts.isNotEmpty ? selectedBodyParts : null,
                      selectedMovements.isNotEmpty ? selectedMovements : null,
                      selectedType,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('적용'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
