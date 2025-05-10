import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'session_manager.dart';
import 'image_processing_service.dart';
import '../models/offline_record.dart';
import 'geolocation_service.dart';  // Certifique-se de importar o GeolocationService
import 'package:geolocator/geolocator.dart';

class ApiService {
  final String baseUrl = 'http://10.0.2.2:8000/';
  final SessionManager _sm = SessionManager();
  final ImageProcessingService _imgService = ImageProcessingService();
  final GeolocationService _geoService = GeolocationService(); // Instanciando GeolocationService

  /// Envia um registro completo, com foto e metadados GPS.
  /// Valida a imagem via IA antes de enviar.
  Future<http.Response> postWithFile({
    required String path,
    required Map<String, dynamic> data,
    required File file,
    required double latitude,
    required double longitude,
  }) async {
    final token = await _sm.getToken();
    final uri = Uri.parse('$baseUrl$path');

    // 1- Valida a imagem por IA
    final isValid = await _imgService.validateImage(file);
    if (!isValid) {
      throw Exception('Imagem inválida. Tire outra foto de melhor qualidade.');
    }

    // 2- Monta a requisição multipart
    final req = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields.addAll(data.map((k, v) => MapEntry(k, v.toString())))
      ..fields['latitude'] = latitude.toString()
      ..fields['longitude'] = longitude.toString()
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: MediaType('image', 'jpeg'),
      ));

    // 3- Envia e converte em http.Response tradicional
    final streamed = await req.send();
    return await http.Response.fromStream(streamed);
  }

  /// POST genérico sem arquivo
  Future<http.Response> post(String path, Map<String, dynamic> data) async {
    final token = await _sm.getToken();
    final uri = Uri.parse('$baseUrl$path');
    return await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );
  }

  /// GET genérico
  Future<http.Response> get(String path) async {
    final token = await _sm.getToken();
    final uri = Uri.parse('$baseUrl$path');
    return await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }

  /// PUT genérico
  Future<http.Response> put(String path, Map<String, dynamic> data) async {
    final token = await _sm.getToken();
    final uri = Uri.parse('$baseUrl$path');
    return await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );
  }

  /// DELETE genérico
  Future<http.Response> delete(String path) async {
    final token = await _sm.getToken();
    final uri = Uri.parse('$baseUrl$path');
    return await http.delete(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }

  /// Sincroniza registros offline pendentes
  Future<void> syncOffline(List<OfflineRecord> pendentes) async {
    for (var rec in pendentes) {
      try {
        // reenvia cada registro
        await postWithFile(
          path: 'records',
          data: {
            'id': rec.id,
            'beneficiaryId': rec.payload['beneficiaryId'],  // Certifique-se de que 'beneficiaryId' está correto
            'report': rec.payload['report'],  // Acessa o relatório
            'status': rec.payload['status'],  // Acessa o status
          },
          file: File(rec.payload['imagePath']), // Usa o caminho da imagem
          latitude: rec.payload['latitude'],
          longitude: rec.payload['longitude'],
        );
        // Se der certo, você pode chamar LocalStorageService.deleteRecord(rec.id)
      } catch (_) {
        // Se falhar, deixa no offline queue
      }
    }
  }

  // Exemplo de implementação do método validateCAR
  Future<bool> validateCAR(String propertyId) async {
    final token = await _sm.getToken();
    final uri = Uri.parse('$baseUrl/validate-car');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode({'propertyId': propertyId}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['isValid'] == true;
    } else {
      throw Exception('Falha na validação do CAR');
    }
  }

  // Adicionar método de localização usando Geolocator
  Future<Position?> getUserLocation() async {
    try {
      return await _geoService.getUserLocation();
    } catch (e) {
      print("Erro ao obter localização: $e");
      return null;
    }
  }

  /// Método para alterar o papel do usuário
  Future<void> changeUserRole(String userId, String newRole) async {
    final token = await _sm.getToken();
    final uri = Uri.parse('$baseUrl/users/$userId/role');
    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode({'role': newRole}),
    );
    if (response.statusCode != 200) {
      throw Exception('Erro ao alterar o papel do usuário');
    }
  }
}
