import '../data/local_chat_model.dart';
import '../data/local_message_model.dart';

class DmState {
  final bool loading;
  final String? error;

  final List<LocalChatModel> chats;

  final Map<String, List<LocalMessageModel>> messagesByChat;

  final String? activeChatId;

  final Set<String> typingUserIds;

  const DmState({
    this.loading = false,
    this.error,
    this.chats = const [],
    this.messagesByChat = const {},
    this.activeChatId,
    this.typingUserIds = const {},
  });

  DmState copyWith({
    bool? loading,
    Object? error = _noChange,
    List<LocalChatModel>? chats,
    Map<String, List<LocalMessageModel>>? messagesByChat,
    Object? activeChatId = _noChange,
    Set<String>? typingUserIds,
  }) {
    return DmState(
      loading: loading ?? this.loading,
      error: error == _noChange ? this.error : error as String?,
      chats: chats ?? this.chats,
      messagesByChat: messagesByChat ?? this.messagesByChat,
      activeChatId: activeChatId == _noChange
          ? this.activeChatId
          : activeChatId as String?,
      typingUserIds: typingUserIds ?? this.typingUserIds,
    );
  }

  List<LocalMessageModel> messagesFor(String chatId) {
    return messagesByChat[chatId] ?? const [];
  }
}

class _NoChange {
  const _NoChange();
}

const _noChange = _NoChange();
