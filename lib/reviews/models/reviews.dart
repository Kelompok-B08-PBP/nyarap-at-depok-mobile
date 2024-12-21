// To parse this JSON data, do
//
//     final review = reviewFromJson(jsonString);

import 'dart:convert';

List<Review> reviewFromJson(String str) => List<Review>.from(json.decode(str).map((x) => Review.fromJson(x)));

String reviewToJson(List<Review> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Review { 
    String model;
    int pk;
    Fields fields;

    Review({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Review.fromJson(Map<String, dynamic> json) => Review(
        model: json["model"],
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class Fields {
    int user;
    String restaurantName;
    String foodName;
    String review;
    int rating;
    DateTime dateAdded;
    String productIdentifier;

    Fields({
        required this.user,
        required this.restaurantName,
        required this.foodName,
        required this.review,
        required this.rating,
        required this.dateAdded,
        required this.productIdentifier,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        user: json["user"],
        restaurantName: json["restaurant_name"],
        foodName: json["food_name"],
        review: json["review"],
        rating: json["rating"],
        dateAdded: DateTime.parse(json["date_added"]),
        productIdentifier: json["product_identifier"],
    );

    Map<String, dynamic> toJson() => {
        "user": user,
        "restaurant_name": restaurantName,
        "food_name": foodName,
        "review": review,
        "rating": rating,
        "date_added": dateAdded.toIso8601String(),
        "product_identifier": productIdentifier,
    };
}
