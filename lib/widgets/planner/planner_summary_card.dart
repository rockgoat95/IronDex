import 'package:flutter/material.dart';

class PlannerSummaryCard extends StatelessWidget {
  const PlannerSummaryCard({super.key, required this.selectedDate});

  final DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateUtils.isSameDay(selectedDate, DateTime.now())
        ? '오늘'
        : '${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일';

    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dateLabel,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '아직 등록된 루틴이 없습니다. 오늘 계획을 세워보세요.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
