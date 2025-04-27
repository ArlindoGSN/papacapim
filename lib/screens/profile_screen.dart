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

  Widget _buildStatistic(BuildContext context, String value, String label) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildFollowButton(ProfileProvider profile, String userLogin) {
    return ElevatedButton.icon(
      onPressed: () async {
        try {
          if (profile.profile?['following'] == true) {
            await profile.unfollowUser(userLogin);
          } else {
            await profile.followUser(userLogin);
          }
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
      icon: Icon(
        profile.profile?['following'] == true
            ? Icons.person_remove
            : Icons.person_add,
      ),
      label: Text(
        profile.profile?['following'] == true
            ? 'Deixar de Seguir'
            : 'Seguir',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Perfil',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
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
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Hero(
                      tag: 'profile-${profileProvider.profile!['login']}',
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: theme.colorScheme.primary,
                        child: Text(
                          profileProvider.profile!['login'][0].toUpperCase(),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profileProvider.profile!['name'],
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '@${profileProvider.profile!['login']}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStatistic(
                          context,
                          profileProvider.profile!['followers_count'].toString(),
                          'seguidores',
                        ),
                        const SizedBox(width: 32),
                        _buildStatistic(
                          context,
                          profileProvider.profile!['following_count'].toString(),
                          'seguindo',
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
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshProfile,
                  child: profileProvider.posts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.post_add_outlined,
                                size: 64,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Nenhum post encontrado',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
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