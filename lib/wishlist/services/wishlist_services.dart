import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/wishlist.dart';

class WishlistService {
  static const String baseUrl = "http://localhost:8000";

  // Fetch wishlist items
  static Future<List<Wishlist>> fetchWishlist(BuildContext context) async {
    final request = Provider.of<CookieRequest>(context, listen: false);
    try {
      final response = await request.get('$baseUrl/wishlist/json/');
      print('Wishlist Response: $response'); // Debug print
      
      if (response['wishlist'] != null) {
        final wishlistItems = WishlistItems.fromJson({
          "wishlist": response['wishlist']
        });
        return wishlistItems.wishlist;
      }
      return [];
    } catch (e) {
      print('Error fetching wishlist: $e');
      return [];
    }
  }

  // Add to wishlist with consistent ID
  static Future<bool> addToWishlist(BuildContext context, Map<String, dynamic> product) async {
    final request = Provider.of<CookieRequest>(context, listen: false);
    try {
      // Make sure we're using the consistent ID
      final productId = product['id'] ?? product['product_id'];
      if (productId == null) {
        throw Exception('Product ID is missing');
      }

      final url = '$baseUrl/wishlist/add/$productId/';
      
      // Convert price to proper format if needed
      var price = product['price'];
      if (price is String) {
        // Remove "Rp " prefix and any thousand separators
        price = price.replaceAll('Rp ', '').replaceAll('.', '');
      }

      final response = await request.post(
        url,
        {
          'product_id': productId.toString(),
          'name': product['name'],
          'restaurant': product['restaurant'] ?? '',
          'category': product['category'] ?? 'umum',
          'location': product['location'] ?? '',
          'price': price.toString(),
          'rating': (product['rating'] ?? 0.0).toString(),
          'operational_hours': product['operational_hours'] ?? '',
          'image_url': product['image_url'] ?? '',
        },
      );

      print('Add to wishlist response: $response');
      return response['status'] == 'success';
    } catch (e) {
      print('Error adding to wishlist: $e');
      return false;
    }
  }

  // Remove from wishlist
  static Future<bool> removeFromWishlist(BuildContext context, String productId) async {
    final request = Provider.of<CookieRequest>(context, listen: false);
    try {
      final response = await request.get(
        '$baseUrl/wishlist/remove/$productId/',
      );
      return response['status'] == 'success';
    } catch (e) {
      print('Error removing from wishlist: $e');
      return false;
    }
  }

  // Check if item is in wishlist
  static Future<bool> isInWishlist(BuildContext context, String productId) async {
    try {
      final wishlistItems = await fetchWishlist(context);
      return wishlistItems.any((item) => item.id.toString() == productId);
    } catch (e) {
      print('Error checking wishlist status: $e');
      return false;
    }
  }
}
