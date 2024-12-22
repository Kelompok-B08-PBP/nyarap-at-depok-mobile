import 'package:flutter/material.dart';
import 'package:nyarap_at_depok_mobile/reviews/models/reviews.dart';
import 'package:nyarap_at_depok_mobile/reviews/screens/review_service.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class AddReviewDialog extends StatefulWidget {
  final Function() onReviewAdded;
  final ReviewService reviewService;
  // Make these optional
  final String? productId;
  final String? restaurantName;
  final String? foodName;

  const AddReviewDialog({
    super.key,
    required this.onReviewAdded,
    required this.reviewService,
    this.productId,
    this.restaurantName,
    this.foodName,
  });
  
  @override
  _AddReviewDialogState createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<AddReviewDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _restaurantNameController;
  late TextEditingController _foodNameController;
  final TextEditingController _reviewController = TextEditingController();
  int _rating = 0;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with pre-filled data if available
    _restaurantNameController = TextEditingController(text: widget.restaurantName ?? '');
    _foodNameController = TextEditingController(text: widget.foodName ?? '');
  }

  @override
  void dispose() {
    _restaurantNameController.dispose();
    _foodNameController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  Widget _buildRatingSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 32,
          ),
          onPressed: () {
            setState(() {
              _rating = index + 1;
            });
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add New Review',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _restaurantNameController,
                      decoration: InputDecoration(
                        labelText: 'Restaurant Name',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      enabled: widget.restaurantName == null, // Only enable if not pre-filled
                      validator: (value) => value?.isEmpty ?? true ? 'Please enter restaurant name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _foodNameController,
                      decoration: InputDecoration(
                        labelText: 'Food Name',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      enabled: widget.foodName == null, // Only enable if not pre-filled
                      validator: (value) => value?.isEmpty ?? true ? 'Please enter food name' : null,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Rating',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4B5563),
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildRatingSelector(),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _reviewController,
                      decoration: InputDecoration(
                        labelText: 'Your Review',
                        hintText: 'Share your thoughts about the food and experience...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      maxLines: 4,
                      validator: (value) => value?.isEmpty ?? true ? 'Please write your review' : null,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: _rating == 0 ? null : () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              try {
                                // Get user ID dari Django session
                                final userInfo = await request.get('http://valiza-nadya-nyarapatdepok.pbp.cs.ui.ac.id/get_user_data/');
                                final userId = userInfo['data']['user']['id'] as int; 

                                final fields = Fields(
                                  user: userId,
                                  restaurantName: _restaurantNameController.text,
                                  foodName: _foodNameController.text,
                                  review: _reviewController.text,
                                  rating: _rating,
                                  dateAdded: DateTime.now(),
                                  productIdentifier: widget.productId ?? '', // Optional product ID
                                );
                                
                                await widget.reviewService.createReview(fields);
                                
                                if (mounted) {
                                  widget.onReviewAdded();
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Review added successfully!')),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error creating review: $e')),
                                  );
                                }
                              }
                            }
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: _rating == 0 ? Colors.grey : const Color(0xFFF6D110),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Save Review'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}