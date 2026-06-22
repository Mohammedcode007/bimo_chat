// import 'dart:convert';

// import 'package:shared_preferences/shared_preferences.dart';

// import 'local_chat_model.dart';
// import 'local_message_model.dart';

// class LocalDmStorage {
//   static const String _chatsKey = 'local_dm_chats_v1';
//   static const String _messagesPrefix = 'local_dm_messages_v1_';

//   String messagesKey(String chatId) {
//     return '$_messagesPrefix$chatId';
//   }

//   Future<List<LocalChatModel>> getChats() async {
//     final prefs = await SharedPreferences.getInstance();
//     final raw = prefs.getString(_chatsKey);

//     if (raw == null || raw.trim().isEmpty) {
//       return [];
//     }

//     try {
//       final decoded = jsonDecode(raw);

//       if (decoded is! List) return [];

//       final chats = decoded
//           .whereType<Map>()
//           .map(
//             (item) => LocalChatModel.fromMap(Map<String, dynamic>.from(item)),
//           )
//           .where((chat) => chat.chatId.isNotEmpty)
//           .toList();

//       chats.sort((a, b) {
//         if (a.isPinned != b.isPinned) {
//           return a.isPinned ? -1 : 1;
//         }

//         return b.lastMessageAt.compareTo(a.lastMessageAt);
//       });

//       return chats;
//     } catch (_) {
//       return [];
//     }
//   }

//   Future<void> saveChats(List<LocalChatModel> chats) async {
//     final prefs = await SharedPreferences.getInstance();

//     final sorted = List<LocalChatModel>.from(chats);

//     sorted.sort((a, b) {
//       if (a.isPinned != b.isPinned) {
//         return a.isPinned ? -1 : 1;
//       }

//       return b.lastMessageAt.compareTo(a.lastMessageAt);
//     });

//     final encoded = jsonEncode(sorted.map((chat) => chat.toMap()).toList());

//     await prefs.setString(_chatsKey, encoded);
//   }

//   Future<List<LocalMessageModel>> getMessages(String chatId) async {
//     final prefs = await SharedPreferences.getInstance();
//     final raw = prefs.getString(messagesKey(chatId));

//     if (raw == null || raw.trim().isEmpty) {
//       return [];
//     }

//     try {
//       final decoded = jsonDecode(raw);

//       if (decoded is! List) return [];

//       final messages = decoded
//           .whereType<Map>()
//           .map(
//             (item) =>
//                 LocalMessageModel.fromMap(Map<String, dynamic>.from(item)),
//           )
//           .where((message) => message.messageId.isNotEmpty)
//           .toList();

//       messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

//       return messages;
//     } catch (_) {
//       return [];
//     }
//   }

//   Future<void> saveMessages({
//     required String chatId,
//     required List<LocalMessageModel> messages,
//   }) async {
//     final prefs = await SharedPreferences.getInstance();

//     final sorted = List<LocalMessageModel>.from(messages)
//       ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

//     final encoded = jsonEncode(
//       sorted.map((message) => message.toMap()).toList(),
//     );

//     await prefs.setString(messagesKey(chatId), encoded);
//   }

//   Future<void> upsertChat(LocalChatModel chat) async {
//     final chats = await getChats();

//     final index = chats.indexWhere((item) => item.chatId == chat.chatId);

//     if (index >= 0) {
//       chats[index] = chat;
//     } else {
//       chats.add(chat);
//     }

//     await saveChats(chats);
//   }

//   Future<void> deleteChat(String chatId) async {
//     final prefs = await SharedPreferences.getInstance();

//     final chats = await getChats();

//     final nextChats = chats.where((chat) => chat.chatId != chatId).toList();

//     await saveChats(nextChats);
//     await prefs.remove(messagesKey(chatId));
//   }

//   Future<void> clearChatMessages(String chatId) async {
//     final prefs = await SharedPreferences.getInstance();

//     await prefs.remove(messagesKey(chatId));

//     final chats = await getChats();

//     final nextChats = chats.map((chat) {
//       if (chat.chatId != chatId) return chat;

//       return chat.copyWith(
//         lastMessageText: '',
//         lastMessageType: 'text',
//         unreadCount: 0,
//         lastMessageAt: DateTime.now(),
//       );
//     }).toList();

//     await saveChats(nextChats);
//   }

//   Future<void> addMessage(LocalMessageModel message) async {
//     final messages = await getMessages(message.chatId);

//     final exists = messages.any((item) {
//       return item.messageId == message.messageId ||
//           (message.tempId != null &&
//               message.tempId!.isNotEmpty &&
//               item.tempId == message.tempId);
//     });

//     if (!exists) {
//       messages.add(message);
//     }

//     await saveMessages(chatId: message.chatId, messages: messages);
//   }

//   Future<void> upsertMessage(LocalMessageModel message) async {
//     final messages = await getMessages(message.chatId);

//     final index = messages.indexWhere((item) {
//       return item.messageId == message.messageId ||
//           (message.tempId != null &&
//               message.tempId!.isNotEmpty &&
//               item.tempId == message.tempId);
//     });

//     if (index >= 0) {
//       messages[index] = message;
//     } else {
//       messages.add(message);
//     }

//     await saveMessages(chatId: message.chatId, messages: messages);
//   }

//   Future<void> updateMessageStatus({
//     required String chatId,
//     required String messageId,
//     String? tempId,
//     required String status,
//   }) async {
//     final messages = await getMessages(chatId);

//     final next = messages.map((message) {
//       final matchByMessageId = message.messageId == messageId;
//       final matchByTempId =
//           tempId != null && tempId.isNotEmpty && message.tempId == tempId;

//       if (!matchByMessageId && !matchByTempId) return message;

//       return message.copyWith(
//         messageId: messageId.isNotEmpty ? messageId : message.messageId,
//         status: status,
//         updatedAt: DateTime.now(),
//       );
//     }).toList();

//     await saveMessages(chatId: chatId, messages: next);
//   }

//   Future<void> markMessagesSeen({
//     required String chatId,
//     required List<String> messageIds,
//   }) async {
//     if (messageIds.isEmpty) return;

//     final messages = await getMessages(chatId);
//     final ids = messageIds.toSet();

//     final next = messages.map((message) {
//       if (!ids.contains(message.messageId)) return message;

//       return message.copyWith(status: 'seen', updatedAt: DateTime.now());
//     }).toList();

//     await saveMessages(chatId: chatId, messages: next);
//   }

//   Future<void> editMessage({
//     required String chatId,
//     required String messageId,
//     required String text,
//   }) async {
//     final messages = await getMessages(chatId);

//     final next = messages.map((message) {
//       if (message.messageId != messageId) return message;

//       return message.copyWith(
//         text: text,
//         isEdited: true,
//         updatedAt: DateTime.now(),
//       );
//     }).toList();

//     await saveMessages(chatId: chatId, messages: next);
//   }

//   Future<void> deleteMessage({
//     required String chatId,
//     required String messageId,
//   }) async {
//     final messages = await getMessages(chatId);

//     final next = messages.map((message) {
//       if (message.messageId != messageId) return message;

//       return message.copyWith(
//         text: 'This message was deleted',
//         status: 'deleted',
//         isDeleted: true,
//         updatedAt: DateTime.now(),
//       );
//     }).toList();

//     await saveMessages(chatId: chatId, messages: next);
//   }

//   Future<void> markChatRead(String chatId) async {
//     final chats = await getChats();

//     final next = chats.map((chat) {
//       if (chat.chatId != chatId) return chat;

//       return chat.copyWith(unreadCount: 0);
//     }).toList();

//     await saveChats(next);
//   }

//   Future<void> clearAll() async {
//     final prefs = await SharedPreferences.getInstance();

//     final chats = await getChats();

//     for (final chat in chats) {
//       await prefs.remove(messagesKey(chat.chatId));
//     }

//     await prefs.remove(_chatsKey);
//   }
// }

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'local_chat_model.dart';
import 'local_message_model.dart';

class LocalDmStorage {
  /*
    المفاتيح القديمة كانت مشتركة بين جميع الحسابات.
    نحتفظ بها فقط لمسح البيانات القديمة مرة واحدة.
  */
  static const String _legacyChatsKey =
      'local_dm_chats_v1';

  static const String _legacyMessagesPrefix =
      'local_dm_messages_v1_';

  /*
    الإصدار الجديد:
    كل حساب يملك مساحة تخزين مستقلة.
  */
  static const String _chatsPrefix =
      'local_dm_chats_v2_';

  static const String _messagesPrefix =
      'local_dm_messages_v2_';

  String _currentUserId = '';

  bool get hasCurrentUser =>
      _currentUserId.trim().isNotEmpty;

  String get currentUserId =>
      _currentUserId;

  /*
    يجب استدعاؤها بعد نجاح تسجيل الدخول.
  */
  Future<void> setCurrentUser(
    String userId,
  ) async {
    final cleanUserId =
        userId.trim();

    if (cleanUserId.isEmpty) {
      clearCurrentUser();
      return;
    }

    _currentUserId =
        cleanUserId;

    /*
      نمسح التخزين القديم المشترك لأنه لا يمكن
      معرفة الحساب الذي كان يخصه بأمان.
    */
    await _clearLegacySharedStorage();
  }

  /*
    تستخدم عند تسجيل الخروج.

    لا تحذف محادثات الحساب من الجهاز،
    بل تفصل الحساب الحالي فقط.
  */
  void clearCurrentUser() {
    _currentUserId = '';
  }

  String _safeKeyPart(
    String value,
  ) {
    return value
        .trim()
        .replaceAll(
          RegExp(r'[^a-zA-Z0-9_-]'),
          '_',
        );
  }

  String get _userKeyPart =>
      _safeKeyPart(
        _currentUserId,
      );

  String get chatsKey {
    if (!hasCurrentUser) {
      return '';
    }

    return '$_chatsPrefix$_userKeyPart';
  }

  String messagesKey(
    String chatId,
  ) {
    if (!hasCurrentUser) {
      return '';
    }

    final cleanChatId =
        _safeKeyPart(chatId);

    if (cleanChatId.isEmpty) {
      return '';
    }

    return '${_messagesPrefix}${_userKeyPart}_$cleanChatId';
  }

  Future<List<LocalChatModel>>
      getChats() async {
    if (!hasCurrentUser) {
      return [];
    }

    final key =
        chatsKey;

    if (key.isEmpty) {
      return [];
    }

    final prefs =
        await SharedPreferences.getInstance();

    final raw =
        prefs.getString(key);

    if (raw == null ||
        raw.trim().isEmpty) {
      return [];
    }

    try {
      final decoded =
          jsonDecode(raw);

      if (decoded is! List) {
        return [];
      }

      final chats = decoded
          .whereType<Map>()
          .map(
            (item) =>
                LocalChatModel.fromMap(
              Map<String, dynamic>.from(
                item,
              ),
            ),
          )
          .where(
            (chat) =>
                chat.chatId.isNotEmpty,
          )
          .toList();

      _sortChats(chats);

      return chats;
    } catch (error) {
      return [];
    }
  }

  Future<void> saveChats(
    List<LocalChatModel> chats,
  ) async {
    if (!hasCurrentUser) {
      return;
    }

    final key =
        chatsKey;

    if (key.isEmpty) {
      return;
    }

    final prefs =
        await SharedPreferences.getInstance();

    final sorted =
        List<LocalChatModel>.from(
      chats,
    );

    _sortChats(sorted);

    final encoded =
        jsonEncode(
      sorted
          .map(
            (chat) =>
                chat.toMap(),
          )
          .toList(),
    );

    await prefs.setString(
      key,
      encoded,
    );
  }

  void _sortChats(
    List<LocalChatModel> chats,
  ) {
    chats.sort(
      (
        a,
        b,
      ) {
        if (a.isPinned !=
            b.isPinned) {
          return a.isPinned
              ? -1
              : 1;
        }

        return b.lastMessageAt
            .compareTo(
          a.lastMessageAt,
        );
      },
    );
  }

  Future<List<LocalMessageModel>>
      getMessages(
    String chatId,
  ) async {
    if (!hasCurrentUser ||
        chatId.trim().isEmpty) {
      return [];
    }

    final key =
        messagesKey(chatId);

    if (key.isEmpty) {
      return [];
    }

    final prefs =
        await SharedPreferences.getInstance();

    final raw =
        prefs.getString(key);

    if (raw == null ||
        raw.trim().isEmpty) {
      return [];
    }

    try {
      final decoded =
          jsonDecode(raw);

      if (decoded is! List) {
        return [];
      }

      final messages = decoded
          .whereType<Map>()
          .map(
            (item) =>
                LocalMessageModel.fromMap(
              Map<String, dynamic>.from(
                item,
              ),
            ),
          )
          .where(
            (message) =>
                message.messageId
                    .isNotEmpty,
          )
          .toList();

      messages.sort(
        (
          a,
          b,
        ) =>
            a.createdAt.compareTo(
          b.createdAt,
        ),
      );

      return messages;
    } catch (error) {
      return [];
    }
  }

  Future<void> saveMessages({
    required String chatId,
    required List<LocalMessageModel>
        messages,
  }) async {
    if (!hasCurrentUser ||
        chatId.trim().isEmpty) {
      return;
    }

    final key =
        messagesKey(chatId);

    if (key.isEmpty) {
      return;
    }

    final prefs =
        await SharedPreferences.getInstance();

    final sorted =
        List<LocalMessageModel>.from(
      messages,
    )..sort(
            (
              a,
              b,
            ) =>
                a.createdAt.compareTo(
              b.createdAt,
            ),
          );

    final encoded =
        jsonEncode(
      sorted
          .map(
            (message) =>
                message.toMap(),
          )
          .toList(),
    );

    await prefs.setString(
      key,
      encoded,
    );
  }

  Future<void> upsertChat(
    LocalChatModel chat,
  ) async {
    if (!hasCurrentUser ||
        chat.chatId.trim().isEmpty) {
      return;
    }

    final chats =
        await getChats();

    final index =
        chats.indexWhere(
      (item) =>
          item.chatId ==
          chat.chatId,
    );

    if (index >= 0) {
      chats[index] = chat;
    } else {
      chats.add(chat);
    }

    await saveChats(chats);
  }

  Future<void> deleteChat(
    String chatId,
  ) async {
    if (!hasCurrentUser ||
        chatId.trim().isEmpty) {
      return;
    }

    final prefs =
        await SharedPreferences.getInstance();

    final chats =
        await getChats();

    final nextChats =
        chats
            .where(
              (chat) =>
                  chat.chatId != chatId,
            )
            .toList();

    await saveChats(
      nextChats,
    );

    final key =
        messagesKey(chatId);

    if (key.isNotEmpty) {
      await prefs.remove(key);
    }
  }

  Future<void> clearChatMessages(
    String chatId,
  ) async {
    if (!hasCurrentUser ||
        chatId.trim().isEmpty) {
      return;
    }

    final prefs =
        await SharedPreferences.getInstance();

    final key =
        messagesKey(chatId);

    if (key.isNotEmpty) {
      await prefs.remove(key);
    }

    final chats =
        await getChats();

    final nextChats =
        chats.map(
      (chat) {
        if (chat.chatId != chatId) {
          return chat;
        }

        return chat.copyWith(
          lastMessageText: '',
          lastMessageType: 'text',
          unreadCount: 0,
          lastMessageAt:
              DateTime.now(),
        );
      },
    ).toList();

    await saveChats(
      nextChats,
    );
  }

  Future<void> addMessage(
    LocalMessageModel message,
  ) async {
    if (!hasCurrentUser ||
        message.chatId
            .trim()
            .isEmpty) {
      return;
    }

    final messages =
        await getMessages(
      message.chatId,
    );

    final exists =
        messages.any(
      (item) {
        return item.messageId ==
                message.messageId ||
            (message.tempId != null &&
                message.tempId!
                    .isNotEmpty &&
                item.tempId ==
                    message.tempId);
      },
    );

    if (!exists) {
      messages.add(message);
    }

    await saveMessages(
      chatId:
          message.chatId,
      messages:
          messages,
    );
  }

  Future<void> upsertMessage(
    LocalMessageModel message,
  ) async {
    if (!hasCurrentUser ||
        message.chatId
            .trim()
            .isEmpty) {
      return;
    }

    final messages =
        await getMessages(
      message.chatId,
    );

    final index =
        messages.indexWhere(
      (item) {
        return item.messageId ==
                message.messageId ||
            (message.tempId != null &&
                message.tempId!
                    .isNotEmpty &&
                item.tempId ==
                    message.tempId);
      },
    );

    if (index >= 0) {
      messages[index] =
          message;
    } else {
      messages.add(message);
    }

    await saveMessages(
      chatId:
          message.chatId,
      messages:
          messages,
    );
  }

  Future<void> updateMessageStatus({
    required String chatId,
    required String messageId,
    String? tempId,
    required String status,
  }) async {
    if (!hasCurrentUser ||
        chatId.trim().isEmpty) {
      return;
    }

    final messages =
        await getMessages(chatId);

    final next =
        messages.map(
      (message) {
        final matchByMessageId =
            message.messageId ==
                messageId;

        final matchByTempId =
            tempId != null &&
                tempId.isNotEmpty &&
                message.tempId ==
                    tempId;

        if (!matchByMessageId &&
            !matchByTempId) {
          return message;
        }

        return message.copyWith(
          messageId:
              messageId.isNotEmpty
                  ? messageId
                  : message.messageId,
          status: status,
          updatedAt:
              DateTime.now(),
        );
      },
    ).toList();

    await saveMessages(
      chatId: chatId,
      messages: next,
    );
  }

  Future<void> markMessagesSeen({
    required String chatId,
    required List<String> messageIds,
  }) async {
    if (!hasCurrentUser ||
        chatId.trim().isEmpty ||
        messageIds.isEmpty) {
      return;
    }

    final messages =
        await getMessages(chatId);

    final ids =
        messageIds.toSet();

    final next =
        messages.map(
      (message) {
        if (!ids.contains(
          message.messageId,
        )) {
          return message;
        }

        return message.copyWith(
          status: 'seen',
          updatedAt:
              DateTime.now(),
        );
      },
    ).toList();

    await saveMessages(
      chatId: chatId,
      messages: next,
    );
  }

  Future<void> editMessage({
    required String chatId,
    required String messageId,
    required String text,
  }) async {
    if (!hasCurrentUser ||
        chatId.trim().isEmpty ||
        messageId.trim().isEmpty) {
      return;
    }

    final messages =
        await getMessages(chatId);

    final next =
        messages.map(
      (message) {
        if (message.messageId !=
            messageId) {
          return message;
        }

        return message.copyWith(
          text: text,
          isEdited: true,
          updatedAt:
              DateTime.now(),
        );
      },
    ).toList();

    await saveMessages(
      chatId: chatId,
      messages: next,
    );
  }

  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
  }) async {
    if (!hasCurrentUser ||
        chatId.trim().isEmpty ||
        messageId.trim().isEmpty) {
      return;
    }

    final messages =
        await getMessages(chatId);

    final next =
        messages.map(
      (message) {
        if (message.messageId !=
            messageId) {
          return message;
        }

        return message.copyWith(
          text:
              'This message was deleted',
          status: 'deleted',
          isDeleted: true,
          updatedAt:
              DateTime.now(),
        );
      },
    ).toList();

    await saveMessages(
      chatId: chatId,
      messages: next,
    );
  }

  Future<void> markChatRead(
    String chatId,
  ) async {
    if (!hasCurrentUser ||
        chatId.trim().isEmpty) {
      return;
    }

    final chats =
        await getChats();

    final next =
        chats.map(
      (chat) {
        if (chat.chatId !=
            chatId) {
          return chat;
        }

        return chat.copyWith(
          unreadCount: 0,
        );
      },
    ).toList();

    await saveChats(next);
  }

  /*
    يحذف محادثات الحساب الحالي فقط.
  */
  Future<void> clearAll() async {
    if (!hasCurrentUser) {
      return;
    }

    final prefs =
        await SharedPreferences.getInstance();

    final chats =
        await getChats();

    for (final chat in chats) {
      final key =
          messagesKey(
        chat.chatId,
      );

      if (key.isNotEmpty) {
        await prefs.remove(key);
      }
    }

    final currentChatsKey =
        chatsKey;

    if (currentChatsKey.isNotEmpty) {
      await prefs.remove(
        currentChatsKey,
      );
    }
  }

  /*
    حذف مفاتيح التخزين القديمة المشتركة.

    هذا يمنع ظهور قائمة أحمد القديمة بعد تركيب
    نظام التخزين الجديد لأول مرة.
  */
  Future<void>
      _clearLegacySharedStorage() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(
      _legacyChatsKey,
    );

    final legacyMessageKeys =
        prefs
            .getKeys()
            .where(
              (key) =>
                  key.startsWith(
                _legacyMessagesPrefix,
              ),
            )
            .toList();

    for (final key
        in legacyMessageKeys) {
      await prefs.remove(key);
    }
  }
}