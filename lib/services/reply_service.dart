import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:papacapim/services/base_service.dart';

class ReplyService extends BaseService {
  /// Lista todas as respostas de um post
  static Future<List<Map<String, dynamic>>> getReplies(int postId) async {
    try {
      // Valida parâmetro
      if (postId <= 0) throw Exception('ID do post inválido');

      // Constrói a URL
      final uri = Uri.parse('${BaseService.baseUrl}/posts/$postId/replies');

      // Log para debug
      print('📫 Buscando respostas - POST: $postId');
      print('URL: $uri');

      // Faz a requisição
      final response = await http.get(
        uri,
        headers: BaseService.headers,
      );

      // Log da resposta
      print('📥 Status: ${response.statusCode}');
      print('Resposta: ${response.body}');

      // Processa a resposta
      switch (response.statusCode) {
        case 200:
          final List<dynamic> data = jsonDecode(response.body);
          final replies = data.cast<Map<String, dynamic>>();
          
          print('✅ ${replies.length} respostas carregadas');
          return replies;

        case 401:
          throw Exception('Sessão expirada. Por favor, faça login novamente.');
        
        case 404:
          throw Exception('Post não encontrado');
        
        default:
          throw Exception(
            'Erro ${response.statusCode} ao carregar respostas: ${response.body}',
          );
      }
    } catch (e) {
      print('❌ Erro ao buscar respostas: $e');
      rethrow;
    }
  }

  // Cria uma nova resposta
  static Future<Map<String, dynamic>> createReply(
    int postId,
    String message,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseService.baseUrl}/posts/$postId/replies'),
        headers: {
          ...BaseService.headers,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'reply': {
            'message': message,
          },
        }),
      );

      print('Create reply status: ${response.statusCode}');
      print('Create reply body: ${response.body}');

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Erro ${response.statusCode} ao criar resposta: ${response.body}',
        );
      }
    } catch (e) {
      print('Erro no createReply: $e');
      rethrow;
    }
  }

  // Delete uma resposta
  static Future<void> deleteReply(int postId, int replyId) async {
    try {
      final response = await http.delete(
        Uri.parse('${BaseService.baseUrl}/posts/$postId/replies/$replyId'),
        headers: BaseService.headers,
      );

      print('Delete reply status: ${response.statusCode}');

      if (response.statusCode != 204) {
        throw Exception(
          'Erro ${response.statusCode} ao deletar resposta',
        );
      }
    } catch (e) {
      print('Erro no deleteReply: $e');
      rethrow;
    }
  }
}