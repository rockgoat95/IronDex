import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:irondex/models/routine_exercise_draft.dart';

const double _columnSpacing = 8;

class ExerciseSetEditorScreen extends StatefulWidget {
  const ExerciseSetEditorScreen({super.key, required this.exercise});

  final RoutineExerciseDraft exercise;

  @override
  State<ExerciseSetEditorScreen> createState() =>
      _ExerciseSetEditorScreenState();
}

class _ExerciseSetEditorScreenState extends State<ExerciseSetEditorScreen> {
  late List<_SetFormEntry> _entries;

  @override
  void initState() {
    super.initState();
    final initialSets = widget.exercise.sets.isNotEmpty
        ? widget.exercise.sets
        : const [
            RoutineExerciseSetDraft(
              order: 1,
              type: RoutineExerciseSetType.warmup,
            ),
          ];
    _entries = initialSets
        .map((set) => _SetFormEntry(set: set))
        .toList(growable: true);
  }

  @override
  void dispose() {
    for (final entry in _entries) {
      entry.dispose();
    }
    super.dispose();
  }

  void _addSet() {
    setState(() {
      final nextOrder = _entries.length + 1;
      _entries.add(
        _SetFormEntry(set: RoutineExerciseSetDraft(order: nextOrder)),
      );
    });
  }

  void _removeSet(int index) {
    if (_entries.length <= 1) {
      return;
    }
    setState(() {
      _entries.removeAt(index).dispose();
      _renumberSets();
    });
  }

  void _removeLastSet() {
    _removeSet(_entries.length - 1);
  }

  void _toggleCompleted(int index) {
    setState(() {
      final entry = _entries[index];
      entry.set = entry.set.copyWith(isCompleted: !entry.set.isCompleted);
    });
  }

  int _mainSetNumberFor(int index) {
    var count = 0;
    for (var i = 0; i <= index; i++) {
      if (_entries[i].set.isMain) {
        count++;
      }
    }
    return count;
  }

  String _labelForSet(int index) {
    final entry = _entries[index];
    if (entry.set.isMain) {
      final sequence = _mainSetNumberFor(index);
      return sequence.toString();
    }
    final shortLabel = entry.set.type.shortLabel;
    return shortLabel.isNotEmpty ? shortLabel : '-';
  }

  Future<void> _selectSetType(int index) async {
    final currentType = _entries[index].set.type;
    final selectedType = await showModalBottomSheet<RoutineExerciseSetType>(
      context: context,
      builder: (context) => _SetTypePicker(currentType: currentType),
    );
    if (!mounted || selectedType == null || selectedType == currentType) {
      return;
    }
    setState(() {
      final entry = _entries[index];
      entry.set = entry.set.copyWith(type: selectedType);
    });
  }

  Future<void> _handleSave() async {
    final updatedSets = <RoutineExerciseSetDraft>[];
    for (var i = 0; i < _entries.length; i++) {
      final entry = _entries[i];
      final weight = double.tryParse(entry.weightController.text.trim());
      final reps = int.tryParse(entry.repsController.text.trim());
      updatedSets.add(
        entry.set.copyWith(order: i + 1, weight: weight, reps: reps),
      );
    }

    final updatedExercise = widget.exercise.copyWith(sets: updatedSets);
    if (!mounted) return;
    Navigator.of(context).pop(updatedExercise);
  }

  void _renumberSets() {
    for (var i = 0; i < _entries.length; i++) {
      final entry = _entries[i];
      entry.set = entry.set.copyWith(order: i + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      appBar: AppBar(
        title: const Text('세트 편집'),
        actions: [TextButton(onPressed: _handleSave, child: const Text('완료'))],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _ExerciseSummaryCard(exercise: widget.exercise),
            const SizedBox(height: 16),
            _SetTableHeader(theme: theme),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  (bottomInset > 0 ? bottomInset : 0) + 24,
                ),
                itemBuilder: (context, index) {
                  if (index == _entries.length) {
                    return _SetControlsRow(
                      onAdd: _addSet,
                      onRemove: _entries.length > 1 ? _removeLastSet : null,
                    );
                  }
                  final entry = _entries[index];
                  final displayLabel = _labelForSet(index);
                  final chipColor = _chipColorForSetType(entry.set.type, theme);
                  return _SetRow(
                    entry: entry,
                    displayLabel: displayLabel,
                    labelColor: chipColor,
                    onTypeTap: () => _selectSetType(index),
                    onCompletedToggle: () => _toggleCompleted(index),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: _entries.length + 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseSummaryCard extends StatelessWidget {
  const _ExerciseSummaryCard({required this.exercise});

  final RoutineExerciseDraft exercise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _ExerciseThumbnail(imageUrl: exercise.imageUrl),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BrandInfo(
                    brandLogoUrl: exercise.brandLogoUrl,
                    brandName: exercise.brandName,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    exercise.machineName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetTableHeader extends StatelessWidget {
  const _SetTableHeader({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  '세트',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: _columnSpacing),
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  '키로',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: _columnSpacing),
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  '회',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: _columnSpacing),
            Expanded(
              flex: 4,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  '완료',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  const _SetRow({
    required this.entry,
    required this.displayLabel,
    required this.labelColor,
    required this.onTypeTap,
    required this.onCompletedToggle,
  });

  final _SetFormEntry entry;
  final String displayLabel;
  final Color labelColor;
  final VoidCallback onTypeTap;
  final VoidCallback onCompletedToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.center,
              child: _SetChip(
                label: displayLabel,
                color: labelColor,
                onTap: onTypeTap,
              ),
            ),
          ),
          const SizedBox(width: _columnSpacing),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.center,
              child: _NumericField(
                controller: entry.weightController,
                hintText: 'KG',
              ),
            ),
          ),
          const SizedBox(width: _columnSpacing),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.center,
              child: _NumericField(
                controller: entry.repsController,
                hintText: '회',
              ),
            ),
          ),
          const SizedBox(width: _columnSpacing),
          Flexible(
            flex: 4,
            child: Align(
              alignment: Alignment.center,
              child: _CompletionButton(
                isCompleted: entry.set.isCompleted,
                onTap: onCompletedToggle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumericField extends StatelessWidget {
  const _NumericField({required this.controller, required this.hintText});

  final TextEditingController controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      ),
    );
  }
}

class _SetChip extends StatelessWidget {
  const _SetChip({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 38,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _CompletionButton extends StatelessWidget {
  const _CompletionButton({required this.isCompleted, required this.onTap});

  final bool isCompleted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 38,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Icon(
          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isCompleted
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _SetControlsRow extends StatelessWidget {
  const _SetControlsRow({required this.onAdd, required this.onRemove});

  final VoidCallback onAdd;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FilledButton.icon(
            onPressed: onAdd,
            style: FilledButton.styleFrom(minimumSize: const Size(112, 44)),
            icon: const Icon(Icons.add),
            label: const Text('세트 추가'),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: onRemove,
            style: OutlinedButton.styleFrom(minimumSize: const Size(112, 44)),
            icon: const Icon(Icons.remove),
            label: const Text('세트 제거'),
          ),
        ],
      ),
    );
  }
}

Color _chipColorForSetType(RoutineExerciseSetType type, ThemeData theme) {
  switch (type) {
    case RoutineExerciseSetType.warmup:
      return theme.colorScheme.tertiary;
    case RoutineExerciseSetType.drop:
      return theme.colorScheme.primary;
    case RoutineExerciseSetType.fail:
      return theme.colorScheme.error;
    case RoutineExerciseSetType.main:
      return theme.colorScheme.onSurface;
  }
}

String _typeSubtitle(RoutineExerciseSetType type) {
  switch (type) {
    case RoutineExerciseSetType.warmup:
      return '화면에서는 W로 표시됩니다';
    case RoutineExerciseSetType.drop:
      return '화면에서는 D로 표시됩니다';
    case RoutineExerciseSetType.fail:
      return '화면에서는 F로 표시됩니다';
    case RoutineExerciseSetType.main:
      return '화면에서는 1, 2, 3처럼 표시됩니다';
  }
}

class _SetTypePicker extends StatelessWidget {
  const _SetTypePicker({required this.currentType});

  final RoutineExerciseSetType currentType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '세트 유형 선택',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            for (final type in RoutineExerciseSetType.values) ...[
              ListTile(
                onTap: () => Navigator.of(context).pop(type),
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: _TypeBadge(
                  label: type == RoutineExerciseSetType.main
                      ? '#'
                      : type.shortLabel,
                  color: _chipColorForSetType(type, theme),
                ),
                title: Text(type.displayName),
                subtitle: Text(_typeSubtitle(type)),
                trailing: type == currentType
                    ? Icon(Icons.check, color: theme.colorScheme.primary)
                    : null,
              ),
              if (type != RoutineExerciseSetType.values.last)
                const Divider(height: 0),
            ],
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _SetFormEntry {
  _SetFormEntry({required RoutineExerciseSetDraft set})
    : _set = set,
      weightController = TextEditingController(
        text: set.weight != null ? set.weight!.toString() : '',
      ),
      repsController = TextEditingController(
        text: set.reps != null ? set.reps!.toString() : '',
      );

  RoutineExerciseSetDraft get set => _set;
  set set(RoutineExerciseSetDraft value) {
    _set = value;
  }

  RoutineExerciseSetDraft _set;
  final TextEditingController weightController;
  final TextEditingController repsController;

  void dispose() {
    weightController.dispose();
    repsController.dispose();
  }
}

class _ExerciseThumbnail extends StatelessWidget {
  const _ExerciseThumbnail({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    const double size = 72;
    final placeholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );

    final url = imageUrl;
    if (url == null || url.isEmpty) {
      return placeholder;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (_, __, ___) => placeholder,
      ),
    );
  }
}

class _BrandInfo extends StatelessWidget {
  const _BrandInfo({this.brandLogoUrl, this.brandName});

  final String? brandLogoUrl;
  final String? brandName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget buildLogo() {
      const double size = 24;
      if (brandLogoUrl == null || brandLogoUrl!.isEmpty) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.fitness_center,
            size: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        );
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: CachedNetworkImage(
          imageUrl: brandLogoUrl!,
          width: size,
          height: size,
          fit: BoxFit.contain,
          placeholder: (_, __) => Container(
            width: size,
            height: size,
            color: theme.colorScheme.surfaceVariant,
          ),
          errorWidget: (_, __, ___) => Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.fitness_center,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        buildLogo(),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            brandName?.isNotEmpty == true ? brandName! : '머신',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
