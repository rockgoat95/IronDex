class FreeWeight {
  const FreeWeight({
    required this.id,
    required this.name,
    this.imageUrl,
    this.bodyParts = const <String>[],
  });

  factory FreeWeight.fromMap(Map<String, dynamic> map) {
    final rawBodyParts = map['body_parts'];
    List<String> parseBodyParts() {
      if (rawBodyParts is List) {
        return rawBodyParts.whereType<String>().toList();
      }
      if (rawBodyParts is String && rawBodyParts.isNotEmpty) {
        return rawBodyParts.split(',').map((part) => part.trim()).toList();
      }
      return const <String>[];
    }

    return FreeWeight(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      imageUrl: map['image_url']?.toString(),
      bodyParts: parseBodyParts(),
    );
  }

  final String id;
  final String name;
  final String? imageUrl;
  final List<String> bodyParts;
}
