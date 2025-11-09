import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Create or get existing chat between two users
  Future<ChatModel> getOrCreateChat({
    required String user1Id,
    required String user1Name,
    required String user2Id,
    required String user2Name,
  }) async {
    try {
      // Check if chat already exists
      QuerySnapshot existingChats = await _firestore
          .collection('chats')
          .where('participantIds', arrayContains: user1Id)
          .get();

      for (var doc in existingChats.docs) {
        ChatModel chat = ChatModel.fromMap(doc.data() as Map<String, dynamic>);
        if (chat.participantIds.contains(user2Id)) {
          return chat;
        }
      }

      // Create new chat if doesn't exist
      String chatId = _firestore.collection('chats').doc().id;

      ChatModel newChat = ChatModel(
        id: chatId,
        participantIds: [user1Id, user2Id],
        participantNames: {
          user1Id: user1Name,
          user2Id: user2Name,
        },
        createdAt: DateTime.now(),
      );

      await _firestore.collection('chats').doc(chatId).set(newChat.toMap());

      return newChat;
    } catch (e) {
      throw 'Error creating/getting chat: $e';
    }
  }

  // Send message
  Future<MessageModel> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    try {
      // Create message
      String messageId = _uuid.v4();

      MessageModel message = MessageModel(
        id: messageId,
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        text: text,
        timestamp: DateTime.now(),
      );

      // Save message to Firestore
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .set(message.toMap());

      // Update chat with last message info
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': text,
        'lastMessageTime': Timestamp.fromDate(message.timestamp),
        'lastMessageSenderId': senderId,
      });

      return message;
    } catch (e) {
      throw 'Error sending message: $e';
    }
  }

  // Stream messages for a chat
  Stream<List<MessageModel>> streamMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.data()))
            .toList());
  }

  // Stream chats for a user
  Stream<List<ChatModel>> streamUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participantIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      List<ChatModel> chats = snapshot.docs
          .map((doc) => ChatModel.fromMap(doc.data()))
          .toList();

      // Sort by last message time
      chats.sort((a, b) {
        if (a.lastMessageTime == null && b.lastMessageTime == null) return 0;
        if (a.lastMessageTime == null) return 1;
        if (b.lastMessageTime == null) return -1;
        return b.lastMessageTime!.compareTo(a.lastMessageTime!);
      });

      return chats;
    });
  }

  // Get messages for a chat
  Future<List<MessageModel>> getMessages(String chatId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => MessageModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw 'Error getting messages: $e';
    }
  }

  // Get single chat
  Future<ChatModel?> getChat(String chatId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('chats').doc(chatId).get();

      if (doc.exists) {
        return ChatModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw 'Error getting chat: $e';
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      QuerySnapshot unreadMessages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('senderId', isNotEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in unreadMessages.docs) {
        await doc.reference.update({'isRead': true});
      }
    } catch (e) {
      // Ignore errors
    }
  }

  // Delete chat
  Future<void> deleteChat(String chatId) async {
    try {
      // Delete all messages in the chat
      QuerySnapshot messages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get();

      for (var doc in messages.docs) {
        await doc.reference.delete();
      }

      // Delete the chat
      await _firestore.collection('chats').doc(chatId).delete();
    } catch (e) {
      throw 'Error deleting chat: $e';
    }
  }
}
