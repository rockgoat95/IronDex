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
                child: Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    image!,
                    fit: BoxFit.contain,
                  ),
                ),
              )
            : Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Container(
                  width: 60,
                  height: 60,
                  child: const Icon(Icons.business),
                ),
              ),
        const SizedBox(height: 4),
        SizedBox(
          width: 60,
          child: Text(
            name,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
