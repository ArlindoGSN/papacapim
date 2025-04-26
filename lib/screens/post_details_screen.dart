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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Post'),
      ),
      body: Column(
        children: [
          PostWidget(
            post: widget.post,
            isInDetailsScreen: true, // Indica que está na tela de detalhes
          ),
          Expanded(
            child: Consumer<PostDetailsProvider>(
              builder: (context, provider, child) {
                if (provider.replies.isEmpty && provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null && provider.replies.isEmpty) {
                  return Center(
                    child: Text('Erro: ${provider.error}'),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: provider.replies.length + 1,
                  itemBuilder: (context, index) {
                    if (index == provider.replies.length) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return const SizedBox.shrink();
                    }

                    final reply = provider.replies[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  child: Text(reply['user_login'][0].toUpperCase()),
                                ),
                                const SizedBox(width: 8),
                                Text('@${reply['user_login']}'),
                                const Spacer(),
                                Text(
                                  timeago.format(
                                    DateTime.parse(reply['created_at']),
                                    locale: 'pt_BR',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(reply['message']),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    decoration: const InputDecoration(
                      hintText: 'Escreva uma resposta...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
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