import 'package:flutter/material.dart';
import 'package:irondex/providers/review_like_provider.dart';
import 'package:provider/provider.dart';

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

  @override
  void didUpdateWidget(covariant ReviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.review['id'] != widget.review['id'] ||
        oldWidget.review['like_count'] != widget.review['like_count']) {
      setState(() {
        likeCount = widget.review['like_count'] ?? 0;
      });
    }
  }

  void _onLikePressed() {
    final reviewId = widget.review['id']?.toString();
    if (reviewId == null) {
      return;
    }

    final likeProvider = context.read<ReviewLikeProvider>();

    likeProvider
        .toggleLike(reviewId)
        .then((isLikedNow) {
          if (!mounted) {
            return;
          }
          setState(() {
            likeCount = isLikedNow
                ? likeCount + 1
                : (likeCount > 0 ? likeCount - 1 : 0);
          });
        })
        .onError((error, stackTrace) {
          if (!mounted) {
            return;
          }
          final messenger = ScaffoldMessenger.of(context);
          final message =
              error is StateError && error.message == 'USER_NOT_LOGGED_IN'
              ? '로그인 후 좋아요를 사용할 수 있습니다.'
              : '좋아요 처리 중 오류가 발생했습니다.';
          messenger.showSnackBar(SnackBar(content: Text(message)));
        });
  }

  @override
  Widget build(BuildContext context) {
    final reviewId = widget.review['id']?.toString();
    final isLiked = context.select<ReviewLikeProvider, bool>((provider) {
      if (reviewId == null) {
        return false;
      }
      return provider.isLiked(reviewId);
    });
    final machine = widget.review['machine'] ?? {};
    final brand = machine['brand'] ?? {};
    final user = widget.review['user'] ?? {};

    return Container(
      width: double.infinity,
      height: 160,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
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
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.redAccent : Colors.black54,
                          ),
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
