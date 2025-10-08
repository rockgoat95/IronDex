import 'package:flutter/material.dart';

class BrandItem extends StatelessWidget {
  final String name;
  final String? image;
  final bool isSelected;
  final bool isPlusButton;
  final bool isUpIcon;

  const BrandItem({
    super.key,
    required this.name,
    this.image,
    this.isSelected = false,
    this.isPlusButton = false,
    this.isUpIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 52;
        final double cardSize = maxWidth >= 52 ? 52 : maxWidth;

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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isUpIcon ? Icons.expand_less : Icons.add,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: SizedBox(
                  width: cardSize,
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
                      borderRadius: BorderRadius.circular(14),
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
                  borderRadius: BorderRadius.circular(12),
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
                width: cardSize,
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
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
