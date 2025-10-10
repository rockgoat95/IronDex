import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RoutineActionsSheet extends StatelessWidget {
  const RoutineActionsSheet({super.key, required this.targetDate});

  final DateTime targetDate;

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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _RoutineActionTile(
                    icon: Icons.add_circle_outline,
                    label: 'Create new routine',
                    onTap: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Planning for $shortLabel will be available soon.',
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _RoutineActionTile(
                    icon: Icons.history_rounded,
                    label: 'Load previous routine',
                    onTap: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Loading history for $shortLabel is coming soon.',
                          ),
                        ),
                      );
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
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
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
