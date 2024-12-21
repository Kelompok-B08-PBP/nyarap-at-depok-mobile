import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nyarap_at_depok_mobile/explore/models/explore.dart';
import 'package:nyarap_at_depok_mobile/explore/models/recommendation.dart';
import 'package:nyarap_at_depok_mobile/home/login.dart';
import 'package:nyarap_at_depok_mobile/explore/widgets/recommendations_form.dart';
import 'package:nyarap_at_depok_mobile/explore/screens/recommendation_list.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class PreferencesScreen extends StatefulWidget {
  final String? username;
  final bool isAuthenticated;

  const PreferencesScreen({
    Key? key,
    this.username,
    this.isAuthenticated = false,
  }) : super(key: key);

  @override
  _PreferencesScreenState createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool _isLoading = true;
  List<Preference>? _preferences;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    if (widget.isAuthenticated) {
      _loadPreferences();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadPreferences() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get('http://localhost:8000/get_user_data/');

      if (response['status'] == 'success') {
        final data = response['data'];
        if (data['preferences'] != null) {
          setState(() {
            _preferences = [
              Preference(
                id: data['preferences']['id'],
                userId: data['user']['id'],
                preferredLocation: data['preferences']['district_category'],
                preferredBreakfastType: data['preferences']['breakfast_category'],
                preferredPriceRange: data['preferences']['price_range'],
                createdAt: DateTime.now(),
              )
            ];
            _isLoading = false;
          });
        } else {
          setState(() {
            _preferences = [];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading preferences: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePreference(Map<String, String> data) async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.post(
        'http://localhost:8000/api/preferences/save/',
        jsonEncode({
          'preferred_location': data['location'],
          'preferred_breakfast_type': data['breakfast_type'],
          'preferred_price_range': data['price_range'],
        }),
      );

      if (response['status'] == 'success') {
        await _loadPreferences();
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

  Future<void> _deletePreference() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.post(
        'http://localhost:8000/api/preferences/delete/',
        {},
      );

      if (response['status'] == 'success') {
        await _loadPreferences();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Preferensi berhasil dihapus')),
          );
        }
      }
    } catch (e) {
      print('Error deleting preference: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghapus preferensi')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Preferensi Sarapan'),
          backgroundColor: Colors.black,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Silakan login untuk mengelola preferensi'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferensi Sarapan'),
        backgroundColor: Colors.black,
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _loadPreferences,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.black.withOpacity(0.1),
              child: Column(
                children: [
                  Text(
                    'Preferensi Sarapan Anda',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (widget.username != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Hi, ${widget.username}!',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: _preferences == null || _preferences!.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Belum ada preferensi tersimpan'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RecommendationsForm(
                                    isAuthenticated: widget.isAuthenticated,
                                    username: widget.username,
                                  ),
                                ),
                              ).then((_) => _loadPreferences());
                            },
                            child: const Text('Tambah Preferensi'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _preferences!.length,
                      itemBuilder: (context, index) {
                        final pref = _preferences![index];
                        return PreferenceCard(
                          preference: pref,
                          onEdit: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecommendationsForm(
                                  isAuthenticated: widget.isAuthenticated,
                                  username: widget.username,
                                  initialPreferences: Explore(
                                    model: "explore.userpreference",
                                    pk: pref.id,
                                    fields: Fields(
                                      user: pref.userId,
                                      preferredLocation: pref.preferredLocation,
                                      preferredBreakfastType:
                                          pref.preferredBreakfastType,
                                      preferredPriceRange:
                                          pref.preferredPriceRange,
                                      createdAt: DateTime.now(),
                                    ),
                                  ),
                                ),
                              ),
                            ).then((_) => _loadPreferences());
                          },
                          onDelete: _deletePreference,
                          onSave: _savePreference,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecommendationsForm(
                isAuthenticated: widget.isAuthenticated,
                username: widget.username,
              ),
            ),
          ).then((_) => _loadPreferences());
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PreferenceCard extends StatefulWidget {
  final Preference preference;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(Map<String, String>) onSave;

  const PreferenceCard({
    Key? key,
    required this.preference,
    required this.onEdit,
    required this.onDelete,
    required this.onSave,
  }) : super(key: key);

  @override
  _PreferenceCardState createState() => _PreferenceCardState();
}

class _PreferenceCardState extends State<PreferenceCard> {
  bool _isLoading = false;

  Widget _buildPreferenceInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 16),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Preferensi Sarapan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: widget.onEdit,
                      child: const Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      onTap: widget.onDelete,
                      child: const Row(
                        children: [
                          Icon(Icons.delete),
                          SizedBox(width: 8),
                          Text('Hapus'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildPreferenceInfo('Kategori',
                _getDisplayBreakfastType(widget.preference.preferredBreakfastType)),
            _buildPreferenceInfo(
                'Lokasi', _getDisplayLocation(widget.preference.preferredLocation)),
            _buildPreferenceInfo('Harga',
                _getDisplayPriceRange(widget.preference.preferredPriceRange)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        setState(() => _isLoading = true);
                        try {
                          // Save preferences
                          final Map<String, String> preferenceData = {
                            'location': widget.preference.preferredLocation,
                            'breakfast_type':
                                widget.preference.preferredBreakfastType,
                            'price_range': widget.preference.preferredPriceRange,
                          };
                          await widget.onSave(preferenceData);

                          // Get recommendations
                          final request = context.read<CookieRequest>();
                          final response = await request.post(
                            'http://localhost:8000/api/recommendations/',
                            jsonEncode({
                              'breakfast_type':
                                  widget.preference.preferredBreakfastType,
                              'location': widget.preference.preferredLocation
                                  .replaceAll('_', ' '),
                              'price_range': widget.preference.preferredPriceRange,
                            }),
                          );

                          if (!mounted) return;

                          if (response['status'] == 'success') {
                            final String cacheKey = response['cache_key'];
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
                                    'location': _getDisplayLocation(
                                        widget.preference.preferredLocation),
                                    'breakfast_type': _getDisplayBreakfastType(
                                        widget.preference.preferredBreakfastType),
                                    'price_range': _getDisplayPriceRange(
                                        widget.preference.preferredPriceRange),
                                  },
                                  cacheKey: cacheKey,
                                ),
                              ),
                            );
                          } else {
                            throw Exception(
                                response['message'] ?? 'Failed to get recommendations');
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
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
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
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Preference {
  final String id;
  final int userId;
  final String preferredLocation;
  final String preferredBreakfastType;
  final String preferredPriceRange;
  final DateTime createdAt;

  Preference({
    required this.id,
    required this.userId,
    required this.preferredLocation,
    required this.preferredBreakfastType,
    required this.preferredPriceRange,
    required this.createdAt,
  });
}