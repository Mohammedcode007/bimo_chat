import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/responsive.dart';
import '../logic/rooms_provider.dart';

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

  void showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
            decoration: const InputDecoration(
              hintText: 'Enter password',
            ),
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

    ref.read(roomsProvider.notifier).setPassword(
          roomId: widget.roomId,
          password: result.trim(),
        );

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

    if (!mounted || result == null) return;

    ref.read(roomsProvider.notifier).setPinnedMessage(
          roomId: widget.roomId,
          text: result,
        );

    showSnack('تم إرسال الرسالة المثبتة');
  }

  void toggleMembersOnly(bool value) {
    setState(() {
      localMembersOnly = value;
    });

    ref.read(roomsProvider.notifier).setRoomLock(
          roomId: widget.roomId,
          locked: value,
        );

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

  void notReady(String title) {
    showSnack('$title غير مربوط حاليًا');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final roomsState = ref.watch(roomsProvider);

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
              onTap: () => notReady('Active Users list'),
            ),

            _SettingsTextTile(
              title: 'Owners',
              subtitle: 'Manage owners from room users menu',
              onTap: () => notReady('Owners'),
            ),

            _SettingsTextTile(
              title: 'Admins',
              subtitle: 'Manage admins from room users menu',
              onTap: () => notReady('Admins'),
            ),

            _SettingsTextTile(
              title: 'Members',
              subtitle: 'Manage members from room users menu',
              onTap: () => notReady('Members'),
            ),

            _SettingsTextTile(
              title: 'Outcasts',
              subtitle: 'Banned users and IP list',
              onTap: () => notReady('Outcasts'),
            ),

            _SettingsTextTile(
              title: 'Room Logs',
              subtitle: 'Role logs and room actions',
              onTap: () => notReady('Room Logs'),
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