import 'package:flutter/material.dart';

import '../../../core/utils/responsive.dart';
import '../data/chat_item_model.dart';
import 'chat_screen.dart';
import 'widgets/chat_tile.dart';
import 'widgets/chats_search_bar.dart';
import 'widgets/chats_header.dart';
import '../../settings/presentation/settings_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final searchController = TextEditingController();

  String query = '';

  final List<ChatItemModel> chats = const [
    ChatItemModel(
      id: '1',
      name: 'Mostafa',
      lastMessage: 'تمام يا محمد، ابعتلي التفاصيل',
      time: '10:45',
      unreadCount: 3,
      isOnline: true,
    ),
    ChatItemModel(
      id: '2',
      name: 'Ahmed',
      lastMessage: 'Photo',
      lastMessageType: ChatLastMessageType.image,
      time: '10:20',
      unreadCount: 1,
      isOnline: false,
    ),
    ChatItemModel(
      id: '3',
      name: 'Sara',
      lastMessage: 'Voice message',
      lastMessageType: ChatLastMessageType.voice,
      time: '09:55',
      unreadCount: 0,
      isOnline: true,
    ),
    ChatItemModel(
      id: '4',
      name: 'Omar',
      lastMessage: 'Video',
      lastMessageType: ChatLastMessageType.video,
      time: 'Yesterday',
      unreadCount: 8,
      isOnline: true,
    ),
    ChatItemModel(
      id: '5',
      name: 'Bimo Support',
      lastMessage: 'Your request has been received.',
      time: 'Yesterday',
      unreadCount: 0,
    ),
    ChatItemModel(
      id: '6',
      name: 'Mona',
      lastMessage: 'File',
      lastMessageType: ChatLastMessageType.file,
      time: 'Mon',
      unreadCount: 0,
      isOnline: true,
    ),
    ChatItemModel(
      id: '7',
      name: 'Khaled',
      lastMessage: 'Typing...',
      time: 'Mon',
      unreadCount: 2,
      isTyping: true,
      isOnline: true,
    ),
    ChatItemModel(
      id: '8',
      name: 'Hassan',
      lastMessage: 'هكلمك بعد شوية',
      time: 'Sun',
      unreadCount: 0,
    ),
    ChatItemModel(
      id: '9',
      name: 'Nour',
      lastMessage: 'Photo',
      lastMessageType: ChatLastMessageType.image,
      time: 'Sat',
      unreadCount: 5,
      isOnline: true,
    ),
    ChatItemModel(
      id: '10',
      name: 'Ali',
      lastMessage: 'Voice message',
      lastMessageType: ChatLastMessageType.voice,
      time: 'Fri',
      unreadCount: 0,
    ),
    ChatItemModel(
      id: '11',
      name: 'Youssef',
      lastMessage: 'تمام وصلت',
      time: 'Thu',
      unreadCount: 0,
      isOnline: true,
    ),
    ChatItemModel(
      id: '12',
      name: 'Admin',
      lastMessage: 'File',
      lastMessageType: ChatLastMessageType.file,
      time: 'Wed',
      unreadCount: 17,
    ),
  ];

  List<ChatItemModel> get filteredChats {
    final text = query.trim().toLowerCase();

    if (text.isEmpty) {
      return chats;
    }

    return chats.where((chat) {
      return chat.name.toLowerCase().contains(text) ||
          chat.lastMessage.toLowerCase().contains(text);
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void openChat(ChatItemModel chat) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatScreen(chat: chat)),
    );
  }

  void updateSearch(String value) {
    setState(() {
      query = value;
    });
  }

  void openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingScreen()),
    );
  }

  void openNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notifications'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingScreen()),
    );
  }

  void logout() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logout'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final items = filteredChats;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          ChatsHeader(
            onAvatarTap: openProfile,
            onNotificationTap: openNotifications,
            onSettingsTap: openSettings,
            onLogoutTap: logout,
          ),

          ChatsSearchBar(controller: searchController, onChanged: updateSearch),

          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Text(
                      'No chats found',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: R.sp(context, 16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.only(
                      top: R.size(context, 2),
                      bottom: R.size(context, 8),
                    ),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final chat = items[index];

                      return ChatTile(chat: chat, onTap: () => openChat(chat));
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
