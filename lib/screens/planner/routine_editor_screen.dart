import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  final List<_DraftRoutineExercise> _exercises = [];
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
        _DraftRoutineExercise(
          machineId: selectedMachine['id']?.toString() ?? '',
          machineName: selectedMachine['name']?.toString() ?? '이름 없는 머신',
          brandName: brandName,
          imageUrl: selectedMachine['image_url']?.toString(),
        ),
      );
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
                            order: index + 1,
                            exercise: exercise,
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

class _DraftRoutineExercise {
  _DraftRoutineExercise({
    required this.machineId,
    required this.machineName,
    this.brandName,
    this.imageUrl,
  });

  final String machineId;
  final String machineName;
  final String? brandName;
  final String? imageUrl;
}

class _RoutineExerciseTile extends StatelessWidget {
  const _RoutineExerciseTile({
    required this.order,
    required this.exercise,
    required this.onRemove,
  });

  final int order;
  final _DraftRoutineExercise exercise;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: theme.colorScheme.primary,
            child: Text(
              order.toString(),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.machineName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (exercise.brandName != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      exercise.brandName!,
                      style: theme.textTheme.bodyMedium?.copyWith(
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
