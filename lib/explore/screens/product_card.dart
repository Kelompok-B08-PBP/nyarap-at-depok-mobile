import 'package:flutter/material.dart';
import './product_details.dart';

class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String restaurant;
  final double rating;
  final String kecamatan;
  final String operationalHours;
  final String price;
  final String kategori;
  
  final double? width;
  final double? imageHeight;

  const ProductCard({
    Key? key,
    required this.imageUrl,
    required this.name,
    required this.restaurant,
    required this.rating,
    required this.kecamatan,
    required this.operationalHours,
    required this.price,
    required this.kategori,
    this.width,
    this.imageHeight,
  }) : super(key: key);

  String truncateLocation(String text) {
    if (text.length <= 10) return text;
    return '${text.substring(0, 10)}...';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    void navigateToDetails() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailsScreen(
            product: {
              'name': name,
              'restaurant': restaurant,
              'rating': rating,
              'location': kecamatan,
              'operational_hours': operationalHours,
              'display_price': price,
              'image_url': imageUrl,
              'kecamatan': kecamatan,
              'category': kategori,
            },
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: navigateToDetails,
      child: Container(
        width: width,
        constraints: BoxConstraints(
          maxWidth: width ?? 600,
          minWidth: 200,
          maxHeight: 100,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                imageUrl,
                height: imageHeight ?? (isSmallScreen ? 100 : 120),
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: imageHeight ?? (isSmallScreen ? 100 : 120),
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
            
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 8.0 : 10.0,
                vertical: isSmallScreen ? 6.0 : 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 13 : 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 12,
                              color: Colors.yellow,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              rating.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 2),
                  
                  Text(
                    restaurant,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 11 : 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined, 
                        size: 12,
                        color: Colors.grey[600]
                      ),
                      const SizedBox(width: 2),
                      Text(
                        truncateLocation(kecamatan),
                        style: TextStyle(
                          fontSize: isSmallScreen ? 11 : 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 2),
                  
                  Row(
                    children: [
                      Icon(
                        Icons.access_time, 
                        size: 12,
                        color: Colors.grey[600]
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          'Opens $operationalHours',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 11 : 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 6),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          price,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 13 : 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 28,
                        child: ElevatedButton(
                          onPressed: navigateToDetails,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Text(
                            'Lihat Detail',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 11 : 12,
                            ),
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
    );
  }
}