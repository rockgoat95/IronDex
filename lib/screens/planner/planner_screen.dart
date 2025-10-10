import 'package:flutter/material.dart';
import 'package:irondex/widgets/planner/planner_calendar.dart';
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

  bool get _isTodaySelected =>
      DateUtils.isSameDay(_selectedDate, DateTime.now());

  void _handleDateSelected(DateTime date) {
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
                  });
                },
              ),
              const SizedBox(height: 24),
              _PlannerSummaryCard(selectedDate: _selectedDate),
              const SizedBox(height: 16),
              Expanded(child: _RoutinePlaceholder(isToday: _isTodaySelected)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlannerSummaryCard extends StatelessWidget {
  const _PlannerSummaryCard({required this.selectedDate});

  final DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateUtils.isSameDay(selectedDate, DateTime.now())
        ? '오늘'
        : '${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일';

    return Align(
      alignment: Alignment.centerLeft,
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dateLabel,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '아직 등록된 루틴이 없습니다. 오늘 계획을 세워보세요.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoutinePlaceholder extends StatelessWidget {
  const _RoutinePlaceholder({required this.isToday});

  final bool isToday;

  @override
  Widget build(BuildContext context) {
    if (isToday) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '오늘의 루틴',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: const Center(
                child: Text(
                  '등록된 루틴이 없습니다. 하단에서 새로운 루틴을 추가해보세요.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(24),
      child: Text(
        '선택한 날짜에는 아직 루틴이 없습니다.',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
