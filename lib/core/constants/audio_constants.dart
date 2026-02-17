/// 音频相关常量
class AudioConstants {
  AudioConstants._();

  /// 正常音量
  static const double normalVolume = 1.0;

  /// Ducking 时音量 (TTS 播放时 BGM 音量)
  static const double duckedVolume = 0.2;

  /// 原始鼓点 BPM (用于速度计算)
  static const int originalBpm = 90;

  /// 默认语速
  static const double defaultSpeechRate = 0.9;
}
