import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nyarap_at_depok_mobile/community/widgets/create_post_form.dart';
import 'package:nyarap_at_depok_mobile/community/widgets/edit_post_form.dart';
import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:nyarap_at_depok_mobile/community/models/community.dart';
import 'package:nyarap_at_depok_mobile/community/widgets/post_card.dart';
import 'package:nyarap_at_depok_mobile/home/login.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  bool isForYou = true;
  bool showLoginMessage = false;
  bool isAuthenticated = false;
  List<Community> posts = [];

  @override
  void initState() {
    super.initState();
    fetchPosts();
    checkAuthentication();
  }

  void checkAuthentication() {
    final request = context.read<CookieRequest>();
    setState(() {
      isAuthenticated = request.loggedIn;
    });
  }

  Future<void> fetchPosts() async {
  try {
    final request = context.read<CookieRequest>();
    final response = await request.get(
      'http://localhost:8000/discovery/get_posts_flutter/'
    );

    if (response != null && response['status'] == 'success') {
      List<Community> allPosts = (response['results'] as List)
          .map((post) => Community.fromJson(post))
          .toList();

      setState(() {
        if (!isForYou && request.loggedIn) {
          // Filter for "Yours" tab - matches Django's implementation
          posts = allPosts.where((post) => 
            post.fields.user.toString() == request.jsonData['id'].toString()
          ).toList();
          
          if (posts.isEmpty) {
            showLoginMessage = false;
          }
        } else {
          // "For You" tab shows all posts - matches Django
          posts = allPosts;
          showLoginMessage = false;
        }
      });
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to fetch posts'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  Future<void> handleDelete(String postId) async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.post(
        'http://localhost:8000/discovery/delete-flutter/$postId/',
        {}
      );

      if (response['status'] == 'success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          fetchPosts(); // Refresh the posts list
        }
      } else {
        throw response['message'] ?? 'Failed to delete post';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Add AppBar here
      appBar: AppBar(
          backgroundColor:Color(0xFFCE181B),
        ),

      body: RefreshIndicator(
        onRefresh: fetchPosts,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Banner Section
              Container(
                width: double.infinity,
                height: 400,
                decoration: const BoxDecoration(
                  color: Color(0xFFCE181B),
                ),
                child: Stack(
                  children: [
                    const Positioned(
                      left: 40,
                      top: 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome to',
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 32,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          Text(
                            'Nyarap\nCommunity',
                            style: TextStyle(
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontFamily: 'Montserrat',
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                  ],
                ),
              ),

              // Main Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
                child: Column(
                  children: [
                    const Text(
                      'Good Morning!',
                      style: TextStyle(
                         color: Color(0xFFCE181B),
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Ready to Explore Breakfast Favorites? Share, discover, and indulge in the most important meal of the day.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[800],
                        height: 1.5,
                        fontFamily: 'Poppins',
                      ),
                    ),

                    // Filter Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildFilterButton('For You', isForYou, () {
                            setState(() {
                              isForYou = true;
                              showLoginMessage = false;
                            });
                          }),
                          const SizedBox(width: 16),
                          _buildFilterButton('Yours', !isForYou, () {
                            setState(() {
                              isForYou = false;
                              showLoginMessage = !isAuthenticated;
                            });
                          }),
                          const SizedBox(width: 16),
                          _buildPostButton(),
                        ],
                      ),
                    ),

                    // Login Message
                    if (showLoginMessage)
                      Column(
                        children: [
                          const Text(
                            'Please log in first.',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Image.asset(
                            'assets/images/haruslogin.png',
                            height: 100,
                          ),
                        ],
                      ),

                    // Posts List
                    if (!showLoginMessage) ..._buildPosts(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(String text, bool isActive, VoidCallback onPressed) {
    final request = context.read<CookieRequest>();
    final isYours = text == 'Yours';

    return OutlinedButton(
      onPressed: () {
        if (!request.loggedIn && (isYours || text == 'Post')) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Login Required'),
              content: const Text('Please login to view your posts.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  child: const Text('Login'),
                ),
              ],
            ),
          );
        } else {
          setState(() {
            isForYou = text == 'For You';
            fetchPosts();
          });
        }
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: isActive ? Colors.white : Colors.black,
        backgroundColor: isActive ? const Color.fromARGB(255, 0, 0, 0) : Colors.white,
        side: isActive ? BorderSide.none : const BorderSide(color: Colors.black),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }


  Widget _buildPostButton() {
    return OutlinedButton(
      onPressed: () {
        if (!isAuthenticated) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Login Required'),
              content: const Text('Please login to create a post.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  child: const Text('Login'),
                ),
              ],
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreatePostEntry(),
            ),
          ).then((value) {
            if (value == true) {
              fetchPosts();
            }
          });
        }
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        side: const BorderSide(color: Colors.black),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
      child: const Text(
        'Post',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  List<Widget> _buildPosts() {
  // Case 1: No posts available at all
    if (posts.isEmpty) {
      return [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No posts available yet.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 20),
            Image.asset(
              'assets/images/bingung.png',
              height: 100,
            ),
          ],
        ),
      ];
    }

    final request = context.read<CookieRequest>();
    final currentUserId = request.loggedIn ? request.jsonData['id'] as int? : null;

    // Filter posts based on the selected tab and authentication
    final filteredPosts = isForYou 
      ? posts // Show all posts for "For You" tab
      : posts.where((post) => 
        post.fields.user.toString() == request.jsonData['id'].toString()
      ).toList();
    // Case 2: Not logged in and trying to view "Yours" tab
    if (!isForYou && !request.loggedIn) {
      return [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Please login to see your posts.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 20),
            Image.asset(
              'assets/images/haruslogin.png',
              height: 100,
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFC3372B),
                side: const BorderSide(color: Color(0xFFC3372B)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Login',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ];
    }

    // Case 3: Logged in but no personal posts in "Yours" tab
    if (!isForYou && filteredPosts.isEmpty) {
      return [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'You haven\'t created any posts yet.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 20),
            Image.asset(
              'assets/images/bingung.png',
              height: 100,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreatePostEntry(),
                  ),
                ).then((value) {
                  if (value == true) {
                    fetchPosts();
                  }
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Post'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFC3372B),
                side: const BorderSide(color: Color(0xFFC3372B)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ];
    }
      return filteredPosts.map((post) {
      final request = context.read<CookieRequest>();
      final isOwner = request.loggedIn && 
                      post.fields.user.toString() == request.jsonData['id'].toString();

      return Column(
        children: [
          PostCard(
            post: post,
            canEdit: isOwner,
            onEdit: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditPostForm(post: post),
                ),
              ).then((value) {
                if (value == true) {
                  fetchPosts();
                }
              });
            },
            onDelete: () async {
              try {
                await handleDelete(post.pk);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },

          ),
          const SizedBox(height: 20),
        ],
      );
    }).toList();
  }
}
