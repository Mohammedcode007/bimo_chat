class LocalChatStorage {
  Future<void> saveMessage(Map<String, dynamic> message) async {
    // لاحقًا هنا نستخدم Hive أو Isar
  }

  Future<List<Map<String, dynamic>>> getMessages(String peerUserId) async {
    // لاحقًا هنا نرجع رسائل محادثة معينة
    return [];
  }

  Future<void> clearChat(String peerUserId) async {
    // لاحقًا مسح محادثة من الهاتف فقط
  }
}
