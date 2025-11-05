import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:irondex/models/catalog/machine.dart';
import 'package:irondex/models/planner_routine.dart';
import 'package:irondex/models/routine_exercise_draft.dart';
import 'package:irondex/screens/planner/exercise_set_editor_screen.dart';
import 'package:irondex/services/planner_repository.dart';
import 'package:irondex/utils/body_part_formatter.dart';
import 'package:irondex/widgets/planner/cards/machine_summary_card.dart';
import 'package:irondex/widgets/planner/sheets/exercise_type_picker_sheet.dart';
import 'package:irondex/widgets/planner/sheets/free_weight_picker_sheet.dart';
import 'package:irondex/widgets/planner/sheets/machine_picker_sheet.dart';

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
  bool _manualSaveInProgress = false;
  bool _completionActionInProgress = false;
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
        _loadError = 'Failed to load routine information.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to load the routine. Please try again shortly.',
          ),
        ),
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

  Future<void> _saveRoutine({
    required bool isAuto,
    String? manualMessage,
  }) async {
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
      } else {
        _manualSaveInProgress = true;
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
        final message = (manualMessage == null || manualMessage.isEmpty)
            ? 'Changes have been saved.'
            : manualMessage;
        if (message.isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
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
        const SnackBar(
          content: Text('Something went wrong while saving. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          if (isAuto) {
            _autoSaveInProgress = false;
          } else {
            _manualSaveInProgress = false;
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
      final selectedFreeWeight = await showModalBottomSheet<Machine>(
        context: context,
        isScrollControlled: true,
        builder: (context) => const FreeWeightPickerSheet(),
      );

      if (!mounted || selectedFreeWeight == null) {
        return;
      }

      _addExerciseFromMachine(
        selectedFreeWeight,
        stripBrand: true,
        fallbackBrandName: 'Free Weight',
      );
      return;
    }

    final selectedMachine = await showModalBottomSheet<Machine>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const MachinePickerSheet(),
    );

    if (!mounted || selectedMachine == null) {
      return;
    }

    _addExerciseFromMachine(selectedMachine);
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

  void _addExerciseFromMachine(
    Machine machine, {
    bool stripBrand = false,
    String? fallbackBrandName,
  }) {
    final isFreeWeight = stripBrand || machine.id.startsWith('fw_');
    final brand = stripBrand ? null : machine.brand;
    final brandName = stripBrand
        ? fallbackBrandName
        : brand?.resolvedName(preferKorean: false) ?? fallbackBrandName;
    final brandLogoUrl = stripBrand ? null : brand?.logoUrl;
    final exerciseName = isFreeWeight
        ? formatDisplayName(machine.name)
        : machine.name;

    setState(() {
      _exercises.add(
        RoutineExerciseDraft(
          machineId: machine.id,
          machineName: exerciseName,
          brandName: brandName,
          brandLogoUrl: brandLogoUrl,
          imageUrl: machine.imageUrl,
          bodyParts: machine.bodyParts,
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

  Widget _buildExerciseStatusBadge(
    RoutineExerciseDraft exercise,
    ThemeData theme,
  ) {
    final hasSets = exercise.sets.isNotEmpty;
    final bool allCompleted =
        hasSets && exercise.sets.every((set) => set.isCompleted);

    final String label = allCompleted ? 'Complete' : 'In Progress';
    final Color backgroundColor = allCompleted
        ? Colors.green.shade500
        : Colors.blue.shade500;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style:
            theme.textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ) ??
            const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
      ),
    );
  }

  Widget _buildCompletionControl(ThemeData theme) {
    final bool isCompleted = _status == PlannerRoutineStatus.completed;
    final bool isBusy =
        _completionActionInProgress ||
        _manualSaveInProgress ||
        _autoSaveInProgress;

    final TextStyle? labelStyle = theme.textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w600,
    );

    final Widget toggleChild = isBusy
        ? const SizedBox(
            height: 24,
            width: 40,
            child: Center(
              child: SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        : Transform.scale(
            scale: 0.86,
            alignment: Alignment.topRight,
            child: Switch.adaptive(
              value: isCompleted,
              onChanged: _isLoading
                  ? null
                  : (value) {
                      _handleCompletionToggle(value);
                    },
              activeTrackColor: theme.colorScheme.primary,
            ),
          );

    return Transform.translate(
      offset: const Offset(0, -4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('Complete', style: labelStyle),
          const SizedBox(height: 1),
          toggleChild,
        ],
      ),
    );
  }

  Future<bool> _completeRoutine() async {
    if (_isLoading ||
        _autoSaveInProgress ||
        _manualSaveInProgress ||
        _completionActionInProgress) {
      return false;
    }

    final trimmedTitle = _titleController.text.trim();
    if (trimmedTitle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a title before completing the routine.'),
        ),
      );
      return false;
    }

    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Add at least one exercise before completing the routine.',
          ),
        ),
      );
      return false;
    }

    final hasEmptySets = _exercises.any((exercise) => exercise.sets.isEmpty);
    if (hasEmptySets) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Add at least one set for every exercise before completing the routine.',
          ),
        ),
      );
      return false;
    }

    final bool allExercisesCompleted = _exercises.every(
      (exercise) => exercise.sets.every((set) => set.isCompleted),
    );
    if (!allExercisesCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complete every set before completing this routine.'),
        ),
      );
      return false;
    }

    final previousStatus = _status;

    setState(() {
      _status = PlannerRoutineStatus.completed;
      _hasPendingChanges = true;
      _completionActionInProgress = true;
    });

    _autoSaveDebounce?.cancel();

    var success = false;
    try {
      await _saveRoutine(isAuto: false, manualMessage: '');
      success = true;
    } finally {
      if (mounted) {
        setState(() {
          _completionActionInProgress = false;
        });
      }
    }

    if (!mounted) {
      return success;
    }

    if (_hasPendingChanges) {
      setState(() {
        _status = previousStatus;
      });
      return false;
    }

    if (success) {
      _shouldNotifySaveOnExit = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Routine marked as completed.')),
      );
    }

    return success;
  }

  Future<bool> _reopenRoutine() async {
    if (_isLoading ||
        _autoSaveInProgress ||
        _manualSaveInProgress ||
        _completionActionInProgress) {
      return false;
    }

    final previousStatus = _status;

    setState(() {
      _status = PlannerRoutineStatus.draft;
      _hasPendingChanges = true;
      _completionActionInProgress = true;
    });

    _autoSaveDebounce?.cancel();

    var success = false;
    try {
      await _saveRoutine(isAuto: false, manualMessage: '');
      success = true;
    } finally {
      if (mounted) {
        setState(() {
          _completionActionInProgress = false;
        });
      }
    }

    if (!mounted) {
      return success;
    }

    if (_hasPendingChanges) {
      setState(() {
        _status = previousStatus;
      });
      return false;
    }

    if (success) {
      _shouldNotifySaveOnExit = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Routine moved back to draft.')),
      );
    }

    return success;
  }

  Future<void> _handleCompletionToggle(bool value) async {
    final bool isCompleted = _status == PlannerRoutineStatus.completed;
    if (value == isCompleted) {
      return;
    }

    final bool success = value
        ? await _completeRoutine()
        : await _reopenRoutine();
    if (!success && mounted) {
      setState(() {});
    }
  }

  Future<bool> _handleWillPop() async {
    _autoSaveDebounce?.cancel();

    if (_autoSaveInProgress ||
        _manualSaveInProgress ||
        _completionActionInProgress) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saving in progress. Please wait.')),
      );
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
    final resolvedAppBarTitleStyle =
        appBarTitleStyle?.copyWith(fontSize: 18, fontWeight: FontWeight.w700) ??
        theme.textTheme.titleLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ) ??
        const TextStyle(fontSize: 18, fontWeight: FontWeight.w700);
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
            style: resolvedAppBarTitleStyle,
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
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _titleController,
                                    enabled: !_isLoading,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 15,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: 'Title',
                                      hintText:
                                          'e.g., Lower body machine routine',
                                      border: const OutlineInputBorder(),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 14,
                                          ),
                                      labelStyle: theme.textTheme.bodySmall
                                          ?.copyWith(fontSize: 13),
                                      hintStyle: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            fontSize: 13,
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _buildCompletionControl(theme),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Expanded(
                              child: _exercises.isEmpty
                                  ? const _RoutineEmptyState()
                                  : ListView.separated(
                                      itemCount: _exercises.length,
                                      separatorBuilder: (context, _) =>
                                          const SizedBox(height: 12),
                                      itemBuilder: (context, index) {
                                        final exercise = _exercises[index];
                                        return MachineSummaryCard(
                                          exercise: exercise,
                                          onTap: () =>
                                              _handleEditExercise(index),
                                          trailing: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              _buildExerciseStatusBadge(
                                                exercise,
                                                theme,
                                              ),
                                              const SizedBox(height: 12),
                                              IconButton(
                                                onPressed: () =>
                                                    _handleRemoveExercise(
                                                      index,
                                                    ),
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                ),
                                                tooltip: 'Delete',
                                                visualDensity:
                                                    const VisualDensity(
                                                      horizontal: -2,
                                                      vertical: -2,
                                                    ),
                                                constraints:
                                                    const BoxConstraints.tightFor(
                                                      width: 40,
                                                      height: 40,
                                                    ),
                                                padding: EdgeInsets.zero,
                                              ),
                                            ],
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
          Text(
            'Add exercises to build your routine.',
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
