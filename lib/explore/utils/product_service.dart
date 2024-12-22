import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductService {
  final String baseUrl;

  ProductService({required this.baseUrl});

  Future<Map<String, dynamic>> fetchProductDetails(
      String productId, String cacheKey) async {
    final url = Uri.parse('$baseUrl/api/product_details/$productId/?cache_key=$cacheKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch product details');
    }
  }
}
