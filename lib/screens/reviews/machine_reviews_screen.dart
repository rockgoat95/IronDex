import 'package:flutter/material.dart';
import 'package:irondex/models/catalog/machine.dart';
import 'package:irondex/providers/auth_provider.dart';
import 'package:irondex/providers/machine_favorite_provider.dart';
import 'package:irondex/screens/reviews/review_create_screen.dart';
import 'package:irondex/services/repositories/review_repository.dart';
import 'package:irondex/widgets/reviews/reviews.dart';
import 'package:provider/provider.dart';

class MachineReviewsScreen extends StatefulWidget {
  const MachineReviewsScreen({super.key, required this.machine});

  final Machine machine;

  @override
  State<MachineReviewsScreen> createState() => _MachineReviewsScreenState();
}

class _MachineReviewsScreenState extends State<MachineReviewsScreen> {
  bool _hasUserReview = false;
  bool _checkingUserReview = true;
  int _refreshToken = 0;

  String? get _machineId =>
      widget.machine.id.isEmpty ? null : widget.machine.id;

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

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final machine = widget.machine;
    final favoritesProvider = context.watch<MachineFavoriteProvider>();
    final machineId = _machineId;
    final isFavorite = favoritesProvider.isFavorite(machineId);
    final brand = machine.brand;
    final brandName = brand?.resolvedName(preferKorean: false) ?? '';

    final bool showPrompt =
        machineId != null && (!_hasUserReview || _checkingUserReview);
    final bool showMessage =
        machineId != null && _hasUserReview && !_checkingUserReview;
    final double reviewListSpacing = showPrompt
        ? 24
        : showMessage
        ? 12
        : 24;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews'),
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
                name: machine.name,
                imageUrl: machine.imageUrl ?? '',
                brandName: brandName,
                brandLogoUrl: brand?.logoUrl ?? '',
                score: machine.score,
                reviewCnt: machine.reviewCount,
                isFavorite: isFavorite,
                onFavoriteToggle: machineId == null
                    ? null
                    : () async {
                        try {
                          await favoritesProvider.toggleFavorite(machineId);
                        } on StateError {
                          _showSnackBar('Please log in to continue.');
                        } catch (_) {
                          _showSnackBar(
                            'An error occurred while updating favorites.',
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
                      builder: (_) => ReviewCreateScreen(machine: machine),
                    ),
                  );

                  if (!mounted) {
                    return;
                  }

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
            if (machineId != null)
              ReviewList(
                machineType: machine.type,
                selectedMachineId: machineId,
                refreshKey: _refreshToken,
              )
            else
              const Center(child: Text('Unable to load machine information.')),
          ],
        ),
      ),
    );
  }
}
