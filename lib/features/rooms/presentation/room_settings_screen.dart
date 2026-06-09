import 'package:flutter/material.dart';

import '../../../core/utils/responsive.dart';

class RoomSettingsScreen extends StatelessWidget {
  final String roomName;

  const RoomSettingsScreen({super.key, required this.roomName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                R.size(context, 48),
              ),
              child: Text(
                roomName,
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
            ),

            const _SettingsSwitchTile(title: 'Members Only'),
            const _SettingsTextTile(title: 'Password'),
            const _SettingsTextTile(title: 'Owners', subtitle: '185'),
            const _SettingsTextTile(title: 'Admins', subtitle: '82'),
            const _SettingsTextTile(title: 'Members', subtitle: '1665'),
            const _SettingsTextTile(title: 'Outcasts', subtitle: '2056'),
            const _SettingsTextTile(title: 'Room Logs'),
            const _SettingsTextTile(
              title: 'Reset banned IP',
              subtitle:
                  'Remove all banned IP now. (Every banned IP will be unbanned automatically after 24 hours) - currently ip banned: 51',
              isDanger: true,
            ),
            const _SettingsTextTile(
              title: 'Reset Room',
              subtitle:
                  'Reset room state removing all roles except the Creator of this room. Also this action remove all banned users and IP',
              isDanger: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSwitchTile extends StatefulWidget {
  final String title;

  const _SettingsSwitchTile({required this.title});

  @override
  State<_SettingsSwitchTile> createState() => _SettingsSwitchTileState();
}

class _SettingsSwitchTileState extends State<_SettingsSwitchTile> {
  bool value = false;

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
              widget.title,
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
            onChanged: (newValue) {
              setState(() => value = newValue);
            },
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

  const _SettingsTextTile({
    required this.title,
    this.subtitle,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final titleColor = isDanger ? colorScheme.error : colorScheme.onSurface;
    final subtitleColor = isDanger
        ? colorScheme.error.withValues(alpha: 0.78)
        : colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: () {},
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
