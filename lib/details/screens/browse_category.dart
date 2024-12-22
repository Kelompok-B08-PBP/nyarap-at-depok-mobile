import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:nyarap_at_depok_mobile/explore/models/recommendation.dart';
import 'package:nyarap_at_depok_mobile/explore/screens/product_card.dart';

class BrowseByCategoryPage extends StatelessWidget {
  final String category;

  const BrowseByCategoryPage({
    Key? key,
    required this.category,
  }) : super(key: key);

  Future<List<Recommendation>> fetchRecommendations(String category) async {
    try {
      final response = await http.get(
        Uri.parse('http://valiza-nadya-nyarapatdepok.pbp.cs.ui.ac.id/api/category/$category/'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final Map<String, dynamic> data = json.decode(response.body);
      if (data['status'] == 'success' && data.containsKey('results')) {
        final List<dynamic> results = data['results'];
        return results.map((json) => Recommendation.fromJson(json)).toList();
      } else {
        throw Exception('Unexpected response structure: $data');
      }
    } catch (e) {
      throw Exception('Failed to load recommendations: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu $category'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Recommendation>>(
              future: fetchRecommendations(category),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'Maaf, tidak ada rekomendasi saat ini.',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Coba ubah filter pencarian Anda',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Kembali ke Pencarian'),
                        ),
                      ],
                    ),
                  );
                } else {
                  final recommendations = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: recommendations.length,
                    itemBuilder: (context, index) {
                      final recommendation = recommendations[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: ProductCard(
                            id: recommendation.id,
                            imageUrl: recommendation.imageUrl,
                            name: recommendation.name,
                            restaurant: recommendation.restaurant,
                            rating: recommendation.rating,
                            kecamatan: recommendation.location,
                            operationalHours: recommendation.operationalHours,
                            price: recommendation.price,
                            kategori: recommendation.productCategory,
                            cacheKey: 'category_$category',
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.home,
              color: Colors.orange,
            ),
            label: const Text(
              'Kembali ke Beranda',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: const BorderSide(color: Colors.orange),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

