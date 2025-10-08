import 'package:flutter/material.dart';
import 'package:irondex/constants/filter_constants.dart';

class DetailFilterModal extends StatefulWidget {
  final List<String>? selectedBodyParts;
  final String? selectedMachineType;
  final ValueChanged<String?> onDetailFilterChanged;

  const DetailFilterModal({
    super.key,
    this.selectedBodyParts,
    this.selectedMachineType,
    required this.onDetailFilterChanged,
  });

  @override
  State<DetailFilterModal> createState() => _DetailFilterModalState();
}

class _DetailFilterModalState extends State<DetailFilterModal> {
  late String? selectedType;

  @override
  void initState() {
    super.initState();
    selectedType = widget.selectedMachineType;
  }

  Widget _buildFilterSection(
    String title,
    List<String> options,
    List<String> selectedValues,
    ValueChanged<String> onTap, {
    required bool isMultiSelect,
  }) {
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
              onSelected: (_) => onTap(option),
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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
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
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
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
                    widget.onDetailFilterChanged(selectedType);
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
