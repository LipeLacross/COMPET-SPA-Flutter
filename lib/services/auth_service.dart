import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AuthService {
  /// Ativa o mock (in-memory) somente em modo debug.
  static const bool _mockEnabled = kDebugMode;

  /// “Banco” em memória para mock.
  static final List<Map<String, String>> _mockUsers = [];

  /// Base URL para o backend real (usado em release).
  final String _baseUrl = 'http://10.0.2.2:8080/auth';

  /// Faz login e retorna um token (fake em debug, real em release).
  Future<Map<String, dynamic>> login(String email, String password) async {
    if (_mockEnabled) {
      await Future.delayed(const Duration(seconds: 1)); // Simula rede
      final user = _mockUsers.firstWhere(
            (u) => u['email'] == email && u['password'] == password,
        orElse: () => {},
      );
      if (user.isEmpty) {
        throw Exception('Credenciais inválidas (mock)');
      }
      return {
        'token': 'fake-token-for-${user['email']}',
        'role': 'admin',  // Simula o papel do usuário (admin ou beneficiário)
      };
    }

    // Fluxo real
    final uri = Uri.parse('$_baseUrl/login');
    final res = await http
        .post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    )
        .timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception('Timeout no login'),
    );

    if (res.statusCode == 200) {
      final data = json.decode(res.body) as Map<String, dynamic>;
      return {
        'token': data['token'] as String,
        'role': data['role'] as String, // Aqui adicionamos o papel (role)
      };
    } else {
      throw Exception('Falha no login: ${res.body}');
    }
  }

  /// Cadastra usuário (mock em debug, real em release).
  Future<void> signup({
    required String nickname,
    required String fullName,
    required String email,
    required String password,
    required String cpf,
    required String dateOfBirth,
  }) async {
    if (_mockEnabled) {
      await Future.delayed(const Duration(seconds: 1)); // Simula rede
      final exists = _mockUsers.any((u) => u['email'] == email);
      if (exists) {
        throw Exception('E-mail já cadastrado (mock)');
      }
      // Adiciona todos os campos no mock
      _mockUsers.add({
        'nickname': nickname,
        'fullName': fullName,
        'email': email,
        'password': password,
        'cpf': cpf,
        'dateOfBirth': dateOfBirth,
      });
      return;
    }

    // Fluxo real
    final uri = Uri.parse('$_baseUrl/signup');
    final res = await http
        .post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nickname': nickname,
        'fullName': fullName,
        'email': email,
        'password': password,
        'cpf': cpf,
        'dateOfBirth': dateOfBirth,
      }),
    )
        .timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception('Timeout no cadastro'),
    );

    if (res.statusCode != 201) {
      throw Exception('Falha no cadastro: ${res.body}');
    }
  }

  /// Solicita reset de senha.
  Future<void> resetPassword(String email) async {
    if (_mockEnabled) {
      await Future.delayed(const Duration(seconds: 1));
      final exists = _mockUsers.any((u) => u['email'] == email);
      if (!exists) {
        throw Exception('E-mail não encontrado (mock)');
      }
      return;
    }

    final uri = Uri.parse('$_baseUrl/reset-password');
    final res = await http
        .post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    )
        .timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception('Timeout no reset-password'),
    );

    if (res.statusCode != 200) {
      throw Exception('Falha no reset de senha: ${res.body}');
    }
  }

  /// Método para debug: retorna todos os usuários cadastrados no mock.
  List<Map<String, String>> listMockUsers() {
    // Devolve cópia para não permitir modificação externa
    return List<Map<String, String>>.from(_mockUsers);
  }
}
