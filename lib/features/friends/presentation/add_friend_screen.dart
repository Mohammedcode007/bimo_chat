import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/responsive.dart';
import '../../chats/data/chat_item_model.dart';
import '../../chats/presentation/chat_screen.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final searchController = TextEditingController();

  String query = '';

  final List<String> users = const [
    'Mostafa',
    'Ahmed',
    'Sara',
    'Omar',
    'Mona',
    'Khaled',
    'Hassan',
    'Nour',
    'Ali',
    'Youssef',
  ];

  List<String> get filteredUsers {
    final text = query.trim().toLowerCase();

    if (text.isEmpty) return [];

    return users.where((name) {
      return name.toLowerCase().contains(text);
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void updateSearch(String value) {
    setState(() {
      query = value;
    });
  }

  void closePage() {
    Navigator.pop(context);
  }

  void openChatWithUser(String name) {
    final chat = ChatItemModel(
      id: name.toLowerCase(),
      name: name,
      lastMessage: '',
      time: '',
      unreadCount: 0,
      isOnline: true,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(chat: chat),
      ),
    );
  }

  void sendRequest(String name) {
    final lang = AppLocalizations.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${lang.t('friend_request_sent_to')} $name',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final lang = AppLocalizations.of(context);
    final items = filteredUsers;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                R.size(context, 8),
                R.size(context, 10),
                R.size(context, 16),
                R.size(context, 10),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: closePage,
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      size: R.size(context, 28),
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      lang.t('add_friend'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: R.sp(context, 27),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              height: R.size(context, 50),
              margin: EdgeInsets.symmetric(
                horizontal: R.size(context, 18),
              ),
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: R.size(context, 14),
              ),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(
                  R.size(context, 28),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    size: R.size(context, 23),
                    color: colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(width: R.size(context, 8)),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      autofocus: true,
                      onChanged: updateSearch,
                      textInputAction: TextInputAction.search,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: R.sp(context, 16),
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: lang.t('search_username'),
                        hintStyle: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: R.sp(context, 16),
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: R.size(context, 14)),

            Expanded(
              child: _buildBody(
                context: context,
                colorScheme: colorScheme,
                items: items,
                searchByUsernameText: lang.t('search_by_username'),
                noUsersFoundText: lang.t('no_users_found'),
                addText: lang.t('add'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody({
    required BuildContext context,
    required ColorScheme colorScheme,
    required List<String> items,
    required String searchByUsernameText,
    required String noUsersFoundText,
    required String addText,
  }) {
    if (query.trim().isEmpty) {
      return _EmptyText(
        text: searchByUsernameText,
        colorScheme: colorScheme,
      );
    }

    if (items.isEmpty) {
      return _EmptyText(
        text: noUsersFoundText,
        colorScheme: colorScheme,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final name = items[index];

        return _UserResultTile(
          name: name,
          addText: addText,
          onTap: () => openChatWithUser(name),
          onAdd: () => sendRequest(name),
        );
      },
    );
  }
}

class _EmptyText extends StatelessWidget {
  final String text;
  final ColorScheme colorScheme;

  const _EmptyText({
    required this.text,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: R.sp(context, 15),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _UserResultTile extends StatelessWidget {
  final String name;
  final String addText;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  const _UserResultTile({
    required this.name,
    required this.addText,
    required this.onTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final username = '@${name.toLowerCase()}';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
          R.size(context, 18),
          R.size(context, 4),
          R.size(context, 18),
          0,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: R.size(context, 28),
              backgroundColor: colorScheme.primary.withValues(
                alpha: 0.12,
              ),
              child: Text(
                name[0].toUpperCase(),
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: R.sp(context, 21),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),

            SizedBox(width: R.size(context, 14)),

            Expanded(
              child: Container(
                constraints: BoxConstraints(
                  minHeight: R.size(context, 72),
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: colorScheme.outlineVariant.withValues(
                        alpha: 0.75,
                      ),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: R.sp(context, 18),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: R.size(context, 3)),
                          Text(
                            username,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: R.sp(context, 13),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    TextButton(
                      onPressed: onAdd,
                      child: Text(
                        addText,
                        style: TextStyle(
                          fontSize: R.sp(context, 14),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}