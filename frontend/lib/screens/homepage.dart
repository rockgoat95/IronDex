import 'package:flutter/material.dart';
import '../mock/mock_data.dart';
import '../utils/squircle_clipper.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.title});
  final String title;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<Map<String, String>> _brands = brands; // 브랜드 리스트
  final List<Map<String, String>> _reviews = reviews; // 리뷰 데이터

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        color: Colors.white, // 기본 배경색을 흰색으로 변경
        child: Column(
          children: [
            // 브랜드별 아이콘
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return ListView.builder(
                                itemCount: _brands.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: AssetImage(_brands[index]['image']!),
                                    ),
                                    title: Text(_brands[index]['name']!),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 100, // GridView의 높이를 제한
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5, // 한 줄에 5개
                        childAspectRatio: 0.9, // 아이템 크기 비율 추가 조정
                      ),
                      itemCount: 5, // 최대 5개만 표시
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey, width: 1), // 보더 추가
                                borderRadius: BorderRadius.circular(15), // 모서리 둥글게
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.4), // 그림자 색상
                                    blurRadius: 4, // 흐림 정도
                                    offset: Offset(4, 4), // 그림자 위치
                                  ),
                                ],
                                image: DecorationImage(
                                  image: AssetImage(_brands[index]['image']!),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _brands[index]['name']!,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // 머신 리뷰 목록
            Expanded(
              child: ListView.builder(
                itemCount: _reviews.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: ListTile(
                      leading: const Icon(Icons.fitness_center),
                      title: Text(_reviews[index]['title']!),
                      subtitle: Text(_reviews[index]['content']!),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}