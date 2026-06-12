import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/ws_events.dart';
import '../../../core/constants/ws_handlers.dart';
import '../../../core/network/ws_client.dart';
import '../../../core/network/ws_provider.dart';
import '../data/local_chat_model.dart';
import '../data/local_dm_storage.dart';
import '../data/local_message_model.dart';
import 'dm_state.dart';

final dmProvider = StateNotifierProvider<DmController, DmState>((ref) {
  final ws = ref.watch(wsClientProvider);
  return DmController(ws);
});

class DmController extends StateNotifier<DmState> {
  final WsClient ws;
  final LocalDmStorage storage;

  StreamSubscription? _sub;

  DmController(this.ws, {LocalDmStorage? storage})
    : storage = storage ?? LocalDmStorage(),
      super(const DmState()) {
    _listen();
    loadChats();
  }

  String makeChatId(String a, String b) {
    final ids = [a, b]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  String previewText(LocalMessageModel message) {
    if (message.isDeleted) return 'This message was deleted';

    if (message.shared != null) {
      return 'Shared message';
    }

    if (message.type == 'text') {
      return message.text;
    }

    if (message.type == 'image') return 'Photo';
    if (message.type == 'video') return 'Video';
    if (message.type == 'audio') return 'Voice message';
    if (message.type == 'file') return 'File';

    return 'Message';
  }

  Future<void> loadChats() async {
    state = state.copyWith(loading: true, error: null);

    final chats = await storage.getChats();

    state = state.copyWith(loading: false, error: null, chats: chats);
  }

  Future<void> loadMessages(String chatId) async {
    if (chatId.trim().isEmpty) return;

    final messages = await storage.getMessages(chatId);

    final next = Map<String, List<LocalMessageModel>>.from(
      state.messagesByChat,
    );

    next[chatId] = messages;

    state = state.copyWith(messagesByChat: next);
  }

Future<void> openChat(String chatId) async {
  if (chatId.trim().isEmpty) return;

  state = state.copyWith(activeChatId: chatId);

  ws.send({
    'handler': WsHandlers.dmOpen,
    'request_id': const Uuid().v4(),
    'chatId': chatId,
    'chat_id': chatId,
  });

  await storage.markChatRead(chatId);
  await loadMessages(chatId);

  final chats = await storage.getChats();

  state = state.copyWith(activeChatId: chatId, chats: chats);
}
void closeChat() {
  final chatId = state.activeChatId;

  if (chatId != null && chatId.trim().isNotEmpty) {
    ws.send({
      'handler': WsHandlers.dmClose,
      'request_id': const Uuid().v4(),
      'chatId': chatId,
      'chat_id': chatId,
    });
  }

  state = state.copyWith(activeChatId: null);
}
  Future<void> deleteChat(String chatId) async {
    if (chatId.trim().isEmpty) return;

    await storage.deleteChat(chatId);

    final nextMessages = Map<String, List<LocalMessageModel>>.from(
      state.messagesByChat,
    );

    nextMessages.remove(chatId);

    final chats = await storage.getChats();

    state = state.copyWith(
      chats: chats,
      messagesByChat: nextMessages,
      activeChatId: state.activeChatId == chatId ? null : state.activeChatId,
    );
  }

  Future<void> clearChatMessages(String chatId) async {
    if (chatId.trim().isEmpty) return;

    await storage.clearChatMessages(chatId);

    final nextMessages = Map<String, List<LocalMessageModel>>.from(
      state.messagesByChat,
    );

    nextMessages[chatId] = [];

    final chats = await storage.getChats();

    state = state.copyWith(chats: chats, messagesByChat: nextMessages);

    ws.send({
      'handler': WsHandlers.dmClear,
      'request_id': const Uuid().v4(),
      'chatId': chatId,
    });
  }

  Future<void> sendTextMessage({
    required String myUserId,
    required String peerUserId,
    required String peerUsername,
    required String peerPhotoUrl,
    required String text,
    Map<String, dynamic>? replyTo,
    Map<String, dynamic>? shared,
  }) async {
    final body = text.trim();

    if (myUserId.trim().isEmpty || peerUserId.trim().isEmpty) return;
    if (body.isEmpty && shared == null) return;

    final now = DateTime.now();
    final tempId = const Uuid().v4();
    final chatId = makeChatId(myUserId, peerUserId);

    final message = LocalMessageModel(
      messageId: tempId,
      tempId: tempId,
      chatId: chatId,
      fromUserId: myUserId,
      toUserId: peerUserId,
      type: 'text',
      text: body,
      media: null,
      replyTo: replyTo,
      shared: shared,
      status: 'sending',
      isMine: true,
      isEdited: false,
      isDeleted: false,
      createdAt: now,
      updatedAt: now,
    );

    await _saveOutgoingMessage(
      message: message,
      peerUserId: peerUserId,
      peerUsername: peerUsername,
      peerPhotoUrl: peerPhotoUrl,
    );

    ws.send({
      'handler': WsHandlers.dmSend,
      'request_id': const Uuid().v4(),
      'temp_id': tempId,
      'to_user_id': peerUserId,
      'type': 'text',
      'text': body,
      if (replyTo != null) 'replyTo': replyTo,
      if (shared != null) 'shared': shared,
    });
  }

  Future<void> sendMediaMessage({
    required String myUserId,
    required String peerUserId,
    required String peerUsername,
    required String peerPhotoUrl,
    required String type,
    required Map<String, dynamic> media,
    String text = '',
    Map<String, dynamic>? replyTo,
  }) async {
    if (myUserId.trim().isEmpty || peerUserId.trim().isEmpty) return;
    if (!['image', 'video', 'audio', 'file'].contains(type)) return;

    final now = DateTime.now();
    final tempId = const Uuid().v4();
    final chatId = makeChatId(myUserId, peerUserId);

    final message = LocalMessageModel(
      messageId: tempId,
      tempId: tempId,
      chatId: chatId,
      fromUserId: myUserId,
      toUserId: peerUserId,
      type: type,
      text: text.trim(),
      media: media,
      replyTo: replyTo,
      shared: null,
      status: 'sending',
      isMine: true,
      isEdited: false,
      isDeleted: false,
      createdAt: now,
      updatedAt: now,
    );

    await _saveOutgoingMessage(
      message: message,
      peerUserId: peerUserId,
      peerUsername: peerUsername,
      peerPhotoUrl: peerPhotoUrl,
    );

    ws.send({
      'handler': WsHandlers.dmSend,
      'request_id': const Uuid().v4(),
      'temp_id': tempId,
      'to_user_id': peerUserId,
      'type': type,
      'text': text.trim(),
      'media': media,
      if (replyTo != null) 'replyTo': replyTo,
    });
  }

  Future<void> _saveOutgoingMessage({
    required LocalMessageModel message,
    required String peerUserId,
    required String peerUsername,
    required String peerPhotoUrl,
  }) async {
    await storage.upsertMessage(message);

    final chat = LocalChatModel(
      chatId: message.chatId,
      peerUserId: peerUserId,
      peerUsername: peerUsername,
      peerPhotoUrl: peerPhotoUrl,
      lastMessageText: previewText(message),
      lastMessageType: message.type,
      lastMessageAt: message.createdAt,
      unreadCount: 0,
    );

    await storage.upsertChat(chat);

    await loadMessages(message.chatId);
    await loadChats();
  }

  Future<void> editTextMessage({
    required String toUserId,
    required String chatId,
    required String messageId,
    required String text,
  }) async {
    final body = text.trim();

    if (toUserId.trim().isEmpty || chatId.trim().isEmpty) return;
    if (messageId.trim().isEmpty || body.isEmpty) return;

    await storage.editMessage(chatId: chatId, messageId: messageId, text: body);

    await _refreshChatAfterMessageChange(chatId);

    ws.send({
      'handler': WsHandlers.dmEdit,
      'request_id': const Uuid().v4(),
      'to_user_id': toUserId,
      'message_id': messageId,
      'text': body,
    });
  }

  Future<void> deleteMessageForEveryone({
    required String toUserId,
    required String chatId,
    required String messageId,
  }) async {
    if (toUserId.trim().isEmpty || chatId.trim().isEmpty) return;
    if (messageId.trim().isEmpty) return;

    await storage.deleteMessage(chatId: chatId, messageId: messageId);

    await _refreshChatAfterMessageChange(chatId);

    ws.send({
      'handler': WsHandlers.dmDelete,
      'request_id': const Uuid().v4(),
      'to_user_id': toUserId,
      'message_id': messageId,
    });
  }

  void sendTyping({required String toUserId, required bool isTyping}) {
    if (toUserId.trim().isEmpty) return;

    ws.send({
      'handler': WsHandlers.dmTyping,
      'request_id': const Uuid().v4(),
      'to_user_id': toUserId,
      'isTyping': isTyping,
    });
  }

  void markSeen({
    required String toUserId,
    required String chatId,
    required List<String> messageIds,
  }) {
    if (toUserId.trim().isEmpty || chatId.trim().isEmpty) return;
    if (messageIds.isEmpty) return;

    ws.send({
      'handler': WsHandlers.dmSeen,
      'request_id': const Uuid().v4(),
      'to_user_id': toUserId,
      'chatId': chatId,
      'messageIds': messageIds,
    });
  }

  Future<void> shareMessage({
    required String myUserId,
    required String targetUserId,
    required String targetUsername,
    required String targetPhotoUrl,
    required String fromChatUserId,
    required String fromChatUsername,
    required LocalMessageModel originalMessage,
  }) async {
    final shared = {
      'fromChatUserId': fromChatUserId,
      'fromChatUsername': fromChatUsername,
      'originalMessageId': originalMessage.messageId,
      'originalType': originalMessage.type,
      'originalText': originalMessage.text,
      'originalMediaUrl': originalMessage.media?['url']?.toString() ?? '',
    };

    await sendTextMessage(
      myUserId: myUserId,
      peerUserId: targetUserId,
      peerUsername: targetUsername,
      peerPhotoUrl: targetPhotoUrl,
      text: originalMessage.text,
      shared: shared,
    );
  }

  Future<void> _refreshChatAfterMessageChange(String chatId) async {
    final messages = await storage.getMessages(chatId);

    final nextMessages = Map<String, List<LocalMessageModel>>.from(
      state.messagesByChat,
    );

    nextMessages[chatId] = messages;

    final chats = await storage.getChats();

    final chatIndex = chats.indexWhere((chat) => chat.chatId == chatId);

    if (chatIndex >= 0 && messages.isNotEmpty) {
      final last = messages.last;

      chats[chatIndex] = chats[chatIndex].copyWith(
        lastMessageText: previewText(last),
        lastMessageType: last.type,
        lastMessageAt: last.updatedAt,
      );

      await storage.saveChats(chats);
    }

    final nextChats = await storage.getChats();

    state = state.copyWith(chats: nextChats, messagesByChat: nextMessages);
  }

  void _listen() {
    _sub = ws.stream.listen((data) async {
      final handler = data['handler']?.toString();
      final type = data['type']?.toString();

      if (handler == WsEvents.dmSendEvent) {
        if (type == 'success') {
          await _handleSendSuccess(data);
          return;
        }

        await _handleSendError(data);
        return;
      }

      if (handler == WsEvents.dmMessageEvent) {
        await _handleIncomingMessage(data);
        return;
      }

      if (handler == WsEvents.dmDeliveryEvent) {
        await _handleDelivered(data);
        return;
      }

      if (handler == WsEvents.dmSeenEvent) {
        await _handleSeen(data);
        return;
      }

      if (handler == WsEvents.dmTypingEvent) {
        _handleTyping(data);
        return;
      }

      if (handler == WsEvents.dmEditEvent) {
        await _handleEdited(data);
        return;
      }

      if (handler == WsEvents.dmDeleteEvent) {
        await _handleDeleted(data);
        return;
      }

      if (handler == WsEvents.dmClearEvent) {
        return;
      }
    });
  }

  Future<void> _handleSendSuccess(Map<String, dynamic> data) async {
    final messageMap = data['message'] is Map
        ? Map<String, dynamic>.from(data['message'] as Map)
        : <String, dynamic>{};

    final tempId = messageMap['tempId']?.toString() ?? '';
    final messageId = messageMap['messageId']?.toString() ?? '';
    final chatId = messageMap['chatId']?.toString() ?? '';

    final delivered =
        data['delivered'] == true || data['delivered']?.toString() == 'true';

    if (chatId.isEmpty) return;

    await storage.updateMessageStatus(
      chatId: chatId,
      messageId: messageId,
      tempId: tempId,
      status: delivered ? 'delivered' : 'sent',
    );

    await loadMessages(chatId);
    await loadChats();
  }

  Future<void> _handleSendError(Map<String, dynamic> data) async {
    final reason = data['reason']?.toString() ?? 'dm_send_error';

    state = state.copyWith(loading: false, error: reason);
  }

Future<void> _handleIncomingMessage(Map<String, dynamic> data) async {
  final messageMap = data['message'] is Map
      ? Map<String, dynamic>.from(data['message'] as Map)
      : <String, dynamic>{};

  if (messageMap.isEmpty) return;

  final message = _messageFromServer(messageMap);

  final isActive = state.activeChatId == message.chatId;

  await storage.upsertMessage(message);

  final peerUserId = message.fromUserId;

  String readNonEmpty(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text;
  }

  final fromUsernameFromEvent = readNonEmpty(data['fromUsername']);
  final fromUsernameFromMessage = readNonEmpty(messageMap['fromUsername']);

  final fromPhotoFromEvent = readNonEmpty(data['fromPhotoUrl']);
  final fromPhotoFromMessage = readNonEmpty(messageMap['fromPhotoUrl']);

  final peerUsername = fromUsernameFromEvent.isNotEmpty
      ? fromUsernameFromEvent
      : fromUsernameFromMessage.isNotEmpty
      ? fromUsernameFromMessage
      : peerUserId;

  final peerPhotoUrl = fromPhotoFromEvent.isNotEmpty
      ? fromPhotoFromEvent
      : fromPhotoFromMessage.isNotEmpty
      ? fromPhotoFromMessage
      : '';

  final chats = await storage.getChats();

  final index = chats.indexWhere((chat) => chat.chatId == message.chatId);

  final unread = isActive
      ? 0
      : index >= 0
      ? chats[index].unreadCount + 1
      : 1;

  final chat = LocalChatModel(
    chatId: message.chatId,
    peerUserId: peerUserId,
    peerUsername: peerUsername,
    peerPhotoUrl: peerPhotoUrl,
    lastMessageText: previewText(message),
    lastMessageType: message.type,
    lastMessageAt: message.createdAt,
    unreadCount: unread,
  );

  await storage.upsertChat(chat);

if (isActive && state.activeChatId == message.chatId) {
  await storage.markChatRead(message.chatId);

  markSeen(
    toUserId: message.fromUserId,
    chatId: message.chatId,
    messageIds: [message.messageId],
  );
}

  await loadMessages(message.chatId);
  await loadChats();
}
  LocalMessageModel _messageFromServer(Map<String, dynamic> map) {
    final fromUserId = map['fromUserId']?.toString() ?? '';
    final toUserId = map['toUserId']?.toString() ?? '';

    return LocalMessageModel(
      messageId: map['messageId']?.toString() ?? const Uuid().v4(),
      tempId: map['tempId']?.toString(),
      chatId: map['chatId']?.toString() ?? makeChatId(fromUserId, toUserId),
      fromUserId: fromUserId,
      toUserId: toUserId,
      type: map['type']?.toString() ?? 'text',
      text: map['text']?.toString() ?? '',
      media: map['media'] is Map
          ? Map<String, dynamic>.from(map['media'] as Map)
          : null,
      replyTo: map['replyTo'] is Map
          ? Map<String, dynamic>.from(map['replyTo'] as Map)
          : null,
      shared: map['shared'] is Map
          ? Map<String, dynamic>.from(map['shared'] as Map)
          : null,
      status: 'delivered',
      isMine: false,
      isEdited: map['isEdited'] == true,
      isDeleted: map['isDeleted'] == true,
      createdAt:
          DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(map['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Future<void> _handleDelivered(Map<String, dynamic> data) async {
    final chatId = data['chatId']?.toString() ?? '';
    final messageId = data['messageId']?.toString() ?? '';
    final tempId = data['tempId']?.toString();

    if (chatId.isEmpty) return;

    await storage.updateMessageStatus(
      chatId: chatId,
      messageId: messageId,
      tempId: tempId,
      status: 'delivered',
    );

    await loadMessages(chatId);
    await loadChats();
  }

  Future<void> _handleSeen(Map<String, dynamic> data) async {
    final chatId = data['chatId']?.toString() ?? '';

    final messageIds = data['messageIds'] is List
        ? (data['messageIds'] as List)
              .map((item) => item.toString())
              .where((id) => id.isNotEmpty)
              .toList()
        : <String>[];

    if (chatId.isEmpty || messageIds.isEmpty) return;

    await storage.markMessagesSeen(chatId: chatId, messageIds: messageIds);

    await loadMessages(chatId);
  }

  void _handleTyping(Map<String, dynamic> data) {
    final fromUserId = data['fromUserId']?.toString() ?? '';
    final isTyping =
        data['isTyping'] == true || data['isTyping']?.toString() == 'true';

    if (fromUserId.isEmpty) return;

    final typing = Set<String>.from(state.typingUserIds);

    if (isTyping) {
      typing.add(fromUserId);
    } else {
      typing.remove(fromUserId);
    }

    state = state.copyWith(typingUserIds: typing);
  }

  Future<void> _handleEdited(Map<String, dynamic> data) async {
    final fromUserId = data['fromUserId']?.toString() ?? '';
    final toUserId = data['toUserId']?.toString() ?? '';
    final chatId = makeChatId(fromUserId, toUserId);

    final messageId = data['messageId']?.toString() ?? '';
    final text = data['text']?.toString() ?? '';

    if (chatId.trim().isEmpty || messageId.isEmpty || text.isEmpty) return;

    await storage.editMessage(chatId: chatId, messageId: messageId, text: text);

    await _refreshChatAfterMessageChange(chatId);
  }

  Future<void> _handleDeleted(Map<String, dynamic> data) async {
    final fromUserId = data['fromUserId']?.toString() ?? '';
    final toUserId = data['toUserId']?.toString() ?? '';
    final chatId = makeChatId(fromUserId, toUserId);

    final messageId = data['messageId']?.toString() ?? '';

    if (chatId.trim().isEmpty || messageId.isEmpty) return;

    await storage.deleteMessage(chatId: chatId, messageId: messageId);

    await _refreshChatAfterMessageChange(chatId);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
