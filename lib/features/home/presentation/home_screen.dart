
import 'package:bimo_chat/features/feed/presentation/feed_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_localizations.dart';

import '../../auth/logic/auth_provider.dart';
import '../../dm/logic/dm_provider.dart';
import '../../dm/presentation/dm_chat_list_screen.dart';
import '../../rooms/presentation/rooms_screen.dart';
import '../../store/presentation/store_screen.dart';
import '../../friends/presentation/friends_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      debugPrint('🏠 HOME: calling dmProvider.loadChats()');

      try {
        await ref.read(dmProvider.notifier).loadChats();

        final state = ref.read(dmProvider);

        debugPrint(
          '✅ HOME: chats loaded successfully. '
          'chats count = ${state.chats.length}',
        );

        for (final chat in state.chats) {
          debugPrint(
            '💬 HOME CHAT => '
            'chatId: ${chat.chatId}, '
            'username: ${chat.peerUsername}, '
            'unreadCount: ${chat.unreadCount}, '
            'lastMessage: ${chat.lastMessageText}',
          );
        }
      } catch (error, stackTrace) {
        debugPrint('❌ HOME: loadChats error: $error');
        debugPrint('❌ HOME STACK: $stackTrace');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context);

    final authState = ref.watch(authProvider);
    final dmState = ref.watch(dmProvider);

    final myUserId = authState.userId ?? '';

    int totalUnreadMessages = 0;

    for (final chat in dmState.chats) {
      totalUnreadMessages += chat.unreadCount;

      debugPrint(
        '🔍 CHECK CHAT => '
        'chatId: ${chat.chatId}, '
        'peerUserId: ${chat.peerUserId}, '
        'username: ${chat.peerUsername}, '
        'unreadCount: ${chat.unreadCount}',
      );
    }

    debugPrint(
      '🔴 TOTAL UNREAD MESSAGES: $totalUnreadMessages',
    );

    final screens = <Widget>[
      const FeedScreen(),
      const RoomsScreen(),
      DmChatListScreen(
        myUserId: myUserId,
      ),
      const FriendsScreen(),
      const StoreScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          debugPrint(
            '📌 NAVIGATION INDEX CHANGED: '
            '$currentIndex => $index',
          );

          setState(() {
            currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(
              Icons.home_outlined,
            ),
            selectedIcon: const Icon(
              Icons.home_rounded,
            ),
            label: lang.t('home'),
          ),

          NavigationDestination(
            icon: const Icon(
              Icons.bubble_chart_outlined,
            ),
            selectedIcon: const Icon(
              Icons.bubble_chart_rounded,
            ),
            label: lang.t('rooms'),
          ),

          NavigationDestination(
            icon: _ChatIconWithBadge(
              icon: Icons.chat_bubble_outline,
              unreadCount: totalUnreadMessages,
            ),
            selectedIcon: _ChatIconWithBadge(
              icon: Icons.chat_bubble_rounded,
              unreadCount: totalUnreadMessages,
            ),
            label: lang.t('chats'),
          ),

          NavigationDestination(
            icon: const Icon(
              Icons.group_outlined,
            ),
            selectedIcon: const Icon(
              Icons.group_rounded,
            ),
            label: lang.t('friends'),
          ),

          NavigationDestination(
            icon: const Icon(
              Icons.storefront_outlined,
            ),
            selectedIcon: const Icon(
              Icons.storefront_rounded,
            ),
            label: lang.t('store'),
          ),
        ],
      ),
    );
  }
}

class _ChatIconWithBadge extends StatelessWidget {
  final IconData icon;
  final int unreadCount;

  const _ChatIconWithBadge({
    required this.icon,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    debugPrint(
      '🎯 CHAT BADGE BUILD => unreadCount: $unreadCount',
    );

    return SizedBox(
      width: 42,
      height: 34,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Icon(
            icon,
            size: 26,
          ),

          if (unreadCount > 0)
            PositionedDirectional(
              top: -5,
              end: -6,
              child: Container(
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: colorScheme.surface,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  unreadCount > 99
                      ? '99+'
                      : unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}