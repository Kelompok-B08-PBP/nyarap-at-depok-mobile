import 'package:flutter/material.dart';
import 'package:nyarap_at_depok_mobile/explore/models/recommendation.dart';
import 'package:nyarap_at_depok_mobile/explore/screens/product_card.dart';
import 'package:nyarap_at_depok_mobile/home/home_page.dart';

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
      appBar: AppBar(
        title: const Text('Rekomendasi Sarapan'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          // Preferences summary card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preferensi Anda',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text('Lokasi: ${preferences['location']}'),
                  Text('Jenis: ${preferences['breakfast_type']}'),
                  Text('Harga: ${preferences['price_range']}'),
                ],
              ),
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
          
          // Recommendations list or empty state
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
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: recommendations.length,
                  itemBuilder: (context, index) {
                    final recommendation = recommendations[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ProductCard(
                        imageUrl: recommendation.imageUrl,
                        name: recommendation.name,
                        restaurant: recommendation.restaurant,
                        rating: recommendation.rating,
                        kecamatan: recommendation.location,
                        operationalHours: recommendation.operationalHours,
                        price: recommendation.price,
                        kategori: preferences['breakfast_type'] ?? '',
                        onTap: () {
                          // Add navigation or detail view logic here
                        },
                      ),
                    );
                  },
                ),
          ),
          
          // Back to Home Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: TextButton.icon(
              onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                    (route) => false,
                  );
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
        ],
      ),
    );
  }
}