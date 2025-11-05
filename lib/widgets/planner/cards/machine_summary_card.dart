import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:irondex/models/routine_exercise_draft.dart';
import 'package:irondex/utils/body_part_formatter.dart';

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
    final machineName = _resolveMachineName(exercise);
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

    final bodyPartLabels = buildBodyPartLabels(exercise.bodyParts);

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
                      machineName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: machineNameStyle,
                    ),
                  ),
                ),
                if (bodyPartLabels.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: _buildBodyPartRow(theme, bodyPartLabels),
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
          if (trailing != null)
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 60),
              child: Align(alignment: Alignment.topRight, child: trailing!),
            ),
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

  String _resolveMachineName(RoutineExerciseDraft exercise) {
    final id = exercise.machineId;
    final String rawName = exercise.machineName;
    final bool looksLikeFreeWeight =
        id.startsWith('fw_') ||
        (exercise.brandName != null &&
            exercise.brandName!.toLowerCase() == 'free weight');

    if (!looksLikeFreeWeight) {
      return rawName;
    }

    return formatDisplayName(rawName);
  }

  Widget _buildBodyPartRow(ThemeData theme, List<String> labels) {
    if (labels.isEmpty) {
      return const SizedBox.shrink();
    }

    final baseStyle =
        (theme.textTheme.labelSmall ??
                const TextStyle(fontSize: 9, fontWeight: FontWeight.w600))
            .copyWith(fontSize: 9);
    final chipTextStyle = baseStyle.copyWith(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.w600,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : double.infinity;

        final visibleLabels = _calculateVisibleBodyPartLabels(
          labels,
          maxWidth,
          chipTextStyle,
        );

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < visibleLabels.length; i++) ...[
              if (i > 0) const SizedBox(width: _bodyPartChipSpacing),
              _buildBodyPartChip(visibleLabels[i], theme, chipTextStyle),
            ],
          ],
        );
      },
    );
  }

  List<String> _calculateVisibleBodyPartLabels(
    List<String> labels,
    double maxWidth,
    TextStyle textStyle,
  ) {
    if (maxWidth.isInfinite) {
      return List<String>.from(labels);
    }

    const ellipsisLabel = '...';
    double usedWidth = 0;
    final List<String> visible = [];
    final widthCache = <String, double>{};

    double chipWidth(String text) {
      return widthCache.putIfAbsent(text, () {
        final painter = TextPainter(
          text: TextSpan(text: text, style: textStyle),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout();
        return painter.width + (_bodyPartChipHorizontalPadding * 2);
      });
    }

    for (final label in labels) {
      final width = chipWidth(label);
      final addition = visible.isEmpty ? width : _bodyPartChipSpacing + width;

      if (usedWidth + addition <= maxWidth) {
        visible.add(label);
        usedWidth += addition;
        continue;
      }

      final ellipsisWidth = chipWidth(ellipsisLabel);

      if (visible.isEmpty) {
        visible.add(ellipsisLabel);
        break;
      }

      double ellipsisAddition = _bodyPartChipSpacing + ellipsisWidth;

      while (visible.isNotEmpty && usedWidth + ellipsisAddition > maxWidth) {
        final wasFirst = visible.length == 1;
        final removed = visible.removeLast();
        final removedWidth = chipWidth(removed);
        usedWidth -= wasFirst
            ? removedWidth
            : (_bodyPartChipSpacing + removedWidth);
        if (usedWidth < 0) {
          usedWidth = 0;
        }
        if (visible.isEmpty) {
          ellipsisAddition = ellipsisWidth;
        }
      }

      if (visible.isEmpty) {
        visible.add(ellipsisLabel);
      } else {
        visible.add(ellipsisLabel);
      }
      break;
    }

    return visible;
  }

  Widget _buildBodyPartChip(
    String label,
    ThemeData theme,
    TextStyle textStyle,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _bodyPartChipHorizontalPadding,
        vertical: _bodyPartChipVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: textStyle),
    );
  }

  static const double _bodyPartChipSpacing = 6;
  static const double _bodyPartChipHorizontalPadding = 8;
  static const double _bodyPartChipVerticalPadding = 3;
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
