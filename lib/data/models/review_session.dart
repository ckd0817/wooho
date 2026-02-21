import 'package:freezed_annotation/freezed_annotation.dart';
import 'dance_element.dart';

part 'review_session.freezed.dart';
part 'review_session.g.dart';

/// 每日复习会话
@freezed
class ReviewSession with _$ReviewSession {
  const factory ReviewSession({
    required String date, // YYYY-MM-DD
    required List<DanceElement> items, // 今日需要复习的元素
    @Default([]) List<String> completedItemIds, // 已打分 ID
    @Default(false) bool isDrillComplete, // 是否完成了串联训练
    required int createdAt, // Timestamp
  }) = _ReviewSession;

  factory ReviewSession.fromJson(Map<String, dynamic> json) =>
      _$ReviewSessionFromJson(json);
}
