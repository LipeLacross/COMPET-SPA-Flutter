import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart'; // Pacote para pegar a imagem
import '../models/offline_record.dart';

class LocalStorageService {
  static const _queueKey = 'offline_queue';
  static const _areasKey = 'areas_key'; // Nova chave para armazenar as áreas cobertas

  /// Salva um novo registro na fila offline, incluindo a foto.
  Future<void> saveRecord(OfflineRecord rec, XFile imageFile) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_queueKey) ?? [];

    // Salvar a foto no diretório local
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = '${rec.id}.jpg';  // Use o ID ou outro identificador único para nomear o arquivo
    final filePath = '${appDir.path}/$fileName';
    await imageFile.saveTo(filePath);

    // A variável imagePath foi alterada de 'final' para permitir modificação
    rec.imagePath = filePath;

    // Adiciona o registro com o caminho da foto à lista de registros offline
    list.add(json.encode(rec.toMap()));  // Serializa o objeto OfflineRecord
    await prefs.setStringList(_queueKey, list);
  }

  /// Retorna todos os registros salvos na fila offline, incluindo as fotos.
  Future<List<OfflineRecord>> fetchQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_queueKey) ?? [];
    return list.map((e) => OfflineRecord.fromMap(json.decode(e))).toList();  // Deserializa os registros
  }

  /// Remove um registro específico pelo seu [id], incluindo a foto.
  Future<void> deleteRecord(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_queueKey) ?? [];
    final filtered = list.where((jsonStr) {
      final map = json.decode(jsonStr) as Map<String, dynamic>;
      return map['id'] != id;  // Filtra o registro com base no id
    }).toList();
    await prefs.setStringList(_queueKey, filtered);  // Atualiza a lista de registros
  }

  /// Atualiza um registro existente na fila offline, incluindo a foto.
  Future<void> updateRecord(OfflineRecord updated) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_queueKey) ?? [];
    final newList = list.map((jsonStr) {
      final map = json.decode(jsonStr) as Map<String, dynamic>;
      if (map['id'] == updated.id) {
        return json.encode(updated.toMap()); // Substitui o registro pelo novo
      }
      return jsonStr;
    }).toList();
    await prefs.setStringList(_queueKey, newList);  // Atualiza a lista de registros
  }

  /// Limpa toda a fila offline, removendo fotos também.
  Future<void> clearQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_queueKey) ?? [];
    for (var record in list) {
      final map = json.decode(record) as Map<String, dynamic>;
      final imagePath = map['imagePath'];
      if (imagePath != null) {
        final file = File(imagePath);
        if (await file.exists()) {
          await file.delete();  // Remove o arquivo de foto
        }
      }
    }
    await prefs.remove(_queueKey);  // Limpa a fila de registros offline
  }

  /// Salva uma nova área coberta (similar ao processo de salvar um registro offline).
  Future<void> saveArea(String areaName) async {
    final prefs = await SharedPreferences.getInstance();
    final areasList = prefs.getStringList(_areasKey) ?? [];
    areasList.add(areaName);  // Adiciona o nome da área
    await prefs.setStringList(_areasKey, areasList);  // Salva a lista de áreas
  }

  /// Retorna todas as áreas cobertas salvas.
  Future<List<String>> fetchAreas() async {
    final prefs = await SharedPreferences.getInstance();
    final areasList = prefs.getStringList(_areasKey) ?? [];
    return areasList;  // Retorna a lista de áreas
  }

  /// Remove uma área coberta específica.
  Future<void> deleteArea(String areaName) async {
    final prefs = await SharedPreferences.getInstance();
    final areasList = prefs.getStringList(_areasKey) ?? [];
    areasList.remove(areaName);  // Remove a área da lista
    await prefs.setStringList(_areasKey, areasList);  // Atualiza a lista de áreas
  }
}
