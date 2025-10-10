import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ReviewMachineSummary extends StatelessWidget {
  const ReviewMachineSummary({
    super.key,
    required this.name,
    required this.brandName,
    required this.imageUrl,
    this.brandLogoUrl,
  });

  final String name;
  final String brandName;
  final String imageUrl;
  final String? brandLogoUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: 96,
              height: 96,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 96,
                height: 96,
                alignment: Alignment.center,
                color: theme.colorScheme.surfaceContainerHighest,
                child: const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 96,
                height: 96,
                alignment: Alignment.center,
                color: theme.colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.fitness_center, size: 32),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (brandLogoUrl != null && brandLogoUrl!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: brandLogoUrl!,
                            width: 24,
                            height: 24,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => Container(
                              width: 24,
                              height: 24,
                              color: theme.colorScheme.surfaceContainerHighest,
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 24,
                              height: 24,
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: const Icon(Icons.fitness_center, size: 14),
                            ),
                          ),
                        ),
                      ),
                    Flexible(
                      child: Text(
                        brandName,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontSize: theme.textTheme.labelMedium?.fontSize ?? 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
