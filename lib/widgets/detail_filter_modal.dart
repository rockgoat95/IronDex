import 'package:flutter/material.dart';
import '../constants/filter_constants.dart';

class DetailFilterModal extends StatefulWidget {
  final List<String>? selectedBodyParts;
  final List<String>? selectedMovements;
  final String? selectedMachineType;
  final Function(List<String>?, String?) onDetailFilterChanged;

  const DetailFilterModal({
    super.key,
    this.selectedBodyParts,
    this.selectedMovements,
    this.selectedMachineType,
    required this.onDetailFilterChanged,
  });

  @override
  State<DetailFilterModal> createState() => _DetailFilterModalState();
}

class _DetailFilterModalState extends State<DetailFilterModal> {
  late List<String> selectedMovements;
  late String? selectedType;

  @override
  void initState() {
    super.initState();
    selectedMovements = List.from(widget.selectedMovements ?? []);
    selectedType = widget.selectedMachineType;
  }

  // 선택된 부위에 따른 움직임 리스트 반환
  List<String> get availableMovements {
    if (widget.selectedBodyParts?.isEmpty ?? true) {
      return []; // 부위가 선택되지 않으면 빈 리스트
    }
    
    Set<String> movements = {};
    for (String bodyPart in widget.selectedBodyParts!) {
      movements.addAll(FilterConstants.bodyPartMovements[bodyPart] ?? []);
    }
    return movements.toList()..sort();
  }

  bool get hasSelectedBodyParts => widget.selectedBodyParts?.isNotEmpty ?? false;

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
              selectedColor: Colors.green.shade100,
              checkmarkColor: Colors.green,
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        children: [
          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '세부 필터',
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
                  // 선택된 부위 정보
                  if (widget.selectedBodyParts?.isNotEmpty ?? false) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '선택된 부위',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.selectedBodyParts!.join(', '),
                            style: TextStyle(color: Colors.blue.shade700),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  // 움직임 섹션 - 부위가 선택된 경우에만 표시
                  if (hasSelectedBodyParts) ...[
                    _buildFilterSection(
                      '운동 동작',
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
                  ] else ...[
                    // 부위가 선택되지 않았을 때 안내 메시지
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.grey.shade600,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '운동 동작 필터',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '먼저 운동 부위를 선택하면\n관련 동작들을 선택할 수 있습니다',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  // 머신 타입 섹션
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
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          
          // 하단 버튼들
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
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
                    widget.onDetailFilterChanged(
                      selectedMovements.isEmpty ? null : selectedMovements,
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
