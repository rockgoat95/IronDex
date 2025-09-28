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
    // '+' or '-' button case
    if (isPlusButton) {
      return Column(
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Icon(isUpIcon ? Icons.expand_less : Icons.add, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 52,
            child: Text(
              name, // '더보기' or '접기'
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    // Normal brand item case
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: isSelected
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            clipBehavior: Clip.antiAlias,
            child: image != null
                ? Image.network(
                    image!,
                    fit: BoxFit.contain,
                  )
                : const Icon(Icons.business), // Default icon when image is null
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 52,
          child: Text(
            name,
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
