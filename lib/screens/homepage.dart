import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/brand_grid.dart';
import '../widgets/review_list.dart';
import '../mock/mock_data.dart';
import '../supabase/meta.dart';

class Home extends StatefulWidget {
  final String title;
  const Home({super.key, required this.title});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<List<Map<String, dynamic>>> _brandMetas;
  final List<Map<String, String>> _reviews = reviews;

  @override
  void initState() {
    super.initState();
    _brandMetas = fetchBrands(); // 함수명도 더 명확하게
  }

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
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _brandMetas,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return const Text('브랜드 정보를 불러올 수 없습니다');
                }
                final brands = snapshot.data ?? [];
                return BrandGrid(brands: brands);
              },
            ),
            Expanded(child: ReviewList(reviews: _reviews)),
          ],
        ),
      ),
    );
  }
}