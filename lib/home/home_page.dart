import 'package:flutter/material.dart';
import 'package:nyarap_at_depok_mobile/explore/screens/browse_category.dart';
import 'package:nyarap_at_depok_mobile/explore/widgets/recommendations_form.dart';
import 'package:nyarap_at_depok_mobile/home/left_drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isMediumScreen = screenSize.width < 1000;

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
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        Text(
                          'mau sarapan apa hari ini?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 32 : isMediumScreen ? 45 : 60,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFC3372B),
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Temukan tempat sarapan terbaik di Depok dalam sekali klik!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 18 : isMediumScreen ? 24 : 32,
                            color: const Color(0xFF676B6F),
                            fontFamily: 'Sarala',
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 12,
                              ),
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
                      fontFamily: 'Montserrat',
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
                    offset: const Offset(0, 4),
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
                color: Color(0xFF333333),
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}