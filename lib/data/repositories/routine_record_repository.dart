import '../datasources/local/routine_record_dao.dart';
import '../models/routine_record.dart';

/// 舞段训练记录仓库
class RoutineRecordRepository {
  final RoutineRecordDao _dao = RoutineRecordDao();

  /// 添加训练记录
  Future<void> addRecord(RoutineRecord record) async {
    await _dao.insert(record);
  }

  /// 获取某舞段的所有训练记录
  Future<List<RoutineRecord>> getRecordsByRoutineId(String routineId) async {
    return await _dao.getByRoutineId(routineId);
  }

  /// 获取某日期范围内的训练记录
  Future<List<RoutineRecord>> getRecordsByDateRange(
    int startTimestamp,
    int endTimestamp,
  ) async {
    return await _dao.getByDateRange(startTimestamp, endTimestamp);
  }

  /// 获取今日训练次数
  Future<int> getTodayReviewCount() async {
    return await _dao.getTodayReviewCount();
  }

  /// 删除某舞段的所有训练记录
  Future<void> deleteRecordsByRoutineId(String routineId) async {
    await _dao.deleteByRoutineId(routineId);
  }

  /// 获取本周训练次数
  Future<int> getWeekReviewCount() async {
    return await _dao.getWeekReviewCount();
  }

  /// 获取连续打卡天数
  Future<int> getStreakDays() async {
    return await _dao.getStreakDays();
  }
}
