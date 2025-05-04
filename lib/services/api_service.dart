// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session_manager.dart';

class ApiService {
  final String baseUrl = 'https://api.exemplo.com/';
  final SessionManager _sm = SessionManager();

  /// Envia dados via POST
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

  /// Obtém dados via GET
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

  /// Atualiza dados via PUT
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

  /// Busca dados do mapa (novo endpoint)
  Future<Map<String, dynamic>> getMapData() async {
    final uri = Uri.parse('$baseUrl/map-data');
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (await _sm.getToken() != null)
          'Authorization': 'Bearer ${await _sm.getToken()}',
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Falha ao carregar dados do mapa');
    }
  }

  /// Exclui dados via DELETE
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

  /// Altera o role de um usuário
  Future<http.Response> changeUserRole(String userId, String newRole) async {
    final token = await _sm.getToken();
    final uri = Uri.parse('$baseUrl/users/$userId/role');
    return await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode({'role': newRole}),
    );
  }
}
