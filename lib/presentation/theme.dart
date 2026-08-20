import 'package:flutter/material.dart';

/// Bảng token — chép NGUYÊN VĂN từ context/DESIGN-SYSTEM.md §2.
/// Đây là hợp đồng hình thức: đổi màu thì sửa §2 trước, sửa đây sau, cùng một
/// commit (luật #4). Không hardcode màu ở bất kỳ widget nào.
class T {
  const T._();

  static const Color bg = Color(0xFF0E1116);
  static const Color surface = Color(0xFF1A1F27);
  static const Color text = Color(0xFFF2F5F9);
  static const Color textMuted = Color(0xFF9CA9BC);
  static const Color primary = Color(0xFF25C05C);
  static const Color onPrimary = Color(0xFF06210F);
  static const Color border = Color(0xFF606E80);
  static const Color danger = Color(0xFFFF6B6B);

  static const double textSm = 14;
  static const double textBase = 17;
  static const double textXl = 28;

  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 32;
  static const double radius = 14;

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          surface: bg,
          primary: primary,
          onPrimary: onPrimary,
          error: danger,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: textBase, color: text),
          bodySmall: TextStyle(fontSize: textSm, color: textMuted),
          headlineSmall:
              TextStyle(fontSize: textXl, color: text, fontWeight: FontWeight.w700),
        ),
      );
}
