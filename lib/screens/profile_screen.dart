import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:papacapim/screens/edit_profile_screen.dart';
import 'package:papacapim/widgets/post_widget.dart';
import 'package:papacapim/providers/profile_provider.dart';
import 'package:papacapim/providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  final String? userLogin;

  const ProfileScreen({
    super.key,
    this.userLogin,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    final login = widget.userLogin ?? 
        context.read<AuthProvider>().user!['login'];
    Future.microtask(() {
      context.read<ProfileProvider>().loadProfile(login);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = widget.userLogin == null || 
        widget.userLogin == context.read<AuthProvider>().user!['login'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          if (isCurrentUser)
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
      body: Consumer<ProfileProvider>(
        builder: (context, profile, child) {
          if (profile.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (profile.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Erro ao carregar perfil: ${profile.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      profile.loadProfile(widget.userLogin ?? 
                          context.read<AuthProvider>().user!['login']);
                    },
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          if (profile.profile == null) {
            return const Center(child: Text('Perfil não encontrado'));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      child: Text(
                        profile.profile!['login'][0].toUpperCase(),
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile.profile!['name'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('@${profile.profile!['login']}'),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${profile.profile!['followers_count']} seguidores',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${profile.profile!['following_count']} seguindo',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    if (!isCurrentUser) ...[
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Implementar seguir/deixar de seguir
                          profile.followUser(widget.userLogin!);
                        },
                        child: const Text('Seguir'),
                      ),
                    ],
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => profile.loadUserPosts(
                    widget.userLogin ?? context.read<AuthProvider>().user!['login'],
                  ),
                  child: ListView.builder(
                    itemCount: profile.posts.length,
                    itemBuilder: (context, index) {
                      return PostWidget(post: profile.posts[index]);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 