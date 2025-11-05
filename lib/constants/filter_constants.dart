class FilterConstants {
  // Body parts - anatomically fixed grouping
  static const List<String> bodyParts = [
    'abductors',
    'abs',
    'adductors',
    'biceps',
    'calves',
    'cardiovascular system',
    'delts',
    'forearms',
    'glutes',
    'hamstrings',
    'lats',
    'levator scapulae',
    'pectorals',
    'quads',
    'serratus anterior',
    'spine',
    'traps',
    'triceps',
    'upper back',
  ];

  // Machine types - mechanical grouping
  static const List<String> machineTypes = [
    'Cable Machine',
    'Plate Loaded',
    'Selectorized',
    'Free Weight',
    'Functional Trainer',
    'Smith Machine',
  ];

  // Default filter values
  static const Map<String, dynamic> defaultFilters = {
    'bodyParts': <String>[],
    'machineType': '',
  };
}
