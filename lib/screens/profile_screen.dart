import 'package:flutter/material.dart';
import 'package:papacapim/screens/edit_profile_screen.dart';
import 'package:papacapim/widgets/post_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Dados fictícios para a primeira parte do projeto
  final Map<String, dynamic> _user = {
    'login': 'usuario_teste',
    'name': 'Usuário Teste',
    'followers_count': 42,
    'following_count': 123,
  };

  final List<Map<String, dynamic>> _posts = [
    {
      'id': 1,
      'user_login': 'usuario_teste',
      'message': 'Meu primeiro post!',
      'created_at': '2024-02-20T10:00:00.000Z',
      'likes_count': 5,
      'replies_count': 2,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  child: Text(
                    _user['login'][0].toUpperCase(),
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _user['name'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('@${_user['login']}'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${_user['followers_count']} seguidores',
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${_user['following_count']} seguindo',
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                return PostWidget(post: _posts[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
} 