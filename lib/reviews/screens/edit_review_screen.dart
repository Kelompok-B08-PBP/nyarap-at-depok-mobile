import 'package:flutter/material.dart';
import 'package:nyarap_at_depok_mobile/reviews/models/reviews.dart';
import 'package:nyarap_at_depok_mobile/reviews/screens/review_service.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class EditReviewScreen extends StatefulWidget {
  final Review review;
  
  const EditReviewScreen({super.key, required this.review});

  @override
  _EditReviewScreenState createState() => _EditReviewScreenState();
}

class _EditReviewScreenState extends State<EditReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  late final ReviewService _reviewService;
  
  late TextEditingController _restaurantNameController;
  late TextEditingController _foodNameController;
  late TextEditingController _reviewController;
  late int _rating;

  @override
  void initState() {
    super.initState();
    final request = Provider.of<CookieRequest>(context, listen: false);
    _reviewService = ReviewService(request);
    _restaurantNameController = TextEditingController(text: widget.review.fields.restaurantName);
    _foodNameController = TextEditingController(text: widget.review.fields.foodName);
    _reviewController = TextEditingController(text: widget.review.fields.review);
    _rating = widget.review.fields.rating;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Review'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _restaurantNameController,
              decoration: const InputDecoration(
                labelText: 'Restaurant Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter restaurant name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _foodNameController,
              decoration: const InputDecoration(
                labelText: 'Food Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter food name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Rating',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            _buildRatingSelector(),
            const SizedBox(height: 16),
                        TextFormField(
              controller: _reviewController,
              decoration: const InputDecoration(
                labelText: 'Review',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your review';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  try {
                    final fields = Fields(
                      user: widget.review.fields.user,
                      restaurantName: _restaurantNameController.text,
                      foodName: _foodNameController.text,
                      review: _reviewController.text,
                      rating: _rating,
                      dateAdded: widget.review.fields.dateAdded,
                      productIdentifier: widget.review.fields.productIdentifier,
                    );
                    
                    await _reviewService.updateReview(widget.review.pk, fields);
                    Navigator.pop(context, true);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating review: $e')),
                    );
                  }
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
