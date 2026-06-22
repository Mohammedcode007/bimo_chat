import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/utils/responsive.dart';
import '../../auth/logic/auth_provider.dart';
import '../data/room_gift_item.dart';
import '../../chats/data/chat_item_model.dart';
import '../../chats/presentation/chat_screen.dart';

import '../../users/presentation/public_profile_screen.dart';

import '../data/room_model.dart';
import '../data/room_role.dart';
import '../data/room_chat_user_model.dart';
import '../data/room_chat_message_model.dart';

import '../logic/rooms_provider.dart';
import '../models/room_live_message_model.dart';
import '../../../core/utils/image_picker_helper.dart';
import '../widgets/active_rooms_drawer.dart';
import '../widgets/room_chat_header.dart';
import '../widgets/room_input_bar.dart';
import '../widgets/room_message_bubble.dart';
import '../widgets/room_pinned_html_message.dart';
import '../widgets/room_users_dialog.dart';
import '../widgets/room_voice_player_bar.dart';
import '../widgets/room_image_preview_screen.dart';
import '../widgets/room_user_action_menu.dart';

import 'room_settings_screen.dart';

class RoomChatScreen extends ConsumerStatefulWidget {
  final RoomModel room;

  const RoomChatScreen({super.key, required this.room});

  @override
  ConsumerState<RoomChatScreen> createState() => _RoomChatScreenState();
}

class _RoomChatScreenState extends ConsumerState<RoomChatScreen> {
  final messageController = TextEditingController();
  final scrollController = ScrollController();

  final imagePicker = ImagePicker();
  final recorder = AudioRecorder();
  final audioPlayer = AudioPlayer();

  bool isRecording = false;
  bool didSendLeave = false;
  bool uploadingMedia = false;
  DateTime? recordStartedAt;

  String? activeVoicePath;
  bool isPlayingVoice = false;
  Duration activeVoicePosition = Duration.zero;
  Duration activeVoiceDuration = Duration.zero;

  StreamSubscription<Duration>? voicePositionSub;
  StreamSubscription<Duration?>? voiceDurationSub;
  StreamSubscription<PlayerState>? voiceStateSub;
  RoomRole myRole = RoomRole.none;

  late final RoomChatUserModel me;

  String pinnedHtml = '';

  List<RoomChatMessageModel> localMessages = [];
  List<RoomModel> localActiveRooms = [];
  final Set<String> shownGiftVideoMessageIds = {};
  @override
  void initState() {
    super.initState();

    me = const RoomChatUserModel(
      id: 'me',
      name: 'Me',
      role: RoomRole.member,
      avatarText: 'M',
      avatarUrl: '',
      frame: 'gold',
      badge: '',
      nameColor: Color(0xFF087887),
      isOnline: true,
    );

    localActiveRooms = [widget.room];
    voicePositionSub = audioPlayer.positionStream.listen((position) {
      if (!mounted) return;

      setState(() {
        activeVoicePosition = position;
      });
    });

    voiceDurationSub = audioPlayer.durationStream.listen((duration) {
      if (!mounted) return;

      setState(() {
        activeVoiceDuration = duration ?? Duration.zero;
      });
    });

    voiceStateSub = audioPlayer.playerStateStream.listen((state) {
      if (!mounted) return;

      final playing = state.playing;

      if (state.processingState == ProcessingState.completed) {
        setState(() {
          isPlayingVoice = false;
          activeVoicePosition = Duration.zero;
        });

        audioPlayer.seek(Duration.zero);
        return;
      }

      setState(() {
        isPlayingVoice = playing;
      });
    });
    /*
      مهم:
      لا تعمل joinRoom هنا لو أنت تعمل joinRoom قبل فتح الشاشة.
      هذا يمنع تكرار رسالة "فلان دخل".
    */

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToBottom(jump: true);
    });
  }

  @override
  void dispose() {
    /*
      مهم جدًا:
      لا ترسل leaveRoom هنا.
      زر الرجوع لا يعني خروج من الغرفة.
      الخروج الحقيقي فقط من اختيار leave من القائمة.
    */
    voicePositionSub?.cancel();
    voiceDurationSub?.cancel();
    voiceStateSub?.cancel();
    messageController.dispose();
    scrollController.dispose();
    recorder.dispose();
    audioPlayer.dispose();

    super.dispose();
  }

  Color get chatBackgroundColor {
    final theme = Theme.of(context);

    if (theme.brightness == Brightness.dark) {
      return theme.colorScheme.surface;
    }

    return const Color(0xFFEAF0F2);
  }

  String firstLetter(String text) {
    final value = text.trim();

    if (value.isEmpty) return '?';

    final runes = value.runes.toList();

    if (runes.isEmpty) return '?';

    return String.fromCharCode(runes.first).toUpperCase();
  }

  RoomRole roleFromString(String value) {
    switch (value.trim().toLowerCase()) {
      case 'creator':
      case 'owner':
        return RoomRole.owner;

      case 'admin':
        return RoomRole.admin;

      case 'member':
        return RoomRole.member;

      case 'banned':
        return RoomRole.banned;

      case 'none':
      default:
        return RoomRole.none;
    }
  }

  Color roleColor(RoomRole role, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (role) {
      case RoomRole.owner:
        return const Color(0xFFF59E0B);

      case RoomRole.admin:
        return const Color(0xFF3B82F6);

      case RoomRole.member:
        return const Color(0xFF087887);

      case RoomRole.banned:
        return colorScheme.error;

      case RoomRole.none:
        return colorScheme.onSurface;
    }
  }

  Color parseUserColor(dynamic value, RoomRole role) {
    final color = (value ?? '').toString().trim();

    if (color.startsWith('#') && color.length == 7) {
      final hex = color.replaceFirst('#', '');
      final parsed = int.tryParse('FF$hex', radix: 16);

      if (parsed != null) {
        return Color(parsed);
      }
    }

    return roleColor(role, context);
  }

  String badgeFromUserMap(Map<String, dynamic> user, RoomRole role) {
    final badgeValue = (user['badgeValue'] ?? '').toString().trim();
    final badgeName = (user['badgeName'] ?? '').toString().trim();
    final badgeKey = (user['badgeKey'] ?? '').toString().trim();

    final verificationType = (user['verificationType'] ?? '')
        .toString()
        .trim()
        .toLowerCase();

    if (badgeValue.isNotEmpty) return badgeValue;
    if (badgeName.isNotEmpty) return badgeName;
    if (badgeKey.isNotEmpty) return badgeKey;

    if (verificationType == 'blue') return '✓';
    if (verificationType == 'gold') return '🏅';
    if (verificationType == 'business') return '✓';

    if (role == RoomRole.owner) return '⭐';
    if (role == RoomRole.admin) return '◆';

    return '';
  }

  Map<String, dynamic>? findLiveUserMap(RoomsState roomsState, String userId) {
    final id = userId.trim();

    if (id.isEmpty) return null;

    final users = roomsState.usersByRoom[widget.room.id] ?? [];

    for (final user in users) {
      final itemId = (user['userId'] ?? user['id'] ?? '').toString().trim();

      if (itemId == id) {
        return user;
      }
    }

    return null;
  }

  RoomChatUserModel userFromLiveMessage(
    RoomLiveMessageModel message,
    RoomsState roomsState,
  ) {
    final liveUser = findLiveUserMap(roomsState, message.fromUserId);

    final rawRole = liveUser == null
        ? message.fromRole
        : (liveUser['role'] ?? message.fromRole).toString();

    final role = roleFromString(rawRole);

    final usernameFromUser = (liveUser?['username'] ?? liveUser?['name'] ?? '')
        .toString()
        .trim();

    final username = usernameFromUser.isNotEmpty
        ? usernameFromUser
        : message.fromUsername.trim().isEmpty
        ? 'User'
        : message.fromUsername.trim();

    final photoUrlFromUser =
        (liveUser?['photoUrl'] ?? liveUser?['avatarUrl'] ?? '')
            .toString()
            .trim();

    final photoUrl = photoUrlFromUser.isNotEmpty
        ? photoUrlFromUser
        : message.fromPhotoUrl;

    final accountColor =
        liveUser?['accountColor'] ??
        liveUser?['nameColor'] ??
        liveUser?['color'];

    final badge = liveUser == null
        ? role == RoomRole.owner
              ? '⭐'
              : role == RoomRole.admin
              ? '◆'
              : ''
        : badgeFromUserMap(liveUser, role);

    final frame = (liveUser?['frame'] ?? liveUser?['avatarFrame'] ?? '')
        .toString()
        .trim();

   final liveUserId =
    (liveUser?['userId'] ?? liveUser?['id'] ?? '').toString().trim();

final finalUserId = liveUserId.isNotEmpty
    ? liveUserId
    : message.fromUserId.trim();

return RoomChatUserModel(
  id: finalUserId,
  name: username,
      role: role,
      avatarText: firstLetter(username),
      avatarUrl: photoUrl,
      frame: frame.isNotEmpty
          ? frame
          : role == RoomRole.owner
          ? 'gold'
          : '',
      badge: badge,
      nameColor: parseUserColor(accountColor, role),
      isOnline: true,
    );
  }

  RoomChatMessageType typeFromLive(RoomLiveMessageModel message) {
    if (message.messageKind == 'join' ||
        message.messageKind == 'leave' ||
        message.messageKind == 'role' ||
        message.messageKind == 'system') {
      return RoomChatMessageType.system;
    }

    final type = message.type.trim().toLowerCase();

    if (type == 'video' || type == 'video') {
      return RoomChatMessageType.video;
    }

    if (type == 'image' || type == 'gif') {
      return RoomChatMessageType.image;
    }

    if (type == 'audio' || type == 'voice') {
      return RoomChatMessageType.voice;
    }

    return RoomChatMessageType.text;
  }

  RoomChatMessageModel messageFromLive(
    RoomLiveMessageModel message,
    RoomsState roomsState,
  ) {
    final sender = userFromLiveMessage(message, roomsState);

    String text = message.text.trim();

    if (message.messageKind == 'join') {
      text = '${sender.name} دخل';
    }

    if (message.messageKind == 'leave') {
      text = '${sender.name} خرج';
    }

    /*
      role لا نعيد كتابته هنا.
      نترك النص القادم من الباك كما هو:
      فلان وضع فلان ادمن
    */

    if (message.mention != null && message.mention!.text.isNotEmpty) {
      text = '@${message.mention!.username} ${message.mention!.text}';
    }

    if (message.gift != null) {
      text = text.isNotEmpty ? text : '🎁 ${message.gift!.name}';
    }

    if (message.entryVideo != null) {
      text = text.isNotEmpty ? text : '${sender.name} دخل الغرفة';
    }

final rawType = message.type.trim().toLowerCase();
final isGiftVideoMessage = rawType == 'video';

final isCenterSystemMessage =
    message.messageKind == 'join' ||
    message.messageKind == 'leave' ||
    message.messageKind == 'role' ||
    message.messageKind == 'system' ||
    isGiftVideoMessage;
    final isMe =
        !isCenterSystemMessage &&
        message.fromUserId.isNotEmpty &&
        roomsState.myUserId.isNotEmpty &&
        message.fromUserId == roomsState.myUserId;

    return RoomChatMessageModel(
      id: message.messageId,
      sender: sender,
      text: text,
      type: typeFromLive(message),
      localPath: message.media?.url,
      isMe: isMe,
      createdAt: message.createdAt,
      systemColor: isGiftVideoMessage
    ? const Color(0xFF087887)
    : isCenterSystemMessage
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : null,
    );
  }

  List<RoomChatMessageModel> buildMessages(RoomsState roomsState) {
    final liveMessages = roomsState.messagesByRoom[widget.room.id] ?? [];

    final converted = liveMessages
        .map((message) => messageFromLive(message, roomsState))
        .toList();

    return [...converted, ...localMessages];
  }

  List<RoomChatUserModel> buildUsers(RoomsState roomsState) {
    final rawUsers = roomsState.usersByRoom[widget.room.id] ?? [];

    final users = rawUsers.map((user) {
      final userId = (user['userId'] ?? user['id'] ?? '').toString().trim();

      final username = (user['username'] ?? user['name'] ?? 'User')
          .toString()
          .trim();

      final photoUrl = (user['photoUrl'] ?? user['avatarUrl'] ?? '').toString();

      final role = roleFromString((user['role'] ?? 'none').toString());

      final accountColor =
          user['accountColor'] ?? user['nameColor'] ?? user['color'];

      final badge = badgeFromUserMap(user, role);

      final frame = (user['frame'] ?? user['avatarFrame'] ?? '').toString();

      return RoomChatUserModel(
        id: userId,
        name: username.isEmpty ? 'User' : username,
        role: role,
        avatarText: firstLetter(username),
        avatarUrl: photoUrl,
        frame: frame.isNotEmpty
            ? frame
            : role == RoomRole.owner
            ? 'gold'
            : '',
        badge: badge,
        nameColor: parseUserColor(accountColor, role),
        isOnline: true,
      );
    }).toList();

    if (users.isEmpty) {
      return [me];
    }

    return users;
  }

  RoomModel uiRoomFromProvider(dynamic room, int index) {
    final name = room.name.toString().trim();

    return RoomModel(
      id: room.roomId,
      name: name,
      membersCount: room.activeCount,
      rank: index + 1,
      isVerified: room.boostScore > 0,
      isActive: room.activeCount > 0,
      isVoice: room.voiceEnabled == true,
      isFavorite: room.isFavorite == true,
      avatarColor: avatarColor(room.roomId),
      avatarText: firstLetter(name),
    );
  }

  Color avatarColor(String id) {
    final colors = <Color>[
      const Color(0xFF009C9A),
      const Color(0xFFA8D988),
      const Color(0xFFE55DAA),
      const Color(0xFFFF7500),
      const Color(0xFF65A532),
      const Color(0xFF4C93F0),
      const Color(0xFF0EA5D8),
      const Color(0xFF7C3AED),
      const Color(0xFFEF4444),
    ];

    final hash = id.codeUnits.fold<int>(
      0,
      (previous, element) => previous + element,
    );

    return colors[hash % colors.length];
  }

  void updatePinnedFromProvider(RoomsState roomsState) {
    for (final room in roomsState.rooms) {
      if (room.roomId != widget.room.id) continue;

      final text = room.pinnedMessage.text.trim();

      /*
        مهم:
        لو النص فاضي نخليه فاضي.
        لا نحتفظ بالرسالة القديمة.
      */
      pinnedHtml = text;

      myRole = roleFromString(room.role);
      return;
    }

    pinnedHtml = '';
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

    ref
        .read(roomsProvider.notifier)
        .sendTextMessage(roomId: widget.room.id, text: text);

    scrollToBottom();
  }

  Future<void> pickImage() async {
    if (uploadingMedia) return;

    setState(() {
      uploadingMedia = true;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'gif'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final picked = result.files.first;

      final fileName = picked.name.trim().isEmpty
          ? 'room_image.jpg'
          : picked.name.trim();

      final lowerName = fileName.toLowerCase();

      final bool isGif = lowerName.endsWith('.gif');
      final bool isPng = lowerName.endsWith('.png');
      final bool isWebp = lowerName.endsWith('.webp');

      final String mimeType = isGif
          ? 'image/gif'
          : isPng
          ? 'image/png'
          : isWebp
          ? 'image/webp'
          : 'image/jpeg';

      final String type = isGif ? 'gif' : 'image';

      List<int>? bytes = picked.bytes;

      if (bytes == null &&
          picked.path != null &&
          picked.path!.trim().isNotEmpty) {
        final file = File(picked.path!);

        if (!await file.exists()) {
          showMessage('Image file not found');
          return;
        }

        bytes = await file.readAsBytes();
      }

      if (bytes == null || bytes.isEmpty) {
        showMessage('Image file is empty');
        return;
      }

      final mediaBase64 = 'data:$mimeType;base64,${base64Encode(bytes)}';

      await ref
          .read(roomsProvider.notifier)
          .sendMediaBase64Message(
            roomId: widget.room.id,
            type: type,
            mediaBase64: mediaBase64,
            fileName: fileName,
            mimeType: mimeType,
            sizeBytes: bytes.length,
          );

      scrollToBottom();
    } catch (error) {
      print('[ROOM_PICK_MEDIA_BASE64_ERROR] $error');
      showMessage('Media upload failed');
    } finally {
      if (mounted) {
        setState(() {
          uploadingMedia = false;
        });
      }
    }
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
      uploadingMedia = true;
    });

    try {
      if (path == null || path.trim().isEmpty) return;

      final file = File(path);

      if (!await file.exists()) {
        showMessage('Voice file not found');
        return;
      }

      final bytes = await file.readAsBytes();
      final sizeBytes = await file.length();

      final duration = startedAt == null ? '0:00' : currentDuration(startedAt);

      final mediaBase64 = 'data:audio/m4a;base64,${base64Encode(bytes)}';

      await ref
          .read(roomsProvider.notifier)
          .sendMediaBase64Message(
            roomId: widget.room.id,
            type: 'audio',
            mediaBase64: mediaBase64,
            fileName: 'room_voice.m4a',
            mimeType: 'audio/m4a',
            sizeBytes: sizeBytes,
            duration: duration,
          );

      scrollToBottom();
    } catch (error) {
      print('[ROOM_VOICE_BASE64_ERROR] $error');
      showMessage('Voice upload failed');
    } finally {
      if (mounted) {
        setState(() {
          uploadingMedia = false;
        });
      }
    }
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
    if (path.trim().isEmpty) return;

    try {
      if (activeVoicePath == path && isPlayingVoice) {
        await audioPlayer.pause();

        setState(() {
          isPlayingVoice = false;
        });

        return;
      }

      if (activeVoicePath == path && !isPlayingVoice) {
        await audioPlayer.play();

        setState(() {
          isPlayingVoice = true;
        });

        return;
      }

      await audioPlayer.stop();

      setState(() {
        activeVoicePath = path;
        isPlayingVoice = false;
        activeVoicePosition = Duration.zero;
        activeVoiceDuration = Duration.zero;
      });

      if (path.startsWith('http://') || path.startsWith('https://')) {
        await audioPlayer.setUrl(path);
      } else {
        await audioPlayer.setFilePath(path);
      }

      await audioPlayer.play();

      setState(() {
        isPlayingVoice = true;
      });
    } catch (error) {
      print('[ROOM_PLAY_VOICE_ERROR] $error');
      showMessage('Voice play failed');
    }
  }

  Future<void> pauseVoice() async {
    await audioPlayer.pause();

    setState(() {
      isPlayingVoice = false;
    });
  }

  Future<void> seekVoice(Duration position) async {
    await audioPlayer.seek(position);

    setState(() {
      activeVoicePosition = position;
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

  void addSystemMessage(String text, {Color? color}) {
    final fallbackColor = Theme.of(context).colorScheme.error;

    setState(() {
      localMessages.add(
        RoomChatMessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          sender: me,
          text: text,
          type: RoomChatMessageType.system,
          createdAt: DateTime.now(),
          systemColor: color ?? fallbackColor,
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
  final userId = user.id == 'me' ? roomsStateMyId() : user.id.trim();

  if (userId.isEmpty) {
    showMessage('User profile not available');
    return;
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => PublicProfileScreen(userId: userId),
    ),
  );
}
  String roomsStateMyId() {
    final id = ref.read(roomsProvider).myUserId.trim();
    return id.isEmpty ? 'me' : id;
  }

void sendRoomGift({
  required RoomChatUserModel targetUser,
  required RoomGiftItem gift,
}) {
  final authState = ref.read(authProvider);

  final myPoints =
      int.tryParse(authState.user?['points']?.toString() ?? '') ?? 0;

  if (myPoints < gift.price) {
    showMessage('Not enough points');
    return;
  }

  final senderName = ref.read(roomsProvider).myUsername.trim().isEmpty
      ? 'Someone'
      : ref.read(roomsProvider).myUsername.trim();

  final targetName = targetUser.name.trim().isEmpty
      ? 'someone'
      : targetUser.name.trim();

  final giftText = '$senderName sent ${gift.name} to $targetName';

  ref.read(roomsProvider.notifier).sendMediaMessage(
        roomId: widget.room.id,
        type: 'video',
        url: gift.videoUrl,
        text: giftText,
        fileName: '${gift.id}.mp4',
        mimeType: 'video/mp4',
        sizeBytes: 0,
      );

  showMessage('${gift.name} sent');

  scrollToBottom();
}
  void showRoomGiftsSheet(RoomChatUserModel user) {
    final colorScheme = Theme.of(context).colorScheme;
    final authState = ref.read(authProvider);

    final myPoints =
        int.tryParse(authState.user?['points']?.toString() ?? '') ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(R.size(context, 24)),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              R.size(context, 14),
              R.size(context, 10),
              R.size(context, 14),
              R.size(context, 16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: R.size(context, 46),
                  height: R.size(context, 5),
                  margin: EdgeInsets.only(bottom: R.size(context, 12)),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),

                Row(
                  children: [
                    Icon(
                      Icons.card_giftcard_rounded,
                      color: colorScheme.primary,
                      size: R.size(context, 28),
                    ),
                    SizedBox(width: R.size(context, 10)),
                    Expanded(
                      child: Text(
                        'Send gift to ${user.name}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: R.sp(context, 20),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: R.size(context, 10),
                        vertical: R.size(context, 5),
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '$myPoints pts',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: R.sp(context, 13),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: R.size(context, 14)),

                ...roomGiftItems.map((gift) {
                  final canBuy = myPoints >= gift.price;

                  return Padding(
                    padding: EdgeInsets.only(bottom: R.size(context, 8)),
                    child: InkWell(
                      onTap: canBuy
                          ? () {
                              Navigator.pop(sheetContext);
                              sendRoomGift(targetUser: user, gift: gift);
                            }
                          : () {
                              showMessage('Not enough points');
                            },
                      borderRadius: BorderRadius.circular(R.size(context, 18)),
                      child: Container(
                        padding: EdgeInsets.all(R.size(context, 12)),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.55,
                          ),
                          borderRadius: BorderRadius.circular(
                            R.size(context, 18),
                          ),
                          border: Border.all(
                            color: canBuy
                                ? colorScheme.outlineVariant.withValues(
                                    alpha: 0.35,
                                  )
                                : colorScheme.error.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: R.size(context, 48),
                              height: R.size(context, 48),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.10,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                gift.emoji,
                                style: TextStyle(fontSize: R.sp(context, 25)),
                              ),
                            ),

                            SizedBox(width: R.size(context, 12)),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    gift.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                      fontSize: R.sp(context, 18),
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  SizedBox(height: R.size(context, 3)),
                                  Text(
                                    '${gift.price} points',
                                    style: TextStyle(
                                      color: canBuy
                                          ? colorScheme.onSurfaceVariant
                                          : colorScheme.error,
                                      fontSize: R.sp(context, 14),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Icon(
                              canBuy ? Icons.send_rounded : Icons.lock_rounded,
                              color: canBuy
                                  ? colorScheme.primary
                                  : colorScheme.error,
                              size: R.size(context, 24),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                SizedBox(height: R.size(context, 4)),
              ],
            ),
          ),
        );
      },
    );
  }

  void showAvatarActions(RoomChatUserModel user) {
    final colorScheme = Theme.of(context).colorScheme;

    final canManageUsers = myRole == RoomRole.owner || myRole == RoomRole.admin;
    final canSetOwner = myRole == RoomRole.owner;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(R.size(context, 24)),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetContext).size.height * 0.72,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: R.size(context, 10),
                bottom:
                    R.size(context, 14) +
                    MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: R.size(context, 46),
                    height: R.size(context, 5),
                    margin: EdgeInsets.only(bottom: R.size(context, 10)),
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),

                  ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    leading: Icon(
                      Icons.copy_rounded,
                      color: colorScheme.onSurface,
                    ),
                    title: Text(
                      'Copy name',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: R.sp(context, 17),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(sheetContext);

                      await Clipboard.setData(ClipboardData(text: user.name));

                      showMessage('${user.name} copied');
                    },
                  ),

                  ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    leading: Icon(
                      Icons.card_giftcard_rounded,
                      color: colorScheme.onSurface,
                      size: R.size(context, 30),
                    ),
                    title: Text(
                      'Send Gift',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: R.sp(context, 20),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      showRoomGiftsSheet(user);
                    },
                  ),
                  if (canManageUsers) ...[
                    Divider(
                      height: 1,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.45),
                    ),

                    ListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      leading: Icon(
                        Icons.person_add_alt_1_rounded,
                        color: colorScheme.onSurface,
                      ),
                      title: Text(
                        'Set Member',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: R.sp(context, 17),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        handleUserAction(user, RoomUserAction.setMember);
                      },
                    ),

                    ListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      leading: Icon(
                        Icons.admin_panel_settings_rounded,
                        color: colorScheme.onSurface,
                      ),
                      title: Text(
                        'Set Admin',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: R.sp(context, 17),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        handleUserAction(user, RoomUserAction.setAdmin);
                      },
                    ),

                    if (canSetOwner)
                      ListTile(
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        leading: Icon(
                          Icons.star_rounded,
                          color: colorScheme.onSurface,
                        ),
                        title: Text(
                          'Set Owner',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: R.sp(context, 17),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          handleUserAction(user, RoomUserAction.setOwner);
                        },
                      ),

                    ListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      leading: Icon(
                        Icons.person_remove_rounded,
                        color: colorScheme.onSurface,
                      ),
                      title: Text(
                        'Remove Role',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: R.sp(context, 17),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        handleUserAction(user, RoomUserAction.removeRole);
                      },
                    ),

                    ListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      leading: Icon(
                        Icons.logout_rounded,
                        color: colorScheme.onSurface,
                      ),
                      title: Text(
                        'Kick',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: R.sp(context, 17),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        handleUserAction(user, RoomUserAction.kick);
                      },
                    ),

                    ListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      leading: Icon(
                        Icons.block_rounded,
                        color: colorScheme.error,
                      ),
                      title: Text(
                        'Ban',
                        style: TextStyle(
                          color: colorScheme.error,
                          fontSize: R.sp(context, 17),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        handleUserAction(user, RoomUserAction.ban);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  RoomChatUserModel copyUserWithRole(RoomChatUserModel user, RoomRole role) {
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

 Future<void> openRoomPost() async {
  await pickImage();
}
void boostRoomFromHeader() {
  ref.read(roomsProvider.notifier).boostRoom(roomId: widget.room.id);

  addSystemMessage(
    'Room has been boosted',
    color: const Color(0xFF087887),
  );

  showMessage('Boost sent');
}
  void handleUserAction(RoomChatUserModel user, RoomUserAction action) {
    switch (action) {
      case RoomUserAction.message:
        openPrivateChat(user);
        break;
      case RoomUserAction.sendGift:
        showRoomGiftsSheet(user);
        break;

      case RoomUserAction.kick:
        ref
            .read(roomsProvider.notifier)
            .kickUser(
              roomId: widget.room.id,
              targetUserId: user.id,
              targetUsername: user.name,
            );
        break;

      case RoomUserAction.ban:
        ref
            .read(roomsProvider.notifier)
            .banUser(
              roomId: widget.room.id,
              targetUserId: user.id,
              targetUsername: user.name,
              banIp: false,
            );
        break;

      case RoomUserAction.setMember:
        ref
            .read(roomsProvider.notifier)
            .setRole(
              roomId: widget.room.id,
              targetUserId: user.id,
              targetUsername: user.name,
              newRole: 'member',
            );
        break;

      case RoomUserAction.setAdmin:
        ref
            .read(roomsProvider.notifier)
            .setRole(
              roomId: widget.room.id,
              targetUserId: user.id,
              targetUsername: user.name,
              newRole: 'admin',
            );
        break;

      case RoomUserAction.setOwner:
        ref
            .read(roomsProvider.notifier)
            .setRole(
              roomId: widget.room.id,
              targetUserId: user.id,
              targetUsername: user.name,
              newRole: 'owner',
            );
        break;

      case RoomUserAction.removeRole:
        ref
            .read(roomsProvider.notifier)
            .setRole(
              roomId: widget.room.id,
              targetUserId: user.id,
              targetUsername: user.name,
              newRole: 'none',
            );
        break;

      case RoomUserAction.copy:
        Clipboard.setData(ClipboardData(text: user.name));
        addSystemMessage('${user.name} copied', color: Colors.grey);
        break;
    }
  }

  void handleRoomMenu(String value) {
    switch (value) {
      case 'favorite':
        ref.read(roomsProvider.notifier).toggleFavorite(widget.room.id);
        showMessage('Favorite updated');
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
        builder: (_) => RoomSettingsScreen(
          roomId: widget.room.id,
          roomName: widget.room.name,
        ),
      ),
    );
  }

  void showWelcomeMessageDialog() {
    final controller = TextEditingController(text: pinnedHtml);
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          title: Text(
            'Welcome message',
            style: TextStyle(
              color: colorScheme.onSurface,
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
              color: colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF087887), width: 1.4),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final text = controller.text.trim();

                setState(() {
                  pinnedHtml = text;
                });

                ref
                    .read(roomsProvider.notifier)
                    .setPinnedMessage(roomId: widget.room.id, text: text);

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
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
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
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Username',
                  hintStyle: TextStyle(
                    fontSize: R.sp(context, 26),
                    color: colorScheme.onSurface.withValues(alpha: 0.38),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFF087887),
                      width: 1.4,
                    ),
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
                      borderRadius: BorderRadius.circular(R.size(context, 40)),
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
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          title: Text(
            'Report Violation',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Do you want to report this room?',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
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
    if (!didSendLeave) {
      didSendLeave = true;

      ref.read(roomsProvider.notifier).leaveRoom(widget.room.id);
      ref.read(roomsProvider.notifier).clearRoomLocalData(widget.room.id);
    }

    Navigator.pop(context);
  }

  void openUsersDialog(List<RoomChatUserModel> users) {
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

  void openActiveRoomsMenu(List<RoomModel> activeRooms) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Active rooms',
      barrierColor: Colors.black.withValues(
        alpha: Theme.of(context).brightness == Brightness.dark ? 0.32 : 0.10,
      ),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ActiveRoomsDrawer(
          currentRoom: widget.room,
          activeRooms: activeRooms.isEmpty ? [widget.room] : activeRooms,
          onRoomTap: openActiveRoom,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        );
      },
    );
  }

  void openActiveRoom(RoomModel room) {
    if (room.id == widget.room.id) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => RoomChatScreen(room: room)),
    );
  }

  PopupMenuItem<RoomUserAction> userMenuItem({
    required RoomUserAction value,
    required String title,
    required Color textColor,
  }) {
    return PopupMenuItem(
      value: value,
      child: Text(
        title,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
      ),
    );
  }

  void showUserNameActions(RoomChatUserModel user) {
    final colorScheme = Theme.of(context).colorScheme;

    showMenu<RoomUserAction>(
      context: context,
      color: colorScheme.surface,
      position: RelativeRect.fromLTRB(
        R.size(context, 90),
        R.size(context, 180),
        R.size(context, 40),
        0,
      ),
      items: [
        userMenuItem(
          value: RoomUserAction.copy,
          title: 'Copy',
          textColor: colorScheme.onSurface,
        ),
        userMenuItem(
          value: RoomUserAction.message,
          title: 'Message',
          textColor: colorScheme.onSurface,
        ),
        if (myRole == RoomRole.owner || myRole == RoomRole.admin) ...[
          userMenuItem(
            value: RoomUserAction.sendGift,
            title: 'Send Gift',
            textColor: colorScheme.onSurface,
          ),
          userMenuItem(
            value: RoomUserAction.kick,
            title: 'Kick',
            textColor: colorScheme.onSurface,
          ),
          userMenuItem(
            value: RoomUserAction.ban,
            title: 'Ban',
            textColor: colorScheme.error,
          ),
          userMenuItem(
            value: RoomUserAction.setMember,
            title: 'Set Member',
            textColor: colorScheme.onSurface,
          ),
          userMenuItem(
            value: RoomUserAction.setAdmin,
            title: 'Set Admin',
            textColor: colorScheme.onSurface,
          ),
        ],
        if (myRole == RoomRole.owner)
          userMenuItem(
            value: RoomUserAction.setOwner,
            title: 'Set Owner',
            textColor: colorScheme.onSurface,
          ),
      ],
    ).then((action) {
      if (action == null) return;

      handleUserAction(user, action);
    });
  }

  void checkAndOpenGiftVideo(List<RoomChatMessageModel> messages) {
    for (final message in messages) {
      if (message.type != RoomChatMessageType.video) continue;

      final videoUrl = message.localPath?.trim() ?? '';

      if (videoUrl.isEmpty) continue;
      if (shownGiftVideoMessageIds.contains(message.id)) continue;

      shownGiftVideoMessageIds.add(message.id);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        Navigator.of(context, rootNavigator: true).push(
          PageRouteBuilder(
            opaque: true,
            barrierDismissible: false,
            pageBuilder: (_, __, ___) {
              return ForcedGiftVideoScreen(videoUrl: videoUrl);
            },
          ),
        );
      });

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

  @override
  Widget build(BuildContext context) {
    final roomsState = ref.watch(roomsProvider);

    updatePinnedFromProvider(roomsState);

    final messages = buildMessages(roomsState);
    checkAndOpenGiftVideo(messages);

    final users = buildUsers(roomsState);

    final activeRooms = roomsState.rooms
        .asMap()
        .entries
        .where((entry) => entry.value.activeCount > 0)
        .map((entry) => uiRoomFromProvider(entry.value, entry.key))
        .toList();

    final activeCount =
        roomsState.activeCountByRoom[widget.room.id] ??
        widget.room.membersCount;

    final hasPinnedMessage = pinnedHtml.trim().isNotEmpty;

    ref.listen(roomsProvider, (previous, next) {
      final oldCount = previous?.messagesByRoom[widget.room.id]?.length ?? 0;
      final newCount = next.messagesByRoom[widget.room.id]?.length ?? 0;

      if (newCount > oldCount) {
        scrollToBottom();
      }

      if (next.error != null && next.error!.isNotEmpty) {
        showMessage(next.error!);
      }
    });

    return Scaffold(
      backgroundColor: chatBackgroundColor,
      body: Column(
        children: [
         RoomChatHeader(
  roomName: widget.room.name,
  membersCount: activeCount,
  isFavorite: widget.room.isFavorite,
  onRoomsMenuTap: () => openActiveRoomsMenu(activeRooms),
  onUsersTap: () => openUsersDialog(users),

  // أيقونة رفع الصورة القديمة أصبحت تعمل Boost
  onUploadTap: boostRoomFromHeader,

  // أيقونة البوست أصبحت تختار صورة/ميديا
  onPostTap: openRoomPost,

  onMenuSelect: handleRoomMenu,
),
          if (activeVoicePath != null)
            RoomVoicePlayerBar(
              isPlaying: isPlayingVoice,
              position: activeVoicePosition,
              duration: activeVoiceDuration,
              onPlayPause: () {
                if (activeVoicePath != null) {
                  playVoice(activeVoicePath!);
                }
              },
              onSeek: seekVoice,
              onClose: closeVoicePlayer,
            ),
          Expanded(
            child: Container(
              color: chatBackgroundColor,
              child: ListView.builder(
                controller: scrollController,
                padding: EdgeInsets.only(
                  top: R.size(context, 14),
                  bottom: R.size(context, 12),
                ),
                itemCount: messages.length + (hasPinnedMessage ? 1 : 0),
                itemBuilder: (context, index) {
                  if (hasPinnedMessage && index == 0) {
                    return RoomPinnedHtmlMessage(html: pinnedHtml);
                  }

                 final messageIndex = hasPinnedMessage ? index - 1 : index;
final message = messages[messageIndex];

if (message.type == RoomChatMessageType.video) {
  return _GiftSystemMessage(text: message.text);
}

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
class _GiftSystemMessage extends StatelessWidget {
  final String text;

  const _GiftSystemMessage({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final value = text.trim().isEmpty ? 'Gift sent' : text.trim();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: R.size(context, 24),
        vertical: R.size(context, 8),
      ),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: R.size(context, 16),
            vertical: R.size(context, 8),
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF087887).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: const Color(0xFF087887).withValues(alpha: 0.30),
            ),
          ),
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF087887),
              fontSize: R.sp(context, 14),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}
class ForcedGiftVideoScreen extends StatefulWidget {
  final String videoUrl;

  const ForcedGiftVideoScreen({
    super.key,
    required this.videoUrl,
  });

  @override
  State<ForcedGiftVideoScreen> createState() => _ForcedGiftVideoScreenState();
}

class _ForcedGiftVideoScreenState extends State<ForcedGiftVideoScreen> {
  VideoPlayerController? controller;

  bool ready = false;
  bool closed = false;

  @override
  void initState() {
    super.initState();
    initVideo();
  }

  Future<void> initVideo() async {
    final url = widget.videoUrl.trim();

    if (url.isEmpty) {
      closeScreen();
      return;
    }

    try {
      final c = VideoPlayerController.networkUrl(Uri.parse(url));

      controller = c;

      await c.initialize();
      await c.setLooping(false);
      await c.play();

      c.addListener(() {
        if (!mounted || closed) return;

        final value = c.value;

        final finished =
            value.isInitialized &&
            value.duration > Duration.zero &&
            value.position >= value.duration;

        if (finished) {
          closeScreen();
        }
      });

      if (!mounted) return;

      setState(() {
        ready = true;
      });
    } catch (error) {
      debugPrint('[FORCED_video_ERROR] $error');

      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        closeScreen();
      });
    }
  }

  void closeScreen() {
    if (closed) return;

    closed = true;

    if (!mounted) return;

    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SizedBox.expand(
          child: !ready || controller == null
              ? const SizedBox.shrink()
              : FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: controller!.value.size.width,
                    height: controller!.value.size.height,
                    child: VideoPlayer(controller!),
                  ),
                ),
        ),
      ),
    );
  }
}
