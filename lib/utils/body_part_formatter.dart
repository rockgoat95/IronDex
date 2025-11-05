List<String> buildBodyPartLabels(Iterable<String>? parts) {
  if (parts == null) {
    return const <String>[];
  }

  final seen = <String>{};
  final labels = <String>[];

  for (final raw in parts) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      continue;
    }

    final normalized = trimmed.replaceAll('_', ' ').toLowerCase();
    if (!seen.add(normalized)) {
      continue;
    }

    labels.add(_titleCase(normalized));
  }

  return labels;
}

String formatBodyParts(Iterable<String>? parts) {
  final labels = buildBodyPartLabels(parts);
  if (labels.isEmpty) {
    return '';
  }
  return labels.join(' • ');
}

String formatDisplayName(String value) {
  final normalized = value.replaceAll('_', ' ').trim();
  if (normalized.isEmpty) {
    return normalized;
  }
  return _titleCase(normalized);
}

String _titleCase(String value) {
  final words = value.split(RegExp(r'\s+'));
  final buffer = <String>[];

  for (final word in words) {
    if (word.isEmpty) {
      buffer.add(word);
      continue;
    }

    final hyphenSegments = word.split('-');
    final casedSegments = hyphenSegments.map((segment) {
      if (segment.isEmpty) {
        return segment;
      }
      final lower = segment.toLowerCase();
      return lower[0].toUpperCase() + lower.substring(1);
    });

    buffer.add(casedSegments.join('-'));
  }

  return buffer.join(' ');
}
