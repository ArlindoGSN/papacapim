import 'package:flutter/foundation.dart';
import 'package:papacapim/services/api_service.dart';

class ProfileProvider extends ChangeNotifier {
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get profile => _profile;
  List<Map<String, dynamic>> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProfile(String login) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.getUser(login);
      _profile = response;
      await loadUserPosts(login);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserPosts(String login) async {
    try {
      _posts = await ApiService.getUserPosts(login);
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> followUser(String login) async {
    try {
      await ApiService.followUser(login);
      if (_profile != null) {
        _profile = {
          ..._profile!,
          'followers_count': (_profile!['followers_count'] ?? 0) + 1,
        };
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> unfollowUser(String login) async {
    try {
      await ApiService.unfollowUser(login);
      if (_profile != null) {
        _profile = {
          ..._profile!,
          'followers_count': (_profile!['followers_count'] ?? 1) - 1,
        };
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
} 