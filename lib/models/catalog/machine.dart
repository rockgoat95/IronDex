import 'package:irondex/models/catalog/brand.dart';

class Machine {
  const Machine({
    required this.id,
    required this.name,
    this.status,
    this.imageUrl,
    this.reviewCount,
    this.score,
    this.bodyParts = const <String>[],
    this.type,
    this.brand,
  });

  factory Machine.fromMap(Map<String, dynamic> map) {
    final dynamic bodyPartsRaw = map['body_parts'];
    List<String> parseBodyParts() {
      if (bodyPartsRaw is List) {
        return bodyPartsRaw.whereType<String>().toList();
      }
      if (bodyPartsRaw is String && bodyPartsRaw.isNotEmpty) {
        return bodyPartsRaw.split(',').map((part) => part.trim()).toList();
      }
      return const <String>[];
    }

    final brandMap = map['brand'];

    return Machine(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      status: map['status']?.toString(),
      imageUrl: map['image_url']?.toString(),
      reviewCount: map['review_cnt'] is num
          ? (map['review_cnt'] as num).toInt()
          : null,
      score: map['score'] is num ? (map['score'] as num).toDouble() : null,
      bodyParts: parseBodyParts(),
      type: map['type']?.toString(),
      brand: brandMap is Map<String, dynamic>
          ? Brand.fromMap(brandMap)
          : _extractLegacyBrand(map),
    );
  }

  static Brand? _extractLegacyBrand(Map<String, dynamic> map) {
    if (!map.containsKey('brand_id') && !map.containsKey('brand_name')) {
      return null;
    }
    return Brand(
      id: map['brand_id']?.toString() ?? '',
      name: map['brand_name']?.toString() ?? '',
      nameKor: map['brand_name_kor']?.toString(),
      logoUrl: map['brand_logo_url']?.toString(),
    );
  }

  final String id;
  final String name;
  final String? status;
  final String? imageUrl;
  final int? reviewCount;
  final double? score;
  final List<String> bodyParts;
  final String? type;
  final Brand? brand;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      if (status != null) 'status': status,
      if (imageUrl != null) 'image_url': imageUrl,
      if (reviewCount != null) 'review_cnt': reviewCount,
      if (score != null) 'score': score,
      'body_parts': bodyParts,
      if (type != null) 'type': type,
      if (brand != null) 'brand': brand!.toJson(),
    };
  }

  Machine copyWith({
    String? id,
    String? name,
    String? status,
    String? imageUrl,
    int? reviewCount,
    double? score,
    List<String>? bodyParts,
    String? type,
    Brand? brand,
  }) {
    return Machine(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      reviewCount: reviewCount ?? this.reviewCount,
      score: score ?? this.score,
      bodyParts: bodyParts ?? this.bodyParts,
      type: type ?? this.type,
      brand: brand ?? this.brand,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Machine &&
        other.id == id &&
        other.name == name &&
        other.status == status &&
        other.imageUrl == imageUrl &&
        other.reviewCount == reviewCount &&
        other.score == score &&
        _listEquals(other.bodyParts, bodyParts) &&
        other.type == type &&
        other.brand == brand;
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    status,
    imageUrl,
    reviewCount,
    score,
    Object.hashAll(bodyParts),
    type,
    brand,
  );

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }
}
