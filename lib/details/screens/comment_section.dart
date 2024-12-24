// lib/details/screens/comment_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:nyarap_at_depok_mobile/details/models/comment.dart';
import 'package:nyarap_at_depok_mobile/details/screens/comment_service.dart';
import '../../home/login.dart';

class CommentSection extends StatefulWidget {
  final String productId;

  const CommentSection({
    required this.productId,
    Key? key,
  }) : super(key: key);

  @override
  _CommentSectionState createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  late Future<List<Comment>> _commentsFuture;
  late String? _currentUser;
  late final CommentService _commentService;

  @override
  void initState() {
    super.initState();
    final request = Provider.of<CookieRequest>(context, listen: false);
    _commentService = CommentService(request);

    _fetchComments();
  }

  void _fetchComments() {
    setState(() {
      _commentsFuture = _commentService.getComments(widget.productId);
    });
    
    _commentService.getCurrentUser(widget.productId).then((username) {
      setState(() {
        _currentUser = username; // username is already a String?
      });
    }).catchError((_) {
      setState(() {
        _currentUser = null; // Jika error, anggap user belum login
      });
    });
}

  void _handleAddComment() {
    if (_currentUser == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => const LoginPage()), // Navigasi ke halaman login
      );
      return;
    }
    _showAddCommentDialog();
  }

  void _showAddCommentDialog() {
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Comment'),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(hintText: 'Enter your comment'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _addComment(_controller.text);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _addComment(String content) async {
    try {
      await _commentService.addComment(widget.productId, content);
      _fetchComments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showEditCommentDialog(int commentId, String initialContent) {
    final TextEditingController _controller =
        TextEditingController(text: initialContent);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Comment'),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(hintText: 'Edit your comment'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _editComment(commentId, _controller.text);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _editComment(int commentId, String content) async {
    try {
      await _commentService.editComment(commentId, content);
      _fetchComments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error editing comment: $e')),
      );
    }
  }

  void _showDeleteCommentDialog(int commentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // User cancels
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), // User confirms
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    // Proceed with deletion if confirmed
    if (confirm == true) {
      try {
        await _commentService.deleteComment(commentId); // Delete the comment
        _fetchComments(); // Refresh the comments after deletion
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting comment: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Comments',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        if (_currentUser != null) // Tampilkan tombol hanya jika login
          ElevatedButton(
            onPressed: _handleAddComment,
            child: const Text('Add Comment'),
          ),
        FutureBuilder<List<Comment>>(
          future: _commentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final comments = snapshot.data ?? [];
            if (comments.isEmpty) {
              return const Center(child: Text('No comments yet.'));
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                final isOwner = comment.userName == _currentUser;

                return ListTile(
                  title: Text(comment.content),
                  subtitle:
                      Text('By ${comment.userName} at ${comment.createdAt}'),
                  trailing: isOwner
                      ? PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditCommentDialog(
                                  comment.id, comment.content);
                            } else if (value == 'delete') {
                              _showDeleteCommentDialog(comment.id);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                                value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(
                                value: 'delete', child: Text('Delete')),
                          ],
                        )
                      : null,
                );
              },
            );
          },
        ),
      ],
    );
  }
}
