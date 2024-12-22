import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:nyarap_at_depok_mobile/reviews/models/reviews.dart';

class ProductReviewService {
  // Ubah sesuai URL deployment Anda
  final String baseUrl = 'http://valiza-nadya-nyarapatdepok.pbp.cs.ui.ac.id/review'; 
  final CookieRequest request;

  ProductReviewService(this.request);

  /// Mengambil SEMUA review (untuk list review page)
  Future<List<Review>> getAllReviews() async {
    try {
      final response = await request.get('$baseUrl/get-reviews/');
      return reviewFromJson(jsonEncode(response));
    } catch (e) {
      print('Error getting all reviews: $e');
      return [];
    }
  }

  /// Mengambil review khusus 1 product (productId = "12" atau "Nasi Uduk", dsb)
  Future<List<Review>> getReviewsForProduct(String productId) async {
    try {
      // Di sini, kita ambil semua review lalu difilter di frontend
      // (Bisa juga buat endpoint terpisah di Django)
      final allReviews = await getAllReviews();
      return allReviews.where((r) => 
        r.fields.productIdentifier == productId
      ).toList();
    } catch (e) {
      print('Error getting product reviews: $e');
      return [];
    }
  }

  /// Menambahkan review
  Future<Review> addProductReview(Fields fields) async {
    try {
      final response = await request.post(
        '$baseUrl/add/', // Pastikan endpoint di Django
        {
          'restaurant_name': fields.restaurantName,
          'food_name': fields.foodName,
          'rating': fields.rating.toString(),
          'review': fields.review,
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

  /// Menghapus review (by pk)
  Future<void> deleteReview(int reviewId) async {
    try {
      final response = await request.post(
        '$baseUrl/delete/$reviewId/',
        {},
      );
      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to delete review');
      }
    } catch (e) {
      print('Error deleting review: $e');
      rethrow;
    }
  }
}
