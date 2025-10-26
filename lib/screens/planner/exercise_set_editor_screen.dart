import 'package:flutter/material.dart';
import 'package:irondex/models/routine_exercise_draft.dart';
import 'package:irondex/widgets/planner/machine_summary_card.dart';

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

  void _handleFieldChanged() {
    setState(() {});
  }

  void _showCompletedEditWarning() {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Completed sets cannot be edited. Unmark Done to make changes.',
        ),
      ),
    );
  }

  void _showInvalidCompletionWarning() {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Enter valid numbers before marking a set as done.'),
      ),
    );
  }

  bool _isValidWeightText(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty || trimmed == '-') {
      return false;
    }
    return double.tryParse(trimmed) != null;
  }

  bool _isValidRepsText(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty || trimmed == '-') {
      return false;
    }
    return int.tryParse(trimmed) != null;
  }

  double? _parseWeight(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty || trimmed == '-') {
      return null;
    }
    return double.tryParse(trimmed);
  }

  int? _parseReps(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty || trimmed == '-') {
      return null;
    }
    return int.tryParse(trimmed);
  }

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
  .map((set) => _SetFormEntry(initialSet: set))
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
  _SetFormEntry(initialSet: RoutineExerciseSetDraft(order: nextOrder)),
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

  void _renumberSets() {
    for (var i = 0; i < _entries.length; i++) {
      final entry = _entries[i];
      entry.set = entry.set.copyWith(order: i + 1);
    }
  }

  RoutineExerciseDraft _buildUpdatedExercise() {
    final updatedSets = <RoutineExerciseSetDraft>[];
    for (var i = 0; i < _entries.length; i++) {
      final entry = _entries[i];
      final weight = _parseWeight(entry.weightController.text);
      final reps = _parseReps(entry.repsController.text);
      final updatedSet = entry.set.copyWith(
        order: i + 1,
        weight: weight,
        reps: reps,
      );
      entry.set = updatedSet;
      updatedSets.add(updatedSet);
    }
    return widget.exercise.copyWith(sets: updatedSets);
  }

  void _popWithUpdatedExercise() {
    final updatedExercise = _buildUpdatedExercise();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(updatedExercise);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        _popWithUpdatedExercise();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Edit Sets')),
        body: SafeArea(
          child: Column(
            children: [
              MachineSummaryCard(
                exercise: widget.exercise,
                margin: const EdgeInsets.all(16),
                thumbnailSize: 72,
              ),
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
                    final chipColor = _chipColorForSetType(
                      entry.set.type,
                      theme,
                    );
                    final weightValid = _isValidWeightText(
                      entry.weightController.text,
                    );
                    final repsValid = _isValidRepsText(
                      entry.repsController.text,
                    );
                    final completionEnabled =
                        entry.set.isCompleted || (weightValid && repsValid);
                    return _SetRow(
                      entry: entry,
                      displayLabel: displayLabel,
                      labelColor: chipColor,
                      onTypeTap: () => _selectSetType(index),
                      onCompletedToggle: () => _toggleCompleted(index),
                      onFieldChanged: _handleFieldChanged,
                      onAttemptEditCompleted: _showCompletedEditWarning,
                      completionEnabled: completionEnabled,
                      onCompletionBlocked: _showInvalidCompletionWarning,
                    );
                  },
                  separatorBuilder: (context, _) => const SizedBox(height: 12),
                  itemCount: _entries.length + 1,
                ),
              ),
            ],
          ),
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
              flex: 2,
              child: Align(
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Set',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: _columnSpacing),
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Weight (kg)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: _columnSpacing),
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Reps',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: _columnSpacing),
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Done',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
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
    required this.onFieldChanged,
    required this.onAttemptEditCompleted,
    required this.completionEnabled,
    required this.onCompletionBlocked,
  });

  final _SetFormEntry entry;
  final String displayLabel;
  final Color labelColor;
  final VoidCallback onTypeTap;
  final VoidCallback onCompletedToggle;
  final VoidCallback onFieldChanged;
  final VoidCallback onAttemptEditCompleted;
  final bool completionEnabled;
  final VoidCallback onCompletionBlocked;

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
            flex: 2,
            child: Align(
              alignment: Alignment.center,
              child: _SetChip(
                label: displayLabel,
                color: labelColor,
                onTap: entry.set.isCompleted
                    ? onAttemptEditCompleted
                    : onTypeTap,
              ),
            ),
          ),
          const SizedBox(width: _columnSpacing),
          Expanded(
            flex: 4,
            child: Align(
              alignment: Alignment.center,
              child: _NumericField(
                controller: entry.weightController,
                hintText: 'kg',
                readOnly: entry.set.isCompleted,
                onAttemptEditCompleted: onAttemptEditCompleted,
                onChanged: (_) => onFieldChanged(),
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
                hintText: 'reps',
                readOnly: entry.set.isCompleted,
                onAttemptEditCompleted: onAttemptEditCompleted,
                onChanged: (_) => onFieldChanged(),
              ),
            ),
          ),
          const SizedBox(width: _columnSpacing),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.center,
              child: _CompletionButton(
                isCompleted: entry.set.isCompleted,
                enabled: completionEnabled,
                onTap: onCompletedToggle,
                onDisabledTap: onCompletionBlocked,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumericField extends StatelessWidget {
  const _NumericField({
    required this.controller,
    required this.hintText,
    required this.readOnly,
    required this.onAttemptEditCompleted,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final bool readOnly;
  final VoidCallback onAttemptEditCompleted;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      readOnly: readOnly,
      onTap: readOnly ? onAttemptEditCompleted : null,
      onChanged: onChanged,
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
  const _CompletionButton({
    required this.isCompleted,
    required this.enabled,
    required this.onTap,
    required this.onDisabledTap,
  });

  final bool isCompleted;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback onDisabledTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: enabled ? onTap : onDisabledTap,
      child: Container(
        width: 40,
        height: 38,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Opacity(
          opacity: enabled || isCompleted ? 1 : 0.4,
          child: Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCompleted
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
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
            label: const Text('Add Set'),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: onRemove,
            style: OutlinedButton.styleFrom(minimumSize: const Size(112, 44)),
            icon: const Icon(Icons.remove),
            label: const Text('Remove Set'),
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
              'Select Set Type',
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
  color: theme.colorScheme.surfaceContainerHighest,
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
  _SetFormEntry({required RoutineExerciseSetDraft initialSet})
    : set = initialSet,
      weightController = TextEditingController(
        text: initialSet.weight != null
            ? initialSet.weight!.toString()
            : '-',
      ),
      repsController = TextEditingController(
        text: initialSet.reps != null ? initialSet.reps!.toString() : '-',
      );

  RoutineExerciseSetDraft set;
  final TextEditingController weightController;
  final TextEditingController repsController;

  void dispose() {
    weightController.dispose();
    repsController.dispose();
  }
}
