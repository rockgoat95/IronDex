import 'package:flutter/material.dart';
import 'package:irondex/widgets/planner/planner_calendar.dart';
import 'package:irondex/widgets/planner/planner_routine_section.dart';
import 'package:irondex/widgets/planner/planner_summary_card.dart';
import 'package:irondex/widgets/planner/routine_actions_sheet.dart';

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
  DateTime _selectedDate = _stripTime(DateTime.now());
  late DateTime _focusedMonth = DateTime(
    _selectedDate.year,
    _selectedDate.month,
  );
  bool _skipNextAutoSelection = false;

  bool get _isTodaySelected =>
      DateUtils.isSameDay(_selectedDate, DateTime.now());

  void _handleDateSelected(DateTime date) {
    if (_skipNextAutoSelection) {
      _skipNextAutoSelection = false;
      return;
    }
    final next = _stripTime(date);
    setState(() {
      _selectedDate = next;
      _focusedMonth = DateTime(next.year, next.month);
    });
    _showRoutineActions(context, next);
  }

  void _showRoutineActions(BuildContext context, DateTime date) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => RoutineActionsSheet(targetDate: date),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('플래너'), elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            children: [
              PlannerCalendar(
                selectedDate: _selectedDate,
                focusedMonth: _focusedMonth,
                onDateSelected: _handleDateSelected,
                onMonthChanged: (date) {
                  setState(() {
                    _focusedMonth = DateTime(date.year, date.month);
                    _skipNextAutoSelection = true;
                  });
                  Future<void>.delayed(const Duration(milliseconds: 250), () {
                    if (!mounted) return;
                    _skipNextAutoSelection = false;
                  });
                },
              ),
              const SizedBox(height: 24),
              PlannerSummaryCard(selectedDate: _selectedDate),
              const SizedBox(height: 16),
              Expanded(child: PlannerRoutineSection(isToday: _isTodaySelected)),
            ],
          ),
        ),
      ),
    );
  }
}
