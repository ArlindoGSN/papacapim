import 'package:flutter/foundation.dart';
import 'package:papacapim/services/auth_service.dart';
import 'package:papacapim/services/user_service.dart';
import 'package:papacapim/services/base_service.dart';

class AuthProvider extends ChangeNotifier {
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  Map<String, dynamic>? get user => _user;
  String? get error => _error;

  Future<void> login(String login, String password) async {
    if (login.isEmpty || password.isEmpty) {
      _error = 'Login e senha são obrigatórios';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await AuthService.login(login, password);
      _user = {
        'login': data['user_login'],
        'name': data['user_name'],
      };
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String userLogin, String name, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await UserService.createUser(userLogin, name, password);
      await login(userLogin, password);
    } catch (e) {
      _error = 'Falha ao criar conta: ${e.toString()}';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(String name, {String? password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedUser = await UserService.updateUser(name, password: password);
      _user = updatedUser;
    } catch (e) {
      _error = 'Falha ao atualizar perfil: ${e.toString()}';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAccount() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await UserService.deleteUser();
      await logout();
    } catch (e) {
      _error = 'Falha ao excluir conta: ${e.toString()}';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Limpa dados locais
      _user = null;
      BaseService.setSessionToken(null);
      
      _error = null;
    } catch (e) {
      _error = 'Erro ao fazer logout: ${e.toString()}';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}