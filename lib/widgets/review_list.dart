import 'package:flutter/material.dart';
import 'review_item.dart';

class ReviewList extends StatelessWidget {
  final List<Map<String, String>> reviews;
  const ReviewList({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        return ReviewItem(
          title: reviews[index]['title'] ?? '',
          content: reviews[index]['content'] ?? '',
        );
      },
    );
  }
}
