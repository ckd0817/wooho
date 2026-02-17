import '../datasources/local/review_dao.dart';

/// 复习记录仓库
class ReviewRepository {
  final ReviewDao _dao = ReviewDao();

  /// 添加复习记录
  Future<void> addRecord(ReviewRecord record) async {
    await _dao.insert(record);
  }

  /// 获取某动作的复习历史
  Future<List<ReviewRecord>> getMoveHistory(String moveId) async {
    return await _dao.getByMoveId(moveId);
  }

  /// 获取日期范围内的复习记录
  Future<List<ReviewRecord>> getRecordsByDateRange(
    int startTimestamp,
    int endTimestamp,
  ) async {
    return await _dao.getByDateRange(startTimestamp, endTimestamp);
  }

  /// 获取今日复习次数
  Future<int> getTodayReviewCount() async {
    return await _dao.getTodayReviewCount();
  }

  /// 删除某动作的复习记录
  Future<void> deleteMoveRecords(String moveId) async {
    await _dao.deleteByMoveId(moveId);
  }
}
