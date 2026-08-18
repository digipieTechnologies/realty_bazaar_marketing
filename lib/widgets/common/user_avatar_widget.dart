// File: lib/widgets/common/user_avatar_widget.dart
// Purpose: Reusable avatar widget displaying user profile image or dynamic name initials circle with themed background colors.

import 'package:flutter/material.dart';
import '../../app/app_colors.dart';
import '../images/cached_image.dart';

class UserAvatarWidget extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double radius;
  final TextStyle? textStyle;

  const UserAvatarWidget({
    super.key,
    required this.name,
    this.imageUrl,
    this.radius = 20.0,
    this.textStyle,
  });

  static String getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'U';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return trimmed.substring(0, trimmed.length >= 2 ? 2 : 1).toUpperCase();
  }

  static Color getAvatarBgColor(String name) {
    final colors = [
      AppColors.primary.withValues(alpha: 0.12),
      AppColors.secondary.withValues(alpha: 0.12),
      AppColors.info.withValues(alpha: 0.12),
      AppColors.warning.withValues(alpha: 0.12),
    ];
    final hash = name.codeUnits.fold(0, (prev, element) => prev + element);
    return colors[hash % colors.length];
  }

  static Color getAvatarTextColor(String name) {
    final colors = [
      AppColors.primaryDark,
      AppColors.secondaryDark,
      AppColors.info,
      AppColors.warning,
    ];
    final hash = name.codeUnits.fold(0, (prev, element) => prev + element);
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final double diameter = radius * 2.0;

    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: CachedImage(
          imageUrl!,
          width: diameter,
          height: diameter,
          fit: BoxFit.cover,
        ),
      );
    }

    final initials = getInitials(name);
    final bgColor = getAvatarBgColor(name);
    final textColor = getAvatarTextColor(name);

    return CircleAvatar(
      radius: radius,
      backgroundColor: bgColor,
      child: Text(
        initials,
        style: textStyle ??
            TextStyle(
              fontSize: radius * 0.7,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
      ),
    );
  }
}
