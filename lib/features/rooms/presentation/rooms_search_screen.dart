import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/responsive.dart';

import '../data/room_model.dart' as ui;
import '../logic/rooms_provider.dart';
import 'room_chat_screen.dart';

class RoomsSearchScreen extends ConsumerStatefulWidget {
  const RoomsSearchScreen({super.key});

  @override
  ConsumerState<RoomsSearchScreen> createState() => _RoomsSearchScreenState();
}

class _RoomsSearchScreenState extends ConsumerState<RoomsSearchScreen> {
  final searchController = TextEditingController();
  final focusNode = FocusNode();

  Timer? debounce;
  String query = '';

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(roomsProvider.notifier).attachRoomSocketListeners();
      ref.read(roomsProvider.notifier).listRooms('public');
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    debounce?.cancel();
    searchController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void updateSearch(String value) {
    debounce?.cancel();

    debounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;

      setState(() {
        query = value.trim();
      });
    });
  }

  String firstLetter(String text) {
    final value = text.trim();

    if (value.isEmpty) return '?';

    final runes = value.runes.toList();

    if (runes.isEmpty) return '?';

    return String.fromCharCode(runes.first).toUpperCase();
  }

  Color avatarColor(String roomId) {
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

    final hash = roomId.codeUnits.fold<int>(
      0,
      (previous, element) => previous + element,
    );

    return colors[hash % colors.length];
  }

  ui.RoomModel toUiRoom(dynamic room, int index) {
    final roomId = (room.roomId ?? '').toString();
    final name = (room.name ?? '').toString().trim();

    final activeCount =
        ref.read(roomsProvider).activeCountByRoom[roomId] ?? room.activeCount;

    return ui.RoomModel(
      id: roomId,
      name: name,
      membersCount: activeCount,
      rank: index + 1,
      isVerified: room.boostScore > 0,
      isActive: activeCount > 0,
      isVoice: room.voiceEnabled == true,
      isFavorite: room.isFavorite == true,
      avatarColor: avatarColor(roomId),
      avatarText: firstLetter(name),
      showGroupIcon: false,
    );
  }

  void openRoom(ui.RoomModel room) {
    final roomId = room.id ?? '';

    if (roomId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid room id'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ref.read(roomsProvider.notifier).joinRoom(roomId: roomId);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RoomChatScreen(room: room)),
    );
  }

  List<dynamic> filteredRooms(List<dynamic> rooms) {
    final text = query.trim().toLowerCase();

    if (text.isEmpty) return [];

    return rooms.where((room) {
      final name = room.name.toString().toLowerCase();
      final roomId = room.roomId.toString().toLowerCase();

      return name.contains(text) || roomId.contains(text);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final roomsState = ref.watch(roomsProvider);

    final results = filteredRooms(roomsState.rooms);

    ref.listen(roomsProvider, (previous, next) {
      if (next.error != null && next.error!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: R.size(context, 66),
              padding: EdgeInsets.symmetric(horizontal: R.size(context, 24)),
              alignment: Alignment.center,
              child: Container(
                height: R.size(context, 50),
                padding: EdgeInsetsDirectional.only(
                  start: R.size(context, 4),
                  end: R.size(context, 14),
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(R.size(context, 40)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: const Color(0xFF087282),
                        size: R.size(context, 28),
                      ),
                    ),
                    SizedBox(width: R.size(context, 8)),
                    Icon(
                      Icons.search_rounded,
                      size: R.size(context, 28),
                      color: colorScheme.onSurface,
                    ),
                    SizedBox(width: R.size(context, 10)),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        focusNode: focusNode,
                        autofocus: true,
                        onChanged: updateSearch,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: R.sp(context, 22),
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(
                            color: colorScheme.onSurface.withValues(
                              alpha: 0.35,
                            ),
                            fontSize: R.sp(context, 22),
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    if (query.isNotEmpty)
                      IconButton(
                        onPressed: () {
                          searchController.clear();
                          setState(() {
                            query = '';
                          });
                        },
                        icon: Icon(
                          Icons.close_rounded,
                          color: colorScheme.onSurfaceVariant,
                          size: R.size(context, 24),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Divider(height: 1, color: colorScheme.outlineVariant),
            Expanded(
              child: roomsState.loading && roomsState.rooms.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : query.trim().isEmpty
                  ? Center(
                      child: Text(
                        'Search for rooms',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: R.sp(context, 16),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : results.isEmpty
                  ? Center(
                      child: Text(
                        'No rooms found',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: R.sp(context, 16),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        ref.read(roomsProvider.notifier).listRooms('public');
                      },
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                          vertical: R.size(context, 8),
                        ),
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final room = results[index];
                          final uiRoom = toUiRoom(room, index);

                          return ListTile(
                            onTap: () => openRoom(uiRoom),
                            leading: CircleAvatar(
                              radius: R.size(context, 22),
                              backgroundColor: uiRoom.avatarColor.withValues(
                                alpha: 0.16,
                              ),
                              child: Text(
                                uiRoom.avatarText ?? '?',
                                style: TextStyle(
                                  color: uiRoom.avatarColor,
                                  fontSize: R.sp(context, 17),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            title: Text(
                              uiRoom.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: R.sp(context, 17),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              '${uiRoom.membersCount} online'
                              '${uiRoom.isVoice ? ' • Voice' : ''}'
                              '${uiRoom.isFavorite ? ' • Favorite' : ''}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: R.sp(context, 14),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: R.size(context, 16),
                              color: colorScheme.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
