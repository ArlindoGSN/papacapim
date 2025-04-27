import 'package:flutter/foundation.dart';
import 'package:papacapim/services/reply_service.dart';

class ReplyProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _replies = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Map<String, dynamic>> get replies => _replies;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadReplies(int postId) async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      notifyListeners();

      final replies = await ReplyService.getReplies(postId);
      _replies = replies;
      _error = null;

      // Ordena as respostas por data
      _sortReplies();
    } catch (e) {
      _error = e.toString();
      print('Erro ao carregar respostas: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createReply(int postId, String message) async {
    if (message.trim().isEmpty) return;

    try {
      _isLoading = true;
      notifyListeners();

      final newReply = await ReplyService.createReply(
        postId,
        message.trim(),
      );

      _replies.insert(0, newReply);
      _error = null;

      // Recarrega todas as respostas para garantir consistência
      await loadReplies(postId);
    } catch (e) {
      print('Erro ao criar resposta: $e');
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteReply(int postId, int replyId) async {
    try {
      await ReplyService.deleteReply(postId, replyId);
      _replies.removeWhere((reply) => reply['id'] == replyId);
      notifyListeners();
    } catch (e) {
      _error = 'Falha ao excluir resposta: ${e.toString()}';
      rethrow;
    }
  }

  void _sortReplies() {
    try {
      _replies.sort((a, b) {
        final DateTime dateA = DateTime.parse(a['created_at'] ?? '');
        final DateTime dateB = DateTime.parse(b['created_at'] ?? '');
        return dateB.compareTo(dateA);
      });
    } catch (e) {
      print('Erro ao ordenar respostas: $e');
    }
  }
}