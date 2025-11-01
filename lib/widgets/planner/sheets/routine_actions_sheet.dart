import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RoutineActionsSheet extends StatelessWidget {
  const RoutineActionsSheet({
    super.key,
    required this.targetDate,
    required this.onCreateRoutine,
    this.hasIncompleteDraft = false,
  });

  final DateTime targetDate;
  final Future<void> Function() onCreateRoutine;
  final bool hasIncompleteDraft;

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat(
      'MMM d, yyyy (EEE)',
      'en_US',
    ).format(targetDate);
    final shortLabel = DateFormat('MMM d', 'en_US').format(targetDate);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24, top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                dateLabel,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 16),
            if (hasIncompleteDraft)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You have an unfinished routine. Continue to complete it.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (hasIncompleteDraft) const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _RoutineActionTile(
                    icon: hasIncompleteDraft
                        ? Icons.playlist_add_check
                        : Icons.add_circle_outline,
                    label: hasIncompleteDraft
                        ? 'Resume Routine Draft'
                        : 'Create New Routine',
                    onTap: onCreateRoutine,
                  ),
                  const SizedBox(height: 12),
                  _RoutineActionTile(
                    icon: Icons.history_rounded,
                    label: 'Load Past Routine',
                    onTap: () async {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Loading history for $shortLabel is coming soon.',
                          ),
                        ),
                      );
                      return;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoutineActionTile extends StatelessWidget {
  const _RoutineActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        await onTap();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
