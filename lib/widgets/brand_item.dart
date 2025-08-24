import 'package:flutter/material.dart';

class BrandItem extends StatelessWidget {
  final String name;
  final String? image;
  const BrandItem({super.key, required this.name, this.image});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        image != null
            ? Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade700, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.hardEdge,
                child: Image.asset(
                  image!,
                  fit: BoxFit.contain,
                ),
              )
            : Icon(Icons.business),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
