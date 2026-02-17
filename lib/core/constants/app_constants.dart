/// 应用常量
class AppConstants {
  AppConstants._();

  /// 应用名称
  static const String appName = 'DanceLoop';

  /// 应用版本
  static const String appVersion = '1.0.0';

  /// 默认 BPM
  static const int defaultBpm = 90;

  /// BPM 范围
  static const int minBpm = 60;
  static const int maxBpm = 130;

  /// 每个动作默认拍数
  static const int beatsPerMove = 8;

  /// 预告拍数 (动作结束前多少拍预告下一个)
  static const int announceBeats = 2;
}
