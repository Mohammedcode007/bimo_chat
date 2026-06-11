import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'local_chat_model.dart';
import 'local_message_model.dart';

class LocalDmStorage {
  static const String _chatsKey = 'local_dm_chats_v1';
  static const String _messagesPrefix = 'local_dm_messages_v1_';

  String messagesKey(String chatId) {
    return '$_messagesPrefix$chatId';
  }

  Future<List<LocalChatModel>> getChats() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_chatsKey);

    if (raw == null || raw.trim().isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw);

      if (decoded is! List) return [];

      final chats = decoded
          .whereType<Map>()
          .map(
            (item) => LocalChatModel.fromMap(Map<String, dynamic>.from(item)),
          )
          .where((chat) => chat.chatId.isNotEmpty)
          .toList();

      chats.sort((a, b) {
        if (a.isPinned != b.isPinned) {
          return a.isPinned ? -1 : 1;
        }

        return b.lastMessageAt.compareTo(a.lastMessageAt);
      });

      return chats;
    } catch (_) {
      return [];
    }
  }

  Future<void> saveChats(List<LocalChatModel> chats) async {
    final prefs = await SharedPreferences.getInstance();

    final sorted = List<LocalChatModel>.from(chats);

    sorted.sort((a, b) {
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }

      return b.lastMessageAt.compareTo(a.lastMessageAt);
    });

    final encoded = jsonEncode(sorted.map((chat) => chat.toMap()).toList());

    await prefs.setString(_chatsKey, encoded);
  }

  Future<List<LocalMessageModel>> getMessages(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(messagesKey(chatId));

    if (raw == null || raw.trim().isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw);

      if (decoded is! List) return [];

      final messages = decoded
          .whereType<Map>()
          .map(
            (item) =>
                LocalMessageModel.fromMap(Map<String, dynamic>.from(item)),
          )
          .where((message) => message.messageId.isNotEmpty)
          .toList();

      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      return messages;
    } catch (_) {
      return [];
    }
  }

  Future<void> saveMessages({
    required String chatId,
    required List<LocalMessageModel> messages,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final sorted = List<LocalMessageModel>.from(messages)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final encoded = jsonEncode(
      sorted.map((message) => message.toMap()).toList(),
    );

    await prefs.setString(messagesKey(chatId), encoded);
  }

  Future<void> upsertChat(LocalChatModel chat) async {
    final chats = await getChats();

    final index = chats.indexWhere((item) => item.chatId == chat.chatId);

    if (index >= 0) {
      chats[index] = chat;
    } else {
      chats.add(chat);
    }

    await saveChats(chats);
  }

  Future<void> deleteChat(String chatId) async {
    final prefs = await SharedPreferences.getInstance();

    final chats = await getChats();

    final nextChats = chats.where((chat) => chat.chatId != chatId).toList();

    await saveChats(nextChats);
    await prefs.remove(messagesKey(chatId));
  }

  Future<void> clearChatMessages(String chatId) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(messagesKey(chatId));

    final chats = await getChats();

    final nextChats = chats.map((chat) {
      if (chat.chatId != chatId) return chat;

      return chat.copyWith(
        lastMessageText: '',
        lastMessageType: 'text',
        unreadCount: 0,
        lastMessageAt: DateTime.now(),
      );
    }).toList();

    await saveChats(nextChats);
  }

  Future<void> addMessage(LocalMessageModel message) async {
    final messages = await getMessages(message.chatId);

    final exists = messages.any((item) {
      return item.messageId == message.messageId ||
          (message.tempId != null &&
              message.tempId!.isNotEmpty &&
              item.tempId == message.tempId);
    });

    if (!exists) {
      messages.add(message);
    }

    await saveMessages(chatId: message.chatId, messages: messages);
  }

  Future<void> upsertMessage(LocalMessageModel message) async {
    final messages = await getMessages(message.chatId);

    final index = messages.indexWhere((item) {
      return item.messageId == message.messageId ||
          (message.tempId != null &&
              message.tempId!.isNotEmpty &&
              item.tempId == message.tempId);
    });

    if (index >= 0) {
      messages[index] = message;
    } else {
      messages.add(message);
    }

    await saveMessages(chatId: message.chatId, messages: messages);
  }

  Future<void> updateMessageStatus({
    required String chatId,
    required String messageId,
    String? tempId,
    required String status,
  }) async {
    final messages = await getMessages(chatId);

    final next = messages.map((message) {
      final matchByMessageId = message.messageId == messageId;
      final matchByTempId =
          tempId != null && tempId.isNotEmpty && message.tempId == tempId;

      if (!matchByMessageId && !matchByTempId) return message;

      return message.copyWith(
        messageId: messageId.isNotEmpty ? messageId : message.messageId,
        status: status,
        updatedAt: DateTime.now(),
      );
    }).toList();

    await saveMessages(chatId: chatId, messages: next);
  }

  Future<void> markMessagesSeen({
    required String chatId,
    required List<String> messageIds,
  }) async {
    if (messageIds.isEmpty) return;

    final messages = await getMessages(chatId);
    final ids = messageIds.toSet();

    final next = messages.map((message) {
      if (!ids.contains(message.messageId)) return message;

      return message.copyWith(status: 'seen', updatedAt: DateTime.now());
    }).toList();

    await saveMessages(chatId: chatId, messages: next);
  }

  Future<void> editMessage({
    required String chatId,
    required String messageId,
    required String text,
  }) async {
    final messages = await getMessages(chatId);

    final next = messages.map((message) {
      if (message.messageId != messageId) return message;

      return message.copyWith(
        text: text,
        isEdited: true,
        updatedAt: DateTime.now(),
      );
    }).toList();

    await saveMessages(chatId: chatId, messages: next);
  }

  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
  }) async {
    final messages = await getMessages(chatId);

    final next = messages.map((message) {
      if (message.messageId != messageId) return message;

      return message.copyWith(
        text: 'This message was deleted',
        status: 'deleted',
        isDeleted: true,
        updatedAt: DateTime.now(),
      );
    }).toList();

    await saveMessages(chatId: chatId, messages: next);
  }

  Future<void> markChatRead(String chatId) async {
    final chats = await getChats();

    final next = chats.map((chat) {
      if (chat.chatId != chatId) return chat;

      return chat.copyWith(unreadCount: 0);
    }).toList();

    await saveChats(next);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();

    final chats = await getChats();

    for (final chat in chats) {
      await prefs.remove(messagesKey(chat.chatId));
    }

    await prefs.remove(_chatsKey);
  }
}
