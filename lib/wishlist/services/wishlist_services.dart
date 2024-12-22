import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class WishlistService {
  static const String baseUrl = "http://localhost:8000";

  static Future<bool> addToWishlist(BuildContext context, Map<String, dynamic> product) async {
    final request = Provider.of<CookieRequest>(context, listen: false);
    print('Starting addToWishlist with product: ${product['id']}'); // Debug log
    
    try {
      final url = '$baseUrl/wishlist/add/${product['id']}/';
      print('Making request to: $url'); // Debug log

      final response = await request.post(
        url,
        {
          'name': product['name'],
          'restaurant': product['restaurant'],
          'category': product['category'],
          'location': product['location'],
          'price': product['price'].toString(),
          'rating': product['rating'].toString(),
          'operational_hours': product['operational_hours'],
          'image_url': product['image_url'],
        },
      );
      
      print('Response received: $response'); // Debug log
      return response['status'] == 'success';
    } catch (e) {
      print('Error in addToWishlist: $e'); // Debug log
      return false;
    }
  }


}
