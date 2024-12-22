import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/comment.dart';

class CommentService {
  final String baseProductUrl = 'http://valiza-nadya-nyarapatdepok.pbp.cs.ui.ac.id/api/products';
  final String baseCommentUrl = 'http://valiza-nadya-nyarapatdepok.pbp.cs.ui.ac.id/api/comments';
  final CookieRequest request;

  CommentService(this.request);

  Future<Map<String, dynamic>> fetchComments(String productIdentifier) async {
  try {
    final response = await request.get('$baseProductUrl/$productIdentifier/comments/');
    if (response is Map<String, dynamic> && 
        response.containsKey('comments') && 
        response.containsKey('current_user')) {
      return response;
    }
    throw Exception('Invalid response format');
  } catch (e) {
    if (e.toString().contains('DOCTYPE')) {
      throw Exception('Server returned HTML instead of JSON. Please check the API endpoint.');
    }
    rethrow;
  }
}

Future<List<Comment>> getComments(String productIdentifier) async {
  try {
    final response = await request.get('$baseProductUrl/$productIdentifier/comments/');
    if (response is Map<String, dynamic> && response.containsKey('comments')) {
      final commentsData = response['comments'] as List;
      return commentsData.map((data) => Comment.fromJson(data)).toList();
    }
    throw Exception('Invalid response format');
  } catch (e) {
    if (e.toString().contains('DOCTYPE')) {
      throw Exception('Server returned HTML instead of JSON. Please check the API endpoint.');
    }
    rethrow;
  }
}

Future<Comment> addComment(String productIdentifier, String content) async {
  try {
    if (!request.loggedIn) throw Exception('You must be logged in to add a comment');
    
    final response = await request.post(
      '$baseProductUrl/$productIdentifier/comments/add/',
      jsonEncode({'content': content}),
    );
    
    if (response is Map<String, dynamic> && response.containsKey('id')) {
      return Comment.fromJson(response);
    }
    throw Exception('Invalid response format');
  } catch (e) {
    if (e.toString().contains('DOCTYPE')) {
      throw Exception('Server returned HTML instead of JSON. Please check the API endpoint.');
    }
    rethrow;
  }
}

Future<void> editComment(int commentId, String content) async {
  final response = await request.post(
    '$baseCommentUrl/$commentId/edit/',
    jsonEncode({'content': content}),
  );

  if (response is Map<String, dynamic> && response.containsKey('id')) {
    // Komentar berhasil diupdate
    return;
  } else if (response is Map<String, dynamic> && response.containsKey('error')) {
    throw Exception(response['error']);
  } else {
    throw Exception('Unexpected response format');
  }
}


Future<void> deleteComment(int commentId) async {
  final response = await request.post(
    '$baseCommentUrl/$commentId/delete/',
    {}, // Body kosong
  );

  if (response is Map<String, dynamic> && response.containsKey('message')) {
    if (response['message'] == 'Comment deleted successfully') {
      return; // Berhasil dihapus
    }
  } else if (response is Map<String, dynamic> && response.containsKey('error')) {
    throw Exception(response['error']);
  } else {
    throw Exception('Unexpected response format: $response');
  }
}
}