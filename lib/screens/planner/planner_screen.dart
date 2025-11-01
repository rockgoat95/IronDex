import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:irondex/models/planner_routine.dart';
import 'package:irondex/screens/planner/routine_editor_screen.dart';
import 'package:irondex/services/planner_repository.dart';
import 'package:irondex/widgets/planner/calendar/planner_calendar.dart';
import 'package:irondex/widgets/planner/cards/planner_summary_card.dart';
import 'package:irondex/widgets/planner/sheets/routine_actions_sheet.dart';

DateTime _stripTime(DateTime date) => DateTime(date.year, date.month, date.day);

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlannerScreenBody();
  }
}

class _PlannerScreenBody extends StatefulWidget {
  const _PlannerScreenBody();

  @override
  State<_PlannerScreenBody> createState() => _PlannerScreenBodyState();
}

class _PlannerScreenBodyState extends State<_PlannerScreenBody> {
  final PlannerRepository _plannerRepository = PlannerRepository();
  DateTime _selectedDate = _stripTime(DateTime.now());
  late DateTime _focusedMonth = DateTime(
    _selectedDate.year,
    _selectedDate.month,
  );
  bool _skipNextAutoSelection = false;
  PlannerRoutine? _selectedRoutine;
  bool _isRoutineLoading = false;
  String? _routineError;

  @override
  void initState() {
    super.initState();
    _loadRoutineForDate(_selectedDate);
  }

  Future<void> _loadRoutineForDate(DateTime date) async {
    setState(() {
      _isRoutineLoading = true;
      _routineError = null;
    });

    try {
      final routine = await _plannerRepository.fetchRoutine(date);
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedRoutine = routine;
      });
    } on PlannerRepositoryException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _routineError = error.message;
        _selectedRoutine = null;
      });
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[PlannerScreen] loadRoutine error=$error');
        debugPrintStack(stackTrace: stackTrace);
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _routineError = 'Failed to load routine information.';
        _selectedRoutine = null;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isRoutineLoading = false;
        });
      }
    }
  }

  Future<void> _navigateToRoutineEditor(DateTime date) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RoutineEditorScreen(targetDate: date)),
    );
    if (!mounted) {
      return;
    }
    await _loadRoutineForDate(date);
    if (result == true) {
      _showRoutineSavedBanner();
    }
  }

  Future<void> _handleDateSelected(DateTime date) async {
    if (_skipNextAutoSelection) {
      _skipNextAutoSelection = false;
      return;
    }
    final next = _stripTime(date);
    final bool isAutoMonthSelection =
        (next.year != _focusedMonth.year ||
            next.month != _focusedMonth.month) &&
        next.day == _selectedDate.day;

    if (isAutoMonthSelection) {
      return;
    }
    setState(() {
      _selectedDate = next;
      _focusedMonth = DateTime(next.year, next.month);
    });
    await _loadRoutineForDate(next);
    bool hasIncomplete = false;
    try {
      hasIncomplete = await _plannerRepository.hasIncompleteRoutine(next);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[PlannerScreen] hasIncompleteRoutine error=$error');
        debugPrintStack(stackTrace: stackTrace);
      }
    }

    if (!mounted) {
      return;
    }

    if (hasIncomplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You have an unfinished routine. Pick up where you left off.',
          ),
        ),
      );
    }

    _showRoutineActions(context, next, hasIncomplete: hasIncomplete);
  }

  void _showRoutineActions(
    BuildContext context,
    DateTime date, {
    required bool hasIncomplete,
  }) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => RoutineActionsSheet(
        targetDate: date,
        hasIncompleteDraft: hasIncomplete,
        onCreateRoutine: () async {
          Navigator.of(sheetContext).pop();
          await _navigateToRoutineEditor(date);
        },
      ),
    );
  }

  void _showRoutineSavedBanner() {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentMaterialBanner();
    final theme = Theme.of(context);
    messenger.showMaterialBanner(
      MaterialBanner(
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        leading: Icon(
          Icons.check_circle_outline,
          color: theme.colorScheme.primary,
        ),
        content: Text(
          'Changes have been saved.',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: messenger.hideCurrentMaterialBanner,
            child: const Text('Close'),
          ),
        ],
      ),
    );

    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        messenger.hideCurrentMaterialBanner();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final DateTime? displaySelectedDate =
        (_selectedDate.year == _focusedMonth.year &&
            _selectedDate.month == _focusedMonth.month)
        ? _selectedDate
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Planner'), elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            children: [
              PlannerCalendar(
                selectedDate: displaySelectedDate,
                focusedMonth: _focusedMonth,
                onDateSelected: _handleDateSelected,
                onMonthChanged: (date) {
                  setState(() {
                    _focusedMonth = DateTime(date.year, date.month);
                    _skipNextAutoSelection = true;
                  });
                },
              ),
              const SizedBox(height: 32),
              PlannerSummaryCard(
                selectedDate: _selectedDate,
                routine: _selectedRoutine,
                isLoading: _isRoutineLoading,
                error: _routineError,
                onAction: _isRoutineLoading
                    ? null
                    : () => _navigateToRoutineEditor(_selectedDate),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
