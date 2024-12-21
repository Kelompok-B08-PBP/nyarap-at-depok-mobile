import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nyarap_at_depok_mobile/explore/screens/recommendation_list.dart';
import 'package:nyarap_at_depok_mobile/explore/models/recommendation.dart';
import 'package:nyarap_at_depok_mobile/explore/models/explore.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class RecommendationsForm extends StatefulWidget {
  final bool isAuthenticated;
  final String? username;
  final Explore? initialPreferences;

  const RecommendationsForm({
    Key? key,
    this.isAuthenticated = false,
    this.username,
    this.initialPreferences,
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

  @override
  void initState() {
    super.initState();
    if (widget.isAuthenticated) {
      _loadUserPreferences();
    }
    if (widget.initialPreferences != null) {
      _selectedBreakfast =
          widget.initialPreferences!.fields.preferredBreakfastType;
      _selectedDistrict = widget.initialPreferences!.fields.preferredLocation
          .replaceAll('_', ' ')
          .split(' ')
          .map((word) => word.capitalize())
          .join(' ');
      _selectedPriceRange =
          widget.initialPreferences!.fields.preferredPriceRange;
    }
  }
  

  Future<void> _loadUserPreferences() async {
    setState(() => _isLoading = true);
    try {
      final request = context.read<CookieRequest>();
      final response =
          await request.get('http://localhost:8000/get_user_data/');

      if (response['status'] == 'success' &&
          response['data']['preferences'] != null) {
        final preferences = response['data']['preferences'];
        setState(() {
          _selectedBreakfast = preferences['breakfast_category'];
          _selectedDistrict = preferences['district_category']
              .replaceAll('_', ' ')
              .split(' ')
              .map((word) => word.capitalize())
              .join(' ');
          _selectedPriceRange = preferences['price_range'];
        });
      }
    } catch (e) {
      print('Error loading user preferences: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitForm() async {
    if (_selectedBreakfast == null ||
        _selectedDistrict == null ||
        _selectedPriceRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Mohon pilih semua kategori yang diperlukan')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.isAuthenticated) {
        final request = context.read<CookieRequest>();
        try {
          final response = await request.post(
            'http://localhost:8000/api/preferences/save/',
            {
              'breakfast_category': _selectedBreakfast,
              'district_category':
                  _selectedDistrict?.toLowerCase().replaceAll(' ', '_'),
              'price_range': _selectedPriceRange,
            },
          );

          print('Save preferences response: $response');

          if (response['status'] == 'success') {
            print('Preferences saved successfully');
          } else {
            print('Failed to save preferences: ${response['message']}');
          }
        } catch (e) {
          print('Error saving preferences: $e');
        }
      }
      
      
      final url = Uri.parse('http://localhost:8000/api/recommendations/');
      final requestBody = jsonEncode({
        'breakfast_type': _selectedBreakfast,
        'location': _selectedDistrict?.toLowerCase(),
        'price_range': _selectedPriceRange,
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: requestBody,
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['status'] == 'success') {
          final String cacheKey = responseData['cache_key'];
          final List<dynamic> recommendationsJson =
              responseData['recommendations'] as List<dynamic>;
          final List<Recommendation> recommendations = recommendationsJson
              .map((json) =>
                  Recommendation.fromJson(json as Map<String, dynamic>))
              .toList();

          if (!mounted) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecommendationsListPage(
                recommendations: recommendations,
                preferences: {
                  'location': _selectedDistrict!,
                  'breakfast_type': breakfastChoices[_selectedBreakfast]!,
                  'price_range': priceRanges[_selectedPriceRange]!['label'],
                },
                cacheKey: cacheKey,
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
        child: Column(
          children: [
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
                          'Pilih Preferensi\nSarapanmu!',
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
                      'assets/images/avatar.png',
                      width: 170,
                      height: 170,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 150,
                          height: 150,
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: districts.map((district) {
                      return ChoiceChip(
                        label: Text(
                          district,
                          style: TextStyle(
                            color: _selectedDistrict == district
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        selected: _selectedDistrict == district,
                        selectedColor:
                            Colors.orange, // Warna chip ketika dipilih
                        backgroundColor: Colors.grey[200], // Warna default
                        onSelected: (selected) {
                          setState(() {
                            _selectedDistrict = selected ? district : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
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
                  ...priceRanges.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: PriceRangeCard(
                        label: entry.value['label'],
                        emoji: entry.value['emoji'],
                        isSelected: _selectedPriceRange == entry.key,
                        onTap: () =>
                            setState(() => _selectedPriceRange = entry.key),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
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
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.image_not_supported,
                  size: 48,
                  color: Colors.grey,
                );
              },
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
