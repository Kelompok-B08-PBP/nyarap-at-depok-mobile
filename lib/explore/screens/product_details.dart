import 'package:flutter/material.dart';
import 'package:nyarap_at_depok_mobile/wishlist/services/wishlist_services.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailsScreen({Key? key, required this.product})
      : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late Map<String, dynamic> _product;

  @override
  void initState() {
    super.initState();
    _product = Map<String, dynamic>.from(widget.product);
  }

  @override
  Widget build(BuildContext context) {
    final request = Provider.of<CookieRequest>(context, listen: false);

    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back, color: Color(0xFF4A5568)),
                        SizedBox(width: 8),
                        Text(
                          'Back',
                          style: TextStyle(
                            color: Color(0xFF4A5568),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Product Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image and Category
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          child: Image.network(
                            _product['image_url'] ?? '/api/placeholder/800/400',
                            height: 300,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 300,
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(Icons.image_not_supported),
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              _product['category'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Product Content
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _product['name'] ?? '',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _product['restaurant'] ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF4A5568),
                            ),
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4CAF50),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Text(
                                      '★',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${_product['rating']}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _product['display_price'] ?? '',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                            ],
                          ),

                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 20),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 20,
                                      color: Color(0xFF4A5568),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _product['location'] ?? '',
                                        style: const TextStyle(
                                          color: Color(0xFF4A5568),
                                          fontSize: 14,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildInfoItem(
                                  Icons.access_time,
                                  _product['operational_hours'] ?? '',
                                ),
                              ],
                            ),
                          ),

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  // In the ElevatedButton onPressed callback:
                                  onPressed: () async {
                                    print(
                                        'Add to wishlist button pressed'); // Debug log
                                    print('Add to wishlist button pressed');
                                    print(_product);
                                    final productId = _product['product_id'];
                                    print(_product); // Try this field name
                                    if (productId != null) {
                                      final success =
                                          await WishlistService.addToWishlist(
                                        context,
                                        _product,
                                      );

                                      print(
                                          'Wishlist operation result: $success'); // Debug log

                                      if (success) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                '${_product['name']} added to wishlist'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                        setState(() {
                                          _product['is_in_wishlist'] = true;
                                        });
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Failed to add to wishlist'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    } else {
                                      print('Product ID is null'); // Debug log
                                    }
                                  },

                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFEDF2F7),
                                    foregroundColor: const Color(0xFF2D3748),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    _product['is_in_wishlist'] ?? false
                                        ? 'Remove from Wishlist'
                                        : 'Add to Wishlist',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF4A5568),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF4A5568),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
