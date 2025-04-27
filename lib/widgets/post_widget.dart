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
    required this.post,
    this.isInDetailsScreen = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateTime createdAt = DateTime.parse(post['created_at']);
    final String timeAgoText = timeago.format(createdAt, locale: 'pt_BR');
    final bool isLiked = post['liked'] ?? false;
    final String userLogin = post['user_login'] ?? '';
    final bool isCurrentUserPost = context.read<AuthProvider>().user?['login'] == userLogin;

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
                    child: Text(userLogin.isNotEmpty ? userLogin[0].toUpperCase() : '?'),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '@$userLogin',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        timeAgoText,
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
                    icon: isLiked 
                        ? const Icon(Icons.thumb_up, color: Colors.green)
                        : const Icon(Icons.thumb_up_outlined),
                    onPressed: () {
                      final postsProvider = context.read<PostsProvider>();
                      if (isLiked) {
                        postsProvider.unlikePost(post['id']);
                      } else {
                        postsProvider.likePost(post['id']);
                      }
                    },
                    tooltip: isLiked ? 'Descurtir' : 'Curtir',
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline),
                    onPressed: () {
                      if (!isInDetailsScreen) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangeNotifierProvider(
                              create: (_) => PostDetailsProvider(),
                              child: PostDetailsScreen(post: post),
                            ),
                          ),
                        );
                      }
                    },
                    tooltip: 'Comentários',
                  ),
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