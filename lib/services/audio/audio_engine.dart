import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../core/constants/audio_constants.dart';
import '../../core/constants/app_constants.dart';

/// 音频引擎 - 管理背景音乐、TTS 和 Audio Ducking
class AudioEngine {
  final AudioPlayer _bgmPlayer = AudioPlayer();
  final FlutterTts _tts = FlutterTts();

  bool _isInitialized = false;
  bool _isPlaying = false;
  int _currentBpm = AppConstants.defaultBpm;

  /// 是否正在播放
  bool get isPlaying => _isPlaying;

  /// 当前 BPM
  int get currentBpm => _currentBpm;

  /// 初始化音频引擎
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. 配置音频会话 (支持后台播放)
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());

      // 2. 初始化 TTS
      await _initTts();

      // 3. 加载背景音乐
      await _bgmPlayer.setAsset('assets/audio/drum_loop_90bpm.mp3');
      await _bgmPlayer.setLoopMode(LoopMode.one);

      _isInitialized = true;
    } catch (e) {
      rethrow;
    }
  }

  /// 初始化 TTS
  Future<void> _initTts() async {
    await _tts.setLanguage('zh-CN');
    await _tts.setSpeechRate(AudioConstants.defaultSpeechRate);
    await _tts.setVolume(1.0);

    // TTS 开始/结束监听 (用于 Audio Ducking)
    _tts.setStartHandler(_onTtsStart);
    _tts.setCompletionHandler(_onTtsComplete);
    _tts.setCancelHandler(_onTtsComplete);
  }

  /// 设置 BPM (60-130)
  Future<void> setBpm(int bpm) async {
    _currentBpm = bpm.clamp(AppConstants.minBpm, AppConstants.maxBpm);

    // 通过调整播放速度来改变 BPM
    // 目标速度 = 目标BPM / 原始BPM
    final speed = _currentBpm / AudioConstants.originalBpm;
    await _bgmPlayer.setSpeed(speed);
  }

  /// 播放背景鼓点
  Future<void> playBgm() async {
    if (!_isInitialized) await initialize();

    try {
      await _bgmPlayer.play();
      _isPlaying = true;
    } catch (e) {
      rethrow;
    }
  }

  /// 暂停背景音乐
  Future<void> pauseBgm() async {
    await _bgmPlayer.pause();
    _isPlaying = false;
  }

  /// 停止背景音乐
  Future<void> stopBgm() async {
    await _bgmPlayer.stop();
    _isPlaying = false;
  }

  /// TTS 朗读动作名称
  Future<void> speakMoveName(String moveName) async {
    await _tts.speak(moveName);
  }

  /// 停止 TTS
  Future<void> stopTts() async {
    await _tts.stop();
  }

  /// TTS 开始时 - 降低 BGM 音量 (Audio Ducking)
  void _onTtsStart() {
    _bgmPlayer.setVolume(AudioConstants.duckedVolume);
  }

  /// TTS 结束时 - 恢复 BGM 音量
  void _onTtsComplete() {
    _bgmPlayer.setVolume(AudioConstants.normalVolume);
  }

  /// 获取每个动作的时长 (毫秒)
  /// 基于当前 BPM 计算 8 拍的时长
  int getMoveDurationMs() {
    // 8 拍时长 (毫秒) = 8 * 60 * 1000 / BPM
    return AppConstants.beatsPerMove * 60 * 1000 ~/ _currentBpm;
  }

  /// 获取预告时长 (毫秒)
  /// 动作结束前 2 拍
  int getAnnounceDurationMs() {
    return AppConstants.announceBeats * 60 * 1000 ~/ _currentBpm;
  }

  /// 设置音量
  Future<void> setVolume(double volume) async {
    await _bgmPlayer.setVolume(volume);
  }

  /// 释放资源
  void dispose() {
    _bgmPlayer.dispose();
    _tts.stop();
  }
}
