import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:nyarap_at_depok_mobile/reviews/models/reviews.dart';
import 'package:nyarap_at_depok_mobile/reviews/widgets/review_card.dart';
import 'package:nyarap_at_depok_mobile/reviews/screens/review_service.dart';
import '../models/recommendation.dart';
import 'package:nyarap_at_depok_mobile/reviews/screens/create_review_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;
  final String cacheKey;

  const ProductDetailsScreen({
    Key? key,
    required this.productId,
    required this.cacheKey,
  }) : super(key: key);

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late Future<Recommendation> _productFuture;
  late Future<List<Review>> _reviewsFuture;
  late ReviewService _reviewService;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final request = Provider.of<CookieRequest>(context, listen: false);
    _reviewService = ReviewService(request);
    _productFuture = fetchProductDetails();
    _refreshReviews();
  }

  void _refreshReviews() {
  setState(() {
    _reviewsFuture = _reviewService.getReviewsForProduct(widget.productId);
  });
}

  Future<Recommendation> fetchProductDetails() async {
    try {
      final uri = Uri.http(
        'localhost:8000',
        '/api/products/${widget.productId}/',
        {'cache_key': widget.cacheKey},
      );

      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        return Recommendation.fromJson(json.decode(response.body));
        
      } else {
        throw Exception('Failed to load product details: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  void _showAddReviewDialog(Recommendation product) {
  showDialog(
    context: context,
    builder: (context) => AddReviewDialog(
      onReviewAdded: _refreshReviews,
      reviewService: _reviewService,
      productId: widget.productId,  // Pass product ID
      restaurantName: product.restaurant,  // Pass restaurant name
      foodName: product.name,  // Pass food name
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Recommendation>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final product = snapshot.data!;
            return SingleChildScrollView(
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
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Product Details Card
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
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                                child: Image.network(
                                  product.imageUrl,
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
                                    color: const Color(0xFFF6D110),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    product.productCategory,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A1A1A),
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  product.restaurant,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF4A5568),
                                    fontFamily: 'Montserrat',
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
                                        color: const Color(0xFFF6D110),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: Colors.black,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            product.rating.toString(),
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              fontFamily: 'Montserrat',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      product.price,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF2D3748),
                                        fontFamily: 'Montserrat',
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
                                              product.location,
                                              style: const TextStyle(
                                                color: Color(0xFF4A5568),
                                                fontSize: 14,
                                                fontFamily: 'Montserrat',
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.access_time,
                                            size: 20,
                                            color: Color(0xFF4A5568),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            product.operationalHours,
                                            style: const TextStyle(
                                              color: Color(0xFF4A5568),
                                              fontSize: 14,
                                              fontFamily: 'Montserrat',
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

                    // Reviews Section
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Reviews',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          TextButton(
                            onPressed: () => _showAddReviewDialog(product),
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFF6D110),
                              foregroundColor: Colors.black,
                            ),
                            child: const Text('Add Review'),
                          ),
                        ],
                      ),
                    ),

                    // Reviews List
                    FutureBuilder<List<Review>>(
                      future: _reviewsFuture,
                      builder: (context, reviewSnapshot) {
                        if (reviewSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        
                        if (reviewSnapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error loading reviews: ${reviewSnapshot.error}',
                              style: const TextStyle(fontFamily: 'Montserrat'),
                            ),
                          );
                        }

                        if (reviewSnapshot.hasData) {
                          if (reviewSnapshot.data!.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: Text(
                                  'No reviews yet. Be the first to review!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: reviewSnapshot.data!.map((review) {
                              return ReviewCard(
                                review: review,
                                onRefresh: _refreshReviews,
                                reviewService: _reviewService,
                              );
                            }).toList(),
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _productFuture = fetchProductDetails();
                        _refreshReviews();
                      });
                    },
                    child: const Text(
                      'Retry',
                      style: TextStyle(fontFamily: 'Montserrat'),
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}