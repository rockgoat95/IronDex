import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:irondex/models/reviews/review.dart';
import 'package:irondex/providers/auth_provider.dart';
import 'package:irondex/providers/review_like_provider.dart';
import 'package:irondex/services/repositories/review_repository.dart';
import 'package:provider/provider.dart';

class ReviewCard extends StatefulWidget {
  final Review review;
  final Future<void> Function()? onDeleted;

  const ReviewCard({super.key, required this.review, this.onDeleted});

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  late int likeCount;
  bool _isExpanded = false;
  bool _canExpand = false;
  bool _isDeleting = false;
  late ReviewRepository _repository;

  @override
  void initState() {
    super.initState();
    likeCount = widget.review.likeCount;
  }

  @override
  void didUpdateWidget(covariant ReviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.review.id != widget.review.id ||
        oldWidget.review.likeCount != widget.review.likeCount) {
      setState(() {
        likeCount = widget.review.likeCount;
      });
    }
  }

  Future<void> _onLikePressed() async {
    final reviewId = widget.review.id;
    final likeProvider = context.read<ReviewLikeProvider>();

    try {
      final isLikedNow = await likeProvider.toggleLike(reviewId);
      if (!mounted) {
        return;
      }
      setState(() {
        likeCount = isLikedNow
            ? likeCount + 1
            : (likeCount > 0 ? likeCount - 1 : 0);
      });
    } on StateError catch (error) {
      final message = error.message == 'USER_NOT_LOGGED_IN'
          ? '로그인 후 좋아요를 사용할 수 있습니다.'
          : '좋아요 처리 중 오류가 발생했습니다.';
      _showSnackBar(message);
    } catch (_) {
      _showSnackBar('좋아요 처리 중 오류가 발생했습니다.');
    }
  }

  Future<void> _onDeletePressed() async {
    final reviewId = widget.review.id;
    if (_isDeleting) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('리뷰 삭제'),
          content: const Text('작성한 리뷰를 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      await _repository.deleteReview(reviewId);
      if (!mounted) {
        return;
      }
      await widget.onDeleted?.call();
      if (!mounted) {
        return;
      }
      _showSnackBar('리뷰가 삭제되었습니다.');
    } catch (error) {
      _showSnackBar('리뷰 삭제 중 오류가 발생했습니다.');
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _repository = context.read<ReviewRepository>();
    final authProvider = context.read<AuthProvider>();
    context.read<ReviewLikeProvider>().updateDependencies(
      authProvider: authProvider,
      repository: _repository,
    );
  }

  @override
  Widget build(BuildContext context) {
    final review = widget.review;
    final authProvider = context.watch<AuthProvider>();
    final likeProvider = context.watch<ReviewLikeProvider>();

    final reviewId = review.id;
    final comment = (review.comment ?? '').trim();
    final imageUrls = review.imageUrls;

    final rating = review.rating;
    final username = (review.user?.username ?? '').trim();
    final displayName = username.isNotEmpty ? username : '익명 회원';
    final createdAt = _formatCreatedAt(review.createdAt);

    final currentUserId = authProvider.currentUser?.id;
    final isOwner = currentUserId != null && review.userId == currentUserId;
    final isLiked = likeProvider.isLiked(reviewId);

    final commentStyle = const TextStyle(
      fontSize: 13,
      height: 1.4,
      color: Colors.black87,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: isOwner ? 40 : 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              displayName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (createdAt != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              createdAt,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9E9E9E),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (isOwner)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: _isDeleting ? null : _onDeletePressed,
                        iconSize: 20,
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(
                          minWidth: 0,
                          minHeight: 0,
                        ),
                        icon: _isDeleting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                                size: 18,
                              ),
                        splashRadius: 20,
                      ),
                    ),
                  ),
              ],
            ),
            if (rating > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: List.generate(5, (index) {
                    final threshold = index + 1;
                    IconData icon;
                    if (rating >= threshold) {
                      icon = Icons.star_rounded;
                    } else if (rating >= threshold - 0.5) {
                      icon = Icons.star_half_rounded;
                    } else {
                      icon = Icons.star_border_rounded;
                    }
                    return Icon(icon, color: Colors.amber, size: 18);
                  }),
                ),
              ),
            if (imageUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: imageUrls.length,
                  separatorBuilder: (context, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final url = imageUrls[index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        url,
                        width: 120,
                        height: 96,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 120,
                          height: 96,
                          color: Colors.grey[300],
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image, size: 28),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final direction = Directionality.of(context);
                final painter = TextPainter(
                  text: TextSpan(text: comment, style: commentStyle),
                  maxLines: 3,
                  textDirection: direction,
                )..layout(maxWidth: constraints.maxWidth);

                final exceeds = painter.didExceedMaxLines;
                if (exceeds != _canExpand) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _canExpand = exceeds;
                        if (!exceeds) {
                          _isExpanded = false;
                        }
                      });
                    }
                  });
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.isNotEmpty ? comment : '내용 없음',
                      style: commentStyle,
                      textAlign: TextAlign.left,
                      maxLines: _isExpanded ? null : 3,
                      overflow: _isExpanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                    ),
                    if (_canExpand)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                            });
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            _isExpanded ? '접기' : '더보기',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => _onLikePressed(),
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.redAccent : Colors.black54,
                  ),
                  iconSize: 20,
                  splashRadius: 20,
                ),
                Text('$likeCount', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String? _formatCreatedAt(DateTime? value) {
    if (value == null) {
      return null;
    }

    return DateFormat('yyyy.MM.dd').format(value.toLocal());
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
