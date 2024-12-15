import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nyarap_at_depok_mobile/explore/screens/recommendation_list.dart';
import 'package:nyarap_at_depok_mobile/explore/models/recommendation.dart';

class RecommendationsForm extends StatefulWidget {
  final bool isAuthenticated;
  final String? username;

  const RecommendationsForm({
    Key? key, 
    this.isAuthenticated = false,
    this.username,
  }) : super(key: key);

  @override
  _RecommendationsFormState createState() => _RecommendationsFormState();
}

class _RecommendationsFormState extends State<RecommendationsForm> {
  String? _selectedBreakfast;
  String? _selectedDistrict;
  String? _selectedPriceRange;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Breakfast choices matching the web form
  final Map<String, String> breakfastChoices = {
    'nasi': 'Nasi',
    'mie': 'Mie',
    'bubur': 'Bubur',
    'lontong': 'Lontong',
    'roti': 'Roti',
    'makanan_berat': 'Sarapan Berat',
    'cemilan': 'Cemilan',
    'makanan_sehat': 'Sarapan Sehat',
    'minuman': 'Minuman',
    'masih_bingung': 'Masih Bingung...',
  };

  // District choices
  final List<String> districts = [
    'Beji',
    'Bojongsari',
    'Cilodong',
    'Cimanggis',
    'Cinere',
    'Cipayung',
    'Limo',
    'Pancoran Mas',
    'Sawangan',
    'Sukmajaya',
    'Tapos',
  ];

  // Price range choices with emojis
  final Map<String, Map<String, dynamic>> priceRanges = {
    '0-15000': {
      'label': 'Dibawah Rp 15.000',
      'emoji': '💰',
    },
    '15000-25000': {
      'label': 'Rp 15.000 - Rp 25.000',
      'emoji': '💰💰',
    },
    '25000-50000': {
      'label': 'Rp 25.000 - Rp 50.000',
      'emoji': '💰💰💰',
    },
    '50000-100000': {
      'label': 'Rp 50.000 - Rp 100.000',
      'emoji': '💰💰💰💰',
    },
    '100000+': {
      'label': 'Diatas Rp 100.000',
      'emoji': '💰💰💰💰💰',
    },
  };

  Future<void> _submitForm() async {
  if (_selectedBreakfast == null || _selectedDistrict == null || _selectedPriceRange == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mohon pilih semua kategori yang diperlukan')),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    final url = Uri.parse('http://localhost:8000/api/recommendations/');
    final requestBody = jsonEncode({
      'breakfast_type': _selectedBreakfast,
      'location': _selectedDistrict?.toLowerCase(),
      'price_range': _selectedPriceRange,
    });

    print('Sending request to: $url with body: $requestBody');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: requestBody,
    );

    print('Response received: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (!mounted) return;
    if (response.statusCode == 200) {
    final Map<String, dynamic> responseData = jsonDecode(response.body);
    print('Full response data: $responseData');

    if (responseData['status'] == 'success') {
      final List<dynamic> recommendationsJson = responseData['recommendations'] as List<dynamic>;
      print('Recommendations JSON: $recommendationsJson');

      final List<Recommendation> recommendations = recommendationsJson
          .map((json) => Recommendation.fromJson(json as Map<String, dynamic>))
          .toList();

      print('Processed recommendations: ${recommendations.length}');

      if (!mounted) return;

      // Tetap navigasi ke RecommendationsListPage meskipun recommendations kosong
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecommendationsListPage(
            recommendations: recommendations, // Bisa kosong
            preferences: {
              'location': _selectedDistrict!,
              'breakfast_type': breakfastChoices[_selectedBreakfast]!,
              'price_range': priceRanges[_selectedPriceRange]!['label'],
            },
          ),
        ),
      );
    } else {
      throw Exception(responseData['message'] ?? 'Unknown error');
    }
  }
  } catch (e) {
    if (!mounted) return;
    print('Error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal terhubung ke server: $e')),
    );
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
} 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Hero Section
              Container(
                height: 300,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black, Colors.grey.shade900],
                  ),
                ),
                child: Stack(
                  children: [
                    // Background image would go here
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.6,
                        child: Image.asset(
                          'assets/images/background-header.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Overlay content
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Pilih preferensi sarapanmu',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.isAuthenticated
                                  ? 'Hai ${widget.username}, ayo tentukan sarapan favoritmu!'
                                  : 'Temukan rekomendasi sarapan terbaik untukmu.',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[200],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Form Content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Breakfast Category Section
                    const Text(
                      'Kategori Sarapan',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pilih kategori makanan yang kamu inginkan.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    
                    // Breakfast Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: breakfastChoices.length,
                      itemBuilder: (context, index) {
                        final key = breakfastChoices.keys.elementAt(index);
                        final value = breakfastChoices[key];
                        return ChoiceCard(
                          title: value!,
                          imagePath: 'assets/images/$key.png',
                          isSelected: _selectedBreakfast == key,
                          onTap: () => setState(() => _selectedBreakfast = key),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 32),

                    // Location Section
                    const Text(
                      'Lokasi',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pilih kecamatan tempat kamu ingin sarapan di Depok.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    
                    // District Wrap
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: districts.map((district) {
                        return ChoiceChip(
                          label: Text(district),
                          selected: _selectedDistrict == district,
                          onSelected: (selected) {
                            setState(() {
                              _selectedDistrict = selected ? district : null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 32),

                    // Price Range Section
                    const Text(
                      'Rentang Harga',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pilih rentang harga sarapan yang kamu inginkan.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    
                    // Price Range List
                    ...priceRanges.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: PriceRangeCard(
                          label: entry.value['label'],
                          emoji: entry.value['emoji'],
                          isSelected: _selectedPriceRange == entry.key,
                          onTap: () => setState(() => _selectedPriceRange = entry.key),
                        ),
                      );
                    }).toList(),
                    
                    const SizedBox(height: 32),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Lihat Rekomendasi'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom widgets for the form
class ChoiceCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const ChoiceCard({
    Key? key,
    required this.title,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 48,
              width: 48,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PriceRangeCard extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const PriceRangeCard({
    Key? key,
    required this.label,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey.shade300,
            width: 2,
          ),
          color: isSelected ? Colors.orange.withOpacity(0.1) : Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            Text(emoji),
          ],
        ),
      ),
    );
  }
}