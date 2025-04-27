import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:papacapim/services/base_service.dart';

class AuthService extends BaseService {
  static Future<Map<String, dynamic>> login(String login, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseService.baseUrl}/sessions'),
        headers: BaseService.headers,
        body: jsonEncode({
          'login': login,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        BaseService.setSessionToken(data['token']);
        return data;
      } else {
        throw Exception('Credenciais inválidas');
      }
    } catch (e) {
      throw Exception('Falha ao fazer login: ${e.toString()}');
    }
  }

  static void logout() {
    BaseService.setSessionToken(null);
  }
}