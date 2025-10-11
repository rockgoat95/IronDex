import 'package:flutter/material.dart';
import 'package:irondex/providers/auth_provider.dart';
import 'package:irondex/providers/machine_favorite_provider.dart';
import 'package:irondex/screens/reviews/review_create_screen.dart';
import 'package:irondex/services/review_repository.dart';
import 'package:irondex/widgets/reviews/reviews.dart';
import 'package:provider/provider.dart';

class MachineReviewsScreen extends StatefulWidget {
  const MachineReviewsScreen({super.key, required this.machine});

  final Map<String, dynamic> machine;

  @override
  State<MachineReviewsScreen> createState() => _MachineReviewsScreenState();
}

class _MachineReviewsScreenState extends State<MachineReviewsScreen> {
  bool _hasUserReview = false;
  bool _checkingUserReview = true;
  int _refreshToken = 0;

  String? get _machineId => widget.machine['id']?.toString();

  @override
  void initState() {
    super.initState();
    _checkUserReview();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MachineFavoriteProvider>().refreshFavorites();
    });
  }

  Future<void> _checkUserReview() async {
    final machineId = _machineId;
    if (machineId == null) {
      setState(() {
        _hasUserReview = false;
        _checkingUserReview = false;
      });
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    if (currentUser == null) {
      setState(() {
        _hasUserReview = false;
        _checkingUserReview = false;
      });
      return;
    }

    try {
      final repository = context.read<ReviewRepository>();
      final exists = await repository.hasUserReviewForMachine(
        machineId: machineId,
        userId: currentUser.id,
      );

      if (mounted) {
        setState(() {
          _hasUserReview = exists;
          _checkingUserReview = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _hasUserReview = false;
          _checkingUserReview = false;
        });
      }
    }
  }

  Future<void> _handleReviewCreated() async {
    await _checkUserReview();
    if (mounted) {
      setState(() {
        _refreshToken++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = context.watch<MachineFavoriteProvider>();
    final machineId = _machineId;
    final isFavorite = favoritesProvider.isFavorite(machineId);
    final brand = widget.machine['brand'] ?? <String, dynamic>{};

    final bool showPrompt =
        _machineId != null && (!_hasUserReview || _checkingUserReview);
    final bool showMessage =
        _machineId != null && _hasUserReview && !_checkingUserReview;
    final double reviewListSpacing = showPrompt
        ? 24
        : showMessage
        ? 12
        : 24;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Machine Reviews'),
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
                name: widget.machine['name'] ?? '',
                imageUrl: widget.machine['image_url'] ?? '',
                brandName: brand['name'] ?? '',
                brandLogoUrl: brand['logo_url'] ?? '',
                score: widget.machine['score'] != null
                    ? double.tryParse(widget.machine['score'].toString())
                    : null,
                reviewCnt: widget.machine['review_cnt'] is int
                    ? widget.machine['review_cnt'] as int
                    : 0,
                isFavorite: isFavorite,
                onFavoriteToggle: machineId == null
                    ? null
                    : () async {
                        try {
                          await favoritesProvider.toggleFavorite(machineId);
                        } on StateError {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('로그인 후 이용해주세요.')),
                          );
                        } catch (_) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('찜 처리 중 오류가 발생했습니다.')),
                          );
                        }
                      },
              ),
            ),
            const SizedBox(height: 16),
            if (showPrompt)
              ReviewAddPromptCard(
                onTap: () async {
                  final created = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) =>
                          ReviewCreateScreen(machine: widget.machine),
                    ),
                  );

                  if (created == true) {
                    await _handleReviewCreated();
                  }
                },
              ),
            if (showMessage)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'You already submitted a review for this machine.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            SizedBox(height: reviewListSpacing),
            if (_machineId != null)
              ReviewList(
                machineType: widget.machine['type']?.toString(),
                selectedMachineId: _machineId,
                refreshKey: _refreshToken,
              )
            else
              const Center(child: Text('머신 정보를 불러오지 못했습니다.')),
          ],
        ),
      ),
    );
  }
}
