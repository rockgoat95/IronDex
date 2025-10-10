import 'package:flutter/material.dart';
import 'package:flutter_neat_and_clean_calendar/flutter_neat_and_clean_calendar.dart';

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
  late DateTime _selectedDate = _stripTime(DateTime.now());

  bool get _isTodaySelected => DateUtils.isSameDay(_selectedDate, DateTime.now());

  void _handleDateSelected(DateTime date) {
    final next = _stripTime(date);
    final isToday = DateUtils.isSameDay(next, DateTime.now());
    setState(() => _selectedDate = next);

    if (isToday) {
      _showTodayActions(context);
    }
  }

  void _showTodayActions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오늘 루틴 작업',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('새로운 루틴 추가 기능은 준비 중입니다.')),
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('새로운 루틴 추가'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('이전 루틴 가져오기 기능은 준비 중입니다.')),
                    );
                  },
                  icon: const Icon(Icons.history_rounded),
                  label: const Text('이전 루틴 가져오기'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weekdayStyle = theme.textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('플래너'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            children: [
              Calendar(
                initialDate: _selectedDate,
                startOnMonday: false,
                weekDays: const ['일', '월', '화', '수', '목', '금', '토'],
                onDateSelected: _handleDateSelected,
                isExpanded: true,
                hideTodayIcon: true,
                showEvents: false,
                selectedColor: theme.colorScheme.primary,
                selectedTodayColor: theme.colorScheme.primary,
                todayColor: theme.colorScheme.primaryContainer,
                defaultDayColor:
                    theme.textTheme.bodyMedium?.color?.withOpacity(0.65),
                defaultOutOfMonthDayColor:
                    theme.textTheme.bodyMedium?.color?.withOpacity(0.25),
                dayOfWeekStyle: weekdayStyle,
                displayMonthTextStyle: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                bottomBarTextStyle: theme.textTheme.bodyMedium,
                expandableDateFormat: 'yyyy년 M월 d일 EEEE',
              ),
              const SizedBox(height: 24),
              _PlannerSummaryCard(selectedDate: _selectedDate),
              const SizedBox(height: 16),
              Expanded(
                child: _RoutinePlaceholder(isToday: _isTodaySelected),
              ),
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
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '아직 등록된 루틴이 없습니다. 오늘 계획을 세워보세요.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey[700]),
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
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
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
