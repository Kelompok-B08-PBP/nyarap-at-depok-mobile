import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:nyarap_at_depok_mobile/home/home_page.dart';
import 'package:nyarap_at_depok_mobile/explore/screens/product_details.dart';


class WishlistScreen extends StatefulWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final TextEditingController _noteController = TextEditingController();
  
  static const String baseUrl = "http://valiza-nadya-nyarapatdepok.pbp.cs.ui.ac.id";

  Future<List<dynamic>> fetchWishlist(BuildContext context) async {
    final request = Provider.of<CookieRequest>(context, listen: false);
    try {
      final response = await request.get('$baseUrl/wishlist/json/');
      print('Data dari server: $response'); 
      if (response['wishlist'] != null) {
        return response['wishlist'] as List;
      }
    } catch (e) {
      print('Error fetching wishlist: $e');
    }
    return [];
  }

  Future<void> removeFromWishlist(BuildContext context, int productId) async {
    final request = Provider.of<CookieRequest>(context, listen: false);
    try {
      final response = await request.post(
        '$baseUrl/wishlist/remove-json/$productId/',
        {},
      );
      
      if (response['status'] == 'success') {
        setState(() {});
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item removed from wishlist'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove item: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> addNote(BuildContext context, int productId, String content) async {
    final request = Provider.of<CookieRequest>(context, listen: false);
    try {
      print('Sending note: $content for product: $productId'); // Debug print
      
      final response = await request.post(
        '$baseUrl/wishlist/note/add-flutter/$productId/',
        jsonEncode({'content': content}) // Encode the data as JSON
      );
      
      print('Response: $response'); // Debug print
      
      if (response['status'] == 'success') {
        _noteController.clear();
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note added successfully'))
        );
      }
    } catch (e) {
      print('Error adding note: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add note: $e'))
      );
    }
}


Future<void> editNote(BuildContext context, int noteId, String content) async {
    final request = Provider.of<CookieRequest>(context, listen: false);
    try {
      print('Editing note $noteId with content: $content'); // Debug print
      
      final response = await request.post(
        '$baseUrl/wishlist/note/edit-flutter/$noteId/',
        jsonEncode({'content': content})
      );
      
      print('Response: $response'); // Debug print
      
      if (response['status'] == 'success') {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note updated successfully'))
        );
      }
    } catch (e) {
      print('Error editing note: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update note: $e'))
      );
    }
}

Future<void> deleteNote(BuildContext context, int noteId) async {
    final request = Provider.of<CookieRequest>(context, listen: false);
    try {
      final response = await request.post(
        '$baseUrl/wishlist/note/delete-flutter/$noteId/',
        {}
      );
      
      if (response['status'] == 'success') {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note deleted successfully'))
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete note: $e'))
      );
    }
}


  Future<Map<String, dynamic>> fetchNotes(BuildContext context, int productId) async {
    final request = Provider.of<CookieRequest>(context, listen: false);
    try {
      final response = await request.get('$baseUrl/wishlist/notes/json/$productId/');
      return response;
    } catch (e) {
      print('Error fetching notes: $e');
      return {'notes': []};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
                title: const Text(
          'Nyarap Nanti',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Plus Jakarta Sans',
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFCE181B),

      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchWishlist(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, color: Colors.grey, size: 80),
                  SizedBox(height: 16),
                  Text(
                    'No items in wishlist',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
            return ListView.builder(
  padding: const EdgeInsets.all(16),
  itemCount: snapshot.data!.length,
  itemBuilder: (context, index) {
    final item = snapshot.data![index];
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                ),
                child: SizedBox(
                  width: 140,
                  height: 140,
                  child: Image.network(
                    item['image_url'] ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 50),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['restaurant'] ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.yellow,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${item['rating']}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Plus Jakarta Sans',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Rp ${item['price']}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['location'] ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ExpansionTile(
              title: const Text(
                'Notes',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _noteController,
                        decoration: const InputDecoration(
                          labelText: 'Add a note',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () {
                          final content = _noteController.text.trim();
                          if (content.isNotEmpty) {
                            addNote(
                              context,
                              int.parse(item['product_id'].toString()),
                              content,
                            );
                          }
                        },
                        child: const Text(
                          'Add Note',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder(
                        future: fetchNotes(context, int.parse(item['product_id'].toString())),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          List<dynamic> notes = snapshot.data?['notes'] ?? [];
                          return Column(
                            children: notes.map((note) => Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(
                                  note['content'],
                                  style: const TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                  ),
                                ),
                                subtitle: Text(
                                  'Updated: ${note['updated_at']}',
                                  style: const TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.green),
                                      onPressed: () {
                                        final TextEditingController editController = TextEditingController(text: note['content']);
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text(
                                              'Edit Note',
                                              style: TextStyle(
                                                fontFamily: 'Plus Jakarta Sans',
                                              ),
                                            ),
                                            content: TextField(
                                              controller: editController,
                                              style: const TextStyle(
                                                fontFamily: 'Plus Jakarta Sans',
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                child: const Text(
                                                  'Cancel',
                                                  style: TextStyle(
                                                    fontFamily: 'Plus Jakarta Sans',
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                onPressed: () => Navigator.pop(context),
                                              ),
                                              TextButton(
                                                child: const Text(
                                                  'Save',
                                                  style: TextStyle(
                                                    fontFamily: 'Plus Jakarta Sans',
                                                    color: Colors.green,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  if (editController.text.trim().isNotEmpty) {
                                                    editNote(context, note['id'], editController.text.trim());
                                                    Navigator.pop(context);
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text(
                                              'Delete Note',
                                              style: TextStyle(
                                                fontFamily: 'Plus Jakarta Sans',
                                              ),
                                            ),
                                            content: const Text(
                                              'Are you sure you want to delete this note?',
                                              style: TextStyle(
                                                fontFamily: 'Plus Jakarta Sans',
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                child: const Text(
                                                  'Cancel',
                                                  style: TextStyle(
                                                    fontFamily: 'Plus Jakarta Sans',
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                onPressed: () => Navigator.pop(context),
                                              ),
                                              TextButton(
                                                child: const Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                    fontFamily: 'Plus Jakarta Sans',
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  deleteNote(context, note['id']);
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            )).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.visibility, color: Color(0xFFCE181B)),
                  label: const Text(
                    'Lihat Detail',
                    style: TextStyle(
                      color: Color(0xFFCE181B),
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailsScreen(
                          product: {
                            'id': item['product_id'],
                            'name': item['name'],
                            'restaurant': item['restaurant'],
                            'rating': item['rating'],
                            'price': item['price'],
                            'location': item['location'],
                            'image_url': item['image_url'],
                            'operational_hours': item['operational_hours'],
                            'category': item['category'] ?? 'umum',
                          },
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    'Remove',
                    style: TextStyle(
                      color: Colors.red,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text(
                            'Remove from Wishlist',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                          content: const Text(
                            'Are you sure you want to remove this item?',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                          actions: [
                            TextButton(
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  color: Colors.grey,
                                ),
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            TextButton(
                              child: const Text(
                                'Remove',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  color: Colors.red,
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                                removeFromWishlist(context, int.parse(item['product_id'].toString()));
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),        ],
      ),
    );
  },
);


          },
      ),
    );
  }
}
