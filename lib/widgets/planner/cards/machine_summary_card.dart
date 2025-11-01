import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:irondex/models/routine_exercise_draft.dart';

typedef SetCountLabelBuilder = String Function(int count);

class MachineSummaryCard extends StatelessWidget {
  const MachineSummaryCard({
    super.key,
    required this.exercise,
    this.onTap,
    this.trailing,
    this.subtitle,
    this.margin,
    this.padding = const EdgeInsets.all(16),
    this.thumbnailSize = 64,
    this.showSetCount = false,
    this.setCountLabelBuilder,
  });

  final RoutineExerciseDraft exercise;
  final VoidCallback? onTap;
  final Widget? trailing;
  final String? subtitle;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry padding;
  final double thumbnailSize;
  final bool showSetCount;
  final SetCountLabelBuilder? setCountLabelBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = exercise.sets.length;
    final machineNameStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
      height: 1.2,
      fontSize: 15,
    );
    final machineNameFontSize = machineNameStyle?.fontSize ?? 15;
    final machineNameLineHeight =
        (machineNameStyle?.height ?? 1.2) * machineNameFontSize;
    final machineNameBoxHeight = machineNameLineHeight * 2;
    final effectiveSubtitle =
        subtitle ??
        (showSetCount && count > 0
            ? (setCountLabelBuilder?.call(count) ??
                  _defaultSetCountLabel(count))
            : null);

    Widget cardContent = Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MachineThumbnail(imageUrl: exercise.imageUrl, size: thumbnailSize),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BrandInfo(
                  brandLogoUrl: exercise.brandLogoUrl,
                  brandName: exercise.brandName,
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: machineNameBoxHeight,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      exercise.machineName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: machineNameStyle,
                    ),
                  ),
                ),
                if (effectiveSubtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      effectiveSubtitle,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );

    if (onTap != null) {
      cardContent = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: cardContent,
      );
    }

    return Padding(padding: margin ?? EdgeInsets.zero, child: cardContent);
  }

  String _defaultSetCountLabel(int count) {
    if (count == 1) {
      return '1 set logged';
    }
    return '$count sets logged';
  }
}

class _MachineThumbnail extends StatelessWidget {
  const _MachineThumbnail({required this.imageUrl, required this.size});

  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );

    final url = imageUrl;
    if (url == null || url.isEmpty) {
      return placeholder;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => placeholder,
      ),
    );
  }
}

class _BrandInfo extends StatelessWidget {
  const _BrandInfo({this.brandLogoUrl, this.brandName});

  final String? brandLogoUrl;
  final String? brandName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const defaultBrandTitle = 'Machine';
    final title = brandName?.isNotEmpty == true
        ? brandName!
        : defaultBrandTitle;

    Widget buildLogo() {
      const double size = 24;
      if (brandLogoUrl == null || brandLogoUrl!.isEmpty) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.fitness_center,
            size: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        );
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: CachedNetworkImage(
          imageUrl: brandLogoUrl!,
          width: size,
          height: size,
          fit: BoxFit.contain,
          placeholder: (context, url) => Container(
            width: size,
            height: size,
            color: theme.colorScheme.surfaceContainerHighest,
          ),
          errorWidget: (context, url, error) => Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.fitness_center,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildLogo(),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
