import 'package:irondex/constants/app_preferences.dart';

class Brand {
  const Brand({
    required this.id,
    required this.name,
    this.nameKor,
    this.logoUrl,
  });

  factory Brand.fromMap(Map<String, dynamic> map) {
    return Brand(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      nameKor: map['name_kor']?.toString(),
      logoUrl: map['logo_url']?.toString(),
    );
  }

  final String id;
  final String name;
  final String? nameKor;
  final String? logoUrl;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      if (nameKor != null) 'name_kor': nameKor,
      if (logoUrl != null) 'logo_url': logoUrl,
    };
  }

  String resolvedName({bool? preferKorean}) {
    final preferKor = preferKorean ?? AppPreferences.preferKoreanBrandNames;
    if (preferKor && nameKor != null && nameKor!.isNotEmpty) {
      return nameKor!;
    }
    return name.isNotEmpty ? name : nameKor ?? '';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Brand &&
        other.id == id &&
        other.name == name &&
        other.nameKor == nameKor &&
        other.logoUrl == logoUrl;
  }

  @override
  int get hashCode => Object.hash(id, name, nameKor, logoUrl);
}
