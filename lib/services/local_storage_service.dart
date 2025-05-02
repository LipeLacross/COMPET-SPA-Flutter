//local_storage_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/offline_record.dart';

class LocalStorageService {
  static const _queueKey = 'offline_queue';

  /// Salva um novo registro na fila offline.
  Future<void> saveRecord(OfflineRecord rec) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_queueKey) ?? [];
    list.add(json.encode(rec.toMap()));
    await prefs.setStringList(_queueKey, list);
  }

  /// Retorna todos os registros salvos na fila offline.
  Future<List<OfflineRecord>> fetchQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_queueKey) ?? [];
    return list
        .map((e) => OfflineRecord.fromMap(json.decode(e)))
        .toList();
  }

  /// Remove um registro específico pelo seu [id].
  Future<void> deleteRecord(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_queueKey) ?? [];
    // Filtra todos os registros que NÃO têm o id fornecido
    final filtered = list.where((jsonStr) {
      final map = json.decode(jsonStr) as Map<String, dynamic>;
      return map['id'] != id;
    }).toList();
    await prefs.setStringList(_queueKey, filtered);
  }
  /// Atualiza um registro existente na fila offline.
  Future<void> updateRecord(OfflineRecord updated) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_queueKey) ?? [];
    final newList = list.map((jsonStr) {
      final map = json.decode(jsonStr) as Map<String, dynamic>;
      if (map['id'] == updated.id) {
        // substitui pelo novo payload
        return json.encode(updated.toMap());
      }
      return jsonStr;
    }).toList();
    await prefs.setStringList(_queueKey, newList);
  }

  /// Limpa toda a fila offline.
  Future<void> clearQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_queueKey);
  }
}
