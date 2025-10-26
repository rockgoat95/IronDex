import 'package:irondex/models/catalog/machine.dart';
import 'package:irondex/models/reviews/review_user.dart';

class Review {
  const Review({
    required this.id,
    required this.userId,
    required this.rating,
    required this.likeCount,
    this.title,
    this.comment,
    this.imageUrls = const <String>[],
    this.createdAt,
    this.machine,
    this.user,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    final imageList = map['image_urls'] ?? map['img_urls'];
    List<String> parseImageUrls() {
      if (imageList is List) {
        return imageList.whereType<String>().toList();
      }
      return const <String>[];
    }

    DateTime? parseCreatedAt() {
      final value = map['created_at']?.toString();
      if (value == null || value.isEmpty) {
        return null;
      }
      return DateTime.tryParse(value);
    }

    final machineMap = map['machine'];
    final userMap = map['user'];

    return Review(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      rating: map['rating'] is num ? (map['rating'] as num).toDouble() : 0,
      likeCount: map['like_count'] is num
          ? (map['like_count'] as num).toInt()
          : 0,
      title: map['title']?.toString(),
      comment: map['comment']?.toString(),
      imageUrls: parseImageUrls(),
      createdAt: parseCreatedAt(),
      machine: machineMap is Map<String, dynamic>
          ? Machine.fromMap(machineMap)
          : null,
      user: userMap is Map<String, dynamic>
          ? ReviewUser.fromMap(userMap)
          : null,
    );
  }

  final String id;
  final String userId;
  final double rating;
  final int likeCount;
  final String? title;
  final String? comment;
  final List<String> imageUrls;
  final DateTime? createdAt;
  final Machine? machine;
  final ReviewUser? user;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'user_id': userId,
      'rating': rating,
      'like_count': likeCount,
      if (title != null) 'title': title,
      if (comment != null) 'comment': comment,
      'image_urls': imageUrls,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (machine != null) 'machine': machine!.toJson(),
      if (user != null) 'user': user!.toJson(),
    };
  }
}
