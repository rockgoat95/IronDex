import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MachineCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String brandName;
  final String brandLogoUrl;
  final double? score;
  final int? reviewCnt;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const MachineCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.brandName,
    required this.brandLogoUrl,
    this.score,
    this.reviewCnt,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color: Colors.white,
                      alignment: Alignment.center,
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => const SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image, size: 48),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: brandLogoUrl,
                        width: 32,
                        height: 32,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Container(
                          width: 32,
                          height: 32,
                          color: Colors.grey[200],
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 32,
                          height: 32,
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image, size: 18),
                        ),
                      ),
                    ),
                  ),
                  if (onFavoriteToggle != null)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: onFavoriteToggle,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Icon(
                            isFavorite ? Icons.bookmark : Icons.bookmark_border,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Text(
              brandName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  score != null ? score!.toStringAsFixed(1) : '-',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '(${reviewCnt ?? 0})',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
