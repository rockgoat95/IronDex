import 'package:flutter/material.dart';

class RatingWidget extends StatelessWidget {
  final double rating;
  final Function(double) onRatingChanged;

  const RatingWidget({
    super.key,
    required this.rating,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 평점 섹션 제목
        const Text(
          'Rating',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        // 별점 위젯
        Row(
          children: List.generate(5, (starIndex) {
            return GestureDetector(
              onTapDown: (TapDownDetails details) {
                // 탭 위치가 별의 왼쪽인지 오른쪽인지 판단
                final double tapX = details.localPosition.dx;
                
                if (tapX < 16) {
                  // 왼쪽 절반 - 0.5점
                  onRatingChanged(starIndex.toDouble() + 0.5);
                } else {
                  // 오른쪽 절반 - 1.0점
                  onRatingChanged(starIndex.toDouble() + 1.0);
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 32,
                height: 32,
                child: Stack(
                  children: [
                    // 베이스 회색 별
                    const Icon(
                      Icons.star,
                      size: 32,
                      color: Colors.grey,
                    ),
                    // 채워진 부분
                    if (rating > starIndex.toDouble()) ...[
                      if (rating >= starIndex.toDouble() + 1.0) 
                        // 완전히 채워진 별
                        const Icon(
                          Icons.star,
                          size: 32,
                          color: Colors.amber,
                        )
                      else
                        // 반만 채워진 별 (왼쪽만)
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
