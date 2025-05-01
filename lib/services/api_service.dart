import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session_manager.dart';

class ApiService {
  final String baseUrl = 'https://api.exemplo.com/';
  final SessionManager _sm = SessionManager();

  Future<http.Response> post(String path, Map<String, dynamic> data) async {
    final token = await _sm.getToken();
    return await http.post(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );
  }

// crie get, put, delete conforme necessidade
}
