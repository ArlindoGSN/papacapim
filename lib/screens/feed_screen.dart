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
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<PostsProvider>().loadPosts(feed: 0);
    });
  }

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
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const PostsSearchBar(), // Adicione a barra de busca aqui
          Expanded(
            child: Consumer<PostsProvider>(
              builder: (context, postsProvider, child) {
                if (postsProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (postsProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Erro ao carregar posts: ${postsProvider.error}',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            postsProvider.loadPosts();
                          },
                          child: const Text('Tentar novamente'),
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
                  onRefresh: () => postsProvider.loadPosts(),
                  child: ListView.builder(
                    itemCount: postsProvider.posts.length,
                    itemBuilder: (context, index) {
                      return PostWidget(post: postsProvider.posts[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
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