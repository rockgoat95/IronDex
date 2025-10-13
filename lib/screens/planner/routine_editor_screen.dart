import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:irondex/models/routine_exercise_draft.dart';
import 'package:irondex/screens/planner/exercise_set_editor_screen.dart';
import 'package:irondex/widgets/planner/exercise_type_picker_sheet.dart';
import 'package:irondex/widgets/planner/machine_picker_sheet.dart';

class RoutineEditorScreen extends StatefulWidget {
  const RoutineEditorScreen({super.key, required this.targetDate});

  final DateTime targetDate;

  @override
  State<RoutineEditorScreen> createState() => _RoutineEditorScreenState();
}

class _RoutineEditorScreenState extends State<RoutineEditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  final List<RoutineExerciseDraft> _exercises = [];
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _handleAddExercise() async {
    final type = await showModalBottomSheet<RoutineExerciseSource>(
      context: context,
      builder: (_) => const ExerciseTypePickerSheet(),
    );

    if (!mounted || type == null) {
      return;
    }

    if (type == RoutineExerciseSource.freeWeight) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('프리웨이트 항목은 곧 추가될 예정입니다.')));
      return;
    }

    final selectedMachine = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const MachinePickerSheet(),
    );

    if (!mounted || selectedMachine == null) {
      return;
    }

    final brand = selectedMachine['brand'] as Map<String, dynamic>?;
    final brandName = brand == null
        ? null
        : (brand['name'] ?? brand['name_kor'])?.toString();

    setState(() {
      _exercises.add(
        RoutineExerciseDraft(
          machineId: selectedMachine['id']?.toString() ?? '',
          machineName: selectedMachine['name']?.toString() ?? '이름 없는 머신',
          brandName: brandName,
          brandLogoUrl: brand?['logo_url']?.toString(),
          imageUrl: selectedMachine['image_url']?.toString(),
          sets: const [RoutineExerciseSetDraft(order: 1, isWarmup: true)],
        ),
      );
    });
  }

  Future<void> _handleEditExercise(int index) async {
    final exercise = _exercises[index];
    final updated = await Navigator.of(context).push<RoutineExerciseDraft>(
      MaterialPageRoute(
        builder: (_) => ExerciseSetEditorScreen(exercise: exercise),
      ),
    );

    if (!mounted || updated == null) {
      return;
    }

    setState(() {
      _exercises[index] = updated;
    });
  }

  void _handleRemoveExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
    });
  }

  Future<void> _handleSaveRoutine() async {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('루틴 제목을 입력해주세요.')));
      return;
    }

    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('최소 한 개 이상의 운동을 추가해주세요.')));
      return;
    }

    setState(() {
      _isSaving = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 400));

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('루틴 저장 기능은 곧 제공될 예정입니다.')));
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat(
      'yyyy년 M월 d일 (E)',
      'ko_KR',
    ).format(widget.targetDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('새 루틴 만들기'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _handleSaveRoutine,
            child: _isSaving
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('저장'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                formattedDate,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '루틴 제목',
                  hintText: '예: 하체 머신 루틴',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _exercises.isEmpty
                    ? const _RoutineEmptyState()
                    : ListView.separated(
                        itemCount: _exercises.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final exercise = _exercises[index];
                          return _RoutineExerciseTile(
                            exercise: exercise,
                            onTap: () => _handleEditExercise(index),
                            onRemove: () => _handleRemoveExercise(index),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _isSaving ? null : _handleAddExercise,
                icon: const Icon(Icons.add),
                label: const Text('운동 추가'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoutineExerciseTile extends StatelessWidget {
  const _RoutineExerciseTile({
    required this.exercise,
    required this.onTap,
    required this.onRemove,
  });

  final RoutineExerciseDraft exercise;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (exercise.sets.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '${exercise.sets.length}세트 구성됨',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline),
              tooltip: '삭제',
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseThumbnail extends StatelessWidget {
  const _ExerciseThumbnail({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    const double size = 64;
    final placeholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
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
          color: Theme.of(context).colorScheme.surfaceVariant,
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
    final title = brandName?.isNotEmpty == true ? brandName! : '머신';

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
      mainAxisSize: MainAxisSize.min,
      children: [
        buildLogo(),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _RoutineEmptyState extends StatelessWidget {
  const _RoutineEmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.fitness_center, size: 48, color: theme.disabledColor),
          const SizedBox(height: 12),
          Text(
            '운동을 추가해서 루틴을 구성해보세요.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
