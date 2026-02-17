import '../datasources/local/dance_move_dao.dart';
import '../models/dance_move.dart';

/// 动作仓库
class DanceMoveRepository {
  final DanceMoveDao _dao = DanceMoveDao();

  /// 添加动作
  Future<void> addMove(DanceMove move) async {
    await _dao.insert(move);
  }

  /// 批量添加动作
  Future<void> addMoves(List<DanceMove> moves) async {
    await _dao.insertAll(moves);
  }

  /// 获取所有动作
  Future<List<DanceMove>> getAllMoves() async {
    return await _dao.getAll();
  }

  /// 根据 ID 获取动作
  Future<DanceMove?> getMoveById(String id) async {
    return await _dao.getById(id);
  }

  /// 获取今日待复习动作
  Future<List<DanceMove>> getDueMoves() async {
    return await _dao.getDueMoves();
  }

  /// 按分类获取动作
  Future<List<DanceMove>> getMovesByCategory(String category) async {
    return await _dao.getByCategory(category);
  }

  /// 获取所有分类
  Future<List<String>> getAllCategories() async {
    return await _dao.getAllCategories();
  }

  /// 更新动作
  Future<void> updateMove(DanceMove move) async {
    await _dao.update(move);
  }

  /// 删除动作
  Future<void> deleteMove(String id) async {
    await _dao.delete(id);
  }

  /// 获取动作总数
  Future<int> getMoveCount() async {
    return await _dao.getCount();
  }

  /// 获取待复习动作数量
  Future<int> getDueCount() async {
    return await _dao.getDueCount();
  }
}
