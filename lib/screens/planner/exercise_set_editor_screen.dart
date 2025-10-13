import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:irondex/models/routine_exercise_draft.dart';

const double _columnSpacing = 12;

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
        : const [RoutineExerciseSetDraft(order: 1, isWarmup: true)];
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

  void _insertSetAfter(int index) {
    setState(() {
      final newEntry = _SetFormEntry(
        set: RoutineExerciseSetDraft(order: _entries.length + 1),
      );
      _entries.insert(index + 1, newEntry);
      _renumberSets();
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

  void _toggleWarmup(int index) {
    setState(() {
      final entry = _entries[index];
      entry.set = entry.set.copyWith(isWarmup: !entry.set.isWarmup);
    });
  }

  void _toggleCompleted(int index) {
    setState(() {
      final entry = _entries[index];
      entry.set = entry.set.copyWith(isCompleted: !entry.set.isCompleted);
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                itemBuilder: (context, index) {
                  return _SetRow(
                    index: index,
                    entry: _entries[index],
                    onWarmupToggle: () => _toggleWarmup(index),
                    onCompletedToggle: () => _toggleCompleted(index),
                    onRemove: () => _removeSet(index),
                    onInsertAfter: () => _insertSetAfter(index),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: _entries.length,
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  '세트',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
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
                  'KG',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
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
                  '회',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: _columnSpacing),
            Expanded(
              flex: 5,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  '완료',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
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
    required this.index,
    required this.entry,
    required this.onWarmupToggle,
    required this.onCompletedToggle,
    required this.onRemove,
    required this.onInsertAfter,
  });

  final int index;
  final _SetFormEntry entry;
  final VoidCallback onWarmupToggle;
  final VoidCallback onCompletedToggle;
  final VoidCallback onRemove;
  final VoidCallback onInsertAfter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final warmupLabel = entry.set.isWarmup ? 'W' : (index + 1).toString();
    final warmupColor = entry.set.isWarmup
        ? theme.colorScheme.error
        : theme.colorScheme.onSurface;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.center,
              child: _SetChip(
                label: warmupLabel,
                color: warmupColor,
                onTap: onWarmupToggle,
              ),
            ),
          ),
          const SizedBox(width: _columnSpacing),
          Expanded(
            flex: 4,
            child: _NumericField(
              controller: entry.weightController,
              hintText: 'KG',
            ),
          ),
          const SizedBox(width: _columnSpacing),
          Expanded(
            flex: 4,
            child: _NumericField(
              controller: entry.repsController,
              hintText: '횟수',
            ),
          ),
          const SizedBox(width: _columnSpacing),
          Expanded(
            flex: 5,
            child: Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CompletionButton(
                    isCompleted: entry.set.isCompleted,
                    onTap: onCompletedToggle,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        tooltip: '세트 추가',
                        onPressed: onInsertAfter,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: '세트 삭제',
                        onPressed: onRemove,
                      ),
                    ],
                  ),
                ],
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
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
        width: 48,
        height: 44,
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
        width: 48,
        height: 44,
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
          fit: BoxFit.cover,
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
