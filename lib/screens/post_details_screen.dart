import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:papacapim/providers/post_details_provider.dart';
import 'package:papacapim/widgets/post_widget.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostDetailsScreen({
    super.key,
    required this.post,
  });

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = context.read<PostDetailsProvider>();
      provider.loadReplies(widget.post['id'], refresh: true);
      provider.loadLikes(widget.post['id']);
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final provider = context.read<PostDetailsProvider>();
    if (!provider.isLoading && 
        _scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      provider.loadReplies(widget.post['id']);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalhes do Post',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          PostWidget(
            post: widget.post,
            isInDetailsScreen: true,
          ),
          Expanded(
            child: Consumer<PostDetailsProvider>(
              builder: (context, provider, child) {
                if (provider.replies.isEmpty && provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (provider.error != null && provider.replies.isEmpty) {
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
                          'Erro: ${provider.error}',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => provider.loadReplies(
                            widget.post['id'],
                            refresh: true,
                          ),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: provider.replies.length + 1,
                  itemBuilder: (context, index) {
                    if (index == provider.replies.length) {
                      if (provider.isLoading) {
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
                      return const SizedBox.shrink();
                    }

                    final reply = provider.replies[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: theme.colorScheme.primary,
                                  child: Text(
                                    reply['user_login'][0].toUpperCase(),
                                    style: TextStyle(
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '@${reply['user_login']}',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        timeago.format(
                                          DateTime.parse(reply['created_at']),
                                          locale: 'pt_BR',
                                        ),
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              reply['message'],
                              style: theme.textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
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
                  offset: const Offset(0, -2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    decoration: InputDecoration(
                      hintText: 'Escreva uma resposta...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: () {
                    if (_replyController.text.isNotEmpty) {
                      context.read<PostDetailsProvider>().createReply(
                        widget.post['id'],
                        _replyController.text,
                      );
                      _replyController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}