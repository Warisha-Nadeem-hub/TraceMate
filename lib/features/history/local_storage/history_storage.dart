import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../../../models/sketch_item.dart';

class HistoryStorage {
  static const String _fileName = 'history.json';

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _file async {
    final path = await _localPath;
    return File(path + '/' + _fileName);
  }

  Future<List<SketchItem>> loadHistory() async {
    try {
      final file = await _file;
      if (!await file.exists()) return [];
      final contents = await file.readAsString();
      if (contents.isEmpty) return [];
      final jsonList = json.decode(contents) as List<dynamic>;
      return jsonList
          .map((e) => SketchItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  Future<void> saveHistory(List<SketchItem> items) async {
    try {
      final file = await _file;
      final jsonList = items.map((e) => e.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> addItem(SketchItem item) async {
    try {
      final items = await loadHistory();
      items.insert(0, item);
      await saveHistory(items);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateItem(SketchItem item) async {
    try {
      final items = await loadHistory();
      final index = items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        items[index] = item;
        await saveHistory(items);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      final items = await loadHistory();
      items.removeWhere((item) => item.id == id);
      await saveHistory(items);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> clearHistory() async {
    try {
      await saveHistory([]);
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
