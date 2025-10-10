import 'package:flutter/material.dart';

class PlannerRoutineSection extends StatelessWidget {
  const PlannerRoutineSection({super.key, required this.isToday});

  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.outlineVariant.withValues(
      alpha: 0.25,
    );

    if (isToday) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '오늘의 루틴',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
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
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(24),
      child: Text('선택한 날짜에는 아직 루틴이 없습니다.', style: theme.textTheme.bodyMedium),
    );
  }
}
