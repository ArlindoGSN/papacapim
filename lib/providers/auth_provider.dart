import 'package:flutter/foundation.dart';
import 'package:papacapim/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  Map<String, dynamic>? _user;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  Map<String, dynamic>? get user => _user;

  Future<void> login(String login, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final session = await ApiService.login(login, password);
      _user = {
        'login': session['user_login'],
        // Adicionar outros dados do usuário conforme necessário
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String login, String name, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.createUser(login, name, password);
      await this.login(login, password);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(String name, {String? password}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updatedUser = await ApiService.updateUser(name, password: password);
      _user = updatedUser;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAccount() async {
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.deleteUser();
      logout();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _user = null;
    ApiService.setSessionToken('');
    notifyListeners();
  }
} 