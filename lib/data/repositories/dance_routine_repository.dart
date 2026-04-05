import '../datasources/local/dance_routine_dao.dart';
import '../models/dance_routine.dart';

/// 舞段仓库
class DanceRoutineRepository {
  final DanceRoutineDao _dao = DanceRoutineDao();

  /// 添加舞段
  Future<void> addRoutine(DanceRoutine routine) async {
    await _dao.insert(routine);
  }

  /// 获取所有舞段
  Future<List<DanceRoutine>> getAllRoutines() async {
    return await _dao.getAll();
  }

  /// 获取训练舞段列表（按优先级排序，选取前 N 个）
  Future<List<DanceRoutine>> getTrainingRoutines({int count = 10}) async {
    return await _dao.getRoutinesForTraining(count: count);
  }

  /// 根据 ID 获取舞段
  Future<DanceRoutine?> getRoutineById(String id) async {
    return await _dao.getById(id);
  }

  /// 按分类获取舞段
  Future<List<DanceRoutine>> getRoutinesByCategory(String category) async {
    return await _dao.getByCategory(category);
  }

  /// 获取所有分类
  Future<List<String>> getAllCategories() async {
    return await _dao.getAllCategories();
  }

  /// 更新舞段
  Future<void> updateRoutine(DanceRoutine routine) async {
    await _dao.update(routine);
  }

  /// 删除舞段
  Future<int> deleteRoutine(String id) async {
    return await _dao.delete(id);
  }

  /// 获取舞段总数
  Future<int> getRoutineCount() async {
    return await _dao.getCount();
  }
}
