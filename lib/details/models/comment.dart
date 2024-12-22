class Comment {
  final int id;
  final String userName;
  final String content;
  final String createdAt;
  final String updatedAt;

  Comment({
    required this.id,
    required this.userName,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      userName: json['user']['username'], // Pastikan sesuai dengan respons backend
      content: json['content'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
