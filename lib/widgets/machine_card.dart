import 'package:flutter/material.dart';

class MachineCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String brandName;
  final String brandLogoUrl;
  final double? score;
  final int? reviewCnt;

  const MachineCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.brandName,
    required this.brandLogoUrl,
    this.score,
    this.reviewCnt,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 160,
          height: 160,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          child: Card(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Center(
                  child: SizedBox(
                    width: 120,
                    height: 90,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 40),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 8,
                  top: 8,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      brandLogoUrl,
                      width: 28,
                      height: 28,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 28,
                        height: 28,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 100,
              child:Text(
                brandName,
                maxLines: 1,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ),
            SizedBox(
              width: 50,
              child:Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 14),
                  SizedBox(width: 2),
                  Text(
                    score != null ? score!.toStringAsFixed(1) : '-',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                  SizedBox(width: 2),
                  Text(
                    '(${reviewCnt ?? 0})',
                    style: const TextStyle(fontSize: 9, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          children: [
            SizedBox(width: 10),
            SizedBox(
              width: 160,
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(255, 50, 50, 50),
                ),
              ),
            ),
          ]
        ),
      ],
    );
  }
}
