import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:papacapim/providers/posts_provider.dart';

class PostsSearchBar extends StatefulWidget {
  const PostsSearchBar({super.key});

  @override
  State<PostsSearchBar> createState() => _PostsSearchBarState();
}

class _PostsSearchBarState extends State<PostsSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<PostsProvider>().loadPosts(
            search: query.trim(),
            refresh: true,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar posts...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context
                        .read<PostsProvider>()
                        .loadPosts(refresh: true);
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }
}