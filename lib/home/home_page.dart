import 'package:flutter/material.dart';
import 'package:nyarap_at_depok_mobile/home/left_drawer.dart';
import 'package:nyarap_at_depok_mobile/explore/screens/product_card.dart';
import 'package:nyarap_at_depok_mobile/explore/widgets/recommendations_form.dart';
import 'package:nyarap_at_depok_mobile/explore/screens/recommendation_list.dart';
import 'package:nyarap_at_depok_mobile/explore/models/explore.dart';
import 'package:nyarap_at_depok_mobile/explore/models/recommendation.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  final bool isAuthenticated;
  final Map<String, dynamic> preferences;
  final List<Map<String, dynamic>>? recommendations;
  final bool isLoading;

  const HomePage({
    super.key,
    this.isAuthenticated = false,
    this.preferences = const {},
    this.recommendations,
    this.isLoading = false,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic> _preferences = {};
  List<Map<String, dynamic>>? _recommendations;
  bool _isLoading = false;
  String? _cacheKey;  
  List<Map<String, dynamic>>? _defaultRecommendations;

  @override
void initState() {
  super.initState();
  
  // Prioritaskan preferences dan recommendations dari widget
  if (widget.preferences.isNotEmpty && widget.recommendations != null) {
    setState(() {
      _preferences = widget.preferences;
      _recommendations = widget.recommendations;
      // Ambil cache_key dari preferences jika ada
      _cacheKey = widget.preferences['preferences']?['cache_key'];
    });
  } else if (widget.isAuthenticated) {
    _fetchUserData();
  } else {
    // Hanya fetch default recommendations jika user tidak authenticated
    _fetchDefaultRecommendations();
  }
}

  bool _shouldShowDefaultRecommendations() {
  // Jika user punya preferences dan recommendations, jangan tampilkan default
  if (_preferences.containsKey('preferences') && 
      _preferences['preferences'] != null && 
      _recommendations != null && 
      _recommendations!.isNotEmpty) {
    return false;
  }
  
  // Jika user belum login atau belum punya preferences, tampilkan default
  return !widget.isAuthenticated || 
         !_preferences.containsKey('preferences') || 
         _preferences['preferences'] == null ||
         _recommendations == null || 
         _recommendations!.isEmpty;
}

  

  void _onUsePreferences() async {
    setState(() => _isLoading = true);
    try {
      final request = context.read<CookieRequest>();
      final userPrefs = _preferences['preferences'];
      
      final response = await request.post(
        'http://valiza-nadya-nyarapatdepok.pbp.cs.ui.ac.id/api/recommendations/',
        jsonEncode({
          'breakfast_type': userPrefs['breakfast_category'],
          'location': userPrefs['district_category'].replaceAll('_', ' '),
          'price_range': userPrefs['price_range'],
        }),
      );
      
      if (!mounted) return;
      if (response['status'] == 'success') {
        final List<Recommendation> recommendations =
            (response['recommendations'] as List)
                .map((json) => Recommendation.fromJson(json))
                .toList();
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecommendationsListPage(
              recommendations: recommendations,
              preferences: {
                'location': _getDisplayLocation(userPrefs['district_category']),
                'breakfast_type': _getDisplayBreakfastType(userPrefs['breakfast_category']),
                'price_range': _getDisplayPriceRange(userPrefs['price_range']),
              },
              isAuthenticated: true,
              cacheKey: response['cache_key'],  // Tambahkan ini
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchDefaultRecommendations() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final request = context.read<CookieRequest>();
      
      final response = await request.post(
        'http://valiza-nadya-nyarapatdepok.pbp.cs.ui.ac.id/api/recommendations/',
        jsonEncode({
          'breakfast_type': 'lontong',
          'location': 'beji',
          'price_range': '0-15000',
        }),
      );

      if (!mounted) return;
      if (response['status'] == 'success') {
        setState(() {
          _cacheKey = response['cache_key'];
          _defaultRecommendations = List<Map<String, dynamic>>.from( // Diubah dari _recommendations menjadi _defaultRecommendations
            response['recommendations'].map((item) => {
              'id': item['id'],
              'imageUrl': item['image_url'],
              'name': item['name'],
              'restaurant': item['restaurant'],
              'rating': double.parse(item['rating'].toString()),
              'kecamatan': item['location'],
              'operationalHours': item['operational_hours'],
              'price': item['price'],
              'kategori': 'lontong',
            })
          );
        });
      }
    } catch (e) {
      print('Error fetching default recommendations: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }


  Future<void> _fetchUserData() async {
  if (!mounted) return;
  setState(() => _isLoading = true);

  try {
    final request = context.read<CookieRequest>();
    final response = await request.get('http://valiza-nadya-nyarapatdepok.pbp.cs.ui.ac.id/get_user_data/');
    
    if (response['status'] == 'success' && mounted) {
      final userData = response['data'];
      final username = userData['user']['username'];
      final preferences = userData['preferences'];
      
      setState(() {
        _preferences = {
          'username': username,
          'preferences': preferences,  // Set preferences even if null
        };
      });

      if (preferences != null) {
        await _fetchRecommendations();
      } else {
        // If no preferences, fetch default recommendations
        await _fetchDefaultRecommendations();
      }
    }
  } catch (e) {
    print('Error in _fetchUserData: $e');
    // On error, try to fetch default recommendations
    await _fetchDefaultRecommendations();
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

  // Modifikasi _deletePreference untuk memastikan default recommendations muncul:
  Future<void> _deletePreference() async {
  final request = context.read<CookieRequest>();
  setState(() => _isLoading = true);
  
  try {
    final response = await request.post(
      'http://valiza-nadya-nyarapatdepok.pbp.cs.ui.ac.id/api/preferences/delete/',
      {},
    );

    if (response['status'] == 'success') {
      if (mounted) {
        setState(() {
          _preferences = {
            'username': _preferences['username'],
            'preferences': null,  // Explicitly set to null
          };
          _recommendations = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferensi berhasil dihapus')),
        );
        
        // Fetch default recommendations after clearing preferences
        await _fetchDefaultRecommendations();
      }
    }
  } catch (e) {
    print('Error deleting preference: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus preferensi')),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

  Future<void> _savePreference(Map<String, String> data) async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.post(
        'http://valiza-nadya-nyarapatdepok.pbp.cs.ui.ac.id/api/preferences/save/',
        jsonEncode({
          'preferred_location': data['location'],
          'preferred_breakfast_type': data['breakfast_type'],
          'preferred_price_range': data['price_range'],
        }),
      );

      if (response['status'] == 'success') {
        await _fetchUserData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Preferensi berhasil disimpan')),
          );
        }
      }
    } catch (e) {
      print('Error saving preference: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan preferensi')),
        );
      }
    }
  }

  Future<void> _fetchRecommendations() async {
    if (!mounted) return;

    try {
      final request = context.read<CookieRequest>();
      final userPrefs = _preferences['preferences'];

      final response = await request.post(
        'http://valiza-nadya-nyarapatdepok.pbp.cs.ui.ac.id/api/recommendations/',
        {
          'breakfast_type': userPrefs['breakfast_category'],
          'location': userPrefs['district_category'].replaceAll('_', ' '),
          'price_range': userPrefs['price_range'],
        },
      );

      if (response['status'] == 'success' && mounted) {
        // Simpan cache_key
        setState(() {
          _cacheKey = response['cache_key'];  // Tambahkan ini
          _recommendations = List<Map<String, dynamic>>.from(
            response['recommendations'].map((item) => {
              'id': item['id'],  // Pastikan ID tersimpan
              'imageUrl': item['image_url'],
              'name': item['name'],
              'restaurant': item['restaurant'],
              'rating': double.parse(item['rating'].toString()),
              'kecamatan': item['location'],
              'operationalHours': item['operational_hours'],
              'price': item['price'],
              'kategori': userPrefs['breakfast_category'],
            })
          );
        });
      }
    } catch (e) {
      print('Error fetching recommendations: $e');
    }
  }


  String _getDisplayBreakfastType(String type) {
    final Map<String, String> breakfastTypes = {
      'masih_bingung': 'Masih Bingung',
      'nasi': 'Nasi',
      'roti': 'Roti',
      'lontong': 'Lontong',
      'cemilan': 'Cemilan',
      'minuman': 'Minuman',
      'mie': 'Mie',
      'makanan_sehat': 'Sarapan Sehat',
      'bubur': 'Bubur',
      'makanan_berat': 'Sarapan Berat',
    };
    return breakfastTypes[type] ?? type;
  }

  String _getDisplayLocation(String location) {
    return location.split('_').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  String _getDisplayPriceRange(String range) {
    final Map<String, String> priceRanges = {
      '0-15000': 'Rp 0 - Rp 15.000',
      '15000-25000': 'Rp 15.000 - Rp 25.000',
      '25000-50000': 'Rp 25.000 - Rp 50.000',
      '50000-100000': 'Rp 50.000 - Rp 100.000',
      '100000+': 'Rp 100.000+',
    };
    return priceRanges[range] ?? range;
  }

  Widget _buildPreferencesButton(BuildContext context) {
    if (!_preferences.containsKey('preferences') ||
        _preferences['preferences'] == null) {
      return Container();
    }
    
    final userPrefs = _preferences['preferences'];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Preferensi Anda',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFFCE181B)),
                    onPressed: () {
                      // Navigate to RecommendationsForm when edit is pressed
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecommendationsForm(
                            isAuthenticated: widget.isAuthenticated,
                            username: _preferences['username'],
                          ),
                        ),
                      ).then((_) => _fetchUserData());
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Color(0xFFCE181B)),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Hapus Preferensi'),
                            content: const Text('Apakah Anda yakin ingin menghapus preferensi?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _deletePreference();
                                },
                                child: const Text('Hapus'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.yellow.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.yellow.shade600),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPreferenceItem(
                  Icons.restaurant_menu,
                  'Kategori',
                  _getDisplayBreakfastType(userPrefs['breakfast_category']),
                ),
                _buildPreferenceItem(
                  Icons.location_on,
                  'Lokasi',
                  _getDisplayLocation(userPrefs['district_category']),
                ),
                _buildPreferenceItem(
                  Icons.attach_money,
                  'Budget',
                  _getDisplayPriceRange(userPrefs['price_range']),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () async {
                      setState(() => _isLoading = true);

                      try {
                        final request = context.read<CookieRequest>();
                        final userPrefs = _preferences['preferences'];
                        
                        // Get recommendations
                        final recommendationsResponse = await request.post(
                          'http://valiza-nadya-nyarapatdepok.pbp.cs.ui.ac.id/api/recommendations/',
                          jsonEncode({
                            'breakfast_type': userPrefs['breakfast_category'],
                            'location': userPrefs['district_category'].replaceAll('_', ' '),
                            'price_range': userPrefs['price_range'],
                          }),
                        );

                        if (!mounted) return;

                        if (recommendationsResponse['status'] == 'success') {
                          final String cacheKey = recommendationsResponse['cache_key'];
                          final List<Recommendation> recommendations =
                              (recommendationsResponse['recommendations'] as List)
                                  .map((json) => Recommendation.fromJson(json))
                                  .toList();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecommendationsListPage(
                                recommendations: recommendations,
                                preferences: {
                                  'location': _getDisplayLocation(userPrefs['district_category']),
                                  'breakfast_type': _getDisplayBreakfastType(userPrefs['breakfast_category']),
                                  'price_range': _getDisplayPriceRange(userPrefs['price_range']),
                                },
                                isAuthenticated: widget.isAuthenticated,
                                cacheKey: cacheKey,
                              ),
                            ),
                          );
                        } else {
                          throw Exception(recommendationsResponse['message'] ?? 'Unknown error');
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
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCE181B),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Gunakan Preferensi Ini',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String title, String imagePath) {
  return Container(
    width: 70,
    margin: const EdgeInsets.only(right: 16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF121212),
            fontSize: 14,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w500,
            letterSpacing: -0.28,
          ),
        ),
      ],
    ),
  );
}

  Widget _buildPreferenceItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFFCE181B)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  @override
Widget build(BuildContext context) {
  final screenSize = MediaQuery.of(context).size;
  final isSmallScreen = screenSize.width < 600;

  return Scaffold(
    appBar: _buildAppBar(context),
    drawer: const LeftDrawer(),
    body: SingleChildScrollView(
      child: Column(
        children: [
          _buildHeroSection(context, isSmallScreen, screenSize),
          
          // Loading indicator
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            ),
          
          // Preferences section
          // Ubah kondisi ini untuk memastikan preferences card muncul
          if (_preferences.containsKey('preferences') && 
              _preferences['preferences'] != null)
            _buildPreferencesButton(context),
            
          // Recommendations section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Special For You',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
                const SizedBox(height: 16),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  SizedBox(
                    height: 320,
                    child: _recommendations != null && _recommendations!.isNotEmpty
                      ? ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _recommendations!.length,
                          itemBuilder: (context, index) {
                            final item = _recommendations![index];
                            return Container(
                              width: screenSize.width * 0.6,
                              margin: const EdgeInsets.only(right: 16),
                              child: ProductCard(
                                id: item['id'] ?? (index + 1).toString(),
                                imageUrl: item['imageUrl'],
                                name: item['name'],
                                restaurant: item['restaurant'],
                                rating: item['rating'].toDouble(),
                                kecamatan: item['kecamatan'],
                                operationalHours: item['operationalHours'],
                                price: item['price'],
                                kategori: item['kategori'],
                                cacheKey: _cacheKey ?? '',
                              ),
                            );
                          },
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _defaultRecommendations?.length ?? 0,
                          itemBuilder: (context, index) {
                            final item = _defaultRecommendations![index];
                            return Container(
                              width: screenSize.width * 0.6,
                              margin: const EdgeInsets.only(right: 16),
                              child: ProductCard(
                                id: item['id'] ?? (index + 1).toString(),
                                imageUrl: item['imageUrl'],
                                name: item['name'],
                                restaurant: item['restaurant'],
                                rating: item['rating'].toDouble(),
                                kecamatan: item['kecamatan'],
                                operationalHours: item['operationalHours'],
                                price: item['price'],
                                kategori: item['kategori'],
                                cacheKey: _cacheKey ?? '',
                              ),
                            );
                          },
                        ),
                  ),
              ],
            ),
          ),
          // Browse by Category section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Browse by Category',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Plus Jakarta Sans',
                    color: Color(0xFF121212),
                    letterSpacing: -0.40,
                  ),
                ),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryItem('Nasi', 'assets/images/nasi.png'),
                      _buildCategoryItem('Cemilan', 'assets/images/cemilan.png'),
                      _buildCategoryItem('Lontong', 'assets/images/lontong.png'),
                      _buildCategoryItem('Makanan Berat', 'assets/images/makanan_berat.png'),
                      _buildCategoryItem('Mie', 'assets/images/mie.png'),
                      _buildCategoryItem('Minuman', 'assets/images/minuman.png'),
                      _buildCategoryItem('Roti', 'assets/images/roti.png'),
                      _buildCategoryItem('Bubur', 'assets/images/bubur.png'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // How Nyarap Works section
          _buildHowNyarapWorks(),
        ],
      ),
    ),
  );
}


  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFCE181B),
      elevation: 0,
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            iconSize: 32,
          );
        },
      ),
      actions: [
        if (widget.isAuthenticated)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hi, ${_preferences['username'] ?? 'User'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 32,
                  width: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person,
                      color: Colors.black54,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isSmallScreen, Size screenSize) {
    return Container(
      width: double.infinity,
      height: 311,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: Color(0xFFCE181B),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -247,
            top: 34,
            child: Container(
              width: 494,
              height: 494,
              decoration: const ShapeDecoration(
                color: Color(0xFFB71418),
                shape: OvalBorder(),
              ),
            ),
          ),
          Positioned(
            right: -80,
            bottom: -20,
            child: Image.asset(
              'images/hero_food.png',
              width: screenSize.width * 0.9,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Error loading hero_food.png: $error');
                return Container(
                  width: screenSize.width * 0.9,
                  height: 200,
                  color: Colors.transparent,
                  child: const Center(
                    child: Icon(
                      Icons.fastfood,
                      size: 80,
                      color: Colors.white54,
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            left: 20,
            top: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Text('👋', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 8),
                      Text(
                        'Welcome!',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Mau Sarapan Apa\nHari Ini?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 32 : 40,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 40),
                _buildSearchBar(context, screenSize),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, Size screenSize) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecommendationsForm(
              isAuthenticated: widget.isAuthenticated,
            ),
          ),
        );
      },
      child: Container(
        width: screenSize.width - 40,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: Colors.grey[600],
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Cari Rekomendasi',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowNyarapWorks() {
 return Container(
   padding: const EdgeInsets.all(16),
   child: Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
       const Text(
         'How Nyarap Works?',
         style: TextStyle(
           fontSize: 20,
           fontWeight: FontWeight.bold,
           fontFamily: 'Plus Jakarta Sans',
         ),
       ),
       const SizedBox(height: 16),
       // Section 1
       Container(
         margin: const EdgeInsets.only(bottom: 16),
         decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.circular(12),
           boxShadow: [
             BoxShadow(
               color: Colors.grey.withOpacity(0.1),
               spreadRadius: 1,
               blurRadius: 4,
               offset: const Offset(0, 1),
             ),
           ],
         ),
         child: ExpansionTile(
           iconColor: Colors.orange,
           collapsedIconColor: Colors.orange,
           backgroundColor: Colors.yellow.shade600,
           collapsedBackgroundColor: Colors.yellow.shade300,
           title: Row(
             children: [
               Container(
                 padding: const EdgeInsets.all(8),
                 child: const Icon(Icons.search, color: Colors.black),
               ),
               const SizedBox(width: 12),
               const Row(
                 children: [
                   Text(
                     '01  ',
                     style: TextStyle(
                       color: Color(0xFFCE181B),
                       fontSize: 16,
                       fontWeight: FontWeight.bold,
                     ),
                   ),
                   Text(
                     'Choose what to eat',
                     style: TextStyle(
                       fontSize: 16,
                       fontWeight: FontWeight.w600,
                     ),
                   ),
                 ],
               ),
             ],
           ),
           children: [
             Container(
               width: double.infinity,
               padding: const EdgeInsets.all(16),
               decoration: BoxDecoration(
                 color: Colors.yellow.shade50,
                 borderRadius: BorderRadius.circular(8),
               ),
               child: const Text(
                 'Browse through our menu and pick your breakfast craving.',
                 style: TextStyle(fontSize: 14, color: Colors.black87),
               ),
             ),
           ],
         ),
       ),

       // Section 2
       Container(
         margin: const EdgeInsets.only(bottom: 16),
         decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.circular(12),
           boxShadow: [
             BoxShadow(
               color: Colors.grey.withOpacity(0.1),
               spreadRadius: 1,
               blurRadius: 4,
               offset: const Offset(0, 1),
             ),
           ],
         ),
         child: ExpansionTile(
           iconColor: Colors.orange,
           collapsedIconColor: Colors.orange,
           backgroundColor: Colors.yellow.shade600,
           collapsedBackgroundColor: Colors.yellow.shade300,
           title: Row(
             children: [
               Container(
                 padding: const EdgeInsets.all(8),
                 child: const Icon(Icons.location_on, color: Colors.black),
               ),
               const SizedBox(width: 12),
               const Row(
                 children: [
                   Text(
                     '02  ',
                     style: TextStyle(
                       color: Color(0xFFCE181B),
                       fontSize: 16,
                       fontWeight: FontWeight.bold,
                     ),
                   ),
                   Text(
                     'Choose your location',
                     style: TextStyle(
                       fontSize: 16,
                       fontWeight: FontWeight.w600,
                     ),
                   ),
                 ],
               ),
             ],
           ),
           children: [
             Container(
               width: double.infinity,
               padding: const EdgeInsets.all(16),
               decoration: BoxDecoration(
                 color: Colors.yellow.shade50,
                 borderRadius: BorderRadius.circular(8),
               ),
               child: const Text(
                 'Set your location to find nearby breakfast options.',
                 style: TextStyle(fontSize: 14, color: Colors.black87),
               ),
             ),
           ],
         ),
       ),

       // Section 3
       Container(
         margin: const EdgeInsets.only(bottom: 16),
         decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.circular(12),
           boxShadow: [
             BoxShadow(
               color: Colors.grey.withOpacity(0.1),
               spreadRadius: 1,
               blurRadius: 4,
               offset: const Offset(0, 1),
             ),
           ],
         ),
         child: ExpansionTile(
           iconColor: Colors.orange,
           collapsedIconColor: Colors.orange,
           backgroundColor: Colors.yellow.shade600,
           collapsedBackgroundColor: Colors.yellow.shade300,
           title: Row(
             children: [
               Container(
                 padding: const EdgeInsets.all(8),
                 child: const Icon(Icons.attach_money, color: Colors.black),
               ),
               const SizedBox(width: 12),
               const Row(
                 children: [
                   Text(
                     '03  ',
                     style: TextStyle(
                       color: Color(0xFFCE181B),
                       fontSize: 16,
                       fontWeight: FontWeight.bold,
                     ),
                   ),
                   Text(
                     'Choose your price range',
                     style: TextStyle(
                       fontSize: 16,
                       fontWeight: FontWeight.w600,
                     ),
                   ),
                 ],
               ),
             ],
           ),
           children: [
             Container(
               width: double.infinity,
               padding: const EdgeInsets.all(16),
               decoration: BoxDecoration(
                 color: Colors.yellow.shade50,
                 borderRadius: BorderRadius.circular(8),
               ),
               child: const Text(
                 'Filter the options based on your budget.',
                 style: TextStyle(fontSize: 14, color: Colors.black87),
               ),
             ),
           ],
         ),
       ),

       // Section 4
       Container(
         margin: const EdgeInsets.only(bottom: 16),
         decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.circular(12),
           boxShadow: [
             BoxShadow(
               color: Colors.grey.withOpacity(0.1),
               spreadRadius: 1,
               blurRadius: 4,
               offset: const Offset(0, 1),
             ),
           ],
         ),
         child: ExpansionTile(
           iconColor: Colors.orange,
           collapsedIconColor: Colors.orange,
           backgroundColor: Colors.yellow.shade600,
           collapsedBackgroundColor: Colors.yellow.shade300,
           title: Row(
             children: [
               Container(
                 padding: const EdgeInsets.all(8),
                 child: const Icon(Icons.person, color: Colors.black),
               ),
               const SizedBox(width: 12),
               const Expanded(
                 child: Row(
                   children: [
                     Text(
                       '04  ',
                       style: TextStyle(
                         color: Color(0xFFCE181B),
                         fontSize: 16,
                         fontWeight: FontWeight.bold,
                       ),
                     ),
                     Expanded(
                       child: Text(
                         'Get personalized recommendations',
                         style: TextStyle(
                           fontSize: 16,
                           fontWeight: FontWeight.w600,
                         ),
                         overflow: TextOverflow.ellipsis,
                         maxLines: 2,
                       ),
                     ),
                   ],
                 ),
               ),
             ],
           ),
           children: [
             Container(
               width: double.infinity,
               padding: const EdgeInsets.all(16),
               decoration: BoxDecoration(
                 color: Colors.yellow.shade50,
                 borderRadius: BorderRadius.circular(8),
               ),
               child: const Text(
                 'Login to save your favorite breakfast spots, post in the community, and leave reviews.',
                 style: TextStyle(fontSize: 14, color: Colors.black87),
               ),
             ),
           ],
         ),
       ),
     ],
   ),
 );
}

  Widget _buildRecommendationSection(
    List<Map<String, dynamic>> items,
    String title,
    Size screenSize,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 280, // Adjust height as needed
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Container(
                  width: screenSize.width * 0.6,
                  margin: const EdgeInsets.only(right: 16),
                  child: ProductCard(
                    id: item['id'] ?? (index + 1).toString(),
                    imageUrl: item['imageUrl'],
                    name: item['name'],
                    restaurant: item['restaurant'],
                    rating: item['rating'].toDouble(),
                    kecamatan: item['kecamatan'],
                    operationalHours: item['operationalHours'],
                    price: item['price'],
                    kategori: item['kategori'],
                    cacheKey: _cacheKey ?? '',
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