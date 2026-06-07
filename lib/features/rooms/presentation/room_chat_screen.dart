import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../core/utils/responsive.dart';

import '../../chats/data/chat_item_model.dart';
import '../../chats/presentation/chat_screen.dart';

import '../../user_profile/data/user_profile_model.dart';
import '../../user_profile/presentation/user_profile_screen.dart';

import '../data/room_model.dart';
import '../data/room_role.dart';
import '../data/room_chat_user_model.dart';
import '../data/room_chat_message_model.dart';

import '../widgets/room_chat_header.dart';
import '../widgets/room_input_bar.dart';
import '../widgets/room_message_bubble.dart';
import '../widgets/room_pinned_html_message.dart';
import '../widgets/room_users_dialog.dart';
import '../widgets/room_voice_player_bar.dart';
import '../widgets/room_image_preview_screen.dart';
import '../widgets/room_user_action_menu.dart';

import 'room_settings_screen.dart';

class RoomChatScreen extends StatefulWidget {
  final RoomModel room;

  const RoomChatScreen({
    super.key,
    required this.room,
  });

  @override
  State<RoomChatScreen> createState() => _RoomChatScreenState();
}

class _RoomChatScreenState extends State<RoomChatScreen> {
  final messageController = TextEditingController();
  final scrollController = ScrollController();

  final imagePicker = ImagePicker();
  final recorder = AudioRecorder();
  final audioPlayer = AudioPlayer();

  bool isRecording = false;
  DateTime? recordStartedAt;

  String? activeVoicePath;
  bool isPlayingVoice = false;

  RoomRole myRole = RoomRole.owner;

  late final RoomChatUserModel me;

  String pinnedHtml =
      '<br><br><h6><font color="#000000">اللهم صل وسلم على نبينا محمد ﷺ</font></h6>';

  late List<RoomChatUserModel> users;

  late List<RoomChatMessageModel> messages;

  @override
  void initState() {
    super.initState();

    me = const RoomChatUserModel(
      id: 'me',
      name: 'محمد',
      role: RoomRole.owner,
      avatarText: 'م',
      avatarUrl: '',
      frame: 'gold',
      badge: '⭐',
      nameColor: Color(0xFF087887),
      isOnline: true,
    );

    users = [
      me,
      const RoomChatUserModel(
        id: '1',
        name: '__bot__',
        role: RoomRole.owner,
        avatarText: 'B',
        badge: '🤖',
        nameColor: Color(0xFF444444),
        isOnline: true,
      ),
      const RoomChatUserModel(
        id: '2',
        name: 'взтнян♡',
        role: RoomRole.owner,
        avatarText: 'B',
        frame: 'red',
        badge: '♥',
        nameColor: Color(0xFFC04A28),
        isOnline: true,
      ),
      const RoomChatUserModel(
        id: '3',
        name: 'شــــيرين',
        role: RoomRole.none,
        avatarText: 'ش',
        badge: '◆',
        nameColor: Color(0xFF111111),
      ),
      const RoomChatUserModel(
        id: '4',
        name: 'r2nda',
        role: RoomRole.admin,
        avatarText: 'R',
        nameColor: Color(0xFF4A90E2),
        isOnline: true,
      ),
      const RoomChatUserModel(
        id: '5',
        name: 'rozetа.',
        role: RoomRole.member,
        avatarText: 'R',
      ),
      const RoomChatUserModel(
        id: '6',
        name: 'new_user',
        role: RoomRole.none,
        avatarText: 'N',
      ),
    ];

    messages = [
      RoomChatMessageModel(
        id: '1',
        sender: users[1],
        text: '👑نووورت✨ياووميكي👑\nعضو أساسي ✅\n(قلوبنا🖤تجمعنا) 💬\n⭐⭐⭐',
        type: RoomChatMessageType.text,
        createdAt: DateTime.now(),
      ),
      RoomChatMessageModel(
        id: '2',
        sender: users[2],
        text: 'هه مافي غيرك نز ححلقوو',
        type: RoomChatMessageType.text,
        createdAt: DateTime.now(),
      ),
      RoomChatMessageModel(
        id: '3',
        sender: users[3],
        text: 'مين اللي بدلك',
        type: RoomChatMessageType.text,
        createdAt: DateTime.now(),
      ),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToBottom(jump: true);
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    recorder.dispose();
    audioPlayer.dispose();
    super.dispose();
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

  String currentDuration(DateTime start) {
    final d = DateTime.now().difference(start);
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void sendText() {
    final text = messageController.text.trim();

    if (text.isEmpty) return;

    messageController.clear();

    setState(() {
      messages.add(
        RoomChatMessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          sender: me,
          text: text,
          type: RoomChatMessageType.text,
          isMe: true,
          createdAt: DateTime.now(),
        ),
      );
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
        RoomChatMessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          sender: me,
          text: '',
          type: RoomChatMessageType.image,
          localPath: image.path,
          isMe: true,
          createdAt: DateTime.now(),
        ),
      );
    });

    scrollToBottom();
  }

  Future<void> startRecord() async {
    if (isRecording) return;

    final hasPermission = await recorder.hasPermission();

    if (!hasPermission) {
      showMessage('Microphone permission denied');
      return;
    }

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/room_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

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

  Future<void> stopRecordAndSend() async {
    if (!isRecording) return;

    final startedAt = recordStartedAt;
    final path = await recorder.stop();

    setState(() {
      isRecording = false;
      recordStartedAt = null;
    });

    if (path == null) return;

    final duration = startedAt == null ? '0:00' : currentDuration(startedAt);

    setState(() {
      messages.add(
        RoomChatMessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          sender: me,
          text: 'Voice message',
          type: RoomChatMessageType.voice,
          localPath: path,
          duration: duration,
          isMe: true,
          createdAt: DateTime.now(),
        ),
      );
    });

    scrollToBottom();
  }

  Future<void> cancelRecord() async {
    if (!isRecording) return;

    final path = await recorder.stop();

    setState(() {
      isRecording = false;
      recordStartedAt = null;
    });

    if (path != null) {
      final file = File(path);

      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  Future<void> playVoice(String path) async {
    if (activeVoicePath == path && isPlayingVoice) {
      await audioPlayer.pause();

      setState(() {
        isPlayingVoice = false;
      });

      return;
    }

    await audioPlayer.setFilePath(path);
    await audioPlayer.play();

    setState(() {
      activeVoicePath = path;
      isPlayingVoice = true;
    });

    audioPlayer.playerStateStream.listen((state) {
      if (!mounted) return;

      if (state.processingState == ProcessingState.completed) {
        setState(() {
          isPlayingVoice = false;
          activeVoicePath = null;
        });
      }
    });
  }

  Future<void> pauseVoice() async {
    await audioPlayer.pause();

    setState(() {
      isPlayingVoice = false;
    });
  }

  Future<void> closeVoicePlayer() async {
    await audioPlayer.stop();

    setState(() {
      isPlayingVoice = false;
      activeVoicePath = null;
    });
  }

  void openImage(String path) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoomImagePreviewScreen(imagePath: path),
      ),
    );
  }

  void addSystemMessage(
    String text, {
    Color color = Colors.red,
  }) {
    setState(() {
      messages.add(
        RoomChatMessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          sender: me,
          text: text,
          type: RoomChatMessageType.system,
          createdAt: DateTime.now(),
          systemColor: color,
        ),
      );
    });

    scrollToBottom();
  }

  void openPrivateChat(RoomChatUserModel user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          chat: ChatItemModel(
            id: user.id,
            name: user.name,
            lastMessage: '',
            time: '',
            unreadCount: 0,
            isOnline: user.isOnline,
            avatarUrl: user.avatarUrl,
          ),
        ),
      ),
    );
  }

void openUserProfile(RoomChatUserModel user) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => UserProfileScreen(
        user: UserProfileModel(
          id: user.id == 'me' ? '579915277' : user.id,
          name: user.name,
          username: '@${user.name.toLowerCase()}',
          avatarText: user.avatarText,
          avatarUrl: user.avatarUrl,
          coverUrl:
              'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=1200',
          role: user.role.label,
          status: user.isOnline ? 'Online now' : 'Offline',
          bio:
              'فقدت حماسي في كل شيء رغباتي كلها تهجرني حتى أني لا أرى أحلامًا ذات شأن لا أرى سوى أحلام عادية.',
          badge: user.badge,
          frame: user.frame,
          nameColor: user.nameColor,
          isOnline: user.isOnline,
          receivedGifts: 0,
          sentGifts: 0,
          views: 363,
          friends: 1,
          since: '2026-6-2',
          country: 'N/A',
          gender: 'N/A',
          age: 'N/A',
        ),
      ),
    ),
  );
}
  void showAvatarActions(RoomChatUserModel user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(R.size(context, 24)),
        ),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: R.size(context, 10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: R.size(context, 46),
                  height: R.size(context, 5),
                  margin: EdgeInsets.only(
                    bottom: R.size(context, 10),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),

                ListTile(
                  leading: const Icon(Icons.copy_rounded),
                  title: const Text('Copy name'),
                  onTap: () async {
                    Navigator.pop(context);

                    await Clipboard.setData(
                      ClipboardData(text: user.name),
                    );

                    showMessage('${user.name} copied');
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.card_giftcard_rounded),
                  title: const Text('Send Gift'),
                  onTap: () {
                    Navigator.pop(context);
                    handleUserAction(user, RoomUserAction.sendGift);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  RoomChatUserModel copyUserWithRole(
    RoomChatUserModel user,
    RoomRole role,
  ) {
    return RoomChatUserModel(
      id: user.id,
      name: user.name,
      role: role,
      avatarText: user.avatarText,
      avatarUrl: user.avatarUrl,
      frame: user.frame,
      badge: user.badge,
      avatarIsGif: user.avatarIsGif,
      nameColor: user.nameColor,
      isOnline: user.isOnline,
    );
  }

  void updateUserRole(
    RoomChatUserModel user,
    RoomRole newRole,
  ) {
    final index = users.indexWhere((item) => item.id == user.id);

    if (index == -1) return;

    setState(() {
      users[index] = copyUserWithRole(user, newRole);
    });
  }

  void handleUserAction(
    RoomChatUserModel user,
    RoomUserAction action,
  ) {
    switch (action) {
      case RoomUserAction.message:
        openPrivateChat(user);
        break;

      case RoomUserAction.sendGift:
        addSystemMessage(
          '🎁 ${me.name} sent a gift to ${user.name}',
          color: const Color(0xFF087887),
        );
        break;

      case RoomUserAction.kick:
        addSystemMessage('${me.name} kicked ${user.name}');
        break;

      case RoomUserAction.ban:
        updateUserRole(user, RoomRole.banned);
        addSystemMessage('${me.name} banned ${user.name}');
        break;

      case RoomUserAction.setMember:
        updateUserRole(user, RoomRole.member);
        addSystemMessage('${me.name} set ${user.name} as member');
        break;

      case RoomUserAction.setAdmin:
        updateUserRole(user, RoomRole.admin);
        addSystemMessage('${me.name} set ${user.name} as admin');
        break;

      case RoomUserAction.setOwner:
        updateUserRole(user, RoomRole.owner);
        addSystemMessage('${me.name} set ${user.name} as owner');
        break;

      case RoomUserAction.removeRole:
        updateUserRole(user, RoomRole.none);
        addSystemMessage('${me.name} removed ${user.name} role');
        break;

      case RoomUserAction.copy:
        Clipboard.setData(
          ClipboardData(text: user.name),
        );

        addSystemMessage(
          '${user.name} copied',
          color: Colors.grey,
        );
        break;
    }
  }

  void handleRoomMenu(String value) {
    switch (value) {
      case 'favorite':
        showMessage('Removed from favourite');
        break;

      case 'welcome':
        showWelcomeMessageDialog();
        break;

      case 'settings':
        openRoomSettings();
        break;

      case 'invitation':
        showInvitationDialog();
        break;

      case 'report':
        showReportDialog();
        break;

      case 'leave':
        leaveRoom();
        break;
    }
  }

  void openRoomSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoomSettingsScreen(roomName: widget.room.name),
      ),
    );
  }

  void showWelcomeMessageDialog() {
    final controller = TextEditingController(text: pinnedHtml);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(
            'Welcome message',
            style: TextStyle(
              fontSize: R.sp(context, 27),
              fontWeight: FontWeight.w600,
            ),
          ),
          content: TextField(
            controller: controller,
            minLines: 3,
            maxLines: 6,
            style: TextStyle(
              fontSize: R.sp(context, 19),
            ),
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  pinnedHtml = controller.text.trim();
                });

                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showInvitationDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          contentPadding: EdgeInsets.fromLTRB(
            R.size(context, 24),
            R.size(context, 18),
            R.size(context, 24),
            R.size(context, 20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                style: TextStyle(
                  fontSize: R.sp(context, 26),
                ),
                decoration: InputDecoration(
                  hintText: 'Username',
                  hintStyle: TextStyle(
                    fontSize: R.sp(context, 26),
                  ),
                ),
              ),

              SizedBox(height: R.size(context, 22)),

              SizedBox(
                width: R.size(context, 170),
                height: R.size(context, 58),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    showMessage('Invitation sent');
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF087887),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        R.size(context, 40),
                      ),
                    ),
                  ),
                  child: Text(
                    'Send',
                    style: TextStyle(
                      fontSize: R.sp(context, 23),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showReportDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Report Violation'),
          content: const Text('Do you want to report this room?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                showMessage('Report sent');
              },
              child: const Text('Report'),
            ),
          ],
        );
      },
    );
  }

  void leaveRoom() {
    Navigator.pop(context);
  }

  void openUsersDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return RoomUsersDialog(
          users: users,
          myRole: myRole,
          onMessageTap: openPrivateChat,
          onUserAction: (user, action) {
            Navigator.pop(context);
            handleUserAction(user, action);
          },
        );
      },
    );
  }

  void openActiveRoomsMenu() {
    showMenu<String>(
      context: context,
      color: const Color(0xFFF4EDF8),
      position: RelativeRect.fromLTRB(
        R.size(context, 12),
        R.size(context, 90),
        R.size(context, 160),
        0,
      ),
      items: const [
        PopupMenuItem(
          value: 'public',
          child: Text('Public rooms'),
        ),
        PopupMenuItem(
          value: 'voice',
          child: Text('Voice rooms'),
        ),
        PopupMenuItem(
          value: 'active',
          child: Text('Active rooms'),
        ),
      ],
    );
  }

  void showUserNameActions(RoomChatUserModel user) {
    showMenu<RoomUserAction>(
      context: context,
      color: const Color(0xFFF4EDF8),
      position: RelativeRect.fromLTRB(
        R.size(context, 90),
        R.size(context, 180),
        R.size(context, 40),
        0,
      ),
      items: [
        const PopupMenuItem(
          value: RoomUserAction.copy,
          child: Text('Copy'),
        ),
        const PopupMenuItem(
          value: RoomUserAction.message,
          child: Text('Message'),
        ),
        if (myRole == RoomRole.owner || myRole == RoomRole.admin) ...[
          const PopupMenuItem(
            value: RoomUserAction.sendGift,
            child: Text('Send Gift'),
          ),
          const PopupMenuItem(
            value: RoomUserAction.kick,
            child: Text('Kick'),
          ),
          const PopupMenuItem(
            value: RoomUserAction.ban,
            child: Text('Ban'),
          ),
          const PopupMenuItem(
            value: RoomUserAction.setMember,
            child: Text('Set Member'),
          ),
          const PopupMenuItem(
            value: RoomUserAction.setAdmin,
            child: Text('Set Admin'),
          ),
        ],
        if (myRole == RoomRole.owner)
          const PopupMenuItem(
            value: RoomUserAction.setOwner,
            child: Text('Set Owner'),
          ),
      ],
    ).then((action) {
      if (action == null) return;

      handleUserAction(user, action);
    });
  }

  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF0F2),
      body: Column(
        children: [
          RoomChatHeader(
            roomName: widget.room.name,
            membersCount: widget.room.membersCount,
            onRoomsMenuTap: openActiveRoomsMenu,
            onUsersTap: openUsersDialog,
            onUploadTap: pickImage,
            onMenuSelect: handleRoomMenu,
          ),

          if (activeVoicePath != null)
            RoomVoicePlayerBar(
              isPlaying: isPlayingVoice,
              onPlayPause: () {
                if (activeVoicePath != null) {
                  playVoice(activeVoicePath!);
                }
              },
              onPause: pauseVoice,
              onClose: closeVoicePlayer,
            ),

          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: EdgeInsets.only(
                top: R.size(context, 14),
                bottom: R.size(context, 12),
              ),
              itemCount: messages.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return RoomPinnedHtmlMessage(html: pinnedHtml);
                }

                final message = messages[index - 1];

                return RoomMessageBubble(
                  message: message,
                  onImageTap: message.localPath == null
                      ? null
                      : () => openImage(message.localPath!),
                  onVoicePlay: message.localPath == null
                      ? null
                      : () => playVoice(message.localPath!),
                  onNameLongPress: () {
                    showUserNameActions(message.sender);
                  },
                  onAvatarTap: () {
                    openUserProfile(message.sender);
                  },
                  onAvatarLongPress: () {
                    showAvatarActions(message.sender);
                  },
                );
              },
            ),
          ),

          RoomInputBar(
            controller: messageController,
            isRecording: isRecording,
            onSendText: sendText,
            onPickImage: pickImage,
            onStartRecord: startRecord,
            onStopRecord: stopRecordAndSend,
            onCancelRecord: cancelRecord,
          ),
        ],
      ),
    );
  }
}