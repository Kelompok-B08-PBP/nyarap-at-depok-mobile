import 'package:flutter/material.dart';
import 'package:nyarap_at_depok_mobile/reviews/models/reviews.dart';
import 'package:nyarap_at_depok_mobile/reviews/screens/review_service.dart';
import 'package:nyarap_at_depok_mobile/reviews/widgets/review_card.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'create_review_screen.dart';

class ReviewListScreen extends StatefulWidget {
  const ReviewListScreen({super.key, required bool isAuthenticated});

  @override
  _ReviewListScreenState createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends State<ReviewListScreen> {
  late Future<List<Review>> _reviewsFuture;
  late final ReviewService _reviewService;
  
  @override
  void initState() {
    super.initState();
    // Inisialisasi review service dengan CookieRequest
    final request = Provider.of<CookieRequest>(context, listen: false);
    _reviewService = ReviewService(request);
    _reviewsFuture = _reviewService.getReviews();
  }

  void _refreshReviews() {
    setState(() {
      _reviewsFuture = _reviewService.getReviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6D110),
        title: const Text(
          'Nyarap Ulasan',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Review>>(
        future: _reviewsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
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
                    'Error loading reviews\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshReviews,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          final reviews = snapshot.data;
          
          if (reviews == null || reviews.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/bingung.png',
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No reviews available',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
            );
          }
          
        return ListView.builder(
          itemCount: reviews.length,
          itemBuilder: (context, index) => ReviewCard(
            review: reviews[index],
            onRefresh: _refreshReviews,
            reviewService: _reviewService, 
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final request = Provider.of<CookieRequest>(context, listen: false);
          final reviewService = ReviewService(request);  // Create ReviewService here
          showDialog(
            context: context,
            builder: (context) => AddReviewDialog(
              onReviewAdded: _refreshReviews,
              reviewService: reviewService,  // Pass it to dialog
            ),
          );
        },
        backgroundColor: const Color(0xFFC3372B),
        child: const Icon(Icons.add),
      ),
    );
  }
}
