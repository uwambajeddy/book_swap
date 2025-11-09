import 'package:flutter/foundation.dart';
import '../../data/models/chat_model.dart';
import '../../data/models/message_model.dart';
import '../../data/services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();

  final List<ChatModel> _chats = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ChatModel> get chats => _chats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Stream user chats
  Stream<List<ChatModel>> streamUserChats(String userId) {
    return _chatService.streamUserChats(userId);
  }

  // Stream messages for a chat
  Stream<List<MessageModel>> streamMessages(String chatId) {
    return _chatService.streamMessages(chatId);
  }

  // Get or create chat
  Future<ChatModel?> getOrCreateChat({
    required String user1Id,
    required String user1Name,
    required String user2Id,
    required String user2Name,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      ChatModel chat = await _chatService.getOrCreateChat(
        user1Id: user1Id,
        user1Name: user1Name,
        user2Id: user2Id,
        user2Name: user2Name,
      );

      _isLoading = false;
      notifyListeners();
      return chat;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Send message
  Future<bool> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    try {
      if (text.trim().isEmpty) return false;

      await _chatService.sendMessage(
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        text: text.trim(),
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Get messages
  Future<List<MessageModel>> getMessages(String chatId) async {
    try {
      return await _chatService.getMessages(chatId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Get single chat
  Future<ChatModel?> getChat(String chatId) async {
    try {
      return await _chatService.getChat(chatId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      await _chatService.markMessagesAsRead(chatId, userId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Delete chat
  Future<bool> deleteChat(String chatId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _chatService.deleteChat(chatId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
