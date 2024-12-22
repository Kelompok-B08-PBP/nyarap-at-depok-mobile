import 'package:nyarap_at_depok_mobile/reviews/models/reviews.dart';
import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:logging/logging.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class ReviewService {
  final CookieRequest request;
  final baseUrl = 'http://localhost:8000/review';

  ReviewService(this.request);

  // Get all reviews (for review list screen)
  Future<List<Review>> getReviews() async {
    try {
      final response = await request.get('$baseUrl/get-reviews/');
      return reviewFromJson(jsonEncode(response));
    } catch (e) {
      throw Exception('Failed to load reviews: $e');
    }
  }

  // Get reviews for specific product (for product details)
  Future<List<Review>> getReviewsForProduct(String productId) async {
    try {
      final response = await request.get('$baseUrl/get-reviews-for-product/$productId/');
      return reviewFromJson(jsonEncode(response));
    } catch (e) {
      throw Exception('Failed to load product reviews: $e');
    }
  }

  Future<Review> createReview(Fields fields) async {
    try {
      final response = await request.post(
        '$baseUrl/add/',
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
        throw Exception(response['message'] ?? 'Failed to create review');
      }
    } catch (e) {
      throw Exception('Failed to create review: $e');
    }
  }

  // Di ReviewService
Future<Review> updateReview(int pk, Fields fields) async {
  try {
    final response = await request.post(
      '$baseUrl/edit/$pk/',  // Sesuaikan dengan endpoint Django
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
      throw Exception(response['message'] ?? 'Failed to update review');
    }
  } catch (e) {
    throw Exception('Failed to update review: $e');
  }
}

Future<void> deleteReview(int pk) async {
  try {
    final response = await request.post(
      '$baseUrl/delete/$pk/',  // Sesuaikan dengan endpoint Django
      {},  // Empty body
    );
    
    if (response['status'] != 'success') {
      throw Exception(response['message'] ?? 'Failed to delete review');
    }
  } catch (e) {
    throw Exception('Failed to delete review: $e');
  }
}
}
 