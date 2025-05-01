import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String _baseUrl = 'https://api.exemplo.com/auth';

  Future<String> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return data['token'] as String;
    } else {
      throw Exception('Falha no login: ${res.body}');
    }
  }

  Future<void> signup(String name, String email, String password) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': name, 'email': email, 'password': password}),
    );
    if (res.statusCode != 201) {
      throw Exception('Falha no cadastro: ${res.body}');
    }
  }
}
