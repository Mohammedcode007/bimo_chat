import 'package:flutter/material.dart';

enum RoomFilterType { public, voice, active, favorite }

class RoomModel {
  final String id;
  final String name;
  final int membersCount;
  final int rank;
  final bool isVerified;
  final bool isVoice;
  final bool isActive;
  final bool isFavorite;
  final Color avatarColor;
  final String? avatarText;
  final bool showGroupIcon;

  const RoomModel({
    required this.id,
    required this.name,
    required this.membersCount,
    required this.rank,
    required this.avatarColor,
    this.isVerified = false,
    this.isVoice = false,
    this.isActive = false,
    this.isFavorite = false,
    this.avatarText,
    this.showGroupIcon = false,
  });
}
