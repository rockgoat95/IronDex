import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:irondex/providers/auth_provider.dart';
import 'package:irondex/services/review_repository.dart';
import 'package:irondex/widgets/reviews/reviews.dart';
import 'package:provider/provider.dart';

class ReviewCreateScreen extends StatefulWidget {
  const ReviewCreateScreen({super.key, required this.machine});

  final Map<String, dynamic> machine;

  @override
  State<ReviewCreateScreen> createState() => _ReviewCreateScreenState();
}

class _ReviewCreateScreenState extends State<ReviewCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  String? _selectedMachineId;
  String? _selectedMachineName;
  String? _selectedMachineBrandName;
  String? _selectedMachineImageUrl;
  String? _selectedMachineBrandLogoUrl;
  double _rating = 5.0;
  bool _isSubmitting = false;
  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final machine = widget.machine;
    final brand = (machine['brand'] as Map<String, dynamic>?) ?? {};
    _selectedMachineId = machine['id']?.toString();
    _selectedMachineName = machine['name']?.toString();
    _selectedMachineBrandName = brand['name']?.toString();
    _selectedMachineImageUrl = machine['image_url']?.toString();
    _selectedMachineBrandLogoUrl = brand['logo_url']?.toString();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onRatingChanged(double rating) {
    setState(() {
      _rating = rating;
    });
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages = images.map((image) => File(image.path)).toList();
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitReview() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedMachineId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('머신을 선택해주세요'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final authProvider = context.read<AuthProvider>();
      final repository = context.read<ReviewRepository>();
      final currentUserId = authProvider.currentUser?.id;

      if (currentUserId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('리뷰를 작성하려면 로그인해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      try {
        await repository.createReview(
          machineId: _selectedMachineId!,
          userId: currentUserId,
          title: _titleController.text.trim(),
          comment: _contentController.text.trim(),
          rating: _rating,
          imageFiles: _selectedImages,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review has been submitted!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('리뷰 저장 중 오류가 발생했습니다: $error'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Write Review'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReviewMachineSummary(
                name: _selectedMachineName ?? 'Unknown machine',
                brandName: _selectedMachineBrandName ?? '',
                imageUrl: _selectedMachineImageUrl ?? '',
                brandLogoUrl: _selectedMachineBrandLogoUrl ?? '',
              ),
              const SizedBox(height: 24),
              RatingWidget(rating: _rating, onRatingChanged: _onRatingChanged),
              const SizedBox(height: 24),
              const Text(
                'Title',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Please enter review title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Content',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contentController,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: 'Please enter review content',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter content';
                  }
                  if (value.trim().length < 10) {
                    return 'Please enter at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              PhotoUploadWidget(
                selectedImages: _selectedImages,
                onPickImages: _pickImages,
                onRemoveImage: _removeImage,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSubmitting
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Submitting...'),
                          ],
                        )
                      : const Text(
                          'Submit Review',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
