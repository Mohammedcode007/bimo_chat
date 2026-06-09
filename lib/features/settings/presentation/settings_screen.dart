import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/app/app_controller.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/image_picker_helper.dart';
import '../../auth/logic/auth_provider.dart';
import '../../auth/presentation/login_screen.dart';
import 'widgets/profile_header.dart';
import 'widgets/settings_section.dart';
import 'widgets/setting_switch_tile.dart';
import 'widgets/setting_text_tile.dart';

class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({super.key});

  @override
  ConsumerState<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends ConsumerState<SettingScreen> {
  final String defaultAvatarUrl =
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=500';

  final String defaultCoverUrl =
      'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=1200';

  String userText(
    Map<String, dynamic> user,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = user[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return fallback;
  }

  String nestedText(
    Map<String, dynamic> user,
    String parent,
    String child, {
    String fallback = '',
  }) {
    final value = user[parent];

    if (value is Map && value[child] != null) {
      return value[child].toString();
    }

    return fallback;
  }

  String maskEmail(String email) {
    if (email.isEmpty || !email.contains('@')) return 'Not added';

    final parts = email.split('@');
    final name = parts.first;
    final domain = parts.last;

    if (name.length <= 2) {
      return '**@$domain';
    }

    return '${name.substring(0, 2)}****@$domain';
  }

  String privateMessageLabel(String value) {
    switch (value) {
      case 'open':
        return 'Everyone';
      case 'friends_only':
        return 'Friends only';
      case 'closed':
        return 'Closed';
      default:
        return value;
    }
  }

  String allowCallsLabel(String value) {
    switch (value) {
      case 'all':
        return 'All';
      case 'friends_only':
        return 'Friends only';
      case 'none':
        return 'None';
      default:
        return value;
    }
  }

  String genderLabel(String value) {
    switch (value) {
      case 'male':
        return 'Male';
      case 'female':
        return 'Female';
      case 'other':
        return 'Other';
      default:
        return 'Not added';
    }
  }

  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void updateProfile(Map<String, dynamic> data) {
    ref.read(authProvider.notifier).updateProfile(data);
  }

  void logout() {
    ref.read(authProvider.notifier).logout();
  }

  Future<void> changeProfileImage(String imageType) async {
    final base64 = await ImagePickerHelper.pickImageAsBase64(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: imageType == 'avatar' ? 800 : 1600,
      maxHeight: imageType == 'avatar' ? 800 : 900,
    );

    if (base64 == null) return;

    ref.read(authProvider.notifier).updateProfileImage(
          imageType: imageType,
          base64: base64,
        );
  }

  Future<void> confirmDeleteAccount() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete account'),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    ref.read(authProvider.notifier).deleteAccount();
  }

  Future<void> editTextField({
    required String title,
    required String initialValue,
    required String fieldKey,
    bool obscureText = false,
  }) async {
    final controller = TextEditingController(text: initialValue);

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: title,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, controller.text.trim());
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == null) return;

    if (fieldKey == 'new_password' && result.length < 6) {
      showMessage('Password must be at least 6 characters');
      return;
    }

    updateProfile({
      fieldKey: result,
    });
  }

  Future<void> editChoiceField({
    required String title,
    required String fieldKey,
    required String currentValue,
    required Map<String, String> options,
  }) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(title),
          children: options.entries.map((entry) {
            return RadioListTile<String>(
              value: entry.key,
              groupValue: currentValue,
              title: Text(entry.value),
              onChanged: (value) {
                Navigator.pop(context, value);
              },
            );
          }).toList(),
        );
      },
    );

    if (result == null) return;

    updateProfile({
      fieldKey: result,
    });
  }

  Future<void> pickCountry() async {
    showCountryPicker(
      context: context,
      showPhoneCode: false,
      countryListTheme: CountryListThemeData(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(22),
        ),
        inputDecoration: const InputDecoration(
          labelText: 'Search',
          hintText: 'Search country',
          prefixIcon: Icon(Icons.search),
        ),
      ),
      onSelect: (Country country) {
        updateProfile({
          'country': country.name,
        });
      },
    );
  }

  Future<void> pickBirthDate(String currentBirthdate) async {
    DateTime initialDate = DateTime(2000, 1, 1);

    final parsedDate = DateTime.tryParse(currentBirthdate);
    if (parsedDate != null) {
      initialDate = parsedDate;
    }

    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(now) ? DateTime(2000, 1, 1) : initialDate,
      firstDate: DateTime(1900, 1, 1),
      lastDate: now,
      helpText: 'Select birthdate',
    );

    if (picked == null) return;

    final formatted = DateFormat('yyyy-MM-dd').format(picked);

    updateProfile({
      'birth_day': formatted,
    });
  }

  Future<void> pickGender(String currentGender) async {
    await editChoiceField(
      title: 'Gender',
      fieldKey: 'gender',
      currentValue: currentGender,
      options: const {
        'male': 'Male',
        'female': 'Female',
        'other': 'Other',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final user = auth.user ?? <String, dynamic>{};

ref.listen(authProvider, (previous, next) {
  final wasLoggedIn = previous?.loggedIn == true;
  final isLoggedOutNow = next.loggedIn == false;

  if (wasLoggedIn && isLoggedOutNow) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
    return;
  }

  if (next.error != null && next.error!.isNotEmpty) {
    showMessage(next.error!);
  }
});
    final app = AppController.of(context);
    final lang = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final username = userText(
      user,
      ['username', 'name'],
      fallback: auth.username ?? 'User',
    );

    final avatarUrl = userText(
      user,
      ['photoUrl', 'avatarUrl', 'photo_url', 'avatar_url'],
      fallback: defaultAvatarUrl,
    );

    final coverUrl = userText(
      user,
      ['coverUrl', 'cover_url'],
      fallback: defaultCoverUrl,
    );

    final statusMessage = userText(
      user,
      ['statusMessage', 'status_message', 'bio', 'current'],
      fallback: 'No status message',
    );

    final email = userText(
      user,
      ['email'],
      fallback: '',
    );

    final birthdate = userText(
      user,
      ['birthdate', 'dateOfBirth', 'date_of_birth'],
      fallback: 'Not added',
    );

    final country = userText(
      user,
      ['country'],
      fallback: 'Not added',
    );

    final gender = userText(
      user,
      ['gender'],
      fallback: '',
    );

    final privateLock = user['privateLock'] == true;
    final autoJoinStream = user['autoJoinStream'] == true;
    final hideActivityStatus = user['hideActivityStatus'] == true;

    final dmPrivacy = nestedText(
      user,
      'privacy',
      'dmPrivacy',
      fallback: 'open',
    );

    final allowCalls = nestedText(
      user,
      'privacy',
      'allowCalls',
      fallback: 'all',
    );

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
              username: username,
              title: lang.t('settings'),
              onEditCover: () {
                changeProfileImage('cover');
              },
              onEditAvatar: () {
                changeProfileImage('avatar');
              },
            ),

            const SizedBox(height: 18),

            SettingsSection(
              children: [
                SettingTextTile(
                  title: lang.t('status_message'),
                  subtitle: statusMessage,
                  trailingIcon: Icons.edit_rounded,
                  onTap: () {
                    editTextField(
                      title: lang.t('status_message'),
                      initialValue: statusMessage == 'No status message'
                          ? ''
                          : statusMessage,
                      fieldKey: 'status_message',
                    );
                  },
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
                    updateProfile({
                      'private_lock': value,
                    });
                  },
                ),

                SettingTextTile(
                  title: 'Private messages',
                  subtitle: privateMessageLabel(dmPrivacy),
                  trailingIcon: Icons.edit_rounded,
                  onTap: () {
                    editChoiceField(
                      title: 'Private messages',
                      fieldKey: 'private_message',
                      currentValue: dmPrivacy,
                      options: const {
                        'open': 'Everyone',
                        'friends_only': 'Friends only',
                        'closed': 'Closed',
                      },
                    );
                  },
                ),

                SettingTextTile(
                  title: lang.t('allow_calls'),
                  subtitle: allowCallsLabel(allowCalls),
                  trailingIcon: Icons.edit_rounded,
                  onTap: () {
                    editChoiceField(
                      title: lang.t('allow_calls'),
                      fieldKey: 'allow_calls',
                      currentValue: allowCalls,
                      options: const {
                        'all': 'All',
                        'friends_only': 'Friends only',
                        'none': 'None',
                      },
                    );
                  },
                ),

                SettingSwitchTile(
                  title: lang.t('auto_join_stream'),
                  value: autoJoinStream,
                  onChanged: (value) {
                    updateProfile({
                      'auto_join_stream': value,
                    });
                  },
                ),

                SettingSwitchTile(
                  title: lang.t('hide_activity_status'),
                  value: hideActivityStatus,
                  onChanged: (value) {
                    updateProfile({
                      'hide_activity_status': value,
                    });
                  },
                ),
              ],
            ),

            SettingsSection(
              children: [
                SettingTextTile(
                  title: lang.t('email'),
                  subtitle: maskEmail(email),
                  trailingIcon: Icons.edit_rounded,
                  onTap: () {
                    editTextField(
                      title: lang.t('email'),
                      initialValue: email,
                      fieldKey: 'email',
                    );
                  },
                ),

                SettingTextTile(
                  title: lang.t('birthdate'),
                  subtitle: birthdate,
                  trailingIcon: Icons.calendar_month_rounded,
                  onTap: () {
                    pickBirthDate(birthdate == 'Not added' ? '' : birthdate);
                  },
                ),

                SettingTextTile(
                  title: lang.t('country'),
                  subtitle: country,
                  trailingIcon: Icons.public_rounded,
                  onTap: pickCountry,
                ),

                SettingTextTile(
                  title: lang.t('gender'),
                  subtitle: genderLabel(gender),
                  trailingIcon: Icons.wc_rounded,
                  onTap: () {
                    pickGender(gender);
                  },
                ),

                SettingTextTile(
                  title: 'User ID',
                  subtitle: auth.userId ?? userText(user, ['userId']),
                  trailingIcon: Icons.copy_rounded,
                  onTap: () {
                    showMessage(auth.userId ?? userText(user, ['userId']));
                  },
                ),

                SettingTextTile(
                  title: lang.t('change_password'),
                  trailingIcon: Icons.edit_rounded,
                  onTap: () {
                    editTextField(
                      title: lang.t('change_password'),
                      initialValue: '',
                      fieldKey: 'new_password',
                      obscureText: true,
                    );
                  },
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
                  titleColor: AppTheme.error,
                  trailingIcon: Icons.delete_forever_rounded,
                  onTap: confirmDeleteAccount,
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
                  onTap: logout,
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