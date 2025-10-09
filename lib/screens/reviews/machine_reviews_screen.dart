import 'package:flutter/material.dart';
import 'package:irondex/widgets/reviews/reviews.dart';

class MachineReviewsScreen extends StatelessWidget {
  const MachineReviewsScreen({super.key, required this.machine});

  final Map<String, dynamic> machine;

  String? get _machineId => machine['id']?.toString();

  @override
  Widget build(BuildContext context) {
    final brand = machine['brand'] ?? <String, dynamic>{};

    return Scaffold(
      appBar: AppBar(
        title: Text(machine['name'] ?? 'Machine reviews'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            SizedBox(
              height: 220,
              child: MachineCard(
                name: machine['name'] ?? '',
                imageUrl: machine['image_url'] ?? '',
                brandName: brand['name'] ?? '',
                brandLogoUrl: brand['logo_url'] ?? '',
                score: machine['score'] != null
                    ? double.tryParse(machine['score'].toString())
                    : null,
                reviewCnt: machine['review_cnt'] is int
                    ? machine['review_cnt'] as int
                    : 0,
                isFavorite: false,
                onFavoriteToggle: null,
              ),
            ),
            const SizedBox(height: 24),
            if (_machineId != null)
              ReviewList(
                machineType: machine['type']?.toString(),
                selectedMachineId: _machineId,
              )
            else
              const Center(child: Text('머신 정보를 불러오지 못했습니다.')),
          ],
        ),
      ),
    );
  }
}
