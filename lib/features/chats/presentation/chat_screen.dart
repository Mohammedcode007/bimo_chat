import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../core/utils/responsive.dart';
import '../data/chat_item_model.dart';
import '../data/chat_message_model.dart';
import 'widgets/private_chat_header.dart';
import 'widgets/private_chat_input_bar.dart';
import 'widgets/private_date_chip.dart';
import 'widgets/private_message_bubble.dart';
import 'widgets/private_reaction_row.dart';

class ChatScreen extends StatefulWidget {
  final ChatItemModel chat;

  const ChatScreen({super.key, required this.chat});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageController = TextEditingController();
  final scrollController = ScrollController();
  final imagePicker = ImagePicker();
  final recorder = AudioRecorder();

  bool isRecording = false;
  DateTime? recordStartedAt;

  ChatMessageModel? replyMessage;
  ChatMessageModel? editingMessage;

  final List<ChatMessageModel> messages = [
    const ChatMessageModel(
      id: 'date_1',
      text: 'Jun 5,  12:21 AM',
      type: ChatMessageType.text,
      isMe: false,
      time: '',
    ),
    const ChatMessageModel(
      id: '1',
      text: 'since 20 min مثلا',
      type: ChatMessageType.text,
      isMe: false,
      time: 'Jun 5,  12:22 AM',
    ),
    const ChatMessageModel(
      id: '2',
      text: 'ترحيب بكرة بصورة',
      type: ChatMessageType.text,
      isMe: true,
      time: 'Jun 5,  12:22 AM',
      status: MessageStatus.seen,
    ),
    const ChatMessageModel(
      id: '3',
      text: 'يتقاله اد كدا ف روم',
      type: ChatMessageType.text,
      isMe: false,
      time: 'Jun 5,  12:22 AM',
    ),
    const ChatMessageModel(
      id: '4',
      text: 'او دخل من كدة',
      type: ChatMessageType.text,
      isMe: false,
      time: 'Jun 5,  12:22 AM',
    ),
    const ChatMessageModel(
      id: '5',
      text: 'ابعت فويس',
      type: ChatMessageType.text,
      isMe: true,
      time: 'Jun 5,  12:22 AM',
      status: MessageStatus.seen,
    ),
    const ChatMessageModel(
      id: '6',
      text: 'بالحته دي',
      type: ChatMessageType.text,
      isMe: true,
      time: 'Jun 5,  12:22 AM',
      status: MessageStatus.seen,
    ),
    const ChatMessageModel(
      id: '7',
      text: 'مش فاهم',
      type: ChatMessageType.text,
      isMe: true,
      time: 'Jun 5,  12:22 AM',
      status: MessageStatus.seen,
    ),
    const ChatMessageModel(
      id: '8',
      text: 'Voice Message',
      type: ChatMessageType.voice,
      isMe: false,
      time: 'Jun 5,  12:22 AM',
      duration: '0:12',
    ),
    const ChatMessageModel(
      id: '9',
      text: 'فهمت',
      type: ChatMessageType.text,
      isMe: true,
      time: 'Jun 5,  12:23 AM',
      status: MessageStatus.seen,
    ),
    const ChatMessageModel(
      id: '10',
      text: 'البوت مش مديني برمشن تاني',
      type: ChatMessageType.text,
      isMe: false,
      time: 'Jun 5,  11:01 AM',
    ),
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToBottom(jump: true);
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    recorder.dispose();
    super.dispose();
  }

  Color chatBackgroundColor(BuildContext context) {
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

  String currentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final amPm = now.hour >= 12 ? 'PM' : 'AM';

    return 'Jun 5,  $hour:$minute $amPm';
  }

  void sendTextMessage() {
    final text = messageController.text.trim();

    if (text.isEmpty) return;

    if (editingMessage != null) {
      final index = messages.indexWhere(
        (item) => item.id == editingMessage!.id,
      );

      if (index != -1) {
        setState(() {
          messages[index] = messages[index].copyWith(
            text: text,
            isEdited: true,
          );

          editingMessage = null;
          replyMessage = null;
        });
      }

      messageController.clear();
      return;
    }

    messageController.clear();

    setState(() {
      messages.add(
        ChatMessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: text,
          type: ChatMessageType.text,
          isMe: true,
          time: currentTime(),
          status: MessageStatus.seen,
          replyTo: replyMessage,
        ),
      );

      replyMessage = null;
    });

    scrollToBottom();
  }

  Future<void> pickImage() async {
    final image = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) return;

    setState(() {
      messages.add(
        ChatMessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: '',
          type: ChatMessageType.image,
          isMe: true,
          time: currentTime(),
          status: MessageStatus.seen,
          localPath: image.path,
          fileName: image.name,
          replyTo: replyMessage,
        ),
      );

      replyMessage = null;
    });

    scrollToBottom();
  }

  Future<void> startRecording() async {
    if (isRecording) return;

    final hasPermission = await recorder.hasPermission();

    if (!hasPermission) {
      showMessage('Microphone permission denied');
      return;
    }

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/private_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: path,
    );

    setState(() {
      isRecording = true;
      recordStartedAt = DateTime.now();
    });
  }

  Future<void> stopRecording() async {
    if (!isRecording) return;

    final startedAt = recordStartedAt;
    final path = await recorder.stop();

    setState(() {
      isRecording = false;
      recordStartedAt = null;
    });

    if (path == null) return;

    final duration = startedAt == null
        ? '0:00'
        : formatDuration(DateTime.now().difference(startedAt));

    setState(() {
      messages.add(
        ChatMessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: 'Voice Message',
          type: ChatMessageType.voice,
          isMe: true,
          time: currentTime(),
          status: MessageStatus.seen,
          duration: duration,
          localPath: path,
          replyTo: replyMessage,
        ),
      );

      replyMessage = null;
    });

    scrollToBottom();
  }

  Future<void> cancelRecording() async {
    if (!isRecording) return;

    final path = await recorder.stop();

    setState(() {
      isRecording = false;
      recordStartedAt = null;
    });

    if (path == null) return;

    final file = File(path);

    if (await file.exists()) {
      await file.delete();
    }
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void startReply(ChatMessageModel message) {
    if (message.isDeleted) return;

    setState(() {
      replyMessage = message;
      editingMessage = null;
    });
  }

  void startEdit(ChatMessageModel message) {
    if (!message.isMe || message.isDeleted) return;

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

  void deleteMessage(ChatMessageModel message) {
    final index = messages.indexWhere((item) => item.id == message.id);

    if (index == -1) return;

    setState(() {
      messages[index] = messages[index].copyWith(
        text: 'This message was deleted',
        isDeleted: true,
        clearReaction: true,
      );
    });
  }

  void setReaction(ChatMessageModel message, String reaction) {
    final index = messages.indexWhere((item) => item.id == message.id);

    if (index == -1) return;

    setState(() {
      messages[index] = messages[index].copyWith(reaction: reaction);
    });
  }

  Future<void> copyMessage(ChatMessageModel message) async {
    if (message.isDeleted) return;

    await Clipboard.setData(ClipboardData(text: message.text));

    showMessage('Message copied');
  }

  void openMessageOptions(ChatMessageModel message) {
    if (message.id.startsWith('date_')) return;

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
                    color: colorScheme.onSurface.withValues(alpha: 0.28),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),

                PrivateReactionRow(
                  onSelected: (reaction) {
                    Navigator.pop(context);
                    setReaction(message, reaction);
                  },
                ),

                _MessageOptionTile(
                  icon: Icons.reply_rounded,
                  title: 'Reply',
                  onTap: () {
                    Navigator.pop(context);
                    startReply(message);
                  },
                ),

                _MessageOptionTile(
                  icon: Icons.copy_rounded,
                  title: 'Copy message',
                  onTap: () {
                    Navigator.pop(context);
                    copyMessage(message);
                  },
                ),

                if (message.isMe && !message.isDeleted)
                  _MessageOptionTile(
                    icon: Icons.edit_rounded,
                    title: 'Edit message',
                    onTap: () {
                      Navigator.pop(context);
                      startEdit(message);
                    },
                  ),

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

  void handleHeaderMenu(String value) {
    switch (value) {
      case 'profile':
        showMessage('Open profile');
        break;
      case 'clear':
        setState(() {
          messages.clear();
        });
        break;
      case 'block':
        showMessage('Blocked');
        break;
    }
  }

  void openImage(String path) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: colorScheme.surface,
          insetPadding: EdgeInsets.all(R.size(context, 16)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(R.size(context, 8)),
            child: Image.file(File(path), fit: BoxFit.contain),
          ),
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    final backgroundColor = chatBackgroundColor(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          PrivateChatHeader(
            chat: widget.chat,
            onProfileTap: () => showMessage('Open profile'),
            onCallTap: () => showMessage('Calling...'),
            onMenuSelect: handleHeaderMenu,
          ),

          Expanded(
            child: Container(
              color: backgroundColor,
              child: ListView.builder(
                controller: scrollController,
                padding: EdgeInsetsDirectional.fromSTEB(
                  R.size(context, 24),
                  R.size(context, 12),
                  R.size(context, 24),
                  R.size(context, 12),
                ),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];

                  if (message.id.startsWith('date_')) {
                    return PrivateDateChip(text: message.text);
                  }

                  return PrivateMessageBubble(
                    message: message,
                    onTap: () => openMessageOptions(message),
                    onReply: () => startReply(message),
                    onVoicePlay: () => showMessage('Play voice'),
                    onImageTap: message.localPath == null
                        ? null
                        : () => openImage(message.localPath!),
                  );
                },
              ),
            ),
          ),

          PrivateChatInputBar(
            controller: messageController,
            replyMessage: replyMessage,
            editingMessage: editingMessage,
            isRecording: isRecording,
            onCancelReplyOrEdit: cancelReplyOrEdit,
            onSend: sendTextMessage,
            onPickImage: pickImage,
            onStartRecord: startRecording,
            onStopRecord: stopRecording,
            onCancelRecord: cancelRecording,
          ),
        ],
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
        style: TextStyle(color: itemColor, fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
    );
  }
}
