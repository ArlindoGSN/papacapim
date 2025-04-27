import 'package:flutter/foundation.dart';
import 'package:papacapim/services/post_service.dart';

class PostsProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 0;
  bool _hasMorePosts = true;
  int _currentFeed = 0;
  String? _currentSearch;

  List<Map<String, dynamic>> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMorePosts => _hasMorePosts;

  Future<void> loadPosts({
    int feed = 0,
    String? search,
    bool refresh = false,
  }) async {
    if (refresh) {
      _currentPage = 0;
      _posts = [];
      _hasMorePosts = true;
      _currentFeed = feed;
      _currentSearch = search;
    }

    if (_isLoading || (!_hasMorePosts && !refresh)) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newPosts = await PostService.getPosts(
        page: _currentPage,
        feed: _currentFeed,
        search: _currentSearch,
      );

      if (newPosts.isEmpty) {
        _hasMorePosts = false;
      } else {
        // Garante que cada novo post tenha um timestamp válido
        for (final post in newPosts) {
          if (!post.containsKey('created_at') || post['created_at'] == null) {
            post['created_at'] = DateTime.now().toIso8601String();
          }
        }
        
        _posts.addAll(newPosts);
        // Força a ordenação após cada carregamento
        _sortPosts();
        _currentPage++;
      }
    } catch (e) {
      _error = 'Falha ao carregar posts: ${e.toString()}';
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
      final newPost = await PostService.createPost(message);
      _posts.insert(0, newPost);
      _sortPosts();
    } catch (e) {
      _error = 'Falha ao criar post: ${e.toString()}';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePost(int postId) async {
    if (postId <= 0) {
      _error = 'ID do post inválido';
      notifyListeners();
      return;
    }

    try {
      // Primeiro faz a chamada à API
      await PostService.deletePost(postId);
      
      // Se bem sucedido, remove localmente
      final index = _posts.indexWhere((post) => post['id'] == postId);
      if (index != -1) {
        _posts.removeAt(index);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Falha ao excluir post: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> likePost(int postId) async {
    if (postId <= 0) return;

    try {
      // Atualiza otimisticamente
      final index = _posts.indexWhere((post) => post['id'] == postId);
      if (index != -1) {
        _posts[index] = {
          ..._posts[index],
          'liked': true,
        };
        notifyListeners();
      }

      // Faz a chamada à API
      await PostService.likePost(postId);
    } catch (e) {
      // Reverte em caso de erro
      final index = _posts.indexWhere((post) => post['id'] == postId);
      if (index != -1) {
        _posts[index] = {
          ..._posts[index],
          'liked': false,
        };
        notifyListeners();
      }
      _error = 'Falha ao curtir post: ${e.toString()}';
    }
  }

  Future<void> unlikePost(int postId) async {
    if (postId <= 0) return;

    try {
      // Atualiza otimisticamente
      final index = _posts.indexWhere((post) => post['id'] == postId);
      if (index != -1) {
        _posts[index] = {
          ..._posts[index],
          'liked': false,
        };
        notifyListeners();
      }

      // Faz a chamada à API
      await PostService.unlikePost(postId);
    } catch (e) {
      // Reverte em caso de erro
      final index = _posts.indexWhere((post) => post['id'] == postId);
      if (index != -1) {
        _posts[index] = {
          ..._posts[index],
          'liked': true,
        };
        notifyListeners();
      }
      _error = 'Falha ao descurtir post: ${e.toString()}';
    }
  }

  void _sortPosts() {
    _posts.sort((a, b) {
      final DateTime dateA = DateTime.parse(a['created_at']);
      final DateTime dateB = DateTime.parse(b['created_at']);
      return dateB.compareTo(dateA);
    });
  }
}