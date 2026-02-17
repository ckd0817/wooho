import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/dance_move.dart';
import '../../services/audio/audio_engine.dart';
import '../../core/constants/app_constants.dart';

/// 音频引擎 Provider
final audioEngineProvider = Provider<AudioEngine>((ref) {
  final engine = AudioEngine();
  ref.onDispose(() => engine.dispose());
  return engine;
});

/// 串联训练状态
class DrillState {
  final List<DanceMove> queue;
  final int currentIndex;
  final bool isPlaying;
  final int bpm;

  const DrillState({
    this.queue = const [],
    this.currentIndex = 0,
    this.isPlaying = false,
    this.bpm = AppConstants.defaultBpm,
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
  }) {
    return DrillState(
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      bpm: bpm ?? this.bpm,
    );
  }
}

/// 串联训练 Notifier
class DrillNotifier extends StateNotifier<DrillState> {
  final AudioEngine _audioEngine;
  Timer? _moveTimer;
  Timer? _announceTimer;
  // ignore: unused_field
  final Ref _ref; // 保留用于将来扩展

  DrillNotifier(this._audioEngine, this._ref) : super(const DrillState());

  /// 开始串联训练
  Future<void> startDrill(List<DanceMove> moves) async {
    if (moves.isEmpty) return;

    // 停止之前的计时器
    _cancelTimers();

    // 随机打乱队列
    final shuffled = List<DanceMove>.from(moves)..shuffle();

    state = DrillState(
      queue: shuffled,
      currentIndex: 0,
      isPlaying: true,
      bpm: state.bpm,
    );

    // 初始化音频引擎
    await _audioEngine.initialize();
    await _audioEngine.setBpm(state.bpm);
    await _audioEngine.playBgm();

    // 预告第一个动作
    await _audioEngine.speakMoveName(state.currentMove!.name);

    // 开始动作循环
    _startMoveCycle();
  }

  /// 开始动作循环
  void _startMoveCycle() {
    final moveDurationMs = _audioEngine.getMoveDurationMs();
    final announceDurationMs = _audioEngine.getAnnounceDurationMs();

    _cancelTimers();

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
  }

  /// 预告下一个动作
  Future<void> _announceNextMove() async {
    if (!state.isPlaying) return;

    final nextMove = state.nextMove;
    if (nextMove != null) {
      await _audioEngine.speakMoveName(nextMove.name);
    }
  }

  /// 当前动作完成，切换到下一个
  void _onMoveComplete() {
    if (!state.isPlaying) return;

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

    // 重启计时器以应用新的时长
    if (state.isPlaying) {
      _startMoveCycle();
    }
  }

  /// 暂停训练
  Future<void> pauseDrill() async {
    _cancelTimers();
    await _audioEngine.pauseBgm();
    state = state.copyWith(isPlaying: false);
  }

  /// 恢复训练
  Future<void> resumeDrill() async {
    if (!state.hasMoves) return;

    await _audioEngine.playBgm();
    state = state.copyWith(isPlaying: true);
    _startMoveCycle();
  }

  /// 停止训练
  Future<void> stopDrill() async {
    _cancelTimers();
    await _audioEngine.stopBgm();
    await _audioEngine.stopTts();
    state = state.copyWith(isPlaying: false);
  }

  /// 取消所有计时器
  void _cancelTimers() {
    _moveTimer?.cancel();
    _moveTimer = null;
    _announceTimer?.cancel();
    _announceTimer = null;
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
