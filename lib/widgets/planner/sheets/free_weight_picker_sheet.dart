import 'package:flutter/material.dart';
import 'package:irondex/models/catalog/machine.dart';
import 'package:irondex/models/free_weight.dart';
import 'package:irondex/providers/catalog_provider.dart';
import 'package:irondex/widgets/planner/lists/free_weight_list.dart';
import 'package:irondex/widgets/planner/sheets/exercise_picker_content.dart';
import 'package:irondex/widgets/reviews/filters/body_part_chips.dart';
import 'package:provider/provider.dart';

class FreeWeightPickerSheet extends StatelessWidget {
  const FreeWeightPickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CatalogProvider(),
      child: Builder(
        builder: (sheetContext) {
          final filter = sheetContext.watch<CatalogProvider>();
          return ExercisePickerContent(
            title: 'Select Free Weight',
            searchHint: 'Search free weight name',
            onClose: () => Navigator.of(sheetContext).maybePop(),
            additionalSections: [
              BodyPartChips(
                selectedBodyParts: filter.selectedBodyParts,
                onBodyPartsChanged: (parts) =>
                    sheetContext.read<CatalogProvider>().selectBodyParts(parts),
              ),
            ],
            listBuilder: (builderContext, scrollController, searchQuery) {
              return FreeWeightList(
                scrollController: scrollController,
                bodyParts: filter.selectedBodyParts,
                searchQuery: searchQuery,
                onFreeWeightTap: (FreeWeight freeWeight) {
                  final machine = Machine(
                    id: 'fw_${freeWeight.id}',
                    name: freeWeight.name,
                    imageUrl: freeWeight.imageUrl,
                    bodyParts: freeWeight.bodyParts,
                    type: 'Free Weight',
                  );
                  Navigator.of(builderContext).pop(machine);
                },
              );
            },
          );
        },
      ),
    );
  }
}
