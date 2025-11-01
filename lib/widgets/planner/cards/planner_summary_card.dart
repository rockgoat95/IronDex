import 'package:flutter/material.dart';
import 'package:irondex/models/planner_routine.dart';

class PlannerSummaryCard extends StatelessWidget {
  const PlannerSummaryCard({
    super.key,
    required this.selectedDate,
    required this.routine,
    required this.isLoading,
    this.error,
    this.onAction,
  });

  final DateTime selectedDate;
  final PlannerRoutine? routine;
  final bool isLoading;
  final String? error;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateUtils.isSameDay(selectedDate, DateTime.now())
        ? 'Today'
        : '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';

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
              const SizedBox(height: 12),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (error != null)
                Text(
                  error!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else if (routine == null)
                Text(
                  'No routine yet. Plan today\'s machine workout.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
              else
                _RoutineStatusBar(
                  routine: routine!,
                  onTap: onAction,
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  titleStyle: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  statusStyle: theme.textTheme.bodyMedium,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoutineStatusBar extends StatelessWidget {
  const _RoutineStatusBar({
    required this.routine,
    required this.backgroundColor,
    required this.titleStyle,
    required this.statusStyle,
    this.onTap,
  });

  final PlannerRoutine routine;
  final Color backgroundColor;
  final TextStyle? titleStyle;
  final TextStyle? statusStyle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = routine.status == PlannerRoutineStatus.completed;
    final String statusLabel = isCompleted ? 'Completed' : 'In Progress';
    final Color statusBackground = isCompleted
        ? Colors.green.shade100
        : Colors.blue.shade100;
    final Color statusForeground = isCompleted
        ? Colors.green.shade900
        : Colors.blue.shade800;

    final Widget content = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              routine.name?.isNotEmpty == true
                  ? routine.name!
                  : 'Untitled Routine',
              style: titleStyle,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusBackground,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              statusLabel,
              style:
                  statusStyle?.copyWith(
                    color: statusForeground,
                    fontWeight: FontWeight.w600,
                  ) ??
                  TextStyle(
                    color: statusForeground,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: content,
    );
  }
}
