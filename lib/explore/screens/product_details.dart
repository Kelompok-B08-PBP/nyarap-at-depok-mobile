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

    // Memuat daftar review ketika halaman ini pertama kali dibuka
    _refreshReviews();
  }

  /// Mengambil review untuk produk ini berdasarkan 'id' (integer) yang di-convert ke string
  void _refreshReviews() {
    setState(() {
      // Gunakan ID (integer) sebagai productIdentifier
      final productId = widget.product['id']?.toString() ?? '';
      _reviewsFuture = _reviewService.getReviewsForProduct(productId);
    });
  }

  /// Handler tombol "Add Review"
  void _handleAddReview() {
    final request = Provider.of<CookieRequest>(context, listen: false);

    // Jika belum login, arahkan ke LoginPage()
    if (!request.loggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      return;
    }

    // Gunakan ID sebagai productIdentifier untuk penambahan review
    final productId = widget.product['id']?.toString() ?? '';
    _showAddReviewDialog(productId);
  }

  /// Menampilkan dialog form untuk menambah review
  void _showAddReviewDialog(String productId) {
    final restaurantName = widget.product['restaurant'] ?? '';
    final foodName = widget.product['name'] ?? ''; // Tampilkan nama produk di form

    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Container(
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
                    _refreshReviews();  // muat ulang review setelah berhasil menambah
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Menghapus review
  Future<void> _handleDeleteReview(Review review) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete this review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
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
    // Tampilan utama detail produk
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tombol Back
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

              // Card detail produk
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
                    // Gambar + Kategori
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          child: Image.network(
                            widget.product['image_url'] ?? '/api/placeholder/800/400',
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
                              widget.product['category'] ?? 'Nasi',
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

                    // Info Produk
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nama Makanan (pakai 'name')
                          Text(
                            widget.product['name'] ?? '',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Nama Resto
                          Text(
                            widget.product['restaurant'] ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF4A5568),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Rating & Harga
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
                                      '${widget.product['rating'] ?? 0}',
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
                                'Rp ${widget.product['price'] ?? "0"}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                            ],
                          ),

                          // Lokasi & Jam Operasional
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
                                  children: [
                                    const Icon(Icons.location_on, size: 20, color: Color(0xFF4A5568)),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        widget.product['location'] ?? '',
                                        style: const TextStyle(
                                          color: Color(0xFF4A5568),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 20, color: Color(0xFF4A5568)),
                                    const SizedBox(width: 10),
                                    Text(
                                      widget.product['operational_hours'] ?? '',
                                      style: const TextStyle(
                                        color: Color(0xFF4A5568),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Tombol Wishlist & Add Review
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final request = Provider.of<CookieRequest>(
                                        context,
                                        listen: false);

                                    // Check login status first and redirect to login if not logged in
                                    if (!request.loggedIn) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const LoginPage()),
                                      );
                                      return;
                                    }
                                    try {
                                      await WishlistService.addToWishlist(context, widget.product);
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Added to Wishlist')),
                                        );
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const WishlistScreen()),
                                        );
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        // Still navigate to wishlist since product was added successfully
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Added to Wishlist')),
                                        );
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const WishlistScreen()),
                                        );
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFEDF2F7),
                                    foregroundColor: const Color(0xFF2D3748),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: const Text('Add to Wishlist'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _handleAddReview,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                  child: const Text('Add Review'),
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


              // Section "Customer Reviews"
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Text(
                  'Customer Reviews',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Menampilkan daftar review
              FutureBuilder<List<Review>>(
                future: _reviewsFuture,
                builder: (context, snapshot) {
                  // Loading
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // Error
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  // Tampilkan data
                  final reviews = snapshot.data ?? [];
                  if (reviews.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No reviews yet. Be the first to review!'),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: reviews.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      final request = Provider.of<CookieRequest>(context, listen: false);
                      final currentUserId = request.jsonData['user_id'];

                      // Hanya penulis review yang dapat Edit/Delete
                      final isAuthor = currentUserId != null &&
                          review.fields.user.toString() == currentUserId.toString();

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header: Restaurant name + rating
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    review.fields.restaurantName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: List.generate(
                                      5,
                                      (starIndex) => Icon(
                                        starIndex < review.fields.rating
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Isi review
                              Text(review.fields.review),
                              const SizedBox(height: 8),

                              // Tanggal tambah review
                              Text(
                                'Added on ${review.fields.dateAdded.toLocal().toString().split(' ')[0]}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),

                              // Tombol Edit/Delete jika author
                            if (isAuthor) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () async {
                                      // EditReviewScreen (jika Anda buat)
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditReviewScreen(review: review),
                                        ),
                                      );
                                      if (result == true) {
                                        _refreshReviews();
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor: const Color(0xFFF6D110),
                                      foregroundColor: Colors.black,
                                    ),
                                    child: const Text('Edit'),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: () => _handleDeleteReview(review),
                                    style: TextButton.styleFrom(
                                      backgroundColor: const Color(0xFFC3372B),
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            // Section Comments
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Comments',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            CommentSection(productId: widget.product['id'].toString(),),
          ],
        ),
      ),
    ),
  );
}
}

/// Form dialog untuk menambah review baru
class _ReviewForm extends StatefulWidget {
  final String initialRestaurantName;
  final String initialFoodName;
  final String productId;  // Gunakan ID (integer->string)
  final ProductReviewService reviewService;
  final VoidCallback onReviewAdded;

  const _ReviewForm({
    required this.initialRestaurantName,
    required this.initialFoodName,
    required this.productId,
    required this.reviewService,
    required this.onReviewAdded,
    Key? key,
  }) : super(key: key);

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
    _restaurantController =
        TextEditingController(text: widget.initialRestaurantName);
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

      // Buat fields
      final fields = Fields(
        user: userId,
        restaurantName: _restaurantController.text,
        foodName: _foodController.text,
        review: _reviewController.text,
        rating: _rating,
        dateAdded: DateTime.now(),
        // Gunakan productId (id) agar match di backend
        productIdentifier: widget.productId,
      );

      await widget.reviewService.addProductReview(fields);
      widget.onReviewAdded(); // Tutup dialog + refresh data
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
          // Restaurant Name
          TextFormField(
            controller: _restaurantController,
            decoration: const InputDecoration(
              labelText: 'Restaurant Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Food Name
          TextFormField(
            controller: _foodController,
            decoration: const InputDecoration(
              labelText: 'Food Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Rating (bintang)
          const Text('Rating'),
          Row(
            children: List.generate(5, (index) {
              return IconButton(
                onPressed: () {
                  setState(() => _rating = index + 1);
                },
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // Review text
          TextFormField(
            controller: _reviewController,
            decoration: const InputDecoration(
              labelText: 'Review',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Required';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Tombol aksi
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _handleSubmit,
                child: const Text('Submit'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}