import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String photoUrl;
  final double radius;
  final Color iconColor;
  final Color backgroundColor;

  const ProfileAvatar({
    super.key,
    required this.photoUrl,
    this.radius = 20,
    this.iconColor = const Color(0xFF09095E),
    this.backgroundColor = const Color(0xFFEEF0FA),
  });

  Widget _buildEmptyAvatar() {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person_outline,
        color: iconColor.withValues(alpha: 0.7),
        size: radius * 1.15,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clean = photoUrl.trim();
    if (clean.isEmpty) {
      return _buildEmptyAvatar();
    }

    if (clean.startsWith('data:image')) {
      final commaIndex = clean.indexOf(',');
      if (commaIndex != -1) {
        try {
          final bytes = base64Decode(clean.substring(commaIndex + 1));
          return ClipOval(
            child: Image.memory(
              bytes,
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _buildEmptyAvatar(),
            ),
          );
        } catch (_) {
          return _buildEmptyAvatar();
        }
      }
    }

    if (clean.startsWith('assets/')) {
      return ClipOval(
        child: Image.asset(
          clean,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildEmptyAvatar(),
        ),
      );
    }

    if (clean.startsWith('http://') || clean.startsWith('https://')) {
      return ClipOval(
        child: Image.network(
          clean,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildEmptyAvatar(),
        ),
      );
    }

    final file = File(clean);
    if (file.existsSync()) {
      return ClipOval(
        child: Image.file(
          file,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildEmptyAvatar(),
        ),
      );
    }

    return _buildEmptyAvatar();
  }
}

