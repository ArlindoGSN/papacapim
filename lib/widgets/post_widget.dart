import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:papacapim/providers/posts_provider.dart';
import 'package:papacapim/providers/auth_provider.dart';
import 'package:papacapim/providers/post_details_provider.dart';
import 'package:papacapim/screens/post_details_screen.dart';

class PostWidget extends StatelessWidget {
  final Map<String, dynamic> post;
  final bool isInDetailsScreen;

  const PostWidget({
    super.key,
    required this.post,
    this.isInDetailsScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime createdAt = DateTime.parse(post['created_at']);
    final String timeAgo = timeago.format(createdAt, locale: 'pt_BR');
    final currentUserLogin = context.read<AuthProvider>().user?['login'];
    final isCurrentUserPost = post['user_login'] == currentUserLogin;

    return InkWell(
      onTap: isInDetailsScreen
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider(
                    create: (_) => PostDetailsProvider(),
                    child: PostDetailsScreen(post: post),
                  ),
                ),
              );
            },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    child: Text(post['user_login'][0].toUpperCase()),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '@${post['user_login']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        timeAgo,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                post['message'],
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () {
                      context.read<PostsProvider>().likePost(post['id']);
                    },
                  ),
                  Text('${post['likes_count'] ?? 0}'),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider(
                            create: (_) => PostDetailsProvider(),
                            child: PostDetailsScreen(post: post),
                          ),
                        ),
                      );
                    },
                  ),
                  Text('${post['replies_count'] ?? 0}'),
                  const Spacer(),
                  if (isCurrentUserPost)
                    PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Excluir'),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'delete') {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Excluir postagem'),
                              content: const Text(
                                'Tem certeza que deseja excluir esta postagem?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    context
                                        .read<PostsProvider>()
                                        .deletePost(post['id']);
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'Excluir',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}