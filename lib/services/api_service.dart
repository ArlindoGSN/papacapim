import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://api.papacapim.just.pro.br';
  static String? _sessionToken;

  static void setSessionToken(String token) {
    _sessionToken = token;
  }

  static Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_sessionToken != null) {
      headers['x-session-token'] = _sessionToken!;
    }
    return headers;
  }

  // Autenticação
  static Future<Map<String, dynamic>> login(
      String login, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sessions'),
      headers: _headers,
      body: jsonEncode({
        'login': login,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setSessionToken(data['token']);
      return data;
    } else {
      throw Exception('Falha ao fazer login');
    }
  }

  // Usuários
  static Future<Map<String, dynamic>> createUser(
    String login,
    String name,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: _headers,
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
      Uri.parse('$baseUrl/users/1'),
      headers: _headers,
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
      Uri.parse('$baseUrl/users/1'),
      headers: _headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Falha ao excluir usuário');
    }
  }

  static Future<Map<String, dynamic>> getUser(String login) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$login'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha ao carregar usuário');
    }
  }

  static Future<List<Map<String, dynamic>>> getUserPosts(String login) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$login/posts'),
      headers: _headers,
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
      Uri.parse('$baseUrl/users/$login/followers'),
      headers: _headers,
    );

    if (response.statusCode != 201) {
      throw Exception('Falha ao seguir usuário');
    }
  }

  static Future<void> unfollowUser(String login) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/users/$login/followers/1'),
      headers: _headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Falha ao deixar de seguir usuário');
    }
  }

  // Posts
  static Future<List<Map<String, dynamic>>> getPosts({
    bool feed = false,
    String? search,
  }) async {
    final queryParams = <String, String>{};
    if (feed) queryParams['feed'] = '1';
    if (search != null) queryParams['search'] = search;

    final response = await http.get(
      Uri.parse('$baseUrl/posts').replace(queryParameters: queryParams),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Falha ao carregar posts');
    }
  }

  static Future<Map<String, dynamic>> createPost(String message) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts'),
      headers: _headers,
      body: jsonEncode({
        'post': {'message': message},
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha ao criar post');
    }
  }

  static Future<void> deletePost(int postId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/posts/$postId'),
      headers: _headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Falha ao excluir post');
    }
  }

  // Curtidas
  static Future<void> likePost(int postId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts/$postId/likes'),
      headers: _headers,
    );

    if (response.statusCode != 201) {
      throw Exception('Falha ao curtir post');
    }
  }

  static Future<void> unlikePost(int postId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/posts/$postId/likes/1'),
      headers: _headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Falha ao descurtir post');
    }
  }
}
