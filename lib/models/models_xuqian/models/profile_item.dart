import 'package:flutter/material.dart';

class ProfileItem {
  final String title;
  final IconData? icon;
  final bool isHeader;

  ProfileItem({
    required this.title,
    this.icon,
    this.isHeader = false,
  });
}