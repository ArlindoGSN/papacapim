import 'package:flutter/foundation.dart';
import 'package:papacapim/services/api_service.dart';

class PostsProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMorePosts = true;
  int _currentFeed = 0;
  String? _currentSearch; // Novo campo para controlar a busca atual

  List<Map<String, dynamic>> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMorePosts => _hasMorePosts;

  void _sortPosts() {
    _posts.sort((a, b) {
      final DateTime dateA = DateTime.parse(a['created_at']);
      final DateTime dateB = DateTime.parse(b['created_at']);
      return dateB.compareTo(dateA); // Ordem decrescente (mais recente primeiro)
    });
  }

  Future<void> loadPosts({
    int feed = 0,
    String? search,
    bool refresh = false,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _posts = [];
      _hasMorePosts = true;
      _currentFeed = feed;
      _currentSearch = search; // Atualiza o termo de busca
    }

    // Verifica se está tentando fazer uma nova busca
    if (_currentSearch != search) {
      _currentPage = 1;
      _posts = [];
      _hasMorePosts = true;
      _currentSearch = search;
    }

    if (_isLoading || (!_hasMorePosts && !refresh)) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newPosts = await ApiService.getPosts(
        feed: _currentFeed,
        search: _currentSearch,
        page: _currentPage,
      );

      if (newPosts.isEmpty) {
        _hasMorePosts = false;
      } else {
        _posts.addAll(newPosts);
        _sortPosts(); // Ordena os posts após adicionar novos
        _currentPage++;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createPost(String message) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newPost = await ApiService.createPost(message);
      _posts.insert(0, newPost); // Não precisa ordenar aqui pois posts novos já vão para o topo
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePost(int postId) async {
    try {
      await ApiService.deletePost(postId);
      _posts.removeWhere((post) => post['id'] == postId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> likePost(int postId) async {
    try {
      await ApiService.likePost(postId);
      final postIndex = _posts.indexWhere((post) => post['id'] == postId);
      if (postIndex != -1) {
        _posts[postIndex] = {
          ..._posts[postIndex],
          'likes_count': (_posts[postIndex]['likes_count'] ?? 0) + 1,
        };
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> unlikePost(int postId) async {
    try {
      await ApiService.unlikePost(postId);
      final postIndex = _posts.indexWhere((post) => post['id'] == postId);
      if (postIndex != -1) {
        _posts[postIndex] = {
          ..._posts[postIndex],
          'likes_count': (_posts[postIndex]['likes_count'] ?? 1) - 1,
        };
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}