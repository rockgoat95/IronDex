import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:irondex/models/planner_routine.dart';
import 'package:irondex/models/routine_exercise_draft.dart';
import 'package:irondex/screens/planner/exercise_set_editor_screen.dart';
import 'package:irondex/services/planner_repository.dart';
import 'package:irondex/widgets/planner/exercise_type_picker_sheet.dart';
import 'package:irondex/widgets/planner/machine_picker_sheet.dart';
import 'package:irondex/widgets/planner/machine_summary_card.dart';

class RoutineEditorScreen extends StatefulWidget {
  const RoutineEditorScreen({super.key, required this.targetDate});

  final DateTime targetDate;

  @override
  State<RoutineEditorScreen> createState() => _RoutineEditorScreenState();
}

class _RoutineEditorScreenState extends State<RoutineEditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  final List<RoutineExerciseDraft> _exercises = [];
  final PlannerRepository _plannerRepository = PlannerRepository();

  Timer? _autoSaveDebounce;
  int? _workoutId;
  PlannerRoutineStatus _status = PlannerRoutineStatus.draft;
  bool _isLoading = true;
  bool _autoSaveInProgress = false;
  bool _hasPendingChanges = false;
  bool _isHydrating = true;
  String? _loadError;
  bool _shouldNotifySaveOnExit = false;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_handleTitleChanged);
    _loadRoutine();
  }

  @override
  void dispose() {
    _autoSaveDebounce?.cancel();
    _titleController.removeListener(_handleTitleChanged);
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _loadRoutine() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
      _isHydrating = true;
    });

    try {
      final routine = await _plannerRepository.fetchRoutine(widget.targetDate);
      if (!mounted) return;

      if (routine != null) {
        _titleController.text = routine.name ?? '';
        setState(() {
          _workoutId = routine.id;
          _status = routine.status;
          _exercises
            ..clear()
            ..addAll(routine.exercises);
          _hasPendingChanges = false;
        });
      } else {
        _titleController.clear();
        setState(() {
          _workoutId = null;
          _status = PlannerRoutineStatus.draft;
          _exercises.clear();
          _hasPendingChanges = false;
        });
      }
    } on PlannerRepositoryException catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.message;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error, stackTrace) {
      debugPrint('[RoutineEditor] loadRoutine error=$error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        _loadError = '루틴 정보를 불러오지 못했습니다.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('루틴 정보를 불러오지 못했습니다. 잠시 후 다시 시도해주세요.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isHydrating = false;
        });
      }
    }
  }

  void _handleTitleChanged() {
    if (_isHydrating) {
      return;
    }
    _markContentDirty();
  }

  void _markContentDirty() {
    if (_isLoading) {
      return;
    }

    final shouldResetStatus = _status == PlannerRoutineStatus.completed;
    if (!shouldResetStatus && _hasPendingChanges) {
      _scheduleAutoSave();
      return;
    }

    setState(() {
      if (shouldResetStatus) {
        _status = PlannerRoutineStatus.draft;
      }
      _hasPendingChanges = true;
    });
    _scheduleAutoSave();
  }

  void _scheduleAutoSave() {
    _autoSaveDebounce?.cancel();
    _autoSaveDebounce = Timer(const Duration(milliseconds: 750), () {
      _autoSaveDebounce = null;
      _saveRoutine(isAuto: true);
    });
  }

  Future<void> _saveRoutine({required bool isAuto}) async {
    if (_isLoading) {
      return;
    }

    if (isAuto && !_hasPendingChanges) {
      return;
    }

    final trimmedTitle = _titleController.text.trim();
    final nextStatus = _status;

    setState(() {
      if (isAuto) {
        _autoSaveInProgress = true;
      }
      _loadError = null;
    });

    try {
      final saved = await _plannerRepository.saveRoutineDraft(
        workoutId: _workoutId,
        date: widget.targetDate,
        name: trimmedTitle.isEmpty ? null : trimmedTitle,
        exercises: List<RoutineExerciseDraft>.from(_exercises),
        status: nextStatus,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _workoutId = saved.id;
        _status = saved.status;
        _hasPendingChanges = false;
      });

      if (!isAuto) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('변경 사항이 저장되었습니다.')));
      }
    } on PlannerRepositoryException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadError = error.message;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error, stackTrace) {
      debugPrint('[RoutineEditor] saveRoutine error=$error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('루틴 저장 중 문제가 발생했습니다. 다시 시도해주세요.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          if (isAuto) {
            _autoSaveInProgress = false;
          }
        });
      }
    }
  }

  Future<void> _handleAddExercise() async {
    if (_isLoading) {
      return;
    }

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
          sets: const [
            RoutineExerciseSetDraft(
              order: 1,
              type: RoutineExerciseSetType.warmup,
            ),
          ],
        ),
      );
    });

    _markContentDirty();
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
    _markContentDirty();
  }

  void _handleRemoveExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
    });
    _markContentDirty();
  }

  Future<bool> _handleWillPop() async {
    _autoSaveDebounce?.cancel();

    if (_autoSaveInProgress) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('저장 중입니다. 잠시만 기다려주세요.')));
      return false;
    }

    final hadPendingChanges = _hasPendingChanges;
    if (hadPendingChanges) {
      await _saveRoutine(isAuto: true);
      if (_hasPendingChanges) {
        return false;
      }
    }
    _shouldNotifySaveOnExit = hadPendingChanges && !_hasPendingChanges;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = DateFormat('yyyy-MM-dd').format(widget.targetDate);
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    final appBarTitleStyle =
        theme.appBarTheme.titleTextStyle ?? theme.textTheme.titleLarge;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        final navigator = Navigator.of(context);
        final shouldPop = await _handleWillPop();
        if (shouldPop && mounted) {
          final exitResult = _shouldNotifySaveOnExit ? true : result;
          _shouldNotifySaveOnExit = false;
          navigator.pop(exitResult);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            'Routine $formattedDate',
            style: appBarTitleStyle?.copyWith(fontSize: 18),
          ),
        ),
        body: SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).unfocus(),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_loadError != null)
                              _ErrorBanner(message: _loadError!),
                            if (_loadError != null) const SizedBox(height: 12),
                            TextField(
                              controller: _titleController,
                              enabled: !_isLoading,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 15,
                              ),
                              decoration: InputDecoration(
                                labelText: '루틴 제목',
                                hintText: '예: 하체 머신 루틴',
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 14,
                                ),
                                labelStyle: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 13,
                                ),
                                hintStyle: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 13,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Expanded(
                              child: _exercises.isEmpty
                                  ? const _RoutineEmptyState()
                                  : ListView.separated(
                                      itemCount: _exercises.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 12),
                                      itemBuilder: (context, index) {
                                        final exercise = _exercises[index];
                                        return MachineSummaryCard(
                                          exercise: exercise,
                                          onTap: () =>
                                              _handleEditExercise(index),
                                          trailing: IconButton(
                                            onPressed: () =>
                                                _handleRemoveExercise(index),
                                            icon: const Icon(
                                              Icons.delete_outline,
                                            ),
                                            tooltip: '삭제',
                                          ),
                                          showSetCount: true,
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: AnimatedPadding(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    padding: EdgeInsets.only(bottom: keyboardInset),
                    child: FilledButton.icon(
                      onPressed: (_autoSaveInProgress || _isLoading)
                          ? null
                          : _handleAddExercise,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Exercise'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
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
