import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/responsive.dart';
import '../logic/rooms_provider.dart';
import '../logic/room_admin_provider.dart';

class RoomSettingsScreen extends ConsumerStatefulWidget {
  final String roomId;
  final String roomName;

  const RoomSettingsScreen({
    super.key,
    required this.roomId,
    required this.roomName,
  });

  @override
  ConsumerState<RoomSettingsScreen> createState() => _RoomSettingsScreenState();
}

class _RoomSettingsScreenState extends ConsumerState<RoomSettingsScreen> {
  bool localMembersOnly = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(roomAdminProvider.notifier).attachListeners();
ref.read(roomAdminProvider.notifier).listRoomRoles(
      roomId: widget.roomId,
      role: 'owner',
    );

ref.read(roomAdminProvider.notifier).listRoomRoles(
      roomId: widget.roomId,
      role: 'admin',
    );

ref.read(roomAdminProvider.notifier).listRoomRoles(
      roomId: widget.roomId,
      role: 'member',
    );

ref.read(roomAdminProvider.notifier).listRoomBanned(
      roomId: widget.roomId,
    );

ref.read(roomAdminProvider.notifier).listRoomLogs(
      roomId: widget.roomId,
      limit: 50,
    );
      final roomsState = ref.read(roomsProvider);

      final room = roomsState.rooms.where((item) {
        return item.roomId == widget.roomId;
      }).firstOrNull;

      if (room != null) {
        setState(() {
          localMembersOnly = room.isLockedForNone;
        });
      }
    });
  }

  @override
  void dispose() {
    ref.read(roomAdminProvider.notifier).disposeListeners();
    super.dispose();
  }

  void showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, textDirection: TextDirection.rtl),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
Future<void> openAddUserDialog({
  required String title,
  required String action,
  required String role,
}) async {
  final usernameController = TextEditingController();

  final result = await showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          title,
          textDirection: TextDirection.rtl,
        ),
        content: TextField(
          controller: usernameController,
          autofocus: true,
          textDirection: TextDirection.rtl,
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'اكتب اسم المستخدم فقط',
          ),
          onSubmitted: (value) {
            Navigator.pop(context, value.trim());
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context, usernameController.text.trim());
            },
            child: const Text('إضافة'),
          ),
        ],
      );
    },
  );

  usernameController.dispose();

  if (!mounted || result == null) return;

  final username = result.trim();

  if (username.isEmpty) {
    showSnack('اكتب اسم المستخدم');
    return;
  }

  if (action == 'ban') {
    ref.read(roomsProvider.notifier).banUser(
          roomId: widget.roomId,
          targetUsername: username,
          banIp: false,
        );

    showSnack('تم إرسال طلب الحظر');
    return;
  }

  ref.read(roomsProvider.notifier).setRole(
        roomId: widget.roomId,
        targetUsername: username,
        newRole: role,
      );

  showSnack('تم إرسال طلب الإضافة');
}
  Future<void> openPasswordDialog() async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Room Password'),
          content: TextField(
            controller: controller,
            obscureText: true,
            decoration: const InputDecoration(hintText: 'Enter password'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, 'remove');
              },
              child: const Text('Remove'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, controller.text.trim());
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (!mounted || result == null) return;

    if (result == 'remove') {
      ref.read(roomsProvider.notifier).removePassword(widget.roomId);
      showSnack('تم حذف باسورد الغرفة');
      return;
    }

    if (result.trim().isEmpty) {
      showSnack('اكتب باسورد صحيح');
      return;
    }

    ref
        .read(roomsProvider.notifier)
        .setPassword(roomId: widget.roomId, password: result.trim());

    showSnack('تم إرسال تغيير الباسورد');
  }

Future<void> openPinnedDialog() async {
  final controller = TextEditingController();

  final roomsState = ref.read(roomsProvider);
  final room = roomsState.rooms.where((item) {
    return item.roomId == widget.roomId;
  }).firstOrNull;

  controller.text = room?.pinnedMessage.text ?? '';

  final result = await showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Pinned Message'),
        content: TextField(
          controller: controller,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Write pinned message',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, '__remove__');
            },
            child: const Text('Remove'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context, controller.text.trim());
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );

  controller.dispose();

  if (!mounted || result == null) return;

  if (result == '__remove__') {
    ref.read(roomsProvider.notifier).setPinnedMessage(
          roomId: widget.roomId,
          text: '',
        );

    showSnack('تم إلغاء الرسالة المثبتة');
    return;
  }

  ref.read(roomsProvider.notifier).setPinnedMessage(
        roomId: widget.roomId,
        text: result.trim(),
      );

  if (result.trim().isEmpty) {
    showSnack('تم إلغاء الرسالة المثبتة');
  } else {
    showSnack('تم إرسال الرسالة المثبتة');
  }
}
  void toggleMembersOnly(bool value) {
    setState(() {
      localMembersOnly = value;
    });

    ref
        .read(roomsProvider.notifier)
        .setRoomLock(roomId: widget.roomId, locked: value);

    showSnack(value ? 'تم قفل الغرفة للأعضاء فقط' : 'تم فتح الغرفة للجميع');
  }

  void toggleFavorite() {
    ref.read(roomsProvider.notifier).toggleFavorite(widget.roomId);
    showSnack('تم إرسال تحديث المفضلة');
  }

  void boostRoom() {
    ref.read(roomsProvider.notifier).boostRoom(roomId: widget.roomId);
    showSnack('تم إرسال Boost للغرفة');
  }

  void openActiveUsersSheet(List<Map<String, dynamic>> activeUsers) {
    showUsersSheet(
      title: 'Active Users',
      users: activeUsers,
      emptyText: 'لا يوجد مستخدمين نشطين الآن',
      canRemoveRole: false,
    );
  }

void openRoleSheet({
  required String title,
  required String role,
}) {
  ref.read(roomAdminProvider.notifier).listRoomRoles(
        roomId: widget.roomId,
        role: role,
      );

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      return Consumer(
        builder: (context, ref, _) {
          final adminState = ref.watch(roomAdminProvider);
          final users =
              adminState.roleUsersByRoom['${widget.roomId}_$role'] ?? [];

          return _UsersSheetContent(
            title: title,
            loading: adminState.loading,
            users: users,
            emptyText: 'لا يوجد مستخدمين هنا',
            canRemoveRole: role != 'creator',
            showAddButton: true,
            onAddTap: () {
              openAddUserDialog(
                title: 'إضافة $title',
                action: 'role',
                role: role,
              );
            },
            onRemoveRole: (user) {
              final userId = _s(user['userId']);
              final username = _s(user['username'], fallback: 'User');

              if (userId.isEmpty) return;

              ref.read(roomAdminProvider.notifier).removeRoomRole(
                    roomId: widget.roomId,
                    targetUserId: userId,
                    targetUsername: username,
                  );

              showSnack('تم إرسال طلب حذف الرتبة');
            },
          );
        },
      );
    },
  );
}
void openBannedSheet() {
  ref.read(roomAdminProvider.notifier).listRoomBanned(
        roomId: widget.roomId,
      );

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      return Consumer(
        builder: (context, ref, _) {
          final adminState = ref.watch(roomAdminProvider);

          final banned = adminState.bannedByRoom[widget.roomId] ?? {};
          final bannedUsers = _readAnyMapList(banned['bannedUsers']);

          final ipsRaw = banned['bannedIps'];
          final bannedIps = ipsRaw is List
              ? ipsRaw.map((item) => item.toString()).toList()
              : <String>[];

          return _BannedSheetContent(
            loading: adminState.loading,
            bannedUsers: bannedUsers,
            bannedIps: bannedIps,
            onAddTap: () {
              openAddUserDialog(
                title: 'إضافة محظور',
                action: 'ban',
                role: 'none',
              );
            },
          );
        },
      );
    },
  );
}
  void openLogsSheet() {
    ref
        .read(roomAdminProvider.notifier)
        .listRoomLogs(roomId: widget.roomId, limit: 50);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final adminState = ref.watch(roomAdminProvider);
            final logs = adminState.logsByRoom[widget.roomId] ?? [];

            return _LogsSheetContent(loading: adminState.loading, logs: logs);
          },
        );
      },
    );
  }

void showUsersSheet({
  required String title,
  required List<Map<String, dynamic>> users,
  required String emptyText,
  required bool canRemoveRole,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      return _UsersSheetContent(
        title: title,
        loading: false,
        users: users,
        emptyText: emptyText,
        canRemoveRole: canRemoveRole,
        showAddButton: false,
        onAddTap: null,
        onRemoveRole: null,
      );
    },
  );
}
  void notReady(String title) {
    showSnack('$title غير مربوط حاليًا');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final roomsState = ref.watch(roomsProvider);
    final adminState = ref.watch(roomAdminProvider);

    ref.listen(roomAdminProvider, (previous, next) {
      final error = next.error?.trim();

      if (error != null && error.isNotEmpty) {
        showSnack(error);
      }
    });

    final room = roomsState.rooms.where((item) {
      return item.roomId == widget.roomId;
    }).firstOrNull;

    final activeUsers = roomsState.usersByRoom[widget.roomId] ?? [];
    final activeCount =
        roomsState.activeCountByRoom[widget.roomId] ?? room?.activeCount ?? 0;

    final hasPassword = room?.hasPassword == true;
    final isFavorite = room?.isFavorite == true;
    final boostScore = room?.boostScore ?? 0;
    final favoriteCount = room?.favoriteCount ?? 0;

    final owners = adminState.roleUsersByRoom['${widget.roomId}_owner'] ?? [];
    final admins = adminState.roleUsersByRoom['${widget.roomId}_admin'] ?? [];
    final members = adminState.roleUsersByRoom['${widget.roomId}_member'] ?? [];

    final banned = adminState.bannedByRoom[widget.roomId] ?? {};
    final bannedUsers = _readAnyMapList(banned['bannedUsers']);

    final logs = adminState.logsByRoom[widget.roomId] ?? [];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                R.size(context, 18),
                R.size(context, 36),
                R.size(context, 18),
                R.size(context, 34),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.roomName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: R.sp(context, 31),
                      fontWeight: FontWeight.w600,
                      height: 1.15,
                    ),
                  ),
                  SizedBox(height: R.size(context, 8)),
                  Text(
                    'Online: $activeCount  •  Favorite: $favoriteCount  •  Boost: $boostScore',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: R.sp(context, 17),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            _SettingsSwitchTile(
              title: 'Members Only',
              value: room?.isLockedForNone ?? localMembersOnly,
              onChanged: toggleMembersOnly,
            ),

            _SettingsTextTile(
              title: 'Password',
              subtitle: hasPassword ? 'Password is active' : 'No password',
              onTap: openPasswordDialog,
            ),

            _SettingsTextTile(
              title: 'Pinned Message',
              subtitle: room?.pinnedMessage.text.isNotEmpty == true
                  ? room!.pinnedMessage.text
                  : 'No pinned message',
              onTap: openPinnedDialog,
            ),

            _SettingsTextTile(
              title: isFavorite ? 'Remove Favorite' : 'Add Favorite',
              subtitle: 'Current favorites: $favoriteCount',
              onTap: toggleFavorite,
            ),

            _SettingsTextTile(
              title: 'Boost Room',
              subtitle: 'Current boost score: $boostScore',
              onTap: boostRoom,
            ),

            _SettingsTextTile(
              title: 'Active Users',
              subtitle: '${activeUsers.length}',
              onTap: () => openActiveUsersSheet(activeUsers),
            ),

           _SettingsTextTile(
  title: 'Owners',
  subtitle: owners.length.toString(),
  onTap: () {
    openRoleSheet(title: 'Owners', role: 'owner');
  },
),

_SettingsTextTile(
  title: 'Admins',
  subtitle: admins.length.toString(),
  onTap: () {
    openRoleSheet(title: 'Admins', role: 'admin');
  },
),

_SettingsTextTile(
  title: 'Members',
  subtitle: members.length.toString(),
  onTap: () {
    openRoleSheet(title: 'Members', role: 'member');
  },
),
     _SettingsTextTile(
  title: 'Outcasts',
  subtitle: bannedUsers.length.toString(),
  onTap: openBannedSheet,
),
          _SettingsTextTile(
  title: 'Room Logs',
  subtitle: logs.length.toString(),
  onTap: openLogsSheet,
),
            _SettingsTextTile(
              title: 'Reset banned IP',
              subtitle:
                  'Remove all banned IP now. This needs a backend handler for reset banned IP.',
              isDanger: true,
              onTap: () => notReady('Reset banned IP'),
            ),

            _SettingsTextTile(
              title: 'Reset Room',
              subtitle:
                  'Reset room state removing all roles except the Creator. This needs a backend handler for reset room.',
              isDanger: true,
              onTap: () => notReady('Reset Room'),
            ),
          ],
        ),
      ),
    );
  }
}

class _UsersSheetContent extends StatelessWidget {
  final String title;
  final bool loading;
  final List<Map<String, dynamic>> users;
  final String emptyText;
  final bool canRemoveRole;
  final bool showAddButton;
  final VoidCallback? onAddTap;
  final ValueChanged<Map<String, dynamic>>? onRemoveRole;

  const _UsersSheetContent({
    required this.title,
    required this.loading,
    required this.users,
    required this.emptyText,
    required this.canRemoveRole,
    this.showAddButton = false,
    this.onAddTap,
    required this.onRemoveRole,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.78,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                R.size(context, 18),
                R.size(context, 8),
                R.size(context, 18),
                R.size(context, 14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: R.sp(context, 24),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    users.length.toString(),
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: R.sp(context, 18),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (showAddButton) ...[
                    SizedBox(width: R.size(context, 8)),
                    IconButton.filled(
                      onPressed: onAddTap,
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ],
              ),
            ),
            if (loading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (users.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    emptyText,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: R.sp(context, 18),
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: users.length,
                  separatorBuilder: (_, __) {
                    return Divider(
                      height: 1,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.45),
                    );
                  },
                  itemBuilder: (context, index) {
                    final user = users[index];

                    final username = _s(user['username'], fallback: 'User');
                    final photoUrl = _s(user['photoUrl']);

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                        child: photoUrl.isEmpty && username.isNotEmpty
                            ? Text(username.characters.first)
                            : null,
                      ),
                      title: Text(
                        username,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: canRemoveRole
                          ? IconButton(
                              onPressed: onRemoveRole == null
                                  ? null
                                  : () {
                                      onRemoveRole!(user);
                                    },
                              icon: Icon(
                                Icons.close_rounded,
                                color: colorScheme.error,
                              ),
                            )
                          : null,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BannedSheetContent extends StatelessWidget {
  final bool loading;
  final List<Map<String, dynamic>> bannedUsers;
  final List<String> bannedIps;
  final VoidCallback? onAddTap;

  const _BannedSheetContent({
    required this.loading,
    required this.bannedUsers,
    required this.bannedIps,
    this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.78,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                R.size(context, 18),
                R.size(context, 8),
                R.size(context, 18),
                R.size(context, 14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Outcasts',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: R.sp(context, 24),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '${bannedUsers.length}',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: R.sp(context, 18),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: R.size(context, 8)),
                  IconButton.filled(
                    onPressed: onAddTap,
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
            ),
            if (loading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else
              Expanded(
                child: ListView(
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                        R.size(context, 18),
                        R.size(context, 10),
                        R.size(context, 18),
                        R.size(context, 8),
                      ),
                      child: Text(
                        'Banned Users',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: R.sp(context, 20),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (bannedUsers.isEmpty)
                      Padding(
                        padding: EdgeInsetsDirectional.symmetric(
                          horizontal: R.size(context, 18),
                          vertical: R.size(context, 14),
                        ),
                        child: Text(
                          'لا يوجد محظورين',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: R.sp(context, 17),
                          ),
                        ),
                      )
                    else
                      ...bannedUsers.map((user) {
                        final username = _s(user['username'], fallback: 'User');
                        final photoUrl = _s(user['photoUrl']);

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: photoUrl.isNotEmpty
                                ? NetworkImage(photoUrl)
                                : null,
                            child: photoUrl.isEmpty && username.isNotEmpty
                                ? Text(username.characters.first)
                                : null,
                          ),
                          title: Text(
                            username,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }),

                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                        R.size(context, 18),
                        R.size(context, 20),
                        R.size(context, 18),
                        R.size(context, 8),
                      ),
                      child: Text(
                        'Banned IPs',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: R.sp(context, 20),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (bannedIps.isEmpty)
                      Padding(
                        padding: EdgeInsetsDirectional.symmetric(
                          horizontal: R.size(context, 18),
                          vertical: R.size(context, 14),
                        ),
                        child: Text(
                          'لا توجد IPs محظورة',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: R.sp(context, 17),
                          ),
                        ),
                      )
                    else
                      ...bannedIps.map((ip) {
                        return ListTile(
                          leading: const Icon(Icons.public_off_rounded),
                          title: Text(ip),
                        );
                      }),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
class _LogsSheetContent extends StatelessWidget {
  final bool loading;
  final List<Map<String, dynamic>> logs;

  const _LogsSheetContent({required this.loading, required this.logs});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.78,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                R.size(context, 18),
                R.size(context, 8),
                R.size(context, 18),
                R.size(context, 14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Room Logs',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: R.sp(context, 24),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    logs.length.toString(),
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: R.sp(context, 18),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (logs.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'لا توجد لوجات',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: R.sp(context, 18),
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: logs.length,
                  separatorBuilder: (_, __) {
                    return Divider(
                      height: 1,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.45),
                    );
                  },
                  itemBuilder: (context, index) {
                    final log = logs[index];

                    final actorUsername = _s(
                      log['actorUsername'],
                      fallback: 'User',
                    );
                    final targetUsername = _s(
                      log['targetUsername'],
                      fallback: 'User',
                    );
                    final oldRole = _s(log['oldRole'], fallback: 'none');
                    final newRole = _s(log['newRole'], fallback: 'none');
                    final createdAt = _s(log['createdAt']);

                    return ListTile(
                      leading: const Icon(Icons.history_rounded),
                      title: Text(
                        '$actorUsername → $targetUsername',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '$oldRole → $newRole${createdAt.isNotEmpty ? ' • $createdAt' : ''}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(
        R.size(context, 18),
        R.size(context, 15),
        R.size(context, 18),
        R.size(context, 15),
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.45),
            width: 0.8,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: R.sp(context, 25),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: value,
            activeColor: const Color(0xFF087887),
            activeTrackColor: const Color(0xFF087887).withValues(alpha: 0.35),
            inactiveThumbColor: colorScheme.onSurfaceVariant,
            inactiveTrackColor: colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.75,
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SettingsTextTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isDanger;
  final VoidCallback? onTap;

  const _SettingsTextTile({
    required this.title,
    this.subtitle,
    this.isDanger = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final titleColor = isDanger ? colorScheme.error : colorScheme.onSurface;
    final subtitleColor = isDanger
        ? colorScheme.error.withValues(alpha: 0.78)
        : colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsetsDirectional.fromSTEB(
          R.size(context, 18),
          R.size(context, 13),
          R.size(context, 18),
          R.size(context, 13),
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.45),
              width: 0.8,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: titleColor,
                fontSize: R.sp(context, 25),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (subtitle != null) ...[
              SizedBox(height: R.size(context, 4)),
              Text(
                subtitle!,
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: R.sp(context, 21),
                  height: 1.18,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

List<Map<String, dynamic>> _readAnyMapList(dynamic value) {
  if (value is! List) {
    return <Map<String, dynamic>>[];
  }

  return value
      .whereType<Map>()
      .map((item) {
        return item.map((key, value) => MapEntry(key.toString(), value));
      })
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

String _s(dynamic value, {String fallback = ''}) {
  final text = (value ?? '').toString().trim();
  return text.isEmpty ? fallback : text;
}
