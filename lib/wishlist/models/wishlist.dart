import 'dart:convert';

WishlistItems wishlistItemsFromJson(String str) => WishlistItems.fromJson(json.decode(str));

String wishlistItemsToJson(WishlistItems data) => json.encode(data.toJson());

class WishlistItems {
    List<Wishlist> wishlist;

    WishlistItems({
        required this.wishlist,
    });

    factory WishlistItems.fromJson(Map<String, dynamic> json) => WishlistItems(
        wishlist: List<Wishlist>.from(json["wishlist"].map((x) => Wishlist.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "wishlist": List<dynamic>.from(wishlist.map((x) => x.toJson())),
    };
}

class Wishlist {
    int? id;
    String name;
    String category;
    String location;
    int? price;
    double rating;
    String operationalHours;
    String imageUrl;

    Wishlist({
        required this.id,
        required this.name,
        required this.category,
        required this.location,
        this.price,
        required this.rating,
        required this.operationalHours,
        required this.imageUrl,
    });

    factory Wishlist.fromJson(Map<String, dynamic> json) => Wishlist(
        id: json["id"] ?? json["product_id"] ?? 0, 
        name: json["name"] ?? "",
        category: json["category"] ?? "",
        location: json["location"] ?? "",
        price: json["price"] != null ? int.tryParse(json["price"].toString()) : null,
        rating: (json["rating"] ?? 0.0).toDouble(),
        operationalHours: json["operational_hours"] ?? "",
        imageUrl: json["image_url"] ?? "",
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "category": category,
        "location": location,
        "price": price,
        "rating": rating,
        "operational_hours": operationalHours,
        "image_url": imageUrl,
    };
}
