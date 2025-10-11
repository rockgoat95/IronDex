import 'package:flutter/material.dart';
import 'package:irondex/services/review_repository.dart';
import 'package:irondex/widgets/reviews/cards/review_card.dart';
import 'package:provider/provider.dart';

class ReviewList extends StatefulWidget {
  final String? brandId;
  final List<String>? bodyParts;
  final String? machineType;
  final String? selectedMachineId;
  final int refreshKey;

  const ReviewList({
    super.key,
    this.brandId,
    this.bodyParts,
    this.machineType,
    this.selectedMachineId,
    this.refreshKey = 0,
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
    if (oldWidget.brandId != widget.brandId ||
        oldWidget.bodyParts != widget.bodyParts ||
        oldWidget.machineType != widget.machineType ||
        oldWidget.selectedMachineId != widget.selectedMachineId ||
        oldWidget.refreshKey != widget.refreshKey) {
      fetchReviews();
    }
  }

  Future<void> fetchReviews() async {
    try {
      setState(() {
        loading = true;
      });
      debugPrint(
        'ReviewList fetchReviews - brandId: ${widget.brandId}, bodyParts: ${widget.bodyParts}, machineId: ${widget.selectedMachineId}',
      );
      final repository = context.read<ReviewRepository>();

      final result = await repository.fetchMachineReviews(
        brandId: widget.brandId,
        machineId: widget.selectedMachineId,
        bodyParts: widget.bodyParts,
        type: widget.machineType,
        limit: 20,
      );
      debugPrint('ReviewList fetchReviews - result count: ${result.length}');

      if (!mounted) {
        return;
      }

      setState(() {
        reviews = result;
        loading = false;
      });
    } catch (e) {
      debugPrint('Error fetching reviews: $e');
      if (!mounted) {
        return;
      }
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
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return ReviewCard(review: review, onDeleted: fetchReviews);
      },
    );
  }
}
