import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:papacapim/services/base_service.dart';

class PostService extends BaseService {
  static Future<List<Map<String, dynamic>>> getPosts({
    int feed = 0,
    String? search,
    int page = 1,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'feed': feed.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final response = await http.get(
      Uri.parse('${BaseService.baseUrl}/posts')
          .replace(queryParameters: queryParams),
      headers: BaseService.headers,
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
      Uri.parse('${BaseService.baseUrl}/posts'),
      headers: BaseService.headers,
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
      Uri.parse('${BaseService.baseUrl}/posts/$postId'),
      headers: BaseService.headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Falha ao excluir post');
    }
  }

  static Future<List<Map<String, dynamic>>> getReplies(
    int postId, {
    int page = 1,
  }) async {
    final queryParams = {'page': page.toString()};
    
    final response = await http.get(
      Uri.parse('${BaseService.baseUrl}/posts/$postId/replies')
          .replace(queryParameters: queryParams),
      headers: BaseService.headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Falha ao carregar respostas');
    }
  }

  static Future<Map<String, dynamic>> createReply(
    int postId,
    String message,
  ) async {
    final response = await http.post(
      Uri.parse('${BaseService.baseUrl}/posts/$postId/replies'),
      headers: BaseService.headers,
      body: jsonEncode({
        'reply': {
          'message': message,
        },
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha ao criar resposta');
    }
  }

  static Future<void> likePost(int postId) async {
    final response = await http.post(
      Uri.parse('${BaseService.baseUrl}/posts/$postId/likes'),
      headers: BaseService.headers,
    );

    if (response.statusCode != 201) {
      throw Exception('Falha ao curtir post');
    }
  }

  static Future<void> unlikePost(int postId) async {
    final response = await http.delete(
      Uri.parse('${BaseService.baseUrl}/posts/$postId/likes/1'),
      headers: BaseService.headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Falha ao descurtir post');
    }
  }

  static Future<List<Map<String, dynamic>>> getLikes(int postId) async {
    final response = await http.get(
      Uri.parse('${BaseService.baseUrl}/posts/$postId/likes'),
      headers: BaseService.headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Falha ao carregar curtidas');
    }
  }
}