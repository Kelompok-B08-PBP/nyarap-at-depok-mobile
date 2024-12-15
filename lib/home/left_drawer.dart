import 'package:flutter/material.dart';
import 'package:nyarap_at_depok_mobile/home/login.dart';
import 'package:nyarap_at_depok_mobile/home/register.dart';
import 'package:nyarap_at_depok_mobile/explore/widgets/recommendations_form.dart';
import 'package:nyarap_at_depok_mobile/reviews/screens/review_list_screen.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer Header with Logo
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFFF6D110), // Yellow background
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 50,
                    height: 50,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Nyarap @Depok',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            
            // Menu Items
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text(
                'Home',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Montserrat',
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // Navigate to home
              },
            ),

            ListTile(
              leading: const Icon(Icons.people_outlined),
              title: const Text(
                'Community',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Montserrat',
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // Navigate to community page
              },
            ),

            ListTile(
              leading: const Icon(Icons.star_border),
              title: const Text(
                'Reviews',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Montserrat',
                ),
              ),
              onTap: () {
                Navigator.pop(context); // Close drawer
                
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
                    const SnackBar(
                      content: Text('Silakan login terlebih dahulu'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                }
              },
            ),
            
            // Preferences Menu
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text(
                'Preferences',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Montserrat',
                ),
              ),
              onTap: () async {
                Navigator.pop(context); // Close drawer first
                
                // Check if user is logged in by checking if there's a logged_in_user cookie
                final isLoggedIn = request.loggedIn;
                
                if (isLoggedIn) {
                  // Get user data from the cookie
                  final response = await request.get('http://localhost:8000/get_user_data/');
                  if (response['status'] == 'success') {
                    if (context.mounted) {
                      if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RecommendationsForm(
                                isAuthenticated: true,
                              ),
                            ),
                          );
                        }
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Gagal mengambil data preferensi'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } else {
                  if (context.mounted) {
                    // Show login required message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Silakan login terlebih dahulu'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    
                    // Navigate to login page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  }
                }
              },
            ),

            const Divider(),

            // Login/Register section at bottom
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  if (!request.loggedIn) ...[
                    // Show login button only if user is not logged in
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        side: const BorderSide(color: Colors.black),
                        minimumSize: const Size.fromHeight(40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC3372B),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterPage()),
                        );
                      },
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ] else ...[
                    // Show logout button if user is logged in
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC3372B),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () async {
                        final response = await request.logout(
                          'http://localhost:8000/logout/'
                        );
                        if (response['status'] == 'success') {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Berhasil logout'),
                              ),
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginPage()),
                            );
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Gagal logout'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
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
}