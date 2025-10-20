import 'package:irondex/models/routine_exercise_draft.dart';

enum PlannerRoutineStatus { draft, completed }

extension PlannerRoutineStatusMapper on PlannerRoutineStatus {
  static PlannerRoutineStatus fromSupabaseValue(String? value) {
    switch (value) {
      case 'completed':
        return PlannerRoutineStatus.completed;
      case 'draft':
      default:
        return PlannerRoutineStatus.draft;
    }
  }

  String get supabaseValue {
    switch (this) {
      case PlannerRoutineStatus.completed:
        return 'completed';
      case PlannerRoutineStatus.draft:
        return 'draft';
    }
  }
}

class PlannerRoutine {
  const PlannerRoutine({
    required this.id,
    required this.userId,
    required this.date,
    this.name,
    required this.status,
    required this.exercises,
  });

  final int id;
  final String userId;
  final DateTime date;
  final String? name;
  final PlannerRoutineStatus status;
  final List<RoutineExerciseDraft> exercises;

  bool get isCompleted => status == PlannerRoutineStatus.completed;

  PlannerRoutine copyWith({
    int? id,
    String? userId,
    DateTime? date,
    String? name,
    PlannerRoutineStatus? status,
    List<RoutineExerciseDraft>? exercises,
  }) {
    return PlannerRoutine(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      name: name ?? this.name,
      status: status ?? this.status,
      exercises: exercises ?? List<RoutineExerciseDraft>.from(this.exercises),
    );
  }
}
