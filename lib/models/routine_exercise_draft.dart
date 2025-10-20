enum RoutineExerciseSetType { warmup, drop, fail, main }

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

extension RoutineExerciseSetTypeX on RoutineExerciseSetType {
  String get shortLabel {
    switch (this) {
      case RoutineExerciseSetType.warmup:
        return 'W';
      case RoutineExerciseSetType.drop:
        return 'D';
      case RoutineExerciseSetType.fail:
        return 'F';
      case RoutineExerciseSetType.main:
        return '';
    }
  }

  String get displayName {
    switch (this) {
      case RoutineExerciseSetType.warmup:
        return 'Warm-up';
      case RoutineExerciseSetType.drop:
        return 'Drop Set';
      case RoutineExerciseSetType.fail:
        return 'Failure Set';
      case RoutineExerciseSetType.main:
        return 'Main Set';
    }
  }
}

class RoutineExerciseSetDraft {
  const RoutineExerciseSetDraft({
    required this.order,
    this.weight,
    this.reps,
    RoutineExerciseSetType? type,
    bool isWarmup = false,
    this.isCompleted = false,
  }) : type =
           type ??
           (isWarmup
               ? RoutineExerciseSetType.warmup
               : RoutineExerciseSetType.main);

  final int order;
  final double? weight;
  final int? reps;
  final RoutineExerciseSetType type;
  final bool isCompleted;

  bool get isWarmup => type == RoutineExerciseSetType.warmup;
  bool get isDrop => type == RoutineExerciseSetType.drop;
  bool get isFail => type == RoutineExerciseSetType.fail;
  bool get isMain => type == RoutineExerciseSetType.main;

  RoutineExerciseSetDraft copyWith({
    int? order,
    double? weight,
    int? reps,
    RoutineExerciseSetType? type,
    bool? isWarmup,
    bool? isCompleted,
  }) {
    final resolvedType =
        type ??
        (isWarmup == null
            ? this.type
            : (isWarmup
                  ? RoutineExerciseSetType.warmup
                  : RoutineExerciseSetType.main));
    return RoutineExerciseSetDraft(
      order: order ?? this.order,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      type: resolvedType,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

extension RoutineExerciseSetTypeDbMapper on RoutineExerciseSetType {
  static RoutineExerciseSetType fromSupabaseValue(String? value) {
    switch (value) {
      case 'warm_up':
        return RoutineExerciseSetType.warmup;
      case 'drop_set':
        return RoutineExerciseSetType.drop;
      case 'failure_set':
        return RoutineExerciseSetType.fail;
      case 'main_set':
      default:
        return RoutineExerciseSetType.main;
    }
  }

  String get supabaseValue {
    switch (this) {
      case RoutineExerciseSetType.warmup:
        return 'warm_up';
      case RoutineExerciseSetType.drop:
        return 'drop_set';
      case RoutineExerciseSetType.fail:
        return 'failure_set';
      case RoutineExerciseSetType.main:
        return 'main_set';
    }
  }
}
