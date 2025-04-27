import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:papacapim/services/base_service.dart';

class UserService extends BaseService {
  static Future<Map<String, dynamic>> createUser(
    String login,
    String name,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('${BaseService.baseUrl}/users'),
      headers: BaseService.headers,
      body: jsonEncode({
        'user': {
          'login': login,
          'name': name,
          'password': password,
          'password_confirmation': password,
        },
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha ao criar usuário');
    }
  }

  static Future<Map<String, dynamic>> updateUser(
    String name, {
    String? password,
  }) async {
    final Map<String, dynamic> userData = {'name': name};
    if (password != null) {
      userData['password'] = password;
      userData['password_confirmation'] = password;
    }

    final response = await http.patch(
      Uri.parse('${BaseService.baseUrl}/users/1'),
      headers: BaseService.headers,
      body: jsonEncode({'user': userData}),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha ao atualizar usuário');
    }
  }

  static Future<void> deleteUser() async {
    final response = await http.delete(
      Uri.parse('${BaseService.baseUrl}/users/1'),
      headers: BaseService.headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Falha ao excluir usuário');
    }
  }

  static Future<Map<String, dynamic>> getUser(String login) async {
    final response = await http.get(
      Uri.parse('${BaseService.baseUrl}/users/$login'),
      headers: BaseService.headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha ao carregar usuário');
    }
  }

  static Future<List<Map<String, dynamic>>> getUserPosts(String login) async {
    final response = await http.get(
      Uri.parse('${BaseService.baseUrl}/users/$login/posts'),
      headers: BaseService.headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Falha ao carregar posts do usuário');
    }
  }

  static Future<void> followUser(String login) async {
    final response = await http.post(
      Uri.parse('${BaseService.baseUrl}/users/$login/followers'),
      headers: BaseService.headers,
    );

    if (response.statusCode != 201) {
      throw Exception('Falha ao seguir usuário');
    }
  }

  static Future<void> unfollowUser(String login) async {
    final response = await http.delete(
      Uri.parse('${BaseService.baseUrl}/users/$login/followers/1'),
      headers: BaseService.headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Falha ao deixar de seguir usuário');
    }
  }
}