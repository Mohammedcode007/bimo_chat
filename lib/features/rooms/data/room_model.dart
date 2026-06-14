import 'package:flutter/material.dart';

enum RoomFilterType { public, voice, active, favorite }

class RoomModel {
  final String id;
  final String name;
  final int membersCount;
  final int rank;

  // الجديد: رتبة المستخدم داخل الغرفة
  final String role;

  final bool isVerified;
  final bool isVoice;
  final bool isActive;
  final bool isFavorite;

  final bool hasPassword;
  final bool isLockedForNone;

  final Color avatarColor;
  final String? avatarText;
  final bool showGroupIcon;

  const RoomModel({
    required this.id,
    required this.name,
    required this.membersCount,
    required this.rank,
    required this.avatarColor,

    // الجديد
    this.role = 'none',

    this.isVerified = false,
    this.isVoice = false,
    this.isActive = false,
    this.isFavorite = false,
    this.hasPassword = false,
    this.isLockedForNone = false,
    this.avatarText,
    this.showGroupIcon = false,
  });

  bool get isCreator => role == 'creator';
  bool get isOwner => role == 'owner';
  bool get isAdmin => role == 'admin';
  bool get isMember => role == 'member';
  bool get isNone => role == 'none';

  RoomModel copyWith({
    String? id,
    String? name,
    int? membersCount,
    int? rank,
    String? role,
    bool? isVerified,
    bool? isVoice,
    bool? isActive,
    bool? isFavorite,
    bool? hasPassword,
    bool? isLockedForNone,
    Color? avatarColor,
    String? avatarText,
    bool? showGroupIcon,
  }) {
    return RoomModel(
      id: id ?? this.id,
      name: name ?? this.name,
      membersCount: membersCount ?? this.membersCount,
      rank: rank ?? this.rank,
      avatarColor: avatarColor ?? this.avatarColor,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      isVoice: isVoice ?? this.isVoice,
      isActive: isActive ?? this.isActive,
      isFavorite: isFavorite ?? this.isFavorite,
      hasPassword: hasPassword ?? this.hasPassword,
      isLockedForNone: isLockedForNone ?? this.isLockedForNone,
      avatarText: avatarText ?? this.avatarText,
      showGroupIcon: showGroupIcon ?? this.showGroupIcon,
    );
  }
}
