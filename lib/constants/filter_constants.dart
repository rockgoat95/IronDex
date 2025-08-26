class FilterConstants {
  // 운동 부위 - 해부학적으로 고정된 분류
  static const List<String> bodyParts = [
    'Chest',
    'Back', 
    'Shoulder',
    'Arms',
    'Legs',
    'Core',
    'Full Body'
  ];

  // 부위별 기능적 움직임 매핑
  static const Map<String, List<String>> bodyPartMovements = {
    'Chest': ['Push', 'Fly', 'Press'],
    'Back': ['Pull', 'Row', 'Lat Pulldown'],
    'Shoulder': ['Press', 'Raise', 'Rotation'],
    'Arms': ['Curl', 'Extension', 'Push', 'Pull'],
    'Legs': ['Squat', 'Lunge', 'Extension', 'Curl'],
    'Core': ['Rotation', 'Flexion', 'Anti-Extension'],
    'Full Body': ['Carry', 'Olympic Lift', 'Functional'],
  };

  // 전체 움직임 리스트 (부위 선택 안했을 때)
  static const List<String> allMovements = [
    'Push', 'Pull', 'Row', 'Press', 'Fly', 'Lat Pulldown',
    'Raise', 'Rotation', 'Curl', 'Extension', 'Squat', 
    'Lunge', 'Flexion', 'Anti-Extension', 'Carry', 
    'Olympic Lift', 'Functional'
  ];

  // 머신 타입 - 기계적 분류
  static const List<String> machineTypes = [
    'Cable Machine',
    'Plate Loaded',
    'Selectorized',
    'Free Weight',
    'Functional Trainer',
    'Smith Machine'
  ];

  // 필터 초기값
  static const Map<String, dynamic> defaultFilters = {
    'bodyParts': <String>[],
    'movements': <String>[],
    'machineType': '',
  };
}
