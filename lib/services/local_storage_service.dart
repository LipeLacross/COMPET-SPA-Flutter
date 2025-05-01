import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/offline_record.dart';

class LocalStorageService {
  static const _queueKey = 'offline_queue';

  Future<void> saveRecord(OfflineRecord rec) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_queueKey) ?? [];
    list.add(json.encode(rec.toMap()));
    await prefs.setStringList(_queueKey, list);
  }

  Future<List<OfflineRecord>> fetchQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_queueKey) ?? [];
    return list
        .map((e) => OfflineRecord.fromMap(json.decode(e)))
        .toList();
  }

  Future<void> clearQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_queueKey);
  }
}
