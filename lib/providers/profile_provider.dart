import 'package:flutter/foundation.dart';
import 'package:papacapim/services/user_service.dart';

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
      _profile = await UserService.getUser(login);
      await loadUserPosts(login);
    } catch (e) {
      _error = 'Falha ao carregar perfil: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserPosts(String login) async {
    try {
      _posts = await UserService.getUserPosts(login);
    } catch (e) {
      _error = 'Falha ao carregar posts: ${e.toString()}';
    }
    notifyListeners();
  }

  Future<void> followUser(String login) async {
    try {
      await UserService.followUser(login);
      if (_profile != null) {
        _profile = {
          ..._profile!,
          'following': true,
        };
      }
      notifyListeners();
    } catch (e) {
      _error = 'Falha ao seguir usuário: ${e.toString()}';
      rethrow;
    }
  }

  Future<void> unfollowUser(String login) async {
    try {
      await UserService.unfollowUser(login);
      if (_profile != null) {
        _profile = {
          ..._profile!,
          'following': false,
        };
      }
      notifyListeners();
    } catch (e) {
      _error = 'Falha ao deixar de seguir usuário: ${e.toString()}';
      rethrow;
    }
  }
}