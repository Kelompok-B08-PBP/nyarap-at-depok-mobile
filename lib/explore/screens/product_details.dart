import 'package:flutter/material.dart';
import 'package:nyarap_at_depok_mobile/explore/screens/product_review_service.dart';
import 'package:nyarap_at_depok_mobile/home/login.dart';
import 'package:nyarap_at_depok_mobile/reviews/screens/edit_review_screen.dart';
import 'package:nyarap_at_depok_mobile/wishlist/screens/wishlist_screens.dart';
import 'package:nyarap_at_depok_mobile/wishlist/services/wishlist_services.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:nyarap_at_depok_mobile/reviews/models/reviews.dart';
import 'package:nyarap_at_depok_mobile/details/models/comment.dart';
import 'package:nyarap_at_depok_mobile/details/screens/comment_service.dart';
import 'package:nyarap_at_depok_mobile/details/screens/comment_section.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailsScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late ProductReviewService _reviewService;
  late Future<List<Review>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    final request = Provider.of<CookieRequest>(context, listen: false);
    _reviewService = ProductReviewService(request);
    _refreshReviews();
  }

  void _refreshReviews() {
    setState(() {
      final productId = widget.product['id']?.toString() ?? '';
      _reviewsFuture = _reviewService.getReviewsForProduct(productId);
    });
  }

  void _handleAddReview() {
    final request = Provider.of<CookieRequest>(context, listen: false);
    if (!request.loggedIn) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
      return;
    }
    final productId = widget.product['id']?.toString() ?? '';
    _showAddReviewDialog(productId);
  }

  void _showAddReviewDialog(String productId) {
    final restaurantName = widget.product['restaurant'] ?? '';
    final foodName = widget.product['name'] ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add New Review',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFCE181B),
                ),
              ),
              const SizedBox(height: 24),
              _ReviewForm(
                initialRestaurantName: restaurantName,
                initialFoodName: foodName,
                productId: productId,
                reviewService: _reviewService,
                onReviewAdded: () {
                  Navigator.pop(context);
                  _refreshReviews();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleDeleteReview(Review review) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete this review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFCE181B)),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _reviewService.deleteReview(review.pk);
        _refreshReviews();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting review: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFFCE181B),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Product Image
                  Image.network(
                    widget.product['image_url'] ?? '/api/placeholder/800/400',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, size: 50),
                    ),
                  ),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Back Button
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFFCE181B)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Info Card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3CD),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.product['category'] ?? 'Nasi',
                          style: const TextStyle(
                            color: Color(0xFFCE181B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Product Name & Restaurant
                      Text(
                        widget.product['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.product['restaurant'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF4A5568),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Rating & Price
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFCE181B),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.product['rating'] ?? 0}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Rp ${widget.product['price'] ?? "0"}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFCE181B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Info Cards
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        Icons.location_on,
                        widget.product['location'] ?? '',
                        const Color(0xFFCE181B),
                      ),
                      const Divider(height: 20),
                      _buildInfoRow(
                        Icons.access_time,
                        widget.product['operational_hours'] ?? '',
                        const Color(0xFFCE181B),
                      ),
                    ],
                  ),
                ),

                // Action Buttons
                Container(
                  margin: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.favorite_border,
                          label: 'Add to Wishlist',
                          onPressed: () async {
                            final request = Provider.of<CookieRequest>(
                              context,
                              listen: false,
                            );
                            if (!request.loggedIn) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginPage()),
                              );
                              return;
                            }
                            try {
                              await WishlistService.addToWishlist(
                                context,
                                widget.product,
                              );
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Added to Wishlist'),
                                  ),
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const WishlistScreen(),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const WishlistScreen(),
                                  ),
                                );
                              }
                            }
                          },
                          isOutlined: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.rate_review,
                          label: 'Add Review',
                          onPressed: _handleAddReview,
                          isOutlined: false,
                        ),
                      ),
                    ],
                  ),
                ),

                // Reviews Section
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Customer Reviews',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<List<Review>>(
                        future: _reviewsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFCE181B),
                              ),
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          }

                          final reviews = snapshot.data ?? [];
                          if (reviews.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF3CD),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Text(
                                  'No reviews yet. Be the first to review!',
                                  style: TextStyle(
                                    color: Color(0xFFCE181B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: reviews.length,
                            itemBuilder: (context, index) {
                              final review = reviews[index];
                              final request = Provider.of<CookieRequest>(
                                context,
                                listen: false,
                              );
                              final currentUserId = request.jsonData['user_id'];
                              final isAuthor = currentUserId != null &&
                                  review.fields.user.toString() == currentUserId.toString();

                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                review.fields.restaurantName,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF1A1A1A),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Added on ${review.fields.dateAdded.toLocal().toString().split(' ')[0]}',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFF3CD),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.star,
                                                size: 16,
                                                color: Color(0xFFCE181B),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                review.fields.rating.toString(),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFFCE181B),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      review.fields.review,
                                      style: const TextStyle(
                                        color: Color(0xFF4A5568),
                                        fontSize: 14,
                                        height: 1.5,
                                      ),
                                    ),
                                    if (isAuthor) ...[
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          _buildReviewButton(
                                            icon: Icons.edit,
                                            label: 'Edit',
                                            color: Colors.orange,
                                            onPressed: () async {
                                              final result = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => EditReviewScreen(
                                                    review: review,
                                                  ),
                                                ),
                                              );
                                              if (result == true) {
                                                _refreshReviews();
                                              }
                                            },
                                          ),
                                          const SizedBox(width: 8),
                                          _buildReviewButton(
                                            icon: Icons.delete,
                                            label: 'Delete',
                                            color: const Color(0xFFCE181B),
                                            onPressed: () => _handleDeleteReview(review),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Comments Section
                Container(
                  margin: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CommentSection(
                            productId: widget.product['id'].toString(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3CD),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4A5568),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isOutlined,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isOutlined ? Colors.white : const Color(0xFFCE181B),
        foregroundColor: isOutlined ? const Color(0xFFCE181B) : Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isOutlined
              ? const BorderSide(color: Color(0xFFCE181B))
              : BorderSide.none,
        ),
        elevation: isOutlined ? 0 : 2,
      ),
    );
  }

  Widget _buildReviewButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: color),
      label: Text(
        label,
        style: TextStyle(color: color),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

// Review Form Widget
class _ReviewForm extends StatefulWidget {
  final String initialRestaurantName;
  final String initialFoodName;
  final String productId;
  final ProductReviewService reviewService;
  final VoidCallback onReviewAdded;

  const _ReviewForm({
    required this.initialRestaurantName,
    required this.initialFoodName,
    required this.productId,
    required this.reviewService,
    required this.onReviewAdded,
  });

  @override
  State<_ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<_ReviewForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _restaurantController;
  late TextEditingController _foodController;
  late TextEditingController _reviewController;
  int _rating = 0;

  @override
  void initState() {
    super.initState();
    _restaurantController = TextEditingController(text: widget.initialRestaurantName);
    _foodController = TextEditingController(text: widget.initialFoodName);
    _reviewController = TextEditingController();
  }

  @override
  void dispose() {
    _restaurantController.dispose();
    _foodController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final request = Provider.of<CookieRequest>(context, listen: false);
      final userId = request.jsonData['user_id'] ?? 1;

      final fields = Fields(
        user: userId,
        restaurantName: _restaurantController.text,
        foodName: _foodController.text,
        review: _reviewController.text,
        rating: _rating,
        dateAdded: DateTime.now(),
        productIdentifier: widget.productId,
      );

      await widget.reviewService.addProductReview(fields);
      widget.onReviewAdded();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _restaurantController,
            decoration: InputDecoration(
              labelText: 'Restaurant Name',
              labelStyle: TextStyle(color: Colors.grey[700]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFCE181B)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _foodController,
            decoration: InputDecoration(
              labelText: 'Food Name',
              labelStyle: TextStyle(color: Colors.grey[700]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFCE181B)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Rating',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              return IconButton(
                onPressed: () => setState(() => _rating = index + 1),
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: const Color(0xFFCE181B),
                  size: 32,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _reviewController,
            decoration: InputDecoration(
              labelText: 'Your Review',
              labelStyle: TextStyle(color: Colors.grey[700]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFCE181B)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCE181B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Submit Review'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}