import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:papacapim/providers/posts_provider.dart';

class PostsSearchBar extends StatefulWidget {
  const PostsSearchBar({Key? key}) : super(key: key);

  @override
  State<PostsSearchBar> createState() => _PostsSearchBarState();
}

class _PostsSearchBarState extends State<PostsSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  bool _showOnlyFollowing = false; // feed=1 mostra apenas posts de quem o usuário segue

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Pesquisar posts...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _performSearch(context);
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onChanged: (_) => _performSearch(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Mostrar apenas posts de quem eu sigo'),
              const SizedBox(width: 8),
              Switch(
                value: _showOnlyFollowing,
                onChanged: (value) {
                  setState(() {
                    _showOnlyFollowing = value;
                    _performSearch(context);
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _performSearch(BuildContext context) {
    final postsProvider = Provider.of<PostsProvider>(context, listen: false);
    postsProvider.loadPosts(
      feed: _showOnlyFollowing ? 1 : 0,
      search: _searchController.text.isEmpty ? null : _searchController.text,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}