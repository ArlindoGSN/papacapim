import 'package:flutter/material.dart';
import 'package:papacapim/widgets/post_widget.dart';
import 'package:papacapim/screens/new_post_screen.dart';
import 'package:papacapim/screens/profile_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  // Dados fictícios para a primeira parte do projeto
  final List<Map<String, dynamic>> _posts = [
    {
      'id': 1,
      'user_login': 'joao',
      'message': 'Primeiro post no Papacapim!',
      'created_at': '2024-02-20T10:00:00.000Z',
      'likes_count': 5,
      'replies_count': 2,
    },
    {
      'id': 2,
      'user_login': 'maria',
      'message': 'Essa rede social é incrível!',
      'created_at': '2024-02-20T11:30:00.000Z',
      'likes_count': 3,
      'replies_count': 1,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Papacapim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Implementar atualização do feed na segunda parte
        },
        child: ListView.builder(
          itemCount: _posts.length,
          itemBuilder: (context, index) {
            return PostWidget(post: _posts[index]);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NewPostScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 