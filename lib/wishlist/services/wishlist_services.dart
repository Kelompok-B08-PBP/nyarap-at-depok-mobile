import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class WishlistService {
  static const String baseUrl = "http://valiza-nadya-nyarapatdepok.pbp.cs.ui.ac.id";

  static Future<bool> addToWishlist(BuildContext context, Map<String, dynamic> product) async {
  final request = Provider.of<CookieRequest>(context, listen: false);
  try {
    final url = '$baseUrl/wishlist/add/${product['id']}/';
    // print('Product ID being sent: ${product['id']}'); // Debug print
    // print('Full product data: $product'); // Debug print
    
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
    
    // print('Response from server: $response'); // Debug print
    return response['status'] == 'success';
  } catch (e) {
    // print('Error adding to wishlist: $e');
    return false;
  }
}
}
