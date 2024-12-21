import 'package:flutter/material.dart';
import 'package:nyarap_at_depok_mobile/explore/models/recommendation.dart';
import 'package:nyarap_at_depok_mobile/explore/screens/product_card.dart';
import 'package:nyarap_at_depok_mobile/home/home_page.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class RecommendationsListPage extends StatelessWidget {
  final List<Recommendation> recommendations;
  final Map<String, String> preferences;

  const RecommendationsListPage({
    Key? key,
    required this.recommendations,
    required this.preferences,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Custom Header
          Container(
            width: double.infinity,
            height: 250,
            decoration: const BoxDecoration(
              color: Color(0xFFCE181B),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -100,
                  bottom: -50,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: const ShapeDecoration(
                      color: Color(0xFFB71418),
                      shape: OvalBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          color: Colors.black,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Rekomendasi\nSarapan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 20,
                  bottom: 0,
                  child: Image.asset(
                    'assets/images/restaurant.png',
                    width: 120,
                    height: 170,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 170,
                        height: 170,
                        color: Colors.transparent,
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.white54,
                          size: 50,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              recommendations.isEmpty 
                ? ' '
                : 'Ditemukan ${recommendations.length} rekomendasi',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),

          // Recommendations grid or empty state
          Expanded(
            child: recommendations.isEmpty
              ? Center(
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
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: recommendations.length,
                  itemBuilder: (context, index) {
                    final recommendation = recommendations[index];
                    return ProductCard(
                      imageUrl: recommendation.imageUrl,
                      name: recommendation.name,
                      restaurant: recommendation.restaurant,
                      rating: recommendation.rating,
                      kecamatan: recommendation.location,
                      operationalHours: recommendation.operationalHours,
                      price: recommendation.price,
                      kategori: preferences['breakfast_type'] ?? '',
                    );
                  },
                ),
          ),

          // Back to Home Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextButton.icon(
              onPressed: () async {
                final request = context.read<CookieRequest>();
                try {
                  final response = await request.get('http://localhost:8000/get_user_data/');
                  
                  if (response['status'] == 'success') {
                    if (!context.mounted) return;
                    
                    final username = response['data']['user']['username'];
                    
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(
                          isAuthenticated: true,
                          preferences: {
                            'preferences': {
                              'breakfast_category': preferences['breakfast_type'],
                              'district_category': preferences['location'],
                              'price_range': preferences['price_range'],
                            },
                            'username': username,
                          },
                          recommendations: recommendations.map((recommendation) => {
                            'imageUrl': recommendation.imageUrl,
                            'name': recommendation.name,
                            'restaurant': recommendation.restaurant,
                            'rating': recommendation.rating,
                            'kecamatan': recommendation.location,
                            'operationalHours': recommendation.operationalHours,
                            'price': recommendation.price,
                            'kategori': preferences['breakfast_type'],
                          }).toList(),
                        ),
                      ),
                      (route) => false,
                    );
                  } else {
                    throw Exception('Failed to fetch user data');
                  }
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              icon: const Icon(Icons.home, color: Colors.orange),
              label: const Text(
                'Kembali ke Beranda',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                minimumSize: const Size(double.infinity, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: const BorderSide(color: Colors.orange),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}