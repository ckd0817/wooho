import 'package:flutter/material.dart';

/// 文字样式定义
class AppTextStyles {
  AppTextStyles._();

  // ============ 标题样式 ============
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  // ============ 正文样式 ============
  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  // ============ Drill 模式样式 ============
  static const TextStyle drillMoveName = TextStyle(
    fontSize: 56,
    fontWeight: FontWeight.bold,
    height: 1.0,
  );

  static const TextStyle drillNextMove = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.normal,
    height: 1.2,
  );

  static const TextStyle drillBpm = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.0,
  );

  // ============ 按钮样式 ============
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.0,
  );

  static const TextStyle buttonLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    height: 1.0,
  );
}
