import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:papacapim/providers/posts_provider.dart';

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final _messageController = TextEditingController();
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Postagem'),
        actions: [
          Consumer<PostsProvider>(
            builder: (context, postsProvider, child) {
              if (postsProvider.isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return TextButton(
                onPressed: _messageController.text.isEmpty
                    ? null
                    : () async {
                        try {
                          await postsProvider
                              .createPost(_messageController.text);
                          if (mounted) {
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          setState(() {
                            _errorMessage = e.toString();
                          });
                        }
                      },
                child: const Text('Publicar'),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'O que está acontecendo?',
                border: InputBorder.none,
              ),
              maxLines: null,
              autofocus: true,
              onChanged: (value) {
                setState(() {});
              },
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 