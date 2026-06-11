import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/responsive.dart';
import '../data/local_chat_model.dart';
import '../data/local_message_model.dart';
import '../logic/dm_provider.dart';

class DmChatScreen extends ConsumerStatefulWidget {
  final LocalChatModel chat;
  final String myUserId;

  const DmChatScreen({super.key, required this.chat, required this.myUserId});

  @override
  ConsumerState<DmChatScreen> createState() => _DmChatScreenState();
}

class _DmChatScreenState extends ConsumerState<DmChatScreen> {
  final messageController = TextEditingController();
  final scrollController = ScrollController();

  LocalMessageModel? replyMessage;
  LocalMessageModel? editingMessage;

  Timer? typingTimer;
  bool typingSent = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await ref.read(dmProvider.notifier).openChat(widget.chat.chatId);
      _markUnreadIncomingSeen();
      scrollToBottom(jump: true);
    });

    messageController.addListener(_handleTyping);
  }

  @override
  void dispose() {
    typingTimer?.cancel();

    if (typingSent) {
      ref
          .read(dmProvider.notifier)
          .sendTyping(toUserId: widget.chat.peerUserId, isTyping: false);
    }

    messageController.removeListener(_handleTyping);
    messageController.dispose();
    scrollController.dispose();

    ref.read(dmProvider.notifier).closeChat();

    super.dispose();
  }

  Color pageBackground(BuildContext context) {
    final theme = Theme.of(context);

    if (theme.brightness == Brightness.dark) {
      return theme.colorScheme.surface;
    }

    return const Color(0xFFF8F9FA);
  }

  void scrollToBottom({bool jump = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;

      final max = scrollController.position.maxScrollExtent;

      if (jump) {
        scrollController.jumpTo(max);
      } else {
        scrollController.animateTo(
          max,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleTyping() {
    final text = messageController.text.trim();

    if (editingMessage != null) return;

    if (text.isNotEmpty && !typingSent) {
      typingSent = true;

      ref
          .read(dmProvider.notifier)
          .sendTyping(toUserId: widget.chat.peerUserId, isTyping: true);
    }

    typingTimer?.cancel();

    typingTimer = Timer(const Duration(milliseconds: 900), () {
      if (!typingSent) return;

      typingSent = false;

      ref
          .read(dmProvider.notifier)
          .sendTyping(toUserId: widget.chat.peerUserId, isTyping: false);
    });
  }

  void _markUnreadIncomingSeen() {
    final state = ref.read(dmProvider);
    final messages = state.messagesFor(widget.chat.chatId);

    final incomingUnseen = messages
        .where((message) {
          if (message.isMine) return false;
          if (message.isDeleted) return false;
          if (message.status == 'seen') return false;
          return message.messageId.isNotEmpty;
        })
        .map((message) => message.messageId)
        .toList();

    if (incomingUnseen.isEmpty) return;

    ref
        .read(dmProvider.notifier)
        .markSeen(
          toUserId: widget.chat.peerUserId,
          chatId: widget.chat.chatId,
          messageIds: incomingUnseen,
        );
  }

  String formatTime(DateTime time) {
    final hour = time.hour > 12
        ? time.hour - 12
        : time.hour == 0
        ? 12
        : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final amPm = time.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $amPm';
  }

  String formatDate(DateTime time) {
    return '${time.day}/${time.month}/${time.year}';
  }

  bool shouldShowDate(List<LocalMessageModel> messages, int index) {
    if (index == 0) return true;

    final current = messages[index].createdAt;
    final previous = messages[index - 1].createdAt;

    return current.year != previous.year ||
        current.month != previous.month ||
        current.day != previous.day;
  }

  Future<void> sendTextMessage() async {
    final text = messageController.text.trim();

    if (text.isEmpty) return;

    if (editingMessage != null) {
      final editing = editingMessage!;

      await ref
          .read(dmProvider.notifier)
          .editTextMessage(
            toUserId: widget.chat.peerUserId,
            chatId: widget.chat.chatId,
            messageId: editing.messageId,
            text: text,
          );

      setState(() {
        editingMessage = null;
        replyMessage = null;
      });

      messageController.clear();
      scrollToBottom();
      return;
    }

    final reply = replyMessage == null
        ? null
        : {
            'messageId': replyMessage!.messageId,
            'fromUserId': replyMessage!.fromUserId,
            'type': replyMessage!.type,
            'text': replyMessage!.text,
            'mediaUrl': replyMessage!.media?['url']?.toString() ?? '',
          };

    messageController.clear();

    setState(() {
      replyMessage = null;
    });

    await ref
        .read(dmProvider.notifier)
        .sendTextMessage(
          myUserId: widget.myUserId,
          peerUserId: widget.chat.peerUserId,
          peerUsername: widget.chat.peerUsername,
          peerPhotoUrl: widget.chat.peerPhotoUrl,
          text: text,
          replyTo: reply,
        );

    scrollToBottom();
  }

  void startReply(LocalMessageModel message) {
    if (message.isDeleted) return;

    setState(() {
      replyMessage = message;
      editingMessage = null;
    });
  }

  void startEdit(LocalMessageModel message) {
    if (!message.isMine || message.isDeleted) return;
    if (message.type != 'text') return;

    setState(() {
      editingMessage = message;
      replyMessage = null;
      messageController.text = message.text;
      messageController.selection = TextSelection.fromPosition(
        TextPosition(offset: messageController.text.length),
      );
    });
  }

  void cancelReplyOrEdit() {
    setState(() {
      replyMessage = null;
      editingMessage = null;
      messageController.clear();
    });
  }

  Future<void> deleteMessage(LocalMessageModel message) async {
    if (message.isDeleted) return;

    await ref
        .read(dmProvider.notifier)
        .deleteMessageForEveryone(
          toUserId: widget.chat.peerUserId,
          chatId: widget.chat.chatId,
          messageId: message.messageId,
        );
  }

  Future<void> copyMessage(LocalMessageModel message) async {
    if (message.isDeleted) return;
    if (message.text.trim().isEmpty) return;

    await Clipboard.setData(ClipboardData(text: message.text));

    showMessage('Message copied');
  }

  Future<void> clearChatMessages() async {
    await ref.read(dmProvider.notifier).clearChatMessages(widget.chat.chatId);
    showMessage('Chat cleared');
  }

  Future<void> deleteChat() async {
    await ref.read(dmProvider.notifier).deleteChat(widget.chat.chatId);

    if (!mounted) return;
    Navigator.pop(context);
  }

  void openMessageOptions(LocalMessageModel message) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(R.size(context, 24)),
        ),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              top: R.size(context, 8),
              bottom: R.size(context, 10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: R.size(context, 48),
                  height: R.size(context, 5),
                  margin: EdgeInsets.only(bottom: R.size(context, 8)),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),

                _MessageOptionTile(
                  icon: Icons.reply_rounded,
                  title: 'Reply',
                  onTap: () {
                    Navigator.pop(context);
                    startReply(message);
                  },
                ),

                if (message.text.trim().isNotEmpty && !message.isDeleted)
                  _MessageOptionTile(
                    icon: Icons.copy_rounded,
                    title: 'Copy message',
                    onTap: () {
                      Navigator.pop(context);
                      copyMessage(message);
                    },
                  ),

                if (message.isMine &&
                    !message.isDeleted &&
                    message.type == 'text')
                  _MessageOptionTile(
                    icon: Icons.edit_rounded,
                    title: 'Edit message',
                    onTap: () {
                      Navigator.pop(context);
                      startEdit(message);
                    },
                  ),

                if (!message.isDeleted)
                  _MessageOptionTile(
                    icon: Icons.delete_rounded,
                    title: 'Delete message',
                    color: colorScheme.error,
                    onTap: () {
                      Navigator.pop(context);
                      deleteMessage(message);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void openHeaderMenu(String value) {
    switch (value) {
      case 'profile':
        showMessage('Open profile');
        break;

      case 'clear':
        clearChatMessages();
        break;

      case 'delete_chat':
        deleteChat();
        break;

      case 'block':
        showMessage('Block user');
        break;
    }
  }

  void showMessage(String text) {
    final colorScheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        content: Text(
          text,
          style: TextStyle(
            color: colorScheme.onInverseSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void showMediaComingSoon() {
    showMessage('Media upload will be connected with Cloudinary next');
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = pageBackground(context);

    final dmState = ref.watch(dmProvider);
    final messages = dmState.messagesFor(widget.chat.chatId);
    final isPeerTyping = dmState.typingUserIds.contains(widget.chat.peerUserId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markUnreadIncomingSeen();
    });

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          _DmChatHeader(
            chat: widget.chat,
            isTyping: isPeerTyping,
            onBack: () => Navigator.pop(context),
            onProfileTap: () => openHeaderMenu('profile'),
            onCallTap: () => showMessage('Calling...'),
            onMenuSelect: openHeaderMenu,
          ),

          Expanded(
            child: Container(
              color: backgroundColor,
              child: messages.isEmpty
                  ? _EmptyChat(peerUsername: widget.chat.peerUsername)
                  : ListView.builder(
                      controller: scrollController,
                      padding: EdgeInsetsDirectional.fromSTEB(
                        R.size(context, 18),
                        R.size(context, 12),
                        R.size(context, 18),
                        R.size(context, 12),
                      ),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];

                        return Column(
                          children: [
                            if (shouldShowDate(messages, index))
                              _DateChip(text: formatDate(message.createdAt)),

                            _MessageBubble(
                              message: message,
                              time: formatTime(message.createdAt),
                              onTap: () => openMessageOptions(message),
                              onReply: () => startReply(message),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ),

          _DmInputBar(
            controller: messageController,
            replyMessage: replyMessage,
            editingMessage: editingMessage,
            onCancelReplyOrEdit: cancelReplyOrEdit,
            onSend: sendTextMessage,
            onPickImage: showMediaComingSoon,
            onRecord: showMediaComingSoon,
          ),
        ],
      ),
    );
  }
}

class _DmChatHeader extends StatelessWidget {
  final LocalChatModel chat;
  final bool isTyping;
  final VoidCallback onBack;
  final VoidCallback onProfileTap;
  final VoidCallback onCallTap;
  final ValueChanged<String> onMenuSelect;

  const _DmChatHeader({
    required this.chat,
    required this.isTyping,
    required this.onBack,
    required this.onProfileTap,
    required this.onCallTap,
    required this.onMenuSelect,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      bottom: false,
      child: Container(
        padding: EdgeInsetsDirectional.fromSTEB(
          R.size(context, 8),
          R.size(context, 8),
          R.size(context, 8),
          R.size(context, 10),
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.12),
            ),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),

            GestureDetector(
              onTap: onProfileTap,
              child: CircleAvatar(
                radius: R.size(context, 22),
                backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
                backgroundImage: chat.peerPhotoUrl.trim().isEmpty
                    ? null
                    : NetworkImage(chat.peerPhotoUrl),
                child: chat.peerPhotoUrl.trim().isEmpty
                    ? Text(
                        chat.peerUsername.isEmpty
                            ? '?'
                            : chat.peerUsername.characters.first.toUpperCase(),
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      )
                    : null,
              ),
            ),

            SizedBox(width: R.size(context, 12)),

            Expanded(
              child: GestureDetector(
                onTap: onProfileTap,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chat.peerUsername,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: R.sp(context, 16),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: R.size(context, 2)),
                    Text(
                      isTyping ? 'typing...' : 'Private chat',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isTyping
                            ? colorScheme.primary
                            : colorScheme.onSurface.withValues(alpha: 0.55),
                        fontSize: R.sp(context, 12),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            IconButton(
              onPressed: onCallTap,
              icon: const Icon(Icons.call_rounded),
            ),

            PopupMenuButton<String>(
              onSelected: onMenuSelect,
              itemBuilder: (context) {
                return const [
                  PopupMenuItem(value: 'profile', child: Text('View profile')),
                  PopupMenuItem(value: 'clear', child: Text('Clear messages')),
                  PopupMenuItem(
                    value: 'delete_chat',
                    child: Text('Delete chat'),
                  ),
                  PopupMenuItem(value: 'block', child: Text('Block user')),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DmInputBar extends StatelessWidget {
  final TextEditingController controller;
  final LocalMessageModel? replyMessage;
  final LocalMessageModel? editingMessage;
  final VoidCallback onCancelReplyOrEdit;
  final VoidCallback onSend;
  final VoidCallback onPickImage;
  final VoidCallback onRecord;

  const _DmInputBar({
    required this.controller,
    required this.replyMessage,
    required this.editingMessage,
    required this.onCancelReplyOrEdit,
    required this.onSend,
    required this.onPickImage,
    required this.onRecord,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final isReplying = replyMessage != null;
    final isEditing = editingMessage != null;

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsetsDirectional.fromSTEB(
          R.size(context, 12),
          R.size(context, 8),
          R.size(context, 12),
          R.size(context, 10),
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(color: colorScheme.outline.withValues(alpha: 0.12)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isReplying || isEditing)
              Container(
                margin: EdgeInsets.only(bottom: R.size(context, 8)),
                padding: EdgeInsets.all(R.size(context, 10)),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(R.size(context, 14)),
                  border: Border(
                    left: BorderSide(
                      color: colorScheme.primary,
                      width: R.size(context, 4),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isEditing ? Icons.edit_rounded : Icons.reply_rounded,
                      color: colorScheme.primary,
                      size: R.size(context, 18),
                    ),
                    SizedBox(width: R.size(context, 8)),
                    Expanded(
                      child: Text(
                        isEditing
                            ? editingMessage!.text
                            : replyMessage!.text.isEmpty
                            ? replyMessage!.type
                            : replyMessage!.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onCancelReplyOrEdit,
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: onPickImage,
                  icon: const Icon(Icons.image_rounded),
                ),

                Expanded(
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: R.size(context, 130),
                    ),
                    padding: EdgeInsetsDirectional.symmetric(
                      horizontal: R.size(context, 14),
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.7,
                      ),
                      borderRadius: BorderRadius.circular(R.size(context, 24)),
                    ),
                    child: TextField(
                      controller: controller,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Message',
                      ),
                    ),
                  ),
                ),

                SizedBox(width: R.size(context, 6)),

                AnimatedBuilder(
                  animation: controller,
                  builder: (context, _) {
                    final hasText = controller.text.trim().isNotEmpty;

                    if (!hasText && !isEditing) {
                      return IconButton(
                        onPressed: onRecord,
                        icon: const Icon(Icons.mic_rounded),
                      );
                    }

                    return IconButton.filled(
                      onPressed: onSend,
                      icon: Icon(
                        isEditing ? Icons.check_rounded : Icons.send_rounded,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final LocalMessageModel message;
  final String time;
  final VoidCallback onTap;
  final VoidCallback onReply;

  const _MessageBubble({
    required this.message,
    required this.time,
    required this.onTap,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final isMine = message.isMine;

    final bubbleColor = isMine
        ? colorScheme.primary
        : colorScheme.surfaceContainerHighest;

    final textColor = isMine ? colorScheme.onPrimary : colorScheme.onSurface;

    return Align(
      alignment: isMine
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onTap,
        onHorizontalDragEnd: (_) => onReply(),
        child: Container(
          margin: EdgeInsetsDirectional.only(
            top: R.size(context, 4),
            bottom: R.size(context, 4),
            start: isMine ? R.size(context, 54) : 0,
            end: isMine ? 0 : R.size(context, 54),
          ),
          padding: EdgeInsetsDirectional.fromSTEB(
            R.size(context, 12),
            R.size(context, 8),
            R.size(context, 10),
            R.size(context, 7),
          ),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadiusDirectional.only(
              topStart: Radius.circular(R.size(context, 18)),
              topEnd: Radius.circular(R.size(context, 18)),
              bottomStart: Radius.circular(
                isMine ? R.size(context, 18) : R.size(context, 5),
              ),
              bottomEnd: Radius.circular(
                isMine ? R.size(context, 5) : R.size(context, 18),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: isMine
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (message.replyTo != null)
                _ReplyPreview(reply: message.replyTo!, isMine: isMine),

              if (message.shared != null)
                _SharedPreview(shared: message.shared!, isMine: isMine),

              _MessageContent(message: message, textColor: textColor),

              SizedBox(height: R.size(context, 4)),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.isEdited && !message.isDeleted
                        ? '$time · Edited'
                        : time,
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.72),
                      fontSize: R.sp(context, 10),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  if (isMine) ...[
                    SizedBox(width: R.size(context, 5)),
                    _StatusIcon(status: message.status, color: textColor),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageContent extends StatelessWidget {
  final LocalMessageModel message;
  final Color textColor;

  const _MessageContent({required this.message, required this.textColor});

  @override
  Widget build(BuildContext context) {
    if (message.isDeleted) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.block_rounded,
            size: R.size(context, 15),
            color: textColor.withValues(alpha: 0.75),
          ),
          SizedBox(width: R.size(context, 6)),
          Flexible(
            child: Text(
              'This message was deleted',
              style: TextStyle(
                color: textColor.withValues(alpha: 0.78),
                fontSize: R.sp(context, 14),
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    }

    if (message.type == 'image') {
      return _MediaBox(
        icon: Icons.image_rounded,
        title: 'Photo',
        textColor: textColor,
      );
    }

    if (message.type == 'video') {
      return _MediaBox(
        icon: Icons.videocam_rounded,
        title: 'Video',
        textColor: textColor,
      );
    }

    if (message.type == 'audio') {
      return _MediaBox(
        icon: Icons.play_arrow_rounded,
        title: 'Voice message',
        textColor: textColor,
      );
    }

    if (message.type == 'file') {
      return _MediaBox(
        icon: Icons.insert_drive_file_rounded,
        title: 'File',
        textColor: textColor,
      );
    }

    return Text(
      message.text,
      style: TextStyle(
        color: textColor,
        fontSize: R.sp(context, 15),
        height: 1.35,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _MediaBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color textColor;

  const _MediaBox({
    required this.icon,
    required this.title,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: R.size(context, 120)),
      padding: EdgeInsets.all(R.size(context, 10)),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(R.size(context, 12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: R.size(context, 22)),
          SizedBox(width: R.size(context, 8)),
          Text(
            title,
            style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _ReplyPreview extends StatelessWidget {
  final Map<String, dynamic> reply;
  final bool isMine;

  const _ReplyPreview({required this.reply, required this.isMine});

  @override
  Widget build(BuildContext context) {
    final text = reply['text']?.toString() ?? reply['type']?.toString() ?? '';

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: R.size(context, 6)),
      padding: EdgeInsets.all(R.size(context, 8)),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: isMine ? 0.16 : 0.07),
        borderRadius: BorderRadius.circular(R.size(context, 10)),
      ),
      child: Text(
        text.isEmpty ? 'Reply' : text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isMine
              ? Colors.white.withValues(alpha: 0.9)
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
          fontWeight: FontWeight.w600,
          fontSize: R.sp(context, 12),
        ),
      ),
    );
  }
}

class _SharedPreview extends StatelessWidget {
  final Map<String, dynamic> shared;
  final bool isMine;

  const _SharedPreview({required this.shared, required this.isMine});

  @override
  Widget build(BuildContext context) {
    final from = shared['fromChatUsername']?.toString() ?? '';

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: R.size(context, 6)),
      padding: EdgeInsets.all(R.size(context, 8)),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: isMine ? 0.16 : 0.07),
        borderRadius: BorderRadius.circular(R.size(context, 10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.ios_share_rounded,
            size: R.size(context, 14),
            color: isMine
                ? Colors.white.withValues(alpha: 0.9)
                : Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.75),
          ),
          SizedBox(width: R.size(context, 6)),
          Flexible(
            child: Text(
              from.isEmpty ? 'Shared message' : 'Shared from $from',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isMine
                    ? Colors.white.withValues(alpha: 0.9)
                    : Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.75),
                fontWeight: FontWeight.w700,
                fontSize: R.sp(context, 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusIcon({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    if (status == 'seen') {
      return Icon(
        Icons.done_all_rounded,
        size: R.size(context, 15),
        color: Colors.lightBlueAccent,
      );
    }

    if (status == 'delivered') {
      return Icon(
        Icons.done_all_rounded,
        size: R.size(context, 15),
        color: color.withValues(alpha: 0.8),
      );
    }

    if (status == 'sent') {
      return Icon(
        Icons.done_rounded,
        size: R.size(context, 15),
        color: color.withValues(alpha: 0.8),
      );
    }

    if (status == 'failed') {
      return Icon(
        Icons.error_outline_rounded,
        size: R.size(context, 15),
        color: Colors.redAccent,
      );
    }

    if (status == 'sending') {
      return SizedBox(
        width: R.size(context, 12),
        height: R.size(context, 12),
        child: CircularProgressIndicator(
          strokeWidth: R.size(context, 1.5),
          color: color.withValues(alpha: 0.7),
        ),
      );
    }

    return Icon(
      Icons.done_rounded,
      size: R.size(context, 15),
      color: color.withValues(alpha: 0.8),
    );
  }
}

class _DateChip extends StatelessWidget {
  final String text;

  const _DateChip({required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: R.size(context, 10)),
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: R.size(context, 12),
          vertical: R.size(context, 6),
        ),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.65),
            fontSize: R.sp(context, 11),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  final String peerUsername;

  const _EmptyChat({required this.peerUsername});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(R.size(context, 24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: R.size(context, 44),
              color: colorScheme.primary,
            ),
            SizedBox(height: R.size(context, 12)),
            Text(
              'Start chatting with $peerUsername',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: R.sp(context, 16),
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: R.size(context, 6)),
            Text(
              'Messages are saved only on this device.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: R.sp(context, 13),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  const _MessageOptionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final itemColor = color ?? colorScheme.onSurface;

    return ListTile(
      leading: Icon(icon, color: itemColor),
      title: Text(
        title,
        style: TextStyle(color: itemColor, fontWeight: FontWeight.w700),
      ),
      onTap: onTap,
    );
  }
}
