import 'package:flutter/material.dart';
import '../../../core/app/app_controller.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import 'widgets/profile_header.dart';
import 'widgets/settings_section.dart';
import 'widgets/setting_switch_tile.dart';
import 'widgets/setting_text_tile.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool privateLock = false;
  bool autoJoinStream = false;
  bool hideActivityStatus = false;

  final String avatarUrl =
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=500';

  final String coverUrl =
      'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=1200';

  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = AppController.of(context);
    final lang = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ProfileHeader(
              coverUrl: coverUrl,
              avatarUrl: avatarUrl,
              username: '᪥◌͜͡ـــه خـود ا̍لـسـمـاـــه◌᪥',
              title: lang.t('settings'),
              onEditCover: () => showMessage(lang.t('edit_cover')),
              onEditAvatar: () => showMessage(lang.t('edit_avatar')),
            ),

            const SizedBox(height: 18),

            SettingsSection(
              children: [
                SettingTextTile(
                  title: lang.t('status_message'),
                  subtitle:
                      'بوشفينى أقولك إني فاقد لم تخطيط العمر المسموح فيه بالمتاهة والسبعينات...',
                  trailingIcon: Icons.edit_rounded,
                  onTap: () => showMessage(lang.t('status_message')),
                ),
              ],
            ),

            SettingsSection(
              children: [
                SettingSwitchTile(
                  title: lang.t('dark_mode'),
                  value: app.isDarkMode,
                  onChanged: app.toggleTheme,
                ),

                SettingTextTile(
                  title: lang.t('language'),
                  subtitle: app.isArabic ? lang.t('arabic') : lang.t('english'),
                  trailingIcon: Icons.language_rounded,
                  onTap: app.toggleLanguage,
                ),

                SettingSwitchTile(
                  title: lang.t('private_lock'),
                  value: privateLock,
                  onChanged: (value) {
                    setState(() => privateLock = value);
                  },
                ),

                SettingTextTile(
                  title: lang.t('allow_calls'),
                  subtitle: lang.t('all'),
                  trailingIcon: Icons.edit_rounded,
                  onTap: () => showMessage(lang.t('allow_calls')),
                ),

                SettingSwitchTile(
                  title: lang.t('auto_join_stream'),
                  value: autoJoinStream,
                  onChanged: (value) {
                    setState(() => autoJoinStream = value);
                  },
                ),

                SettingSwitchTile(
                  title: lang.t('hide_activity_status'),
                  value: hideActivityStatus,
                  onChanged: (value) {
                    setState(() => hideActivityStatus = value);
                  },
                ),
              ],
            ),

            SettingsSection(
              children: [
                SettingTextTile(
                  title: lang.t('email'),
                  subtitle: 'si****r0@gmail.com',
                  trailingIcon: Icons.delete_rounded,
                  onTap: () => showMessage(lang.t('email')),
                ),
                SettingTextTile(
                  title: lang.t('birthdate'),
                  subtitle: '01-01-1970',
                  trailingIcon: Icons.edit_rounded,
                  onTap: () => showMessage(lang.t('birthdate')),
                ),
                SettingTextTile(
                  title: lang.t('country'),
                  subtitle: lang.t('egypt'),
                  trailingIcon: Icons.edit_rounded,
                  onTap: () => showMessage(lang.t('country')),
                ),
                SettingTextTile(
                  title: lang.t('gender'),
                  subtitle: lang.t('male'),
                  trailingIcon: Icons.edit_rounded,
                  onTap: () => showMessage(lang.t('gender')),
                ),
                SettingTextTile(
                  title: lang.t('change_password'),
                  trailingIcon: Icons.edit_rounded,
                  onTap: () => showMessage(lang.t('change_password')),
                ),
                SettingTextTile(
                  title: lang.t('blocked_users'),
                  onTap: () => showMessage(lang.t('blocked_users')),
                ),
                SettingTextTile(
                  title: lang.t('sessions_log'),
                  onTap: () => showMessage(lang.t('sessions_log')),
                ),
                SettingTextTile(
                  title: lang.t('delete_my_account'),
                  titleColor: colorScheme.onSurface,
                  onTap: () => showMessage(lang.t('delete_my_account')),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 10),
              child: Text(
                lang.t('more'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
            ),

            SettingsSection(
              children: [
                SettingTextTile(
                  title: lang.t('privacy_policy'),
                  titleColor: colorScheme.onSurfaceVariant,
                  onTap: () => showMessage(lang.t('privacy_policy')),
                ),
                SettingTextTile(
                  title: lang.t('terms'),
                  titleColor: colorScheme.onSurfaceVariant,
                  onTap: () => showMessage(lang.t('terms')),
                ),
                SettingTextTile(
                  title: lang.t('logout'),
                  titleColor: AppTheme.error,
                  trailingIcon: Icons.logout_rounded,
                  onTap: () => showMessage(lang.t('logout')),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
