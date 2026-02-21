import '../datasources/local/dance_element_dao.dart';
import '../models/dance_element.dart';

/// 元素仓库
class DanceElementRepository {
  final DanceElementDao _dao = DanceElementDao();

  /// 添加元素
  Future<void> addElement(DanceElement element) async {
    await _dao.insert(element);
  }

  /// 批量添加元素
  Future<void> addElements(List<DanceElement> elements) async {
    await _dao.insertAll(elements);
  }

  /// 获取所有元素
  Future<List<DanceElement>> getAllElements() async {
    return await _dao.getAll();
  }

  /// 获取训练元素列表（按优先级排序，选取前 N 个）
  Future<List<DanceElement>> getTrainingElements({int count = 10}) async {
    return await _dao.getElementsForTraining(count: count);
  }

  /// 根据 ID 获取元素
  Future<DanceElement?> getElementById(String id) async {
    return await _dao.getById(id);
  }

  /// 按分类获取元素
  Future<List<DanceElement>> getElementsByCategory(String category) async {
    return await _dao.getByCategory(category);
  }

  /// 获取所有分类
  Future<List<String>> getAllCategories() async {
    return await _dao.getAllCategories();
  }

  /// 更新元素
  Future<void> updateElement(DanceElement element) async {
    await _dao.update(element);
  }

  /// 删除元素
  Future<void> deleteElement(String id) async {
    await _dao.delete(id);
  }

  /// 获取元素总数
  Future<int> getElementCount() async {
    return await _dao.getCount();
  }
}
