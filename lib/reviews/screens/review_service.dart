import 'package:nyarap_at_depok_mobile/reviews/models/reviews.dart';
import 'package:nyarap_at_depok_mobile/explore/models/recommendation.dart';
import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:logging/logging.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class ReviewService {
  final String baseUrl = 'http://localhost:8000/review';
  final _logger = Logger('ReviewService');
  final CookieRequest request;  // Add this

  ReviewService(this.request) {  // Update constructor
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      debugPrint('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  Future<int?> getCurrentUserId(String username) async {
  try {
    final response = await request.get(
      '$baseUrl/get-user-id/',
    );
    
    if (response != null && response['user_id'] != null) {
      return response['user_id'] as int;
    }
    return null;
  } catch (e) {
    _logger.severe('Error getting user ID', e);
    return null;
  }
}

Future<List<Review>> getReviewsForProduct(String productId) async {
  try {
    final response = await request.get('$baseUrl/get-reviews/');
    _logger.info('Got response from get-reviews');

    final List<Review> allReviews = reviewFromJson(jsonEncode(response));

    // Filter review berdasarkan product_identifier
    return allReviews.where((review) => 
      review.fields.productIdentifier == productId
    ).toList();
  } catch (e) {
    _logger.severe('Error getting reviews for product', e);
    throw Exception('Failed to load reviews: $e');
  }
}


Future<Review> createProductReview(Fields fields, String productId) async {
  try {
    final response = await request.post(
      '$baseUrl/add/',  // Gunakan endpoint yang sama dengan review biasa
      {
        'restaurant_name': fields.restaurantName,
        'food_name': fields.foodName,
        'rating': fields.rating.toString(),
        'review': fields.review,
        'product_identifier': productId,
      },
    );
    
    _logger.info('Create product review response: $response');
    
    if (response['status'] == 'success') {
      return Review.fromJson(response['data']);
    } else {
      throw Exception(response['message'] ?? 'Failed to create review');
    }
  } catch (e) {
    _logger.severe('Error creating product review', e);
    throw Exception('Failed to create product review: $e');
  }
}

  Future<List<Review>> getReviews() async {
    try {
      final response = await request.get(
        '$baseUrl/get-reviews/',
      );

      _logger.info('Got response from get-reviews');
      return reviewFromJson(jsonEncode(response));
    } catch (e) {
      _logger.severe('Error getting reviews', e);
      throw Exception('Failed to load reviews: $e');
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
        },
      );

      _logger.info('Create review response received');
      
      if (response['status'] == 'success') {
        return Review.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Failed to create review');
      }
    } catch (e) {
      _logger.severe('Error creating review', e);
      throw Exception('Failed to create review: $e');
    }
  }

  Future<void> deleteReview(int id) async {
    try {
      final response = await request.post(
        '$baseUrl/delete/$id/',
        {},  // empty body for delete
      );

      _logger.info('Delete response received');
      
      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to delete review');
      }
    } catch (e) {
      _logger.severe('Error deleting review', e);
      throw Exception('Failed to delete review: $e');
    }
  }

  Future<Review> updateReview(int id, Fields fields) async {
    try {
      final response = await request.post(
        '$baseUrl/edit-product-review/$id/',
        {
          'restaurant_name': fields.restaurantName,
          'food_name': fields.foodName,
          'rating': fields.rating.toString(),
          'review': fields.review,
        },
      );

      _logger.info('Update response received');
      
      if (response['status'] == 'success') {
        return Review.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Failed to update review');
      }
    } catch (e) {
      _logger.severe('Error updating review', e);
      throw Exception('Failed to update review: $e');
    }
  }
}

