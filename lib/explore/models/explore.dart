import 'dart:convert';

List<Explore> exploreFromJson(String str) => List<Explore>.from(
    json.decode(str).map((x) => Explore.fromJson(x)));

String exploreToJson(List<Explore> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Explore {
  String model;
  String pk;
  Fields fields;

  Explore({
    required this.model,
    required this.pk,
    required this.fields,
  });

  factory Explore.fromJson(Map<String, dynamic> json) => Explore(
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
  String preferredLocation;
  String preferredBreakfastType;
  String preferredPriceRange;
  DateTime createdAt;

  Fields({
    required this.user,
    required this.preferredLocation,
    required this.preferredBreakfastType,
    required this.preferredPriceRange,
    required this.createdAt,
  });

  factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        user: json["user"],
        preferredLocation: json["preferred_location"],
        preferredBreakfastType: json["preferred_breakfast_type"],
        preferredPriceRange: json["preferred_price_range"],
        createdAt: DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "user": user,
        "preferred_location": preferredLocation,
        "preferred_breakfast_type": preferredBreakfastType,
        "preferred_price_range": preferredPriceRange,
        "created_at": createdAt.toIso8601String(),
      };
}