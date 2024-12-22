import 'package:flutter/material.dart';

class WishlistProvider with ChangeNotifier {
  List<Map<String, dynamic>> _wishlist = [];

  List<Map<String, dynamic>> get wishlist => _wishlist;

  void addToWishlist(Map<String, dynamic> product) {
    _wishlist.add(product);
    notifyListeners();
  }

  void removeFromWishlist(int productId) {
    _wishlist.removeWhere((item) => item['id'] == productId);
    notifyListeners();
  }
}
