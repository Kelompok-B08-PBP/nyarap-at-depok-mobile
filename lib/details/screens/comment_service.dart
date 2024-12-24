// lib/details/screens/comment_service.dart
import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/comment.dart';

class CommentService {
  final CookieRequest request;
  final String baseUrl = 'http://localhost:8000';  // Base URL as a class property

  CommentService(this.request);

  Future<List<Comment>> getComments(String productId) async {
    try {
      final response = await request.get(
          '$baseUrl/api/products/$productId/comments/');
      
      if (response is String) {
        if (response.contains('<!DOCTYPE') || response.contains('<html>')) {
          return [];
        }
        final jsonData = jsonDecode(response);
        if (jsonData['comments'] != null) {
          return (jsonData['comments'] as List)
              .map((data) => Comment.fromJson(data))
              .toList();
        }
      }

      if (response is Map<String, dynamic> && response['comments'] != null) {
        return (response['comments'] as List)
            .map((data) => Comment.fromJson(data))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error getting comments: $e');
      return [];
    }
  }

  Future<String?> getCurrentUser(String productId) async {
    try {
      final response = await request.get(
          '$baseUrl/api/products/$productId/comments/');
      
      if (response is String) {
        if (response.contains('<!DOCTYPE') || response.contains('<html>')) {
          return null;
        }
        try {
          final jsonData = jsonDecode(response);
          return jsonData['current_user']?.toString();
        } catch (e) {
          print('Error parsing user data: $e');
          return null;
        }
      }

      if (response is Map<String, dynamic>) {
        return response['current_user']?.toString();
      }

      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  Future<bool> addComment(String productId, String content) async {
    if (!request.loggedIn) {
      throw Exception('Please log in to add a comment');
    }

    try {
      final response = await request.post(
        '$baseUrl/api/products/$productId/comments/add/',
        jsonEncode({
          'content': content,
        }),
      );

      if (response is String) {
        if (response.contains('<!DOCTYPE') || response.contains('<html>')) {
          return false;
        }
        final jsonData = jsonDecode(response);
        return jsonData['id'] != null;
      }

      if (response is Map<String, dynamic>) {
        return response['id'] != null;
      }

      return false;
    } catch (e) {
      print('Error adding comment: $e');
      rethrow;
    }
  }

  Future<bool> editComment(int commentId, String content) async {
    try {
      final response = await request.post(
        '$baseUrl/api/comments/$commentId/edit/',
        jsonEncode({'content': content}),
      );

      if (response is String) {
        if (response.contains('<!DOCTYPE') || response.contains('<html>')) {
          return false;
        }
        final jsonData = jsonDecode(response);
        return jsonData['id'] != null;
      }

      return response is Map<String, dynamic> && response['id'] != null;
    } catch (e) {
      print('Error editing comment: $e');
      rethrow;
    }
  }

  Future<bool> deleteComment(int commentId) async {
    try {
      final response = await request.post(
        '$baseUrl/api/comments/$commentId/delete/',
        {},
      );

      if (response is String) {
        if (response.contains('<!DOCTYPE') || response.contains('<html>')) {
          return false;
        }
        final jsonData = jsonDecode(response);
        return jsonData['message'] == 'Comment deleted successfully';
      }

      return response is Map<String, dynamic> && 
             response['message'] == 'Comment deleted successfully';
    } catch (e) {
      print('Error deleting comment: $e');
      rethrow;
    }
  }
}