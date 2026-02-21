import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 预置元素（官方库中的元素名称）
class PresetElement {
  final String id;
  final String name;

  const PresetElement({
    required this.id,
    required this.name,
  });

  factory PresetElement.fromJson(Map<String, dynamic> json) {
    return PresetElement(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}

/// 预置分类
class PresetCategory {
  final String id;
  final String name;
  final String description;
  final List<PresetElement> elements;

  const PresetCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.elements,
  });

  factory PresetCategory.fromJson(Map<String, dynamic> json) {
    return PresetCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      elements: (json['elements'] as List)
          .map((e) => PresetElement.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// 预置元素库
class PresetElementsLibrary {
  final List<PresetCategory> categories;

  const PresetElementsLibrary({
    required this.categories,
  });

  factory PresetElementsLibrary.fromJson(Map<String, dynamic> json) {
    return PresetElementsLibrary(
      categories: (json['categories'] as List)
          .map((e) => PresetCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 获取所有分类名称
  List<String> getCategoryNames() {
    return categories.map((c) => c.name).toList();
  }

  /// 根据分类名称获取元素
  List<PresetElement> getElementsForCategory(String categoryName) {
    final category = categories.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => categories.first,
    );
    return category.elements;
  }

  /// 搜索元素
  List<(PresetCategory, PresetElement)> searchElements(String query) {
    final results = <(PresetCategory, PresetElement)>[];
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

/// 加载预置元素库
Future<PresetElementsLibrary> loadPresetElementsLibrary() async {
  try {
    final String jsonString = await rootBundle.loadString(
      'assets/data/dance_elements.json',
    );
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    return PresetElementsLibrary.fromJson(jsonMap);
  } catch (e) {
    // 如果加载失败，返回空库
    return const PresetElementsLibrary(categories: []);
  }
}

/// 预置元素库 Provider
final presetElementsLibraryProvider = FutureProvider<PresetElementsLibrary>((ref) async {
  return await loadPresetElementsLibrary();
});

/// 分类列表 Provider
final categoryNamesProvider = FutureProvider<List<String>>((ref) async {
  final library = await ref.watch(presetElementsLibraryProvider.future);
  return library.getCategoryNames();
});

/// 搜索元素 Provider
final searchPresetElementsProvider = Provider.family<List<(PresetCategory, PresetElement)>, String>((ref, query) {
  final libraryAsync = ref.watch(presetElementsLibraryProvider);
  return libraryAsync.maybeWhen(
    data: (library) => library.searchElements(query),
    orElse: () => [],
  );
});
