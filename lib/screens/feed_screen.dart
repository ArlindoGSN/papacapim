import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:papacapim/widgets/post_widget.dart';
import 'package:papacapim/screens/new_post_screen.dart';
import 'package:papacapim/screens/profile_screen.dart';
import 'package:papacapim/providers/posts_provider.dart';
import 'package:papacapim/providers/auth_provider.dart';
import 'package:papacapim/widgets/posts_search_bar.dart'; // Adicione este import

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showingFollowingOnly = false; // Novo estado

  @override
  void initState() {
    super.initState();
    _initializeFeed();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _initializeFeed() async {
    await Future.microtask(() {
      if (!mounted) return;
      context.read<PostsProvider>().loadPosts(
        feed: _showingFollowingOnly ? 1 : 0,
        refresh: true,
      );
    });
  }

  Future<void> _toggleFeed() async {
    setState(() {
      _showingFollowingOnly = !_showingFollowingOnly;
    });
    
    await context.read<PostsProvider>().loadPosts(
      feed: _showingFollowingOnly ? 1 : 0,
      refresh: true,
    );
  }

  Future<void> _handleLogout() async {
    try {
      final navigator = Navigator.of(context);
      await context.read<AuthProvider>().logout();
      
      if (mounted) {
        // Limpa a pilha de navegação e vai para login
        navigator.pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao fazer logout: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onScroll() {
    final postsProvider = context.read<PostsProvider>();
    if (!postsProvider.isLoading && 
        _scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      postsProvider.loadPosts(
        feed: _showingFollowingOnly ? 1 : 0, // Usa o valor correto do feed
      );
    }
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Center(
        child: SizedBox(
          height: 32,
          width: 32,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Papacapim',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showingFollowingOnly ? Icons.group : Icons.public,
              color: theme.colorScheme.primary,
            ),
            onPressed: _toggleFeed,
            tooltip: _showingFollowingOnly 
              ? 'Mostrando posts de quem você segue'
              : 'Mostrando todos os posts',
          ),
          IconButton(
            icon: Icon(
              Icons.person,
              color: theme.colorScheme.primary,
            ),
            onPressed: () => _navigateToProfile(context),
          ),
          IconButton(
            icon: Icon(
              Icons.logout,
              color: theme.colorScheme.error,
            ),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
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
            child: const PostsSearchBar(),
          ),
          Expanded(
            child: Consumer<PostsProvider>(
              builder: (context, postsProvider, child) {
                if (postsProvider.posts.isEmpty && postsProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (postsProvider.error != null && postsProvider.posts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Erro ao carregar posts: ${postsProvider.error}',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => postsProvider.loadPosts(refresh: true),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  );
                }

                if (postsProvider.posts.isEmpty) {
                  return const Center(
                    child: Text('Nenhuma postagem encontrada'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => postsProvider.loadPosts(refresh: true),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: postsProvider.posts.length + 1,
                    itemBuilder: (context, index) {
                      if (index == postsProvider.posts.length) {
                        if (!postsProvider.hasMorePosts) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'Não há mais postagens para carregar',
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        if (postsProvider.isLoading) {
                          return _buildLoadingIndicator();
                        }
                        return const SizedBox.shrink();
                      }
                      return PostWidget(post: postsProvider.posts[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NewPostScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova Postagem'),
      ),
    );
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      ),
    );
  }
}