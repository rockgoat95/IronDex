import 'package:flutter/material.dart';

class RatingWidget extends StatelessWidget {
  const RatingWidget({
    super.key,
    required this.rating,
    required this.onRatingChanged,
  });

  final double rating;
  final void Function(double) onRatingChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rating',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(5, (starIndex) {
            return GestureDetector(
              onTapDown: (details) {
                final tapX = details.localPosition.dx;

                if (tapX < 16) {
                  onRatingChanged(starIndex.toDouble() + 0.5);
                } else {
                  onRatingChanged(starIndex.toDouble() + 1.0);
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 32,
                height: 32,
                child: Stack(
                  children: [
                    const Icon(Icons.star, size: 32, color: Colors.grey),
                    if (rating > starIndex.toDouble()) ...[
                      if (rating >= starIndex.toDouble() + 1.0)
                        const Icon(Icons.star, size: 32, color: Colors.amber)
                      else
                        ClipRect(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            widthFactor: 0.5,
                            child: const Icon(
                              Icons.star,
                              size: 32,
                              color: Colors.amber,
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
