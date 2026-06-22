import 'package:flutter/material.dart';

import 'room_chat_user_model.dart';
import 'room_role.dart';

enum RoomChatMessageType {
  text,
  image,
  video,
  voice,
  system,
}
class RoomChatMessageModel {
  final String id;
  final RoomChatUserModel sender;
  final String text;
  final RoomChatMessageType type;
  final String? localPath;
  final String? duration;
  final bool isMe;
  final DateTime createdAt;
  final Color? systemColor;

  const RoomChatMessageModel({
    required this.id,
    required this.sender,
    required this.text,
    required this.type,
    this.localPath,
    this.duration,
    this.isMe = false,
    required this.createdAt,
    this.systemColor,
  });

  Color get roleStarColor {
    switch (sender.role) {
      case RoomRole.owner:
        return Colors.red;

      case RoomRole.admin:
        return Colors.blue;

      case RoomRole.member:
      case RoomRole.none:
      case RoomRole.banned:
        return Colors.transparent;
    }

    return Colors.transparent;
  }
}
