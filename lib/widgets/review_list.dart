import 'package:flutter/material.dart';
import '../supabase/meta.dart';
import 'review_card.dart';

class ReviewList extends StatefulWidget {
  final String? brandId;
  final List<String>? bodyParts;
  final List<String>? movements;
  final String? machineType;
  final String? selectedMachineId; // 특정 머신 선택시
  
  const ReviewList({
    super.key,
    this.brandId,
    this.bodyParts,
    this.movements,
    this.machineType,
    this.selectedMachineId,
  });

  @override
  State<ReviewList> createState() => _ReviewListState();
}

class _ReviewListState extends State<ReviewList> {
  List<Map<String, dynamic>> reviews = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  @override
  void didUpdateWidget(ReviewList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 필터가 변경되면 다시 가져오기
    if (oldWidget.brandId != widget.brandId ||
        oldWidget.bodyParts != widget.bodyParts ||
        oldWidget.movements != widget.movements ||
        oldWidget.machineType != widget.machineType ||
        oldWidget.selectedMachineId != widget.selectedMachineId) {
      fetchReviews();
    }
  }

  Future<void> fetchReviews() async {
    try {
      print('ReviewList fetchReviews - brandId: ${widget.brandId}, bodyParts: ${widget.bodyParts}, machineId: ${widget.selectedMachineId}');
      final result = await fetchMachineReviews(
        brandId: widget.brandId,
        machineId: widget.selectedMachineId,
        bodyParts: widget.bodyParts,
        movements: widget.movements,
        type: widget.machineType,
        limit: 20,
      );
      print('ReviewList fetchReviews - result count: ${result.length}');
      setState(() {
        reviews = result;
        loading = false;
      });
    } catch (e) {
      print('Error fetching reviews: $e');
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (reviews.isEmpty) {
      return const Center(
        child: Text(
          '리뷰가 없습니다.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        return ReviewCard(review: reviews[index]);
      },
    );
  }
}
