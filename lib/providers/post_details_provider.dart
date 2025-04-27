import 'package:flutter/foundation.dart';
import 'package:papacapim/services/post_service.dart';

class PostDetailsProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _replies = [];
  List<Map<String, dynamic>> _likes = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMoreReplies = true;
  Map<String, dynamic>? _currentPost;

  List<Map<String, dynamic>> get replies => _replies;
  List<Map<String, dynamic>> get likes => _likes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMoreReplies => _hasMoreReplies;
  Map<String, dynamic>? get currentPost => _currentPost;

  Future<void> loadReplies(int postId, {bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _replies = [];
      _hasMoreReplies = true;
    }

    if (_isLoading || (!_hasMoreReplies && !refresh)) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newReplies = await PostService.getReplies(postId, page: _currentPage);
      
      if (newReplies.isEmpty) {
        _hasMoreReplies = false;
      } else {
        _replies.addAll(newReplies);
        _sortReplies();
        _currentPage++;
      }
    } catch (e) {
      _error = 'Falha ao carregar comentários: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadLikes(int postId) async {
    try {
      _likes = await PostService.getLikes(postId);
    } catch (e) {
      _error = 'Falha ao carregar curtidas: ${e.toString()}';
    }
    notifyListeners();
  }

  Future<void> createReply(int postId, String message) async {
    if (message.trim().isEmpty) {
      _error = 'O comentário não pode estar vazio';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newReply = await PostService.createReply(postId, message.trim());
      _replies.insert(0, newReply);
      _sortReplies();
    } catch (e) {
      _error = 'Falha ao criar comentário: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _sortReplies() {
    _replies.sort((a, b) {
      final DateTime dateA = DateTime.parse(a['created_at']);
      final DateTime dateB = DateTime.parse(b['created_at']);
      return dateB.compareTo(dateA);
    });
  }
}