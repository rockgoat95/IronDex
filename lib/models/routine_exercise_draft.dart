class RoutineExerciseDraft {
  RoutineExerciseDraft({
    required this.machineId,
    required this.machineName,
    this.brandName,
    this.brandLogoUrl,
    this.imageUrl,
    List<RoutineExerciseSetDraft>? sets,
  }) : sets = List<RoutineExerciseSetDraft>.from(sets ?? const []);

  final String machineId;
  final String machineName;
  final String? brandName;
  final String? brandLogoUrl;
  final String? imageUrl;
  final List<RoutineExerciseSetDraft> sets;

  RoutineExerciseDraft copyWith({
    String? machineId,
    String? machineName,
    String? brandName,
    String? brandLogoUrl,
    String? imageUrl,
    List<RoutineExerciseSetDraft>? sets,
  }) {
    return RoutineExerciseDraft(
      machineId: machineId ?? this.machineId,
      machineName: machineName ?? this.machineName,
      brandName: brandName ?? this.brandName,
      brandLogoUrl: brandLogoUrl ?? this.brandLogoUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      sets: sets ?? List<RoutineExerciseSetDraft>.from(this.sets),
    );
  }
}

class RoutineExerciseSetDraft {
  const RoutineExerciseSetDraft({
    required this.order,
    this.weight,
    this.reps,
    this.isWarmup = false,
    this.isCompleted = false,
  });

  final int order;
  final double? weight;
  final int? reps;
  final bool isWarmup;
  final bool isCompleted;

  RoutineExerciseSetDraft copyWith({
    int? order,
    double? weight,
    int? reps,
    bool? isWarmup,
    bool? isCompleted,
  }) {
    return RoutineExerciseSetDraft(
      order: order ?? this.order,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      isWarmup: isWarmup ?? this.isWarmup,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
