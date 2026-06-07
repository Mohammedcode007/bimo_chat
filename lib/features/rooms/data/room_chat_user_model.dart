import 'package:flutter/material.dart';

import 'room_role.dart';

class RoomChatUserModel {
  final String id;
  final String name;
  final RoomRole role;
  final String avatarText;
  final String avatarUrl;
  final String? frame;
  final String? badge;
  final bool avatarIsGif;
  final Color? nameColor;
  final bool isOnline;

  const RoomChatUserModel({
    required this.id,
    required this.name,
    required this.role,
    required this.avatarText,
    this.avatarUrl = '',
    this.frame,
    this.badge,
    this.avatarIsGif = false,
    this.nameColor,
    this.isOnline = false,
  });
}
