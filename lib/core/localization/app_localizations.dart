import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  const AppLocalizations(this.locale);

  bool get isArabic => locale.languageCode == 'ar';

  static AppLocalizations of(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return AppLocalizations(locale);
  }

  static TextDirection textDirectionOf(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr;
  }

  String t(String key) {
    final map = isArabic ? _ar : _en;
    return map[key] ?? key;
  }
}

const Map<String, String> _en = {
  'settings': 'Settings',
  'status_message': 'Status Message',
  'dark_mode': 'Dark Mode',
  'language': 'Language',
  'arabic': 'Arabic',
  'english': 'English',
  'private_lock': 'Private Lock',
  'allow_calls': 'Allow Calls',
  'all': 'All',
  'auto_join_stream': 'Auto join stream',
  'hide_activity_status': 'Hide activity status',
  'email': 'Email',
  'birthdate': 'Birthdate',
  'country': 'Country',
  'egypt': 'Egypt',
  'gender': 'Gender',
  'male': 'Male',
  'change_password': 'Change Password',
  'blocked_users': 'Blocked users',
  'sessions_log': 'Sessions Log',
  'delete_my_account': 'Delete my account',
  'more': 'More',
  'privacy_policy': 'Privacy Policy',
  'terms': 'Terms And Conditions',
  'logout': 'Logout',
  'edit_cover': 'Edit cover clicked',
  'edit_avatar': 'Edit avatar clicked',
    'home': 'Home',
  'rooms': 'Rooms',
  'chats': 'Chats',
  'friends': 'Friends',
  'store': 'Store',
  'search_chats_or_messages': 'Search chats or messages',
'clear_search': 'Clear search',
'notifications': 'Notifications',
'menu': 'Menu',
'add_friend': 'Add Friend',
'search_username': 'Search username',
'search_by_username': 'Search by username',
'no_users_found': 'No users found',
'add': 'Add',
'friend_request_sent_to': 'Friend request sent to',
  
};

const Map<String, String> _ar = {
  'settings': 'الإعدادات',
  'status_message': 'رسالة الحالة',
  'dark_mode': 'الوضع الداكن',
  'language': 'اللغة',
  'arabic': 'العربية',
  'english': 'الإنجليزية',
  'private_lock': 'قفل الخصوصية',
  'allow_calls': 'السماح بالمكالمات',
  'all': 'الكل',
  'auto_join_stream': 'دخول البث تلقائيًا',
  'hide_activity_status': 'إخفاء حالة النشاط',
  'email': 'البريد الإلكتروني',
  'birthdate': 'تاريخ الميلاد',
  'country': 'الدولة',
  'egypt': 'مصر',
  'gender': 'النوع',
  'male': 'ذكر',
  'change_password': 'تغيير كلمة المرور',
  'blocked_users': 'المستخدمون المحظورون',
  'sessions_log': 'سجل الجلسات',
  'delete_my_account': 'حذف حسابي',
  'more': 'المزيد',
  'privacy_policy': 'سياسة الخصوصية',
  'terms': 'الشروط والأحكام',
  'logout': 'تسجيل الخروج',
  'edit_cover': 'تعديل الغلاف',
  'edit_avatar': 'تعديل الصورة',
    'home': 'الرئيسية',
  'rooms': 'الغرف',
  'chats': 'المحادثات',
  'friends': 'الأصدقاء',
  'store': 'المتجر',
  'search_chats_or_messages': 'البحث في المحادثات أو الرسائل',
'clear_search': 'مسح البحث',
'add_friend': 'إضافة صديق',
'notifications': 'الإشعارات',
'menu': 'القائمة',
'search_username': 'البحث باسم المستخدم',
'search_by_username': 'ابحث باسم المستخدم',
'no_users_found': 'لم يتم العثور على مستخدمين',
'add': 'إضافة',
'friend_request_sent_to': 'تم إرسال طلب صداقة إلى',
};
