import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Google Material 3 核心調色盤
  static const Color primary = Color(0xFF1A73E8); // Google Material Blue
  static const Color primaryDark = Color(0xFF8AB4F8);
  static const Color secondary = Color(0xFF34A853); // Material Green
  static const Color accent = Color(0xFF4285F4);
  static const Color warning = Color(0xFFFBBC04); // Material Amber/Yellow
  static const Color error = Color(0xFFEA4335); // Material Red

  // 背景與表面
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightDivider = Color(0xFFE0E0E0);
  static const Color lightTextPrimary = Color(0xFF202124);
  static const Color lightTextSecondary = Color(0xFF5F6368);

  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF242424);
  static const Color darkDivider = Color(0xFF3C4043);
  static const Color darkTextPrimary = Color(0xFFE8EAED);
  static const Color darkTextSecondary = Color(0xFF9AA0A6);

  // 答題與狀態
  static const Color correctGreen = Color(0xFF0F9D58);
  static const Color incorrectRed = Color(0xFFDB4437);
  static const Color optionSelected = Color(0xFFE8F0FE);
  static const Color optionSelectedDark = Color(0xFF1A3B66);

  // 浮水印顏色
  static const Color watermarkLight = Color(0x0F000000);
  static const Color watermarkDark = Color(0x0FFFFFFF);
}
