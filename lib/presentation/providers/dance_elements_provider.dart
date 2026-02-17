import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 舞蹈元素（动作名称）
class DanceElement {
  final String id;
  final String name;

  const DanceElement({
    required this.id,
    required this.name,
  });

  factory DanceElement.fromJson(Map<String, dynamic> json) {
    return DanceElement(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}

/// 舞蹈分类
class DanceCategory {
  final String id;
  final String name;
  final String description;
  final List<DanceElement> elements;

  const DanceCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.elements,
  });

  factory DanceCategory.fromJson(Map<String, dynamic> json) {
    return DanceCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      elements: (json['elements'] as List)
          .map((e) => DanceElement.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// 预置舞蹈元素库
class DanceElementsLibrary {
  final List<DanceCategory> categories;

  const DanceElementsLibrary({
    required this.categories,
  });

  factory DanceElementsLibrary.fromJson(Map<String, dynamic> json) {
    return DanceElementsLibrary(
      categories: (json['categories'] as List)
          .map((e) => DanceCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 获取所有分类名称
  List<String> getCategoryNames() {
    return categories.map((c) => c.name).toList();
  }

  /// 根据分类名称获取元素
  List<DanceElement> getElementsForCategory(String categoryName) {
    final category = categories.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => categories.first,
    );
    return category.elements;
  }

  /// 搜索元素
  List<(DanceCategory, DanceElement)> searchElements(String query) {
    final results = <(DanceCategory, DanceElement)>[];
    final lowerQuery = query.toLowerCase();

    for (final category in categories) {
      for (final element in category.elements) {
        if (element.name.toLowerCase().contains(lowerQuery) ||
            category.name.toLowerCase().contains(lowerQuery)) {
          results.add((category, element));
        }
      }
    }

    return results;
  }
}

/// 加载预置舞蹈元素库
Future<DanceElementsLibrary> loadDanceElementsLibrary() async {
  try {
    final String jsonString = await rootBundle.loadString(
      'assets/data/dance_elements.json',
    );
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    return DanceElementsLibrary.fromJson(jsonMap);
  } catch (e) {
    // 如果加载失败，返回空库
    return const DanceElementsLibrary(categories: []);
  }
}

/// 预置舞蹈元素库 Provider
final danceElementsLibraryProvider = FutureProvider<DanceElementsLibrary>((ref) async {
  return await loadDanceElementsLibrary();
});

/// 分类列表 Provider
final categoryNamesProvider = FutureProvider<List<String>>((ref) async {
  final library = await ref.watch(danceElementsLibraryProvider.future);
  return library.getCategoryNames();
});

/// 搜索元素 Provider
final searchElementsProvider = Provider.family<List<(DanceCategory, DanceElement)>, String>((ref, query) {
  final libraryAsync = ref.watch(danceElementsLibraryProvider);
  return libraryAsync.maybeWhen(
    data: (library) => library.searchElements(query),
    orElse: () => [],
  );
});
