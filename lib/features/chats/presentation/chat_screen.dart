import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../data/chat_item_model.dart';
import '../data/chat_message_model.dart';
import 'widgets/chat_header.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/chat_message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final ChatItemModel chat;

  const ChatScreen({super.key, required this.chat});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageController = TextEditingController();
  final scrollController = ScrollController();
  final ImagePicker imagePicker = ImagePicker();
  final AudioRecorder recorder = AudioRecorder();

  bool isRecording = false;
  String? currentRecordPath;
  DateTime? recordStartedAt;

  final List<ChatMessageModel> messages = [
    const ChatMessageModel(
      id: '1',
      text: 'السلام عليكم يا محمد',
      type: ChatMessageType.text,
      isMe: false,
      time: '10:12',
    ),
    const ChatMessageModel(
      id: '2',
      text: 'وعليكم السلام، عامل إيه؟',
      type: ChatMessageType.text,
      isMe: true,
      time: '10:13',
      status: MessageStatus.seen,
    ),
    const ChatMessageModel(
      id: '3',
      text: '',
      type: ChatMessageType.voice,
      isMe: false,
      time: '10:14',
      duration: '0:12',
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

  void scrollToBottom({bool jump = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;

      final position = scrollController.position.maxScrollExtent;

      if (jump) {
        scrollController.jumpTo(position);
      } else {
        scrollController.animateTo(
          position,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void addMessage(ChatMessageModel message) {
    setState(() {
      messages.add(message);
    });

    scrollToBottom();
  }

  void sendTextMessage() {
    final text = messageController.text.trim();

    if (text.isEmpty) return;

    messageController.clear();

    addMessage(
      ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        type: ChatMessageType.text,
        isMe: true,
        time: currentTime(),
        status: MessageStatus.sent,
      ),
    );
  }

  Future<void> pickImage() async {
    final XFile? image = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) return;

    addMessage(
      ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: '',
        type: ChatMessageType.image,
        isMe: true,
        time: currentTime(),
        status: MessageStatus.sent,
        localPath: image.path,
        fileName: image.name,
      ),
    );
  }

  ChatMessageType detectMessageType(String fileName) {
    final lower = fileName.toLowerCase();

    if (lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp')) {
      return ChatMessageType.image;
    }

    if (lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.mkv') ||
        lower.endsWith('.webm')) {
      return ChatMessageType.video;
    }

    if (lower.endsWith('.m4a') ||
        lower.endsWith('.mp3') ||
        lower.endsWith('.wav') ||
        lower.endsWith('.aac')) {
      return ChatMessageType.voice;
    }

    return ChatMessageType.file;
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
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

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
      currentRecordPath = path;
      recordStartedAt = DateTime.now();
    });
  }

  Future<void> stopRecording() async {
    if (!isRecording) return;

    final path = await recorder.stop();

    final duration = recordStartedAt == null
        ? '0:00'
        : formatDuration(DateTime.now().difference(recordStartedAt!));

    setState(() {
      isRecording = false;
      currentRecordPath = null;
      recordStartedAt = null;
    });

    if (path == null) return;

    addMessage(
      ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: '',
        type: ChatMessageType.voice,
        isMe: true,
        time: currentTime(),
        duration: duration,
        status: MessageStatus.sent,
        localPath: path,
        fileName: 'Voice message',
      ),
    );
  }

  Future<void> cancelRecording() async {
    if (!isRecording) return;

    final path = await recorder.stop();

    setState(() {
      isRecording = false;
      currentRecordPath = null;
      recordStartedAt = null;
    });

    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String currentTime() {
    final now = TimeOfDay.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ChatHeader(chat: widget.chat),

          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(vertical: 10),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ChatMessageBubble(message: messages[index]);
              },
            ),
          ),

          ChatInputBar(
            controller: messageController,
            isRecording: isRecording,
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
