import 'package:flutter/material.dart';
import 'package:nyarap_at_depok_mobile/explore/screens/browse_category.dart';
import 'package:nyarap_at_depok_mobile/explore/screens/product_card.dart';
import 'package:nyarap_at_depok_mobile/explore/widgets/recommendations_form.dart';
import 'package:nyarap_at_depok_mobile/home/left_drawer.dart';

class HomePage extends StatelessWidget {
  final bool isAuthenticated;
  final Map<String, dynamic> preferences;
  final List<Map<String, dynamic>>? recommendations;

  const HomePage({
    super.key,
    this.isAuthenticated = false,
    this.preferences = const {},
    this.recommendations,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isMediumScreen = screenSize.width < 1000;

    // Sample recommendation for non-logged in users
    final defaultRecommendation = {
      'imageUrl': 'images/nasi.png',
      'name': 'Nasi Uduk',
      'restaurant': 'Warung Bu Siti',
      'rating': 4.5,
      'kecamatan': 'Beji',
      'operationalHours': '06.00 - 10.00',
      'price': 'Rp 12.000',
      'kategori': 'Nasi',
    };

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6D110),
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 40,
            ),
            const SizedBox(width: 8),
            const Text(
              'Nyarap @Depok',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          if (isAuthenticated)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Hi, ${preferences['username'] ?? 'User'}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: const Icon(
                      Icons.person,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      drawer: const LeftDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Stack(
              children: [
                Container(
                  height: isSmallScreen
                      ? screenSize.height * 0.5
                      : screenSize.height * 0.7,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/backgroundhero.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: isSmallScreen
                      ? screenSize.height * 0.5
                      : screenSize.height * 0.7,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.width * 0.05,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Welcome,',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 32 : isMediumScreen ? 45 : 60,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Mau Sarapan Apa Hari Ini?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 32 : isMediumScreen ? 45 : 60,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFC3372B),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Temukan tempat sarapan terbaik di Depok dalam sekali klik!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 18 : isMediumScreen ? 24 : 32,
                            color: const Color(0xFF676B6F),
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: isSmallScreen ? 200 : 250,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RecommendationsForm(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC3372B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text(
                              'Get Started',
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
                ),
              ],
            ),

            // User Preferences (if logged in)
            if (isAuthenticated && recommendations != null && recommendations!.isNotEmpty)
              _buildRecommendationSection(recommendations!, 'Special For You'),

            // Default recommendations for non-logged in users
            if (!isAuthenticated)
              _buildRecommendationSection(
                [defaultRecommendation],
                'Special For You',
              ),

            // Category Section
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.05,
                vertical: 40,
              ),
              child: Column(
                children: [
                  Text(
                    'Browse by Category',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 28 : 36,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 40),
                  isSmallScreen
                      ? _buildCategoryGrid(context)
                      : _buildCategoryList(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationSection(List<Map<String, dynamic>> items, String title) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ProductCard(
                  imageUrl: item['imageUrl'],
                  name: item['name'],
                  restaurant: item['restaurant'],
                  rating: item['rating'].toDouble(),
                  kecamatan: item['kecamatan'],
                  operationalHours: item['operationalHours'],
                  price: item['price'],
                  kategori: item['kategori'],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildCategoryItem('Nasi', 'assets/images/nasi.png', context),
          _buildCategoryItem('Roti', 'assets/images/roti.png', context),
          _buildCategoryItem('Lontong', 'assets/images/lontong.png', context),
          _buildCategoryItem('Cemilan', 'assets/images/cemilan.png', context),
          _buildCategoryItem('Minuman', 'assets/images/minuman.png', context),
          _buildCategoryItem('Mie', 'assets/images/mie.png', context),
          _buildCategoryItem('Sarapan Sehat', 'assets/images/telur.png', context),
          _buildCategoryItem('Bubur', 'assets/images/bubur.png', context),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 0.9,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      children: [
        _buildCategoryItem('Nasi', 'assets/images/nasi.png', context),
        _buildCategoryItem('Roti', 'assets/images/roti.png', context),
        _buildCategoryItem('Lontong', 'assets/images/lontong.png', context),
        _buildCategoryItem('Cemilan', 'assets/images/cemilan.png', context),
        _buildCategoryItem('Minuman', 'assets/images/minuman.png', context),
        _buildCategoryItem('Mie', 'assets/images/mie.png', context),
        _buildCategoryItem('Sarapan Sehat', 'assets/images/telur.png', context),
        _buildCategoryItem('Bubur', 'assets/images/bubur.png', context),
      ],
    );
  }

  Widget _buildCategoryItem(String name, String imagePath, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BrowseByCategoryPage(category: name),
          ),
        );
      },
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
