import 'api_client.dart';
import 'package:dio/dio.dart';

/// 客服AI服务：调用后端 /ai/chat 或 /ai/analyze 接口
class CustomerServiceApi {
  /// 走多轮会话接口（后端优先使用 Ollama /api/chat 或 OpenAI Responses）
  Future<String> getReply(String userInput, {String? selectedText, String? bookTitle}) async {
    try {
      final dio = ApiClient().dio;
      final resp = await dio.post(
        '/ai/chat',
        data: {
          'messages': [
            {
              'role': 'user',
              'content': userInput,
            }
          ],
          'context': {
            'selectedText': selectedText ?? '',
            'bookTitle': bookTitle ?? '',
          }
        },
        options: Options(
          // AI生成可能较慢，提高接收超时以避免10秒超时
          receiveTimeout: const Duration(minutes: 2),
          sendTimeout: const Duration(seconds: 30),
        ),
      );
      final reply = (resp.data['reply'] ?? '').toString();
      if (reply.isEmpty) return '抱歉，暂时没有可用的回复。';
      return reply;
    } catch (e) {
      return 'AI接口请求失败：$e';
    }
  }

  /// 单轮分析接口（返回 summary/sentiment/keywords 等JSON，可用于后续扩展）
  Future<Map<String, dynamic>> analyzeText(String text) async {
      try {
        final dio = ApiClient().dio;
        final resp = await dio.post(
          '/ai/analyze',
          data: {
            'text': text,
          },
          options: Options(
            receiveTimeout: const Duration(minutes: 1),
            sendTimeout: const Duration(seconds: 30),
          ),
        );
        final m = resp.data as Map<String, dynamic>;
        return m;
      } catch (e) {
        return {'error': 'request_failed', 'message': e.toString()};
      }
  }
}
