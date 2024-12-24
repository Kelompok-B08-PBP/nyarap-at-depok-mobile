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
        Uri.parse('http://localhost:8000/api/category/$category/'),
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
      body: CustomScrollView(
        slivers: [
          // Custom App Bar
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: const Color(0xFFCE181B),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Menu $category',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFFCE181B),
                          const Color(0xFFCE181B).withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFFCE181B)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: FutureBuilder<List<Recommendation>>(
              future: fetchRecommendations(category),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFCE181B),
                      ),
                    ),
                  );
                }
                
                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Color(0xFFCE181B),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Oops! Something went wrong',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Error: ${snapshot.error}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3CD),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: const Icon(
                              Icons.search_off,
                              size: 48,
                              color: Color(0xFFCE181B),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Tidak ada menu $category',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Coba pilih kategori menu lainnya',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Kembali ke Beranda'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFCE181B),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final recommendations = snapshot.data!;
                return SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final recommendation = recommendations[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
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
                    childCount: recommendations.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      
      // Bottom Navigation Bar with Shadow
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, -2),
              blurRadius: 10,
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.home),
              label: const Text('Kembali ke Beranda'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFCE181B),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFCE181B)),
                ),
                elevation: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}