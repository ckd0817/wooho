import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/dance_move.dart';
import '../../data/models/drum_loop.dart';
import '../../services/audio/audio_engine.dart';
import '../../core/constants/app_constants.dart';

/// 音频引擎 Provider
final audioEngineProvider = Provider<AudioEngine>((ref) {
  final engine = AudioEngine();
  ref.onDispose(() => engine.dispose());
  return engine;
});

/// 当前节拍 Provider（独立管理，确保 UI 更新）
final currentBeatProvider = StateProvider<int>((ref) => 0);

/// 串联训练状态
class DrillState {
  final List<DanceMove> queue;
  final int currentIndex;
  final bool isPlaying;
  final int bpm;
  final DrumLoop? currentDrumLoop;
  final List<DrumLoop> availableLoops;

  const DrillState({
    this.queue = const [],
    this.currentIndex = 0,
    this.isPlaying = false,
    this.bpm = AppConstants.defaultBpm,
    this.currentDrumLoop,
    this.availableLoops = const [],
  });

  /// 当前动作
  DanceMove? get currentMove =>
      queue.isNotEmpty && currentIndex < queue.length
          ? queue[currentIndex]
          : null;

  /// 下一个动作
  DanceMove? get nextMove {
    final nextIndex = currentIndex + 1;
    if (nextIndex < queue.length) {
      return queue[nextIndex];
    }
    // 如果是最后一个，返回洗牌后的第一个
    return queue.isNotEmpty ? queue[0] : null;
  }

  /// 是否有动作
  bool get hasMoves => queue.isNotEmpty;

  DrillState copyWith({
    List<DanceMove>? queue,
    int? currentIndex,
    bool? isPlaying,
    int? bpm,
    DrumLoop? currentDrumLoop,
    List<DrumLoop>? availableLoops,
  }) {
    return DrillState(
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      bpm: bpm ?? this.bpm,
      currentDrumLoop: currentDrumLoop ?? this.currentDrumLoop,
      availableLoops: availableLoops ?? this.availableLoops,
    );
  }
}

/// 串联训练 Notifier
class DrillNotifier extends StateNotifier<DrillState> {
  final AudioEngine _audioEngine;
  final Ref _ref;
  Timer? _moveTimer;
  Timer? _announceTimer;
  Timer? _beatTimer;
  int _beatCount = 0;
  bool _isPlaying = false; // 实例级别的播放状态，用于 Timer 回调

  DrillNotifier(this._audioEngine, this._ref) : super(const DrillState());

  /// 开始串联训练
  Future<void> startDrill(List<DanceMove> moves) async {
    if (moves.isEmpty) return;

    // 停止之前的计时器
    _cancelTimers();
    _isPlaying = false; // 重置状态

    // 随机打乱队列
    final shuffled = List<DanceMove>.from(moves)..shuffle();

    // 初始化音频引擎
    await _audioEngine.initialize();

    // 使用音频的原始 BPM 作为默认值
    final defaultBpm = _audioEngine.currentDrumLoop?.bpm ?? AppConstants.defaultBpm;
    await _audioEngine.setBpm(defaultBpm);

    // 1. 立即更新状态，让 UI 马上响应
    _isPlaying = true;
    state = DrillState(
      queue: shuffled,
      currentIndex: 0,
      isPlaying: true,
      bpm: defaultBpm,
      currentDrumLoop: _audioEngine.currentDrumLoop,
      availableLoops: _audioEngine.availableLoops,
    );

    // 2. 立即启动 Timer（同步操作，几乎无延迟）
    _startMoveCycle();

    // 3. 异步播放音频（不阻塞 UI）
    await _audioEngine.playBgm();
  }

  /// 准备训练（不自动开始，等待用户点击播放）
  Future<void> prepareDrill(List<DanceMove> moves) async {
    if (moves.isEmpty) return;

    // 停止之前的计时器
    _cancelTimers();
    _isPlaying = false; // 确保初始状态为暂停

    // 随机打乱队列
    final shuffled = List<DanceMove>.from(moves)..shuffle();

    // 初始化音频引擎（但不播放）
    await _audioEngine.initialize();

    // 使用音频的原始 BPM 作为默认值
    final defaultBpm = _audioEngine.currentDrumLoop?.bpm ?? AppConstants.defaultBpm;
    await _audioEngine.setBpm(defaultBpm);

    // 设置状态但不开始播放
    state = DrillState(
      queue: shuffled,
      currentIndex: 0,
      isPlaying: false,  // 初始为暂停状态
      bpm: defaultBpm,
      currentDrumLoop: _audioEngine.currentDrumLoop,
      availableLoops: _audioEngine.availableLoops,
    );
  }

  /// 开始动作循环
  void _startMoveCycle() {
    final moveDurationMs = _audioEngine.getMoveDurationMs();
    final announceDurationMs = _audioEngine.getAnnounceDurationMs();

    debugPrint('_startMoveCycle called: moveDuration=$moveDurationMs ms, isPlaying=${state.isPlaying}, _isPlaying=$_isPlaying');

    // 如果外部状态显示正在播放但内部状态不是，同步它们
    if (state.isPlaying && !_isPlaying) {
      debugPrint('Syncing _isPlaying to match state.isPlaying');
      _isPlaying = true;
    }

    _cancelTimers();

    // 启动节拍循环
    _startBeatCycle();

    // 在动作结束前 2 拍预告下一个动作
    final announceDelayMs = moveDurationMs - announceDurationMs;
    _announceTimer = Timer(
      Duration(milliseconds: announceDelayMs),
      () => _announceNextMove(),
    );

    // 动作结束后切换到下一个
    _moveTimer = Timer(
      Duration(milliseconds: moveDurationMs),
      () => _onMoveComplete(),
    );

    debugPrint('Timers created: beatTimer=$_beatTimer, moveTimer=$_moveTimer');
  }

  /// 开始节拍循环
  void _startBeatCycle() {
    final moveDurationMs = _audioEngine.getMoveDurationMs();
    final beatDurationMs = moveDurationMs ~/ 8;

    debugPrint('Beat cycle started: moveDuration=$moveDurationMs ms, beatDuration=$beatDurationMs ms, _isPlaying=$_isPlaying');

    _beatTimer?.cancel();
    _beatCount = 0;
    // 使用独立的 currentBeatProvider 来更新节拍
    _ref.read(currentBeatProvider.notifier).state = 0;
    debugPrint('Initial currentBeat = 0');

    _beatTimer = Timer.periodic(
      Duration(milliseconds: beatDurationMs),
      (_) {
        if (!_isPlaying) {
          debugPrint('Beat timer: not playing (_isPlaying=$_isPlaying), skip');
          return;
        }

        _beatCount = (_beatCount + 1) % 8;
        debugPrint('Beat: $_beatCount');
        // 使用独立的 currentBeatProvider 来更新节拍
        _ref.read(currentBeatProvider.notifier).state = _beatCount;
      },
    );
  }

  /// 预告下一个动作 (已移除 TTS)
  void _announceNextMove() {
    // TTS 功能已移除
  }

  /// 当前动作完成，切换到下一个
  void _onMoveComplete() {
    // 使用实例变量进行检查
    if (!_isPlaying) {
      debugPrint('_onMoveComplete: not playing, return');
      return;
    }

    final nextIndex = state.currentIndex + 1;

    if (nextIndex >= state.queue.length) {
      // 队列结束，重新洗牌并继续
      _reshuffleAndContinue();
    } else {
      // 切换到下一个动作
      state = state.copyWith(currentIndex: nextIndex);
      _startMoveCycle();
    }
  }

  /// 重新洗牌并继续
  void _reshuffleAndContinue() {
    final reshuffled = List<DanceMove>.from(state.queue)..shuffle();

    state = state.copyWith(
      queue: reshuffled,
      currentIndex: 0,
    );

    _startMoveCycle();
  }

  /// 调整 BPM
  Future<void> setBpm(int bpm) async {
    final clampedBpm = bpm.clamp(AppConstants.minBpm, AppConstants.maxBpm);
    await _audioEngine.setBpm(clampedBpm);
    state = state.copyWith(bpm: clampedBpm);

    // 重启计时器以应用新的时长（使用实例变量检查）
    if (_isPlaying) {
      _startMoveCycle();
    }
  }

  /// 选择音频
  Future<void> selectDrumLoop(DrumLoop loop) async {
    await _audioEngine.selectDrumLoop(loop);
    state = state.copyWith(currentDrumLoop: loop);
  }

  /// 暂停训练
  Future<void> pauseDrill() async {
    _isPlaying = false; // 先更新实例变量
    _cancelTimers();
    await _audioEngine.pauseBgm();
    state = state.copyWith(isPlaying: false);
  }

  /// 恢复训练（或从准备状态开始）
  Future<void> resumeDrill() async {
    debugPrint('resumeDrill called, hasMoves=${state.hasMoves}');

    if (!state.hasMoves) {
      debugPrint('resumeDrill: no moves, returning');
      return;
    }

    // 1. 立即更新状态，让 UI 马上响应
    _isPlaying = true;
    state = state.copyWith(isPlaying: true);

    // 2. 立即启动 Timer（同步操作，几乎无延迟）
    _startMoveCycle();

    // 3. 异步播放音频（不阻塞 UI）
    try {
      await _audioEngine.initialize();
      await _audioEngine.setBpm(state.bpm);
      await _audioEngine.playBgm();
    } catch (e) {
      debugPrint('Drill resume error: $e');
    }
  }

  /// 停止训练
  Future<void> stopDrill() async {
    _isPlaying = false; // 先更新实例变量
    _cancelTimers();
    await _audioEngine.stopBgm();
    state = state.copyWith(isPlaying: false);
  }

  /// 取消所有计时器
  void _cancelTimers() {
    _moveTimer?.cancel();
    _moveTimer = null;
    _announceTimer?.cancel();
    _announceTimer = null;
    _beatTimer?.cancel();
    _beatTimer = null;
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }
}

/// 串联训练 Provider
final drillProvider =
    StateNotifierProvider<DrillNotifier, DrillState>((ref) {
  return DrillNotifier(ref.watch(audioEngineProvider), ref);
});
