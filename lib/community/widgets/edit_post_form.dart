import 'package:flutter/material.dart';
import 'package:nyarap_at_depok_mobile/community/models/community.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class EditPostForm extends StatefulWidget {
  final Community post;

  const EditPostForm({Key? key, required this.post}) : super(key: key);

  @override
  _EditPostFormState createState() => _EditPostFormState();
}

class _EditPostFormState extends State<EditPostForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _captionController;
  late TextEditingController _locationController;
  late TextEditingController _photoUrlController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post.fields.title);
    _captionController = TextEditingController(text: widget.post.fields.caption);
    _locationController = TextEditingController(text: widget.post.fields.location);
    _photoUrlController = TextEditingController(text: widget.post.fields.photoUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Edit Post'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Edit Post',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildFormField(
                          controller: _titleController,
                          label: 'Title',
                          validator: (value) => 
                            value?.isEmpty ?? true ? 'Title is required' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildFormField(
                          controller: _captionController,
                          label: 'Caption',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        _buildFormField(
                          controller: _locationController,
                          label: 'Location',
                        ),
                        const SizedBox(height: 16),
                        _buildFormField(
                          controller: _photoUrlController,
                          label: 'Photo URL',
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final request = context.read<CookieRequest>();
                              try {
                                final response = await request.post(
                                  'http://localhost:8000/discovery/update-flutter/${widget.post.pk}/',
                                  {
                                    'title': _titleController.text,
                                    'caption': _captionController.text,
                                    'location': _locationController.text,
                                    'photo_url': _photoUrlController.text,
                                  },
                                );

                                if (response['status'] == 'success') {
                                  if (context.mounted) {
                                    Navigator.pop(context, true);
                                  }
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                }
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Colors.black, width: 0.5),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    int? maxLines,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      maxLines: maxLines ?? 1,
      validator: validator,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _captionController.dispose();
    _locationController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }
}
