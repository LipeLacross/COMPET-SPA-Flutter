// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session_manager.dart';

class ApiService {
  final String baseUrl = 'https://api.exemplo.com/';
  final SessionManager _sm = SessionManager();

  // Método para enviar dados via POST
  Future<http.Response> post(String path, Map<String, dynamic> data) async {
    final token = await _sm.getToken();
    return await http.post(
      Uri.parse('\$baseUrl\$path'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer \$token',
      },
      body: json.encode(data),
    );
  }

  // Método para obter dados via GET
  Future<http.Response> get(String path) async {
    final token = await _sm.getToken();
    return await http.get(
      Uri.parse('\$baseUrl\$path'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer \$token',
      },
    );
  }

  // Método para atualizar dados via PUT
  Future<http.Response> put(String path, Map<String, dynamic> data) async {
    final token = await _sm.getToken();
    return await http.put(
      Uri.parse('\$baseUrl\$path'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer \$token',
      },
      body: json.encode(data),
    );
  }

  // Método para buscar dados do mapa (Novo endpoint para o mapa)
  Future<Map<String, dynamic>> getMapData() async {
    final response = await http.get(Uri.parse('\$baseUrl/map-data'));

    if (response.statusCode == 200) {
      return json.decode(response.body);  // Retorna os dados como um mapa
    } else {
      throw Exception('Falha ao carregar dados do mapa');
    }
  }

  // Método para excluir dados via DELETE
  Future<http.Response> delete(String path) async {
    final token = await _sm.getToken();
    return await http.delete(
      Uri.parse('\$baseUrl\$path'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer \$token',
      },
    );
  }

  /// Altera o role de um usuário (ex: para 'beneficiary' ou 'user')
  Future<http.Response> changeUserRole(String userId, String newRole) async {
    final token = await _sm.getToken();
    final uri = Uri.parse('\$baseUrl/users/\$userId/role');
    return await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer \$token',
      },
      body: json.encode({'role': newRole}),
    );
  }
}

