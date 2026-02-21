import '../datasources/local/review_dao.dart';

/// 复习记录仓库
class ReviewRepository {
  final ReviewDao _dao = ReviewDao();

  /// 添加复习记录
  Future<void> addRecord(ReviewRecord record) async {
    await _dao.insert(record);
  }

  /// 获取某元素的复习历史
  Future<List<ReviewRecord>> getElementHistory(String elementId) async {
    return await _dao.getByElementId(elementId);
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

  /// 删除某元素的复习记录
  Future<void> deleteElementRecords(String elementId) async {
    await _dao.deleteByElementId(elementId);
  }

  /// 获取本周复习次数
  Future<int> getWeekReviewCount() async {
    return await _dao.getWeekReviewCount();
  }

  /// 获取连续打卡天数
  Future<int> getStreakDays() async {
    return await _dao.getStreakDays();
  }

  /// 获取某天的复习记录数
  Future<int> getReviewCountForDate(DateTime date) async {
    return await _dao.getReviewCountForDate(date);
  }
}
