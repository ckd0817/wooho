import 'package:freezed_annotation/freezed_annotation.dart';

part 'drum_loop.freezed.dart';
part 'drum_loop.g.dart';

/// 鼓点循环音频
@freezed
class DrumLoop with _$DrumLoop {
  const factory DrumLoop({
    required String id,
    required String name,
    required String assetPath, // assets/audio/xxx.mp3
    required int bpm, // 原始 BPM
    @Default(true) bool isDefault, // 是否为内置
  }) = _DrumLoop;

  factory DrumLoop.fromJson(Map<String, dynamic> json) =>
      _$DrumLoopFromJson(json);
}
