import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/wishlist_provider.dart';

class WishlistButton extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback? onToggle;

  const WishlistButton({
    Key? key,
    required this.product,
    this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<WishlistProvider>(
      builder: (context, wishlistProvider, child) {
        final isInWishlist = wishlistProvider.isInWishlist(product['id'].toString());

        return IconButton(
          icon: Icon(
            isInWishlist ? Icons.favorite : Icons.favorite_border,
            color: isInWishlist ? Colors.red : null,
          ),
          onPressed: () async {
            try {
              bool success;
              if (isInWishlist) {
                success = await wishlistProvider.removeFromWishlist(
                  context,
                  product['id'].toString(),
                );
              } else {
                success = await wishlistProvider.addToWishlist(context, product);
              }

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isInWishlist
                          ? 'Removed from wishlist'
                          : 'Added to wishlist',
                    ),
                  ),
                );
                if (onToggle != null) onToggle!();
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          },
        );
      },
    );
  }
}