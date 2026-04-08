import '../core/api_client.dart';
import '../core/constants.dart';
import '../core/storage_service.dart';
import '../models/message.dart';

class MessageService {
  static Future<Message> sendMessage(String receiverId, String content) async {
    final res = await ApiClient.post(
      ApiConstants.messages,
      {'receiverId': receiverId, 'content': content},
    );
    return Message.fromJson(res);
  }

  static Future<List<Conversation>> getConversations() async {
    final res = await ApiClient.get(ApiConstants.conversations);
    final info = await StorageService.getUserInfo();
    final currentUserId = info?['userId'] ?? '';
    return (res as List)
        .map((c) => Conversation.fromJson(c, currentUserId))
        .toList();
  }

  static Future<List<Message>> getMessages(String userId) async {
    final res = await ApiClient.get('${ApiConstants.messages}/$userId');
    return (res as List).map((m) => Message.fromJson(m)).toList();
  }

  static Future<void> markAsRead(String messageId) async {
    await ApiClient.patch('${ApiConstants.messages}/$messageId/read', {});
  }
}
