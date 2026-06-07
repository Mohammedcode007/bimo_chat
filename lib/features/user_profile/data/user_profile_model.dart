import 'package:flutter/material.dart';

class UserProfileModel {
  final String id;
  final String name;
  final String username;

  final String avatarText;
  final String avatarUrl;
  final String coverUrl;

  final String role;
  final String status;
  final String bio;

  final String? badge;
  final String? frame;
  final Color? nameColor;
  final bool isOnline;

  final int receivedGifts;
  final int sentGifts;
  final int views;
  final int friends;

  final String since;
  final String country;
  final String gender;
  final String age;

  const UserProfileModel({
    required this.id,
    required this.name,
    required this.username,
    required this.avatarText,
    this.avatarUrl = '',
    this.coverUrl = '',
    this.role = 'member',
    this.status = '',
    this.bio = '',
    this.badge,
    this.frame,
    this.nameColor,
    this.isOnline = false,
    this.receivedGifts = 0,
    this.sentGifts = 0,
    this.views = 0,
    this.friends = 0,
    this.since = 'N/A',
    this.country = 'N/A',
    this.gender = 'N/A',
    this.age = 'N/A',
  });
}