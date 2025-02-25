import 'package:flutter/material.dart';

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Postagem'),
        actions: [
          TextButton(
            onPressed: _messageController.text.isEmpty
                ? null
                : () {
                    // Implementar criação de post na segunda parte
                    Navigator.pop(context);
                  },
            child: const Text('Publicar'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
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
      ),
    );
  }
} 