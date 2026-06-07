import 'package:flutter/material.dart';
import '../../../core/utils/responsive.dart';

class RoomSettingsScreen extends StatelessWidget {
  final String roomName;

  const RoomSettingsScreen({super.key, required this.roomName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                style: TextStyle(
                  fontSize: R.sp(context, 31),
                  fontWeight: FontWeight.w500,
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
            ),
            const _SettingsTextTile(
              title: 'Reset Room',
              subtitle:
                  'Reset room state removing all roles except the Creator of this room. Also this action remove all banned users and IP',
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
    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(
        R.size(context, 18),
        R.size(context, 15),
        R.size(context, 18),
        R.size(context, 15),
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.withValues(alpha: 0.25)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.title,
              style: TextStyle(
                fontSize: R.sp(context, 25),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: value,
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

  const _SettingsTextTile({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(
        R.size(context, 18),
        R.size(context, 13),
        R.size(context, 18),
        R.size(context, 13),
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.withValues(alpha: 0.25)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: R.sp(context, 25),
              fontWeight: FontWeight.w500,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: R.size(context, 2)),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: R.sp(context, 21),
                height: 1.18,
                color: Colors.black.withValues(alpha: 0.72),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
