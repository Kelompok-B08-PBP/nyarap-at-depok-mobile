
class Recommendation {
  final String id;
  final String name;
  final String restaurant;
  final String price;
  final double rating;
  final String imageUrl;
  final String location;
  final String operationalHours;

  String productCategory;


  Recommendation({
    required this.id,
    required this.name,
    required this.restaurant,
    required this.price,
    required this.rating,
    required this.imageUrl,
    required this.location,
    required this.operationalHours,
    required this.productCategory, 

  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'].toString(),
      name: json['name'] ?? 'Unnamed',
      restaurant: json['restaurant'] ?? 'Unknown Restaurant',
      price: json['price'] ?? 'Harga tidak tersedia',
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : 0.0,
      imageUrl: json['image_url'] ?? '',
      location: json['location'] ?? 'Lokasi tidak tersedia',
      operationalHours: json['operational_hours'] ?? 'Jam buka tidak tersedia',
      productCategory: json['product_category'] ?? 'Uncategorized',
    );
  }
}