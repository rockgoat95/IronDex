class FilterConstants {
  // 운동 부위 - 해부학적으로 고정된 분류
  static const List<String> bodyParts = [
    'Chest',
    'Back',
    'Shoulder',
    'Arms',
    'Legs',
    'Core',
    'Full Body',
  ];

  // 머신 타입 - 기계적 분류
  static const List<String> machineTypes = [
    'Cable Machine',
    'Plate Loaded',
    'Selectorized',
    'Free Weight',
    'Functional Trainer',
    'Smith Machine',
  ];

  // 필터 초기값
  static const Map<String, dynamic> defaultFilters = {
    'bodyParts': <String>[],
    'machineType': '',
  };
}
