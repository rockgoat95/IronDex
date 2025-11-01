import 'package:flutter/material.dart';

enum RoutineExerciseSource { freeWeight, machine }

class ExerciseTypePickerSheet extends StatelessWidget {
  const ExerciseTypePickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add Exercise',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _ExerciseTypeButton(
              icon: Icons.fitness_center,
              label: 'Free Weight',
              description: 'Barbells, dumbbells, and other free-weight moves',
              onTap: () =>
                  Navigator.of(context).pop(RoutineExerciseSource.freeWeight),
            ),
            const SizedBox(height: 16),
            _ExerciseTypeButton(
              icon: Icons.precision_manufacturing,
              label: 'Machine',
              description: 'Choose from the IronDex machine catalog',
              onTap: () =>
                  Navigator.of(context).pop(RoutineExerciseSource.machine),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseTypeButton extends StatelessWidget {
  const _ExerciseTypeButton({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ],
        ),
      ),
    );
  }
}
