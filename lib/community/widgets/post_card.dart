
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nyarap_at_depok_mobile/community/models/community.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class PostCard extends StatelessWidget {
  final Community post;
  final Function()? onEdit;
  final Function()? onDelete;
  final bool canEdit;

  const PostCard({
    Key? key,
    required this.post,
    this.onEdit,
    this.onDelete,
    required this.canEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final isOwner = request.loggedIn &&
        post.fields.user.toString() == request.jsonData['id'].toString();

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(56),
      ),
      elevation: 4,
      margin: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Left side - Image
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(56),
                bottomLeft: Radius.circular(56),
              ),
              child: post.fields.photoUrl != "https://example.com/default-image.jpg"
                  ? Image.network(
                      post.fields.photoUrl,
                      height: 400,
                      fit: BoxFit.cover,
                    )
                  : Container(color: Colors.grey[200]),
            ),
          ),
          // Right side - Content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.fields.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Posted by: User ${post.fields.user}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(post.fields.caption),
                  if (post.fields.location.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16),
                        Text(post.fields.location),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    'Posted on: ${DateFormat('MMMM d, y').format(post.fields.createdAt!)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (canEdit) ...[
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          label: const Text('Edit', style: TextStyle(color: Colors.blue)),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () => showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Post'),
                              content: const Text('Are you sure you want to delete this post?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    onDelete?.call();
                                  },
                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          ),
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
