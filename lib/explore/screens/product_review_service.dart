
import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:nyarap_at_depok_mobile/reviews/models/reviews.dart';

class ProductReviewService {
  // Ubah sesuai URL deployment Anda
  final String baseUrl = 'http://localhost:8000/review'; 
  final CookieRequest request;

  ProductReviewService(this.request);

  Future<List<Review>> getAllReviews() async {
    try {
      final response = await request.get('$baseUrl/get-reviews/');
      return reviewFromJson(jsonEncode(response));
    } catch (e) {
      print('Error getting all reviews: $e');
      return [];
    }
  }

  Future<List<Review>> getReviewsForProduct(String productId) async {
    try {
      // Contoh: ambil semua, lalu filter di frontend
      final allReviews = await getAllReviews();
      return allReviews.where(
        (r) => r.fields.productIdentifier == productId
      ).toList();
    } catch (e) {
      print('Error getting product reviews: $e');
      return [];
    }
  }

  Future<Review> addProductReview(Fields fields) async {
    try {
      final response = await request.post(
        // Pastikan endpoint di-backend sesuai:
        '$baseUrl/add/',  // --> /review/add/ (bukan /add/<str:id>)
        {
          'restaurant_name': fields.restaurantName,
          'food_name': fields.foodName,
          'rating': fields.rating.toString(),
          'review': fields.review,
          // KIRIM product_identifier
          'product_identifier': fields.productIdentifier,
        },
      );
      if (response['status'] == 'success') {
        return Review.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Failed to add review');
      }
    } catch (e) {
      print('Error adding product review: $e');
      rethrow;
    }
  }

  Future<void> deleteReview(int reviewId) async {
    try {
      final response = await request.post('$baseUrl/delete/$reviewId/', {});
      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to delete review');
      }
    } catch (e) {
      print('Error deleting review: $e');
      rethrow;
    }
  }
}
