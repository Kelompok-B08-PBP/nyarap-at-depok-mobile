// lib/details/models/comment.dart

class Comment {
  final int id;
  final String content;
  final String userName;
  final String createdAt;

  Comment({
    required this.id,
    required this.content,
    required this.userName,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int,
      content: json['content'] as String,
      userName: json['user_name'] as String,
      createdAt: json['created_at'] as String,
    );
  }
}