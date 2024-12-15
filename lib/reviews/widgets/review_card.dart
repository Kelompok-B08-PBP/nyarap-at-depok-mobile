import 'package:flutter/material.dart';
import 'package:nyarap_at_depok_mobile/reviews/models/reviews.dart';
import 'package:nyarap_at_depok_mobile/reviews/screens/review_service.dart';
import 'package:nyarap_at_depok_mobile/reviews/screens/edit_review_screen.dart';

class ReviewCard extends StatelessWidget {
  final Review review;
  final VoidCallback onRefresh;
  final ReviewService reviewService;

  const ReviewCard({
    super.key,
    required this.review,
    required this.onRefresh,
    required this.reviewService,
  });

  Widget _buildStarRating(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: index < rating ? Colors.amber : Colors.grey,
          size: 20,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final date = review.fields.dateAdded.toString().split(' ')[0];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              review.fields.restaurantName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              review.fields.foodName,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 8),
            _buildStarRating(review.fields.rating),
            const SizedBox(height: 8),
            Text(
              review.fields.review,
              style: const TextStyle(
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Added on $date',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditReviewScreen(review: review),
                      ),
                    );
                    if (result == true) {
                      onRefresh();
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF6D110),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Review'),
                        content: const Text('Are you sure you want to delete this review?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    
                    if (confirm == true) {
                      try {
                        await reviewService.deleteReview(review.pk);
                        onRefresh();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error deleting review: $e')),
                        );
                      }
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFC3372B),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
