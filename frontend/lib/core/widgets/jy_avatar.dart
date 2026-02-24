import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class JYAvatar extends StatelessWidget {
  const JYAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.radius = 20,
    this.onTap,
  });

  final String? imageUrl;
  final String? name;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final initial = name != null && name!.isNotEmpty ? name![0] : '?';

    Widget avatar;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatar = CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: imageUrl!,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            placeholder: (_, __) => _buildFallback(initial),
            errorWidget: (_, __, ___) => _buildFallback(initial),
          ),
        ),
      );
    } else {
      avatar = _buildFallback(initial);
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: avatar);
    }
    return avatar;
  }

  Widget _buildFallback(String initial) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
      child: Text(
        initial,
        style: TextStyle(
          fontSize: radius * 0.8,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
