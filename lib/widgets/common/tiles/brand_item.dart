import 'package:flutter/material.dart';
import 'package:irondex/constants/ui_constants.dart';

class BrandItem extends StatelessWidget {
  const BrandItem({
    super.key,
    required this.name,
    this.image,
    this.isSelected = false,
    this.isPlusButton = false,
    this.isUpIcon = false,
  });

  final String name;
  final String? image;
  final bool isSelected;
  final bool isPlusButton;
  final bool isUpIcon;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double tileWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 52;
        final double cardSize = tileWidth >= 48 ? 48 : tileWidth;

        if (isPlusButton) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                width: cardSize,
                height: cardSize,
                child: Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kCompactCardRadius),
                  ),
                  child: Icon(
                    isUpIcon ? Icons.expand_less : Icons.add,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Flexible(
                child: SizedBox(
                  width: tileWidth,
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: cardSize,
              height: cardSize,
              decoration: isSelected
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(kHighlightCardRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.3),
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    )
                  : null,
              child: Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(kCompactCardRadius),
                ),
                clipBehavior: Clip.antiAlias,
                child: image != null
                    ? Image.network(image!, fit: BoxFit.contain)
                    : const Icon(Icons.business),
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: SizedBox(
                width: tileWidth,
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    height: 1.18,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
