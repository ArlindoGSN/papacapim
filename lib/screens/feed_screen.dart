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
        scrolledUnderElevation: 2,
        title: Row(
          children: [
            Hero(
              tag: 'app_logo',
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.nature,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Papacapim',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        actions: [
          // Botão de atualização
          Consumer<PostsProvider>(
            builder: (context, postsProvider, _) => IconButton(
              icon: postsProvider.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  )
                : Icon(
                    Icons.refresh,
                    color: theme.colorScheme.primary,
                  ),
              onPressed: postsProvider.isLoading
                ? null
                : () => postsProvider.loadPosts(
                    feed: _showingFollowingOnly ? 1 : 0,
                    refresh: true,
                  ),
              tooltip: 'Atualizar feed',
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: IconButton(
              key: ValueKey(_showingFollowingOnly),
              icon: Icon(
                _showingFollowingOnly ? Icons.group : Icons.public,
                color: theme.colorScheme.primary,
              ),
              onPressed: _toggleFeed,
              tooltip: _showingFollowingOnly 
                ? 'Mostrando posts de quem você segue'
                : 'Mostrando todos os posts',
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.person,
              color: theme.colorScheme.primary,
            ),
            onPressed: () => _navigateToProfile(context),
            tooltip: 'Seu perfil',
          ),
          IconButton(
            icon: Icon(
              Icons.logout,
              color: theme.colorScheme.error,
            ),
            onPressed: _handleLogout,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de pesquisa com estilo melhorado
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const PostsSearchBar(),
          ),
          // Lista de posts com estados melhorados
          Expanded(
            child: Consumer<PostsProvider>(
              builder: (context, postsProvider, child) {
                if (postsProvider.posts.isEmpty && postsProvider.isLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Carregando posts...',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (postsProvider.error != null && postsProvider.posts.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Ops! Algo deu errado',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            postsProvider.error!,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: () => postsProvider.loadPosts(refresh: true),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (postsProvider.posts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.post_add,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhuma postagem encontrada',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _showingFollowingOnly 
                            ? 'Siga outros usuários para ver seus posts'
                            : 'Seja o primeiro a postar algo!',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    // Mostra feedback visual
                    final messenger = ScaffoldMessenger.of(context);
                    messenger.showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.refresh, color: theme.colorScheme.onInverseSurface),
                            const SizedBox(width: 10),
                            const Text('Atualizando feed...'),
                          ],
                        ),
                        duration: const Duration(milliseconds: 800),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: theme.colorScheme.primaryContainer,
                      ),
                    );
                    
                    // Atualiza os posts
                    await postsProvider.loadPosts(
                      feed: _showingFollowingOnly ? 1 : 0,
                      refresh: true,
                    );
                    
                    if (mounted) {
                      // Feedback de sucesso
                      messenger.hideCurrentSnackBar();
                      messenger.showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.check_circle, color: theme.colorScheme.onInverseSurface),
                              const SizedBox(width: 10),
                              const Text('Feed atualizado!'),
                            ],
                          ),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: theme.colorScheme.secondaryContainer,
                        ),
                      );
                    }
                  },
                  color: theme.colorScheme.primary,
                  displacement: 40,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: postsProvider.posts.length + 1,
                    itemBuilder: (context, index) {
                      if (index == postsProvider.posts.length) {
                        if (!postsProvider.hasMorePosts) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Não há mais posts para carregar',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        }
                        if (postsProvider.isLoading) {
                          return _buildLoadingIndicator();
                        }
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: PostWidget(
                          post: postsProvider.posts[index],
                          key: ValueKey(postsProvider.posts[index]['id']),
                        ),
                      );
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
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 4,
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