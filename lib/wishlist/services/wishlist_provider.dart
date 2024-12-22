import 'package:flutter/material.dart';
import '../models/wishlist.dart';
import '../services/wishlist_services.dart';

class WishlistProvider with ChangeNotifier {
  List<Wishlist> _items = [];
  bool _isLoading = false;

  List<Wishlist> get items => _items;
  bool get isLoading => _isLoading;

  Future<void> loadWishlist(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      _items = await WishlistService.fetchWishlist(context);
    } catch (e) {
      print('Error loading wishlist: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addToWishlist(BuildContext context, Map<String, dynamic> product) async {
    try {
      final success = await WishlistService.addToWishlist(context, product);
      if (success) {
        await loadWishlist(context);
      }
      return success;
    } catch (e) {
      print('Error in wishlist provider - add: $e');
      return false;
    }
  }

  Future<bool> removeFromWishlist(BuildContext context, String productId) async {
    try {
      final success = await WishlistService.removeFromWishlist(context, productId);
      if (success) {
        await loadWishlist(context);
      }
      return success;
    } catch (e) {
      print('Error in wishlist provider - remove: $e');
      return false;
    }
  }

  bool isInWishlist(String productId) {
    return _items.any((item) => item.id.toString() == productId);
  }
}
