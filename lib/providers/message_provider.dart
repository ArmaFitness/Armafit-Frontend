import 'package:flutter/foundation.dart';
import '../models/message.dart';
import '../services/message_service.dart';

class MessageProvider extends ChangeNotifier {
  List<Conversation> _conversations = [];
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<Conversation> get conversations => _conversations;
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadConversations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _conversations = await MessageService.getConversations();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMessages(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _messages = await MessageService.getMessages(userId);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> send(String receiverId, String content) async {
    try {
      final msg = await MessageService.sendMessage(receiverId, content);
      _messages.add(msg);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearMessages() {
    _messages = [];
  }
}
