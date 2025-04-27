import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:papacapim/screens/edit_profile_screen.dart';
import 'package:papacapim/widgets/post_widget.dart';
import 'package:papacapim/providers/profile_provider.dart';
import 'package:papacapim/providers/auth_provider.dart';
import 'package:papacapim/providers/posts_provider.dart';

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
    // Agenda o carregamento para depois do build inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    
    final login = widget.userLogin ?? 
        context.read<AuthProvider>().user!['login'];
    
    await context.read<ProfileProvider>().loadProfile(login);
  }

  Future<void> _refreshProfile() async {
    await _loadProfile();
  }

  // Botão de seguir/deixar de seguir
  Widget _buildFollowButton(ProfileProvider profile, String userLogin) {
    return ElevatedButton(
      onPressed: () async {
        try {
          await profile.followUser(userLogin);
        } catch (e) {
          if (!mounted) return;
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Text(
        profile.profile?['following'] == true ? 'Deixar de Seguir' : 'Seguir'
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          Consumer<ProfileProvider>(
            builder: (context, profile, child) {
              final isCurrentUser = widget.userLogin == null || 
                  widget.userLogin == context.read<AuthProvider>().user!['login'];
              return Row(
                children: [
                  if (isCurrentUser)
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                        if (mounted) {
                          _loadProfile();
                        }
                      },
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer2<ProfileProvider, PostsProvider>(
        builder: (context, profileProvider, postsProvider, child) {
          final isCurrentUser = widget.userLogin == null || 
              widget.userLogin == context.read<AuthProvider>().user!['login'];

          if (profileProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (profileProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Erro ao carregar perfil: ${profileProvider.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      profileProvider.loadProfile(widget.userLogin ?? 
                          context.read<AuthProvider>().user!['login']);
                    },
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          if (profileProvider.profile == null) {
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
                        profileProvider.profile!['login'][0].toUpperCase(),
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profileProvider.profile!['name'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('@${profileProvider.profile!['login']}'),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${profileProvider.profile!['followers_count']} seguidores',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${profileProvider.profile!['following_count']} seguindo',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    if (!isCurrentUser) ...[
                      const SizedBox(height: 16),
                      _buildFollowButton(profileProvider, widget.userLogin!),
                    ],
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshProfile,
                  child: profileProvider.posts.isEmpty
                      ? const Center(
                          child: Text('Nenhum post encontrado'),
                        )
                      : ListView.builder(
                          itemCount: profileProvider.posts.length,
                          itemBuilder: (context, index) {
                            final post = profileProvider.posts[index];
                            return PostWidget(
                              post: post,
                              key: ValueKey(post['id']),
                              onPostDeleted: () async {
                                // Recarrega os posts do usuário após a exclusão
                                final userLogin = widget.userLogin ?? 
                                    context.read<AuthProvider>().user!['login'];
                                await profileProvider.loadUserPosts(userLogin);
                              },
                            );
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