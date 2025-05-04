// lib/services/auth_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AuthService {
  /// Ativa o mock (in-memory) somente em modo debug.
  static const bool _mockEnabled = kDebugMode;

  /// “Banco” em memória para mock, com três usuários:
  /// 1) admin/admin           | role: admin
  /// 2) usuario/usuario       | role: usuario
  /// 3) beneficiario/beneficiario | role: beneficiary
  static final List<Map<String, String>> _mockUsers = [
    {
      'email': 'admin',
      'password': 'admin',
      'role': 'admin',
      'nickname': 'admin',
      'fullName': 'Administrador',
      'phone': '(11) 9999-8888',
      'biography': 'Sou o administrador do sistema.',
      'avatarPath': '/assets/avatars/admin.png',
      'cpf': '000.000.000-00',
      'dateOfBirth': '1970-01-01',
    },
    {
      'email': 'usuario',
      'password': 'usuario',
      'role': 'usuario',
      'nickname': 'usuario',
      'fullName': 'Usuário Comum',
      'phone': '(21) 98877-6655',
      'biography': 'Perfil de usuário comum para testes.',
      'avatarPath': '/assets/avatars/user.png',
      'cpf': '111.111.111-11',
      'dateOfBirth': '1990-05-15',
    },
    {
      'email': 'beneficiario',
      'password': 'beneficiario',
      'role': 'beneficiary',
      'nickname': 'benefício',
      'fullName': 'Beneficiário Exemplo',
      'phone': '(31) 97766-5544',
      'biography': 'Beneficiário com acesso especial a recursos.',
      'avatarPath': '/assets/avatars/beneficiary.png',
      'cpf': '222.222.222-22',
      'dateOfBirth': '1985-10-25',
    },
  ];

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
      // Retorna todas as informações de perfil do mock
      return {
        'token': 'fake-token-for-${user['email']}',
        'role': user['role']!,
        'nickname': user['nickname']!,
        'fullName': user['fullName']!,
        'email': user['email']!,
        'phone': user['phone']!,
        'biography': user['biography']!,
        'avatarPath': user['avatarPath']!,
        'cpf': user['cpf']!,
        'dateOfBirth': user['dateOfBirth']!,
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
        'role': data['role'] as String,
        // campos opcionais do real backend (se houver)
        if (data.containsKey('nickname')) 'nickname': data['nickname'],
        if (data.containsKey('fullName')) 'fullName': data['fullName'],
        if (data.containsKey('email')) 'email': data['email'],
        if (data.containsKey('phone')) 'phone': data['phone'],
        if (data.containsKey('biography')) 'biography': data['biography'],
        if (data.containsKey('avatarPath')) 'avatarPath': data['avatarPath'],
        if (data.containsKey('cpf')) 'cpf': data['cpf'],
        if (data.containsKey('dateOfBirth')) 'dateOfBirth': data['dateOfBirth'],
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
    String role = 'usuario', // Papel padrão "usuario"
  }) async {
    if (_mockEnabled) {
      await Future.delayed(const Duration(seconds: 1)); // Simula rede
      final exists = _mockUsers.any((u) => u['email'] == email);
      if (exists) {
        throw Exception('E-mail já cadastrado (mock)');
      }
      _mockUsers.add({
        'nickname': nickname,
        'fullName': fullName,
        'email': email,
        'password': password,
        'cpf': cpf,
        'dateOfBirth': dateOfBirth,
        'role': role,
        'phone': '',
        'biography': '',
        'avatarPath': '',
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
        'role': role,
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
    return List<Map<String, String>>.from(_mockUsers);
  }
}
