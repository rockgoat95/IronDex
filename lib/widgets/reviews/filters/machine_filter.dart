import 'package:flutter/material.dart';
import 'package:irondex/constants/filter_constants.dart';

class MachineFilter extends StatefulWidget {
  final void Function(List<String>?, String?) onFilterChanged;

  const MachineFilter({super.key, required this.onFilterChanged});

  @override
  State<MachineFilter> createState() => _MachineFilterState();
}

class _MachineFilterState extends State<MachineFilter> {
  List<String> selectedBodyParts = [];
  String? selectedType;

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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      });
                    },
                    isMultiSelect: true,
                  ),
                  const SizedBox(height: 20),
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
                      selectedBodyParts.clear();
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
