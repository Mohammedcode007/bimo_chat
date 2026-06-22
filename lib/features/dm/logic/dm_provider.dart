// import 'dart:async';

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:uuid/uuid.dart';

// import '../../../core/constants/ws_events.dart';
// import '../../../core/constants/ws_handlers.dart';
// import '../../../core/network/ws_background_controller.dart';
// import '../../../core/network/ws_event_bus.dart';

// import '../data/local_chat_model.dart';
// import '../data/local_dm_storage.dart';
// import '../data/local_message_model.dart';
// import 'dm_state.dart';

// final dmProvider = StateNotifierProvider<DmController, DmState>((ref) {
//   return DmController();
// });

// class DmController extends StateNotifier<DmState> {
//   final LocalDmStorage storage;

//   StreamSubscription? _sub;

//   DmController({LocalDmStorage? storage})
//       : storage = storage ?? LocalDmStorage(),
//         super(const DmState()) {
//     _listen();
//     loadChats();
//   }

//   String makeChatId(String a, String b) {
//     final ids = [a, b]..sort();
//     return '${ids[0]}_${ids[1]}';
//   }

//   String previewText(LocalMessageModel message) {
//     if (message.isDeleted) return 'This message was deleted';

//     if (message.shared != null) {
//       return 'Shared message';
//     }

//     if (message.type == 'text') {
//       return message.text;
//     }

//     if (message.type == 'image') return 'Photo';
//     if (message.type == 'video') return 'Video';
//     if (message.type == 'audio') return 'Voice message';
//     if (message.type == 'file') return 'File';

//     return 'Message';
//   }

//   Future<void> loadChats() async {
//     state = state.copyWith(loading: true, error: null);

//     final chats = await storage.getChats();

//     state = state.copyWith(loading: false, error: null, chats: chats);
//   }

//   Future<void> loadMessages(String chatId) async {
//     if (chatId.trim().isEmpty) return;

//     final messages = await storage.getMessages(chatId);

//     final next = Map<String, List<LocalMessageModel>>.from(
//       state.messagesByChat,
//     );

//     next[chatId] = messages;

//     state = state.copyWith(messagesByChat: next);
//   }

//   Future<void> openChat(String chatId) async {
//     if (chatId.trim().isEmpty) return;

//     state = state.copyWith(activeChatId: chatId);

//     sendBackgroundWs({
//       'handler': WsHandlers.dmOpen,
//       'request_id': const Uuid().v4(),
//       'chatId': chatId,
//       'chat_id': chatId,
//     });

//     await storage.markChatRead(chatId);
//     await loadMessages(chatId);

//     final chats = await storage.getChats();

//     state = state.copyWith(activeChatId: chatId, chats: chats);
//   }

//   void closeChat() {
//     final chatId = state.activeChatId;

//     if (chatId != null && chatId.trim().isNotEmpty) {
//       sendBackgroundWs({
//         'handler': WsHandlers.dmClose,
//         'request_id': const Uuid().v4(),
//         'chatId': chatId,
//         'chat_id': chatId,
//       });
//     }

//     state = state.copyWith(activeChatId: null);
//   }

//   Future<void> deleteChat(String chatId) async {
//     if (chatId.trim().isEmpty) return;

//     await storage.deleteChat(chatId);

//     final nextMessages = Map<String, List<LocalMessageModel>>.from(
//       state.messagesByChat,
//     );

//     nextMessages.remove(chatId);

//     final chats = await storage.getChats();

//     state = state.copyWith(
//       chats: chats,
//       messagesByChat: nextMessages,
//       activeChatId: state.activeChatId == chatId ? null : state.activeChatId,
//     );
//   }

//   Future<void> clearChatMessages(String chatId) async {
//     if (chatId.trim().isEmpty) return;

//     await storage.clearChatMessages(chatId);

//     final nextMessages = Map<String, List<LocalMessageModel>>.from(
//       state.messagesByChat,
//     );

//     nextMessages[chatId] = [];

//     final chats = await storage.getChats();

//     state = state.copyWith(chats: chats, messagesByChat: nextMessages);

//     sendBackgroundWs({
//       'handler': WsHandlers.dmClear,
//       'request_id': const Uuid().v4(),
//       'chatId': chatId,
//     });
//   }

//   Future<void> sendTextMessage({
//     required String myUserId,
//     required String peerUserId,
//     required String peerUsername,
//     required String peerPhotoUrl,
//     required String text,
//     Map<String, dynamic>? replyTo,
//     Map<String, dynamic>? shared,
//   }) async {
//     final body = text.trim();

//     if (myUserId.trim().isEmpty || peerUserId.trim().isEmpty) return;
//     if (body.isEmpty && shared == null) return;

//     final now = DateTime.now();
//     final tempId = const Uuid().v4();
//     final chatId = makeChatId(myUserId, peerUserId);

//     final message = LocalMessageModel(
//       messageId: tempId,
//       tempId: tempId,
//       chatId: chatId,
//       fromUserId: myUserId,
//       toUserId: peerUserId,
//       type: 'text',
//       text: body,
//       media: null,
//       replyTo: replyTo,
//       shared: shared,
//       status: 'sending',
//       isMine: true,
//       isEdited: false,
//       isDeleted: false,
//       createdAt: now,
//       updatedAt: now,
//     );

//     await _saveOutgoingMessage(
//       message: message,
//       peerUserId: peerUserId,
//       peerUsername: peerUsername,
//       peerPhotoUrl: peerPhotoUrl,
//     );

//     sendBackgroundWs({
//       'handler': WsHandlers.dmSend,
//       'request_id': const Uuid().v4(),
//       'temp_id': tempId,
//       'to_user_id': peerUserId,
//       'type': 'text',
//       'text': body,
//       if (replyTo != null) 'replyTo': replyTo,
//       if (shared != null) 'shared': shared,
//     });
//   }

//   Future<void> sendMediaMessage({
//     required String myUserId,
//     required String peerUserId,
//     required String peerUsername,
//     required String peerPhotoUrl,
//     required String type,
//     required Map<String, dynamic> media,
//     String text = '',
//     Map<String, dynamic>? replyTo,
//   }) async {
//     if (myUserId.trim().isEmpty || peerUserId.trim().isEmpty) return;
//     if (!['image', 'video', 'audio', 'file'].contains(type)) return;

//     final now = DateTime.now();
//     final tempId = const Uuid().v4();
//     final chatId = makeChatId(myUserId, peerUserId);

//     final message = LocalMessageModel(
//       messageId: tempId,
//       tempId: tempId,
//       chatId: chatId,
//       fromUserId: myUserId,
//       toUserId: peerUserId,
//       type: type,
//       text: text.trim(),
//       media: media,
//       replyTo: replyTo,
//       shared: null,
//       status: 'sending',
//       isMine: true,
//       isEdited: false,
//       isDeleted: false,
//       createdAt: now,
//       updatedAt: now,
//     );

//     await _saveOutgoingMessage(
//       message: message,
//       peerUserId: peerUserId,
//       peerUsername: peerUsername,
//       peerPhotoUrl: peerPhotoUrl,
//     );

//     sendBackgroundWs({
//       'handler': WsHandlers.dmSend,
//       'request_id': const Uuid().v4(),
//       'temp_id': tempId,
//       'to_user_id': peerUserId,
//       'type': type,
//       'text': text.trim(),
//       'media': media,
//       if (replyTo != null) 'replyTo': replyTo,
//     });
//   }

//   Future<void> sendMediaBase64Message({
//     required String myUserId,
//     required String peerUserId,
//     required String peerUsername,
//     required String peerPhotoUrl,
//     required String type,
//     required String mediaBase64,
//     required String fileName,
//     required String mimeType,
//     int sizeBytes = 0,
//     String text = '',
//     Map<String, dynamic>? replyTo,
//   }) async {
//     if (myUserId.trim().isEmpty || peerUserId.trim().isEmpty) return;
//     if (!['image', 'video', 'audio', 'file'].contains(type)) return;
//     if (mediaBase64.trim().isEmpty) return;

//     final now = DateTime.now();
//     final tempId = const Uuid().v4();
//     final chatId = makeChatId(myUserId, peerUserId);

//     final media = {
//       'url': '',
//       'base64': mediaBase64,
//       'fileName': fileName,
//       'mimeType': mimeType,
//       'sizeBytes': sizeBytes,
//     };

//     final message = LocalMessageModel(
//       messageId: tempId,
//       tempId: tempId,
//       chatId: chatId,
//       fromUserId: myUserId,
//       toUserId: peerUserId,
//       type: type,
//       text: text.trim(),
//       media: media,
//       replyTo: replyTo,
//       shared: null,
//       status: 'sending',
//       isMine: true,
//       isEdited: false,
//       isDeleted: false,
//       createdAt: now,
//       updatedAt: now,
//     );

//     await _saveOutgoingMessage(
//       message: message,
//       peerUserId: peerUserId,
//       peerUsername: peerUsername,
//       peerPhotoUrl: peerPhotoUrl,
//     );

//     sendBackgroundWs({
//       'handler': WsHandlers.dmSend,
//       'request_id': tempId,
//       'temp_id': tempId,
//       'to_user_id': peerUserId,
//       'chatId': chatId,
//       'chat_id': chatId,
//       'type': type,
//       'text': text.trim(),
//       'mediaBase64': mediaBase64,
//       'media': {
//         'fileName': fileName,
//         'mimeType': mimeType,
//         'sizeBytes': sizeBytes,
//       },
//       if (replyTo != null) 'replyTo': replyTo,
//     });
//   }

//   Future<void> _saveOutgoingMessage({
//     required LocalMessageModel message,
//     required String peerUserId,
//     required String peerUsername,
//     required String peerPhotoUrl,
//   }) async {
//     await storage.upsertMessage(message);

//     final chat = LocalChatModel(
//       chatId: message.chatId,
//       peerUserId: peerUserId,
//       peerUsername: peerUsername,
//       peerPhotoUrl: peerPhotoUrl,
//       lastMessageText: previewText(message),
//       lastMessageType: message.type,
//       lastMessageAt: message.createdAt,
//       unreadCount: 0,
//     );

//     await storage.upsertChat(chat);

//     await loadMessages(message.chatId);
//     await loadChats();
//   }

//   Future<void> editTextMessage({
//     required String toUserId,
//     required String chatId,
//     required String messageId,
//     required String text,
//   }) async {
//     final body = text.trim();

//     if (toUserId.trim().isEmpty || chatId.trim().isEmpty) return;
//     if (messageId.trim().isEmpty || body.isEmpty) return;

//     await storage.editMessage(chatId: chatId, messageId: messageId, text: body);

//     await _refreshChatAfterMessageChange(chatId);

//     sendBackgroundWs({
//       'handler': WsHandlers.dmEdit,
//       'request_id': const Uuid().v4(),
//       'to_user_id': toUserId,
//       'message_id': messageId,
//       'text': body,
//     });
//   }

//   Future<void> deleteMessageForEveryone({
//     required String toUserId,
//     required String chatId,
//     required String messageId,
//   }) async {
//     if (toUserId.trim().isEmpty || chatId.trim().isEmpty) return;
//     if (messageId.trim().isEmpty) return;

//     await storage.deleteMessage(chatId: chatId, messageId: messageId);

//     await _refreshChatAfterMessageChange(chatId);

//     sendBackgroundWs({
//       'handler': WsHandlers.dmDelete,
//       'request_id': const Uuid().v4(),
//       'to_user_id': toUserId,
//       'message_id': messageId,
//     });
//   }

//   void sendTyping({required String toUserId, required bool isTyping}) {
//     if (toUserId.trim().isEmpty) return;

//     sendBackgroundWs({
//       'handler': WsHandlers.dmTyping,
//       'request_id': const Uuid().v4(),
//       'to_user_id': toUserId,
//       'isTyping': isTyping,
//     });
//   }

//   void markSeen({
//     required String toUserId,
//     required String chatId,
//     required List<String> messageIds,
//   }) {
//     if (toUserId.trim().isEmpty || chatId.trim().isEmpty) return;
//     if (messageIds.isEmpty) return;

//     sendBackgroundWs({
//       'handler': WsHandlers.dmSeen,
//       'request_id': const Uuid().v4(),
//       'to_user_id': toUserId,
//       'chatId': chatId,
//       'messageIds': messageIds,
//     });
//   }

//   Future<void> shareMessage({
//     required String myUserId,
//     required String targetUserId,
//     required String targetUsername,
//     required String targetPhotoUrl,
//     required String fromChatUserId,
//     required String fromChatUsername,
//     required LocalMessageModel originalMessage,
//   }) async {
//     final shared = {
//       'fromChatUserId': fromChatUserId,
//       'fromChatUsername': fromChatUsername,
//       'originalMessageId': originalMessage.messageId,
//       'originalType': originalMessage.type,
//       'originalText': originalMessage.text,
//       'originalMediaUrl': originalMessage.media?['url']?.toString() ?? '',
//     };

//     await sendTextMessage(
//       myUserId: myUserId,
//       peerUserId: targetUserId,
//       peerUsername: targetUsername,
//       peerPhotoUrl: targetPhotoUrl,
//       text: originalMessage.text,
//       shared: shared,
//     );
//   }

//   Future<void> _refreshChatAfterMessageChange(String chatId) async {
//     final messages = await storage.getMessages(chatId);

//     final nextMessages = Map<String, List<LocalMessageModel>>.from(
//       state.messagesByChat,
//     );

//     nextMessages[chatId] = messages;

//     final chats = await storage.getChats();

//     final chatIndex = chats.indexWhere((chat) => chat.chatId == chatId);

//     if (chatIndex >= 0 && messages.isNotEmpty) {
//       final last = messages.last;

//       chats[chatIndex] = chats[chatIndex].copyWith(
//         lastMessageText: previewText(last),
//         lastMessageType: last.type,
//         lastMessageAt: last.updatedAt,
//       );

//       await storage.saveChats(chats);
//     }

//     final nextChats = await storage.getChats();

//     state = state.copyWith(chats: nextChats, messagesByChat: nextMessages);
//   }

//   void _listen() {
//     _sub?.cancel();

//     _sub = WsEventBus.instance.stream.listen((data) async {
//       final handler = data['handler']?.toString();
//       final type = data['type']?.toString();

//       if (handler == WsEvents.dmSendEvent) {
//         if (type == 'success') {
//           await _handleSendSuccess(data);
//           return;
//         }

//         await _handleSendError(data);
//         return;
//       }

//       if (handler == WsEvents.dmMessageEvent) {
//         await _handleIncomingMessage(data);
//         return;
//       }

//       if (handler == WsEvents.dmDeliveryEvent) {
//         await _handleDelivered(data);
//         return;
//       }

//       if (handler == WsEvents.dmSeenEvent) {
//         await _handleSeen(data);
//         return;
//       }

//       if (handler == WsEvents.dmTypingEvent) {
//         _handleTyping(data);
//         return;
//       }

//       if (handler == WsEvents.dmEditEvent) {
//         await _handleEdited(data);
//         return;
//       }

//       if (handler == WsEvents.dmDeleteEvent) {
//         await _handleDeleted(data);
//         return;
//       }

//       if (handler == WsEvents.dmClearEvent) {
//         return;
//       }
//     });
//   }

//   Future<void> _handleSendSuccess(Map<String, dynamic> data) async {
//     final messageMap = data['message'] is Map
//         ? Map<String, dynamic>.from(data['message'] as Map)
//         : <String, dynamic>{};

//     final tempId = messageMap['tempId']?.toString() ?? '';
//     final messageId = messageMap['messageId']?.toString() ?? '';
//     final chatId = messageMap['chatId']?.toString() ?? '';

//     final delivered =
//         data['delivered'] == true || data['delivered']?.toString() == 'true';

//     if (chatId.isEmpty) return;

//     if (messageMap.isNotEmpty) {
//       final serverMessage = LocalMessageModel(
//         messageId: messageId.isNotEmpty ? messageId : const Uuid().v4(),
//         tempId: tempId.isNotEmpty ? tempId : null,
//         chatId: chatId,
//         fromUserId: messageMap['fromUserId']?.toString() ?? '',
//         toUserId: messageMap['toUserId']?.toString() ?? '',
//         type: messageMap['type']?.toString() ?? 'text',
//         text: messageMap['text']?.toString() ?? '',
//         media: messageMap['media'] is Map
//             ? Map<String, dynamic>.from(messageMap['media'] as Map)
//             : null,
//         replyTo: messageMap['replyTo'] is Map
//             ? Map<String, dynamic>.from(messageMap['replyTo'] as Map)
//             : null,
//         shared: messageMap['shared'] is Map
//             ? Map<String, dynamic>.from(messageMap['shared'] as Map)
//             : null,
//         status: delivered ? 'delivered' : 'sent',
//         isMine: true,
//         isEdited: messageMap['isEdited'] == true,
//         isDeleted: messageMap['isDeleted'] == true,
//         createdAt:
//             DateTime.tryParse(messageMap['createdAt']?.toString() ?? '') ??
//                 DateTime.now(),
//         updatedAt:
//             DateTime.tryParse(messageMap['updatedAt']?.toString() ?? '') ??
//                 DateTime.now(),
//       );

//       await storage.upsertMessage(serverMessage);
//     }

//     await storage.updateMessageStatus(
//       chatId: chatId,
//       messageId: messageId,
//       tempId: tempId,
//       status: delivered ? 'delivered' : 'sent',
//     );

//     await loadMessages(chatId);
//     await loadChats();
//   }

//   Future<void> _handleSendError(Map<String, dynamic> data) async {
//     final reason = data['reason']?.toString() ?? 'dm_send_error';

//     state = state.copyWith(loading: false, error: reason);
//   }

//   Future<void> _handleIncomingMessage(Map<String, dynamic> data) async {
//     final messageMap = data['message'] is Map
//         ? Map<String, dynamic>.from(data['message'] as Map)
//         : <String, dynamic>{};

//     if (messageMap.isEmpty) return;

//     final message = _messageFromServer(messageMap);

//     final isActive = state.activeChatId == message.chatId;

//     await storage.upsertMessage(message);

//     final peerUserId = message.fromUserId;

//     String readNonEmpty(dynamic value) {
//       final text = value?.toString().trim() ?? '';
//       return text;
//     }

//     final fromUsernameFromEvent = readNonEmpty(data['fromUsername']);
//     final fromUsernameFromMessage = readNonEmpty(messageMap['fromUsername']);

//     final fromPhotoFromEvent = readNonEmpty(data['fromPhotoUrl']);
//     final fromPhotoFromMessage = readNonEmpty(messageMap['fromPhotoUrl']);

//     final peerUsername = fromUsernameFromEvent.isNotEmpty
//         ? fromUsernameFromEvent
//         : fromUsernameFromMessage.isNotEmpty
//             ? fromUsernameFromMessage
//             : peerUserId;

//     final peerPhotoUrl = fromPhotoFromEvent.isNotEmpty
//         ? fromPhotoFromEvent
//         : fromPhotoFromMessage.isNotEmpty
//             ? fromPhotoFromMessage
//             : '';

//     final chats = await storage.getChats();

//     final index = chats.indexWhere((chat) => chat.chatId == message.chatId);

//     final unread = isActive
//         ? 0
//         : index >= 0
//             ? chats[index].unreadCount + 1
//             : 1;

//     final chat = LocalChatModel(
//       chatId: message.chatId,
//       peerUserId: peerUserId,
//       peerUsername: peerUsername,
//       peerPhotoUrl: peerPhotoUrl,
//       lastMessageText: previewText(message),
//       lastMessageType: message.type,
//       lastMessageAt: message.createdAt,
//       unreadCount: unread,
//     );

//     await storage.upsertChat(chat);

//     if (isActive && state.activeChatId == message.chatId) {
//       await storage.markChatRead(message.chatId);

//       markSeen(
//         toUserId: message.fromUserId,
//         chatId: message.chatId,
//         messageIds: [message.messageId],
//       );
//     }

//     await loadMessages(message.chatId);
//     await loadChats();
//   }

//   LocalMessageModel _messageFromServer(Map<String, dynamic> map) {
//     final fromUserId = map['fromUserId']?.toString() ?? '';
//     final toUserId = map['toUserId']?.toString() ?? '';

//     return LocalMessageModel(
//       messageId: map['messageId']?.toString() ?? const Uuid().v4(),
//       tempId: map['tempId']?.toString(),
//       chatId: map['chatId']?.toString() ?? makeChatId(fromUserId, toUserId),
//       fromUserId: fromUserId,
//       toUserId: toUserId,
//       type: map['type']?.toString() ?? 'text',
//       text: map['text']?.toString() ?? '',
//       media: map['media'] is Map
//           ? Map<String, dynamic>.from(map['media'] as Map)
//           : null,
//       replyTo: map['replyTo'] is Map
//           ? Map<String, dynamic>.from(map['replyTo'] as Map)
//           : null,
//       shared: map['shared'] is Map
//           ? Map<String, dynamic>.from(map['shared'] as Map)
//           : null,
//       status: 'delivered',
//       isMine: false,
//       isEdited: map['isEdited'] == true,
//       isDeleted: map['isDeleted'] == true,
//       createdAt:
//           DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
//               DateTime.now(),
//       updatedAt:
//           DateTime.tryParse(map['updatedAt']?.toString() ?? '') ??
//               DateTime.now(),
//     );
//   }

//   Future<void> _handleDelivered(Map<String, dynamic> data) async {
//     final chatId = data['chatId']?.toString() ?? '';
//     final messageId = data['messageId']?.toString() ?? '';
//     final tempId = data['tempId']?.toString();

//     if (chatId.isEmpty) return;

//     await storage.updateMessageStatus(
//       chatId: chatId,
//       messageId: messageId,
//       tempId: tempId,
//       status: 'delivered',
//     );

//     await loadMessages(chatId);
//     await loadChats();
//   }

//   Future<void> _handleSeen(Map<String, dynamic> data) async {
//     final chatId = data['chatId']?.toString() ?? '';

//     final messageIds = data['messageIds'] is List
//         ? (data['messageIds'] as List)
//             .map((item) => item.toString())
//             .where((id) => id.isNotEmpty)
//             .toList()
//         : <String>[];

//     if (chatId.isEmpty || messageIds.isEmpty) return;

//     await storage.markMessagesSeen(chatId: chatId, messageIds: messageIds);

//     await loadMessages(chatId);
//   }

//   void _handleTyping(Map<String, dynamic> data) {
//     final fromUserId = data['fromUserId']?.toString() ?? '';
//     final isTyping =
//         data['isTyping'] == true || data['isTyping']?.toString() == 'true';

//     if (fromUserId.isEmpty) return;

//     final typing = Set<String>.from(state.typingUserIds);

//     if (isTyping) {
//       typing.add(fromUserId);
//     } else {
//       typing.remove(fromUserId);
//     }

//     state = state.copyWith(typingUserIds: typing);
//   }

//   Future<void> _handleEdited(Map<String, dynamic> data) async {
//     final fromUserId = data['fromUserId']?.toString() ?? '';
//     final toUserId = data['toUserId']?.toString() ?? '';
//     final chatId = makeChatId(fromUserId, toUserId);

//     final messageId = data['messageId']?.toString() ?? '';
//     final text = data['text']?.toString() ?? '';

//     if (chatId.trim().isEmpty || messageId.isEmpty || text.isEmpty) return;

//     await storage.editMessage(chatId: chatId, messageId: messageId, text: text);

//     await _refreshChatAfterMessageChange(chatId);
//   }

//   Future<void> _handleDeleted(Map<String, dynamic> data) async {
//     final fromUserId = data['fromUserId']?.toString() ?? '';
//     final toUserId = data['toUserId']?.toString() ?? '';
//     final chatId = makeChatId(fromUserId, toUserId);

//     final messageId = data['messageId']?.toString() ?? '';

//     if (chatId.trim().isEmpty || messageId.isEmpty) return;

//     await storage.deleteMessage(chatId: chatId, messageId: messageId);

//     await _refreshChatAfterMessageChange(chatId);
//   }

//   void clearError() {
//     state = state.copyWith(error: null);
//   }

//   @override
//   void dispose() {
//     _sub?.cancel();
//     super.dispose();
//   }
// }

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/ws_events.dart';
import '../../../core/constants/ws_handlers.dart';
import '../../../core/network/ws_background_controller.dart';
import '../../../core/network/ws_event_bus.dart';

import '../../auth/logic/auth_provider.dart';
import '../data/local_chat_model.dart';
import '../data/local_dm_storage.dart';
import '../data/local_message_model.dart';
import 'dm_state.dart';

final dmProvider = StateNotifierProvider<DmController, DmState>((ref) {
  final controller = DmController();

  ref.listen(
    authProvider,
    (previous, next) {
      final nextUserId =
          next.loggedIn
              ? (next.userId ?? '').trim()
              : '';

      if (nextUserId.isNotEmpty) {
        unawaited(
          controller.setCurrentUser(
            nextUserId,
          ),
        );
      } else {
        unawaited(
          controller.clearCurrentSession(),
        );
      }
    },
    fireImmediately: true,
  );

  return controller;
});

class DmController extends StateNotifier<DmState> {
  final LocalDmStorage storage;

  StreamSubscription? _sub;

  String _currentUserId = '';
  int _sessionVersion = 0;

  DmController({
    LocalDmStorage? storage,
  })  : storage = storage ?? LocalDmStorage(),
        super(const DmState()) {
    _listen();
  }

  bool get hasCurrentUser =>
      _currentUserId.trim().isNotEmpty;

  String get currentUserId =>
      _currentUserId;

  Future<void> setCurrentUser(
    String userId,
  ) async {
    final cleanUserId =
        userId.trim();

    if (cleanUserId.isEmpty) {
      await clearCurrentSession();
      return;
    }

    if (_currentUserId ==
        cleanUserId) {
      if (state.chats.isEmpty &&
          !state.loading) {
        await loadChats();
      }

      return;
    }

    final version =
        ++_sessionVersion;

    _currentUserId =
        cleanUserId;

    state = const DmState();

    await storage.setCurrentUser(
      cleanUserId,
    );

    if (version !=
            _sessionVersion ||
        _currentUserId !=
            cleanUserId) {
      return;
    }

    await loadChats();
  }

  Future<void> clearCurrentSession() async {
    final activeChatId =
        state.activeChatId;

    ++_sessionVersion;

    if (activeChatId != null &&
        activeChatId.trim().isNotEmpty &&
        hasCurrentUser) {
      sendBackgroundWs({
        'handler': WsHandlers.dmClose,
        'request_id':
            const Uuid().v4(),
        'chatId': activeChatId,
        'chat_id': activeChatId,
      });
    }

    _currentUserId = '';

    storage.clearCurrentUser();

    state = const DmState();
  }

  bool _chatBelongsToCurrentUser(
    String chatId,
  ) {
    if (!hasCurrentUser) {
      return false;
    }

    final cleanChatId =
        chatId.trim();

    if (cleanChatId.isEmpty) {
      return false;
    }

    return cleanChatId
        .split('_')
        .contains(_currentUserId);
  }

  bool _messageBelongsToCurrentUser({
    required String fromUserId,
    required String toUserId,
  }) {
    if (!hasCurrentUser) {
      return false;
    }

    return fromUserId ==
            _currentUserId ||
        toUserId ==
            _currentUserId;
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
    if (!hasCurrentUser) {
      state = const DmState();
      return;
    }

    final version =
        _sessionVersion;

    final userId =
        _currentUserId;

    state = state.copyWith(
      loading: true,
      error: null,
    );

    final chats =
        await storage.getChats();

    if (version !=
            _sessionVersion ||
        userId !=
            _currentUserId) {
      return;
    }

    state = state.copyWith(
      loading: false,
      error: null,
      chats: chats,
    );
  }

  Future<void> loadMessages(
    String chatId,
  ) async {
    if (!hasCurrentUser ||
        chatId.trim().isEmpty ||
        !_chatBelongsToCurrentUser(
          chatId,
        )) {
      return;
    }

    final version =
        _sessionVersion;

    final messages =
        await storage.getMessages(
      chatId,
    );

    if (version !=
        _sessionVersion) {
      return;
    }

    final next = Map<
        String,
        List<LocalMessageModel>>.from(
      state.messagesByChat,
    );

    next[chatId] = messages;

    state = state.copyWith(
      messagesByChat: next,
    );
  }

  Future<void> openChat(String chatId) async {
    if (!hasCurrentUser ||
        chatId.trim().isEmpty ||
        !_chatBelongsToCurrentUser(
          chatId,
        )) {
      return;
    }

    state = state.copyWith(activeChatId: chatId);

    sendBackgroundWs({
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
      sendBackgroundWs({
        'handler': WsHandlers.dmClose,
        'request_id': const Uuid().v4(),
        'chatId': chatId,
        'chat_id': chatId,
      });
    }

    state = state.copyWith(activeChatId: null);
  }

  Future<void> deleteChat(String chatId) async {
    if (!hasCurrentUser ||
        chatId.trim().isEmpty ||
        !_chatBelongsToCurrentUser(
          chatId,
        )) {
      return;
    }

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
    if (!hasCurrentUser ||
        chatId.trim().isEmpty ||
        !_chatBelongsToCurrentUser(
          chatId,
        )) {
      return;
    }

    await storage.clearChatMessages(chatId);

    final nextMessages = Map<String, List<LocalMessageModel>>.from(
      state.messagesByChat,
    );

    nextMessages[chatId] = [];

    final chats = await storage.getChats();

    state = state.copyWith(chats: chats, messagesByChat: nextMessages);

    sendBackgroundWs({
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

    if (!hasCurrentUser ||
        myUserId.trim().isEmpty ||
        peerUserId.trim().isEmpty ||
        myUserId.trim() !=
            _currentUserId) {
      return;
    }

    if (body.isEmpty &&
        shared == null) {
      return;
    }

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

    sendBackgroundWs({
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
    if (!hasCurrentUser ||
        myUserId.trim().isEmpty ||
        peerUserId.trim().isEmpty ||
        myUserId.trim() !=
            _currentUserId) {
      return;
    }

    if (![
      'image',
      'video',
      'audio',
      'file',
    ].contains(type)) {
      return;
    }

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

    sendBackgroundWs({
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

  Future<void> sendMediaBase64Message({
    required String myUserId,
    required String peerUserId,
    required String peerUsername,
    required String peerPhotoUrl,
    required String type,
    required String mediaBase64,
    required String fileName,
    required String mimeType,
    int sizeBytes = 0,
    String text = '',
    Map<String, dynamic>? replyTo,
  }) async {
    if (!hasCurrentUser ||
        myUserId.trim().isEmpty ||
        peerUserId.trim().isEmpty ||
        myUserId.trim() !=
            _currentUserId) {
      return;
    }

    if (![
      'image',
      'video',
      'audio',
      'file',
    ].contains(type)) {
      return;
    }
    if (mediaBase64.trim().isEmpty) return;

    final now = DateTime.now();
    final tempId = const Uuid().v4();
    final chatId = makeChatId(myUserId, peerUserId);

    final media = {
      'url': '',
      'base64': mediaBase64,
      'fileName': fileName,
      'mimeType': mimeType,
      'sizeBytes': sizeBytes,
    };

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

    sendBackgroundWs({
      'handler': WsHandlers.dmSend,
      'request_id': tempId,
      'temp_id': tempId,
      'to_user_id': peerUserId,
      'chatId': chatId,
      'chat_id': chatId,
      'type': type,
      'text': text.trim(),
      'mediaBase64': mediaBase64,
      'media': {
        'fileName': fileName,
        'mimeType': mimeType,
        'sizeBytes': sizeBytes,
      },
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

    sendBackgroundWs({
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

    sendBackgroundWs({
      'handler': WsHandlers.dmDelete,
      'request_id': const Uuid().v4(),
      'to_user_id': toUserId,
      'message_id': messageId,
    });
  }

  void sendTyping({required String toUserId, required bool isTyping}) {
    if (toUserId.trim().isEmpty) return;

    sendBackgroundWs({
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

    sendBackgroundWs({
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
    _sub?.cancel();

    _sub = WsEventBus.instance.stream.listen((data) async {
      final handler =
          data['handler']?.toString();

      final type =
          data['type']?.toString();

      if (!hasCurrentUser) {
        return;
      }

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
        data['delivered'] == true ||
        data['delivered']
                ?.toString() ==
            'true';

    final fromUserId =
        messageMap['fromUserId']
                ?.toString() ??
            '';

    final toUserId =
        messageMap['toUserId']
                ?.toString() ??
            '';

    if (chatId.isEmpty ||
        !_messageBelongsToCurrentUser(
          fromUserId:
              fromUserId,
          toUserId:
              toUserId,
        )) {
      return;
    }

    if (messageMap.isNotEmpty) {
      final serverMessage = LocalMessageModel(
        messageId: messageId.isNotEmpty ? messageId : const Uuid().v4(),
        tempId: tempId.isNotEmpty ? tempId : null,
        chatId: chatId,
        fromUserId: messageMap['fromUserId']?.toString() ?? '',
        toUserId: messageMap['toUserId']?.toString() ?? '',
        type: messageMap['type']?.toString() ?? 'text',
        text: messageMap['text']?.toString() ?? '',
        media: messageMap['media'] is Map
            ? Map<String, dynamic>.from(messageMap['media'] as Map)
            : null,
        replyTo: messageMap['replyTo'] is Map
            ? Map<String, dynamic>.from(messageMap['replyTo'] as Map)
            : null,
        shared: messageMap['shared'] is Map
            ? Map<String, dynamic>.from(messageMap['shared'] as Map)
            : null,
        status: delivered ? 'delivered' : 'sent',
        isMine: true,
        isEdited: messageMap['isEdited'] == true,
        isDeleted: messageMap['isDeleted'] == true,
        createdAt:
            DateTime.tryParse(messageMap['createdAt']?.toString() ?? '') ??
                DateTime.now(),
        updatedAt:
            DateTime.tryParse(messageMap['updatedAt']?.toString() ?? '') ??
                DateTime.now(),
      );

      await storage.upsertMessage(serverMessage);
    }

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

    if (messageMap.isEmpty) {
      return;
    }

    final fromUserId =
        messageMap['fromUserId']
                ?.toString() ??
            '';

    final toUserId =
        messageMap['toUserId']
                ?.toString() ??
            '';

    if (!_messageBelongsToCurrentUser(
      fromUserId:
          fromUserId,
      toUserId:
          toUserId,
    )) {
      return;
    }

    final message =
        _messageFromServer(
      messageMap,
    );

    final isActive =
        state.activeChatId ==
            message.chatId;

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

    if (chatId.isEmpty ||
        !_chatBelongsToCurrentUser(
          chatId,
        )) {
      return;
    }

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

    if (chatId.isEmpty ||
        messageIds.isEmpty ||
        !_chatBelongsToCurrentUser(
          chatId,
        )) {
      return;
    }

    await storage.markMessagesSeen(chatId: chatId, messageIds: messageIds);

    await loadMessages(chatId);
  }

  void _handleTyping(Map<String, dynamic> data) {
    final fromUserId = data['fromUserId']?.toString() ?? '';
    final isTyping =
        data['isTyping'] == true || data['isTyping']?.toString() == 'true';

    if (!hasCurrentUser ||
        fromUserId.isEmpty ||
        fromUserId ==
            _currentUserId) {
      return;
    }

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

    if (chatId.trim().isEmpty ||
        messageId.isEmpty ||
        text.isEmpty ||
        !_messageBelongsToCurrentUser(
          fromUserId:
              fromUserId,
          toUserId:
              toUserId,
        )) {
      return;
    }

    await storage.editMessage(chatId: chatId, messageId: messageId, text: text);

    await _refreshChatAfterMessageChange(chatId);
  }

  Future<void> _handleDeleted(Map<String, dynamic> data) async {
    final fromUserId = data['fromUserId']?.toString() ?? '';
    final toUserId = data['toUserId']?.toString() ?? '';
    final chatId = makeChatId(fromUserId, toUserId);

    final messageId = data['messageId']?.toString() ?? '';

    if (chatId.trim().isEmpty ||
        messageId.isEmpty ||
        !_messageBelongsToCurrentUser(
          fromUserId:
              fromUserId,
          toUserId:
              toUserId,
        )) {
      return;
    }

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