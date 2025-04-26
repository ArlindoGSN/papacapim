import 'package:flutter/foundation.dart';
import 'package:papacapim/services/api_service.dart';

class PostsProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPosts({int feed = 0, String? search}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _posts = await ApiService.getPosts(feed: feed, search: search);
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
      _posts.insert(0, newPost);
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