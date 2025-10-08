import 'package:flutter/material.dart';

class ReviewCard extends StatefulWidget {
  final Map<String, dynamic> review;

  const ReviewCard({super.key, required this.review});

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  late int likeCount;

  @override
  void initState() {
    super.initState();
    likeCount = widget.review['like_count'] ?? 0;
  }

  void _onLikePressed() {
    setState(() {
      likeCount++;
    });
    // TODO: Supabase에 좋아요 업데이트 API 호출
  }

  @override
  Widget build(BuildContext context) {
    final machine = widget.review['machine'] ?? {};
    final brand = machine['brand'] ?? {};
    final user = widget.review['user'] ?? {};

    return Container(
      width: double.infinity,
      height: 160,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Card(
        elevation: 3,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  machine['image_url'] ?? '',
                  width: 100,
                  height: 136,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 100,
                    height: 136,
                    color: Colors.grey[300],
                    child: const Icon(Icons.fitness_center, size: 40),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            machine['name'] ?? 'Not Found',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (brand['logo_url'] != null)
                          Image.network(
                            brand['logo_url'],
                            width: 24,
                            height: 24,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const SizedBox.shrink(),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          user['username'] ?? '익명',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color.fromARGB(255, 43, 43, 43),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: List.generate(5, (index) {
                            final rating = widget.review['rating'] ?? 0;
                            return Icon(
                              index < rating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 16,
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        widget.review['comment'] ?? '',
                        style: const TextStyle(fontSize: 13),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: _onLikePressed,
                          icon: const Icon(Icons.favorite_border),
                          iconSize: 20,
                        ),
                        Text(
                          '$likeCount',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
