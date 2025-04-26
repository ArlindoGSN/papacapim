import 'package:flutter/foundation.dart';
import 'package:papacapim/services/api_service.dart';

class PostDetailsProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _replies = [];
  List<Map<String, dynamic>> _likes = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMoreReplies = true;

  List<Map<String, dynamic>> get replies => _replies;
  List<Map<String, dynamic>> get likes => _likes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMoreReplies => _hasMoreReplies;

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
      final newReplies = await ApiService.getReplies(postId, page: _currentPage);
      
      if (newReplies.isEmpty) {
        _hasMoreReplies = false;
      } else {
        _replies.addAll(newReplies);
        _currentPage++;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadLikes(int postId) async {
    try {
      _likes = await ApiService.getLikes(postId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> createReply(int postId, String message) async {
    try {
      final newReply = await ApiService.createReply(postId, message);
      _replies.insert(0, newReply);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}