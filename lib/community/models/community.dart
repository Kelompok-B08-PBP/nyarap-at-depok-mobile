import 'dart:convert';

// Convert JSON string to List of Community objects
List<Community> communityFromJson(String str) =>
    List<Community>.from(json.decode(str).map((x) => Community.fromJson(x)));

// Convert List of Community objects to JSON string
String communityToJson(List<Community> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Community {
  String model;
  String pk;  // Changed from int to String to match Explore
  Fields fields;

  Community({
    required this.model,
    required this.pk,
    required this.fields,
  });

  factory Community.fromJson(Map<String, dynamic> json) => Community(
        model: json["model"] ?? "unknown_model",
        pk: json["pk"]?.toString() ?? "0",  // Convert to String
        fields: Fields.fromJson(json["fields"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
      };
}

class Fields {
  String title;
  String caption;
  String location;
  String photoUrl;
  DateTime? createdAt;
  int user;  // This matches the Explore model's user field

  Fields({
    required this.title,
    required this.caption,
    required this.location,
    required this.photoUrl,
    required this.createdAt,
    required this.user,
  });

  factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        title: json["title"] ?? "Untitled",
        caption: json["caption"] ?? "",
        location: json["location"] ?? "Unknown",
        photoUrl: json["photo_url"] ?? "https://example.com/default-image.jpg",
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"])
            : null,
        user: json["user"] ?? 0,
      );

  String? get content => null;

  Map<String, dynamic> toJson() => {
        "title": title,
        "caption": caption,
        "location": location,
        "photo_url": photoUrl,
        "created_at": createdAt?.toIso8601String(),
        "user": user,
      };
}