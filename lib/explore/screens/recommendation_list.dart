import 'package:flutter/material.dart';
import 'package:nyarap_at_depok_mobile/explore/models/recommendation.dart';

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
                      Icon(Icons.search_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Maaf, tidak ada rekomendasi saat ini.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Coba ubah filter pencarian Anda',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Kembali ke Pencarian'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: recommendations.length,
                  itemBuilder: (context, index) {
                    final recommendation = recommendations[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image
                          if (recommendation.imageUrl.isNotEmpty)
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              child: Image.network(
                                recommendation.imageUrl,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 200,
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: Icon(Icons.error),
                                    ),
                                  );
                                },
                              ),
                            ),
                            
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title and rating
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        recommendation.name,
                                        style: Theme.of(context).textTheme.titleLarge,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber),
                                        Text(recommendation.rating.toString()),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                
                                // Restaurant name
                                Text(
                                  recommendation.restaurant,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                
                                // Location and operational hours
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 16),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(recommendation.location),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 16),
                                    const SizedBox(width: 4),
                                    Text(recommendation.operationalHours),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                
                                // Price
                                Text(
                                  recommendation.price,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}