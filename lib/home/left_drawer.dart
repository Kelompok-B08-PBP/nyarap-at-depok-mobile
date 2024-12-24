import 'package:flutter/material.dart';
import 'package:nyarap_at_depok_mobile/home/login.dart';
import 'package:nyarap_at_depok_mobile/home/register.dart';
import 'package:nyarap_at_depok_mobile/explore/screens/preferences_screen.dart';
import 'package:nyarap_at_depok_mobile/wishlist/screens/wishlist_screens.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:nyarap_at_depok_mobile/reviews/screens/review_list_screen.dart';
import 'package:nyarap_at_depok_mobile/community/screens/community_page.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Modern Drawer Header with Gradient
            Container(
              padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFCE181B),
                    const Color(0xFFCE181B).withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFFFC107).withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Image.asset(
                          'assets/images/logo_besar.png',
                          width: 40,
                          height: 40,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nyarap @Depok',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Find Your Breakfast',
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFFFFF176).withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Scrollable Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'MENU',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  _buildMenuItem(
                    context,
                    icon: Icons.home_rounded,
                    title: 'Home',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),

                  _buildMenuItem(
                    context,
                    icon: Icons.people_alt_rounded,
                    title: 'Community',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CommunityPage(),
                        ),
                      );
                    },
                  ),

                  _buildMenuItem(
                    context,
                    icon: Icons.favorite_rounded,
                    title: 'Wishlist',
                    onTap: () {
                      final request = Provider.of<CookieRequest>(context, listen: false);

                      // Check if user is logged in
                      if (request.loggedIn) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WishlistScreen(),
                          ),
                        );
                      } else {
                        // Show message and redirect to LoginPage
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Silakan login terlebih dahulu untuk melihat wishlist Anda'),
                            backgroundColor: Colors.red[700],
                          ),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      }
                    },
                  ),


                  _buildMenuItem(
                    context,
                    icon: Icons.star_rounded,
                    title: 'Reviews',
                    onTap: () {
                      Navigator.pop(context);
                      if (request.loggedIn) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReviewListScreen(
                              isAuthenticated: true,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Silakan login terlebih dahulu'),
                            backgroundColor: Colors.red[700],
                          ),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            // Account Section at Bottom
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDE7).withOpacity(0.3),
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFFFFF59D).withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!request.loggedIn) ...[
                    // Login Button
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFCE181B),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                      },
                      icon: const Icon(Icons.login_rounded, size: 20),
                      label: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Register Button with yellow border
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFCE181B),
                        minimumSize: const Size(double.infinity, 46),
                        side: BorderSide(
                          color: const Color(0xFFCE181B),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterPage()),
                        );
                      },
                      icon: const Icon(Icons.person_add_rounded, size: 20),
                      label: const Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ] else ...[
                    // Logout Button
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFCE181B),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final response = await request.logout(
                          'http://localhost:8000/auth/logout/'
                        );
                        String message = response["message"];
                        
                        if (context.mounted) {
                          if (response['status']) {
                            String uname = response["username"];
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text("$message Sampai jumpa, $uname."),
                                  ],
                                ),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                margin: const EdgeInsets.all(16),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                ),
                              ),
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginPage()),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.error, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text(message),
                                  ],
                                ),
                                backgroundColor: Colors.red[700],
                                behavior: SnackBarBehavior.floating,
                                margin: const EdgeInsets.all(16),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                ),
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.logout_rounded, size: 20),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFFFF9C4).withOpacity(0.2) : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: isActive ? const Color(0xFFFFC107) : Colors.transparent,
                width: 4,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: isActive ? const Color(0xFFCE181B) : Colors.grey[700],
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? const Color(0xFFCE181B) : Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}