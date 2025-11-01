class FilterConstants {
  // Body parts - anatomically fixed grouping
  static const List<String> bodyParts = [
    'Chest',
    'Back',
    'Shoulder',
    'Arms',
    'Legs',
    'Core',
    'Full Body',
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
