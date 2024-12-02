import 'package:flutter/material.dart';
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
                            onPressed: () {},
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

            // How Nyarap Works Section
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.05,
                vertical: 40,
              ),
              child: Column(
                children: [
                  Text(
                    'How Nyarap Works?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 32 : 46,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2E2C49),
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 40),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: isSmallScreen ? 1 : isMediumScreen ? 2 : 4,
                    childAspectRatio: isSmallScreen ? 1.2 : 0.9,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    children: const [
                      StepCard(
                        step: "01",
                        emoji: "🍳",
                        title: "Choose what to eat",
                        description: "Browse through our menu and pick your breakfast craving.",
                      ),
                      StepCard(
                        step: "02",
                        emoji: "📍",
                        title: "Choose your location",
                        description: "Set your location to find nearby breakfast options.",
                      ),
                      StepCard(
                        step: "03",
                        emoji: "💰",
                        title: "Choose your price range",
                        description: "Filter the options based on your budget.",
                      ),
                      StepCard(
                        step: "04",
                        emoji: "👤",
                        title: "Add to Wishlist",
                        description: "Login to save your favorite breakfast spots and get personalized recommendations.",
                      ),
                    ],
                  ),
                ],
              ),
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
          _buildCategoryItem('Nasi', 'assets/images/nasi.png'),
          _buildCategoryItem('Roti', 'assets/images/roti.png'),
          _buildCategoryItem('Lontong', 'assets/images/lontong.png'),
          _buildCategoryItem('Cemilan', 'assets/images/cemilan.png'),
          _buildCategoryItem('Minuman', 'assets/images/minuman.png'),
          _buildCategoryItem('Mie', 'assets/images/mie.png'),
          _buildCategoryItem('Sarapan Sehat', 'assets/images/telur.png'),
          _buildCategoryItem('Bubur', 'assets/images/bubur.png'),
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
        _buildCategoryItem('Nasi', 'assets/images/nasi.png'),
        _buildCategoryItem('Roti', 'assets/images/roti.png'),
        _buildCategoryItem('Lontong', 'assets/images/lontong.png'),
        _buildCategoryItem('Cemilan', 'assets/images/cemilan.png'),
        _buildCategoryItem('Minuman', 'assets/images/minuman.png'),
        _buildCategoryItem('Mie', 'assets/images/mie.png'),
        _buildCategoryItem('Sarapan Sehat', 'assets/images/telur.png'),
        _buildCategoryItem('Bubur', 'assets/images/bubur.png'),
      ],
    );
  }

  Widget _buildCategoryItem(String name, String imagePath) {
    return Container(
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
    );
  }
}

class StepCard extends StatelessWidget {
  final String step;
  final String emoji;
  final String title;
  final String description;

  const StepCard({
    super.key,
    required this.step,
    required this.emoji,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            step,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFF5331),
              fontFamily: 'Montserrat',
            ),
          ),
          Container(
            width: 60,
            height: 60,
            margin: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 30),
              ),
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF191720),
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF676B6F),
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}