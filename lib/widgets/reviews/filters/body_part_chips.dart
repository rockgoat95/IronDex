import 'package:flutter/material.dart';
import 'package:irondex/constants/filter_constants.dart';

class BodyPartChips extends StatelessWidget {
  final List<String>? selectedBodyParts;
  final ValueChanged<List<String>?> onBodyPartsChanged;

  const BodyPartChips({
    super.key,
    this.selectedBodyParts,
    required this.onBodyPartsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: FilterConstants.bodyParts.map((bodyPart) {
                final isSelected =
                    selectedBodyParts?.contains(bodyPart) ?? false;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    decoration: isSelected
                        ? BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withValues(alpha: 0.4),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          )
                        : null,
                    child: FilterChip(
                      label: Text(bodyPart),
                      selected: isSelected,
                      onSelected: (selected) {
                        final newSelection = List<String>.from(
                          selectedBodyParts ?? [],
                        );

                        if (selected) {
                          if (!newSelection.contains(bodyPart)) {
                            newSelection.add(bodyPart);
                          }
                        } else {
                          newSelection.remove(bodyPart);
                        }

                        onBodyPartsChanged(
                          newSelection.isEmpty ? null : newSelection,
                        );
                      },
                      selectedColor: Colors.white,
                      checkmarkColor: Colors.blue,
                      backgroundColor: Colors.white,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
