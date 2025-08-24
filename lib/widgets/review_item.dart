import 'package:flutter/material.dart';

class ReviewItem extends StatelessWidget {
  final String title;
  final String content;
  const ReviewItem({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        leading: const Icon(Icons.fitness_center),
        title: Text(title),
        subtitle: Text(content),
      ),
    );
  }
}
