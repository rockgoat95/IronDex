import 'package:flutter/material.dart';
import '../widgets/brand_list.dart';
import '../widgets/review_list.dart';
import '../widgets/machine_list.dart';
import '../mock/mock_data.dart';

class Home extends StatefulWidget {
  final String title;
  const Home({super.key, required this.title});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<Map<String, String>> _reviews = reviews;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            const SizedBox(height: 24),
            const BrandGrid(),
            const SizedBox(height: 12),
            const MachineList(),
            const SizedBox(height: 24),
            Expanded(child: ReviewList(reviews: _reviews)),
          ],
        ),
      ),
    );
  }
}