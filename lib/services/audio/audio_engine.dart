import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../core/constants/audio_constants.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/drum_loop.dart';

/// 音频引擎 - 管理背景音乐、TTS 和 Audio Ducking
/// 支持多个不同 BPM 的鼓点音频文件
class AudioEngine {
  final AudioPlayer _bgmPlayer = AudioPlayer();
  final FlutterTts _tts = FlutterTts();

  bool _isInitialized = false;
  bool _isPlaying = false;
  int _currentBpm = AppConstants.defaultBpm;
  DrumLoop? _currentDrumLoop;
  List<DrumLoop> _availableLoops = [];

  /// 是否正在播放
  bool get isPlaying => _isPlaying;

  /// 当前 BPM
  int get currentBpm => _currentBpm;

  /// 当前音频
  DrumLoop? get currentDrumLoop => _currentDrumLoop;

  /// 可用的音频列表
  List<DrumLoop> get availableLoops => _availableLoops;

  /// 加载音频配置
  Future<void> _loadDrumLoops() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/drum_loops.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      _availableLoops = jsonList.map((json) => DrumLoop.fromJson(json)).toList();
    } catch (e) {
      // 如果加载失败，使用空列表
      _availableLoops = [];
    }
  }

  /// 根据目标 BPM 选择最接近的音频
  DrumLoop? _selectBestLoop(int targetBpm) {
    if (_availableLoops.isEmpty) return null;

    // 找到最接近的音频
    DrumLoop? bestLoop;
    int minDiff = double.maxFinite.toInt();

    for (final loop in _availableLoops) {
      final diff = (loop.bpm - targetBpm).abs();
      if (diff < minDiff) {
        minDiff = diff;
        bestLoop = loop;
      }
    }

    return bestLoop;
  }

  /// 初始化音频引擎
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. 加载音频配置
      await _loadDrumLoops();

      // 2. 配置音频会话 (支持后台播放)
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());

      // 3. 初始化 TTS
      await _initTts();

      // 4. 加载默认音频
      await _loadAudioForBpm(_currentBpm);

      _isInitialized = true;
    } catch (e) {
      debugPrint('音频引擎初始化失败: $e');
      // 不抛出异常，允许应用继续运行
      _isInitialized = false;
    }
  }

  /// 加载指定 BPM 的音频
  Future<void> _loadAudioForBpm(int bpm) async {
    final loop = _selectBestLoop(bpm);
    if (loop == null) {
      throw Exception('没有可用的鼓点音频');
    }

    // 如果是同一个音频，不需要重新加载
    if (_currentDrumLoop?.id == loop.id) {
      return;
    }

    _currentDrumLoop = loop;
    await _bgmPlayer.setAsset(loop.assetPath);
    await _bgmPlayer.setLoopMode(LoopMode.one);
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

    // 计算播放速度 (基于当前音频的原始 BPM)
    if (_currentDrumLoop != null) {
      final speed = _currentBpm / _currentDrumLoop!.bpm;
      await _bgmPlayer.setSpeed(speed);
    }
  }

  /// 选择指定音频
  Future<void> selectDrumLoop(DrumLoop loop) async {
    if (_currentDrumLoop?.id == loop.id) return;

    final wasPlaying = _isPlaying;
    if (wasPlaying) {
      await _bgmPlayer.stop();
    }

    _currentDrumLoop = loop;
    await _bgmPlayer.setAsset(loop.assetPath);
    await _bgmPlayer.setLoopMode(LoopMode.one);

    // 根据当前 BPM 调整播放速度
    final speed = _currentBpm / loop.bpm;
    await _bgmPlayer.setSpeed(speed);

    if (wasPlaying) {
      await _bgmPlayer.play();
    }
  }

  /// 播放背景鼓点
  Future<void> playBgm() async {
    if (!_isInitialized) {
      await initialize();
      if (!_isInitialized) {
        debugPrint('音频未初始化，无法播放');
        return;
      }
    }

    try {
      await _bgmPlayer.play();
      _isPlaying = true;
    } catch (e) {
      debugPrint('播放音频失败: $e');
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
