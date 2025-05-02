// lib/services/session_manager.dart

import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _tokenKey             = 'auth_token';
  static const _roleKey              = 'user_role';
  static const _nickKey              = 'user_nickname';
  static const _emailKey             = 'user_email';
  static const _phoneKey             = 'user_phone';
  static const _avatarKey            = 'user_avatar_path';

  // NOVO: chave para o token de beneficiário
  static const _beneficiaryTokenKey  = 'beneficiary_token';

  /// Salva o JWT
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Lê o JWT
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Salva o papel (role) do usuário
  Future<void> saveUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role);
  }

  /// Recupera o papel (role) do usuário
  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  /// Salva o apelido do usuário
  Future<void> saveNickname(String nick) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nickKey, nick);
  }

  /// Recupera o apelido do usuário
  Future<String?> getNickname() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nickKey);
  }

  /// Salva o e-mail do usuário
  Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
  }

  /// Recupera o e-mail do usuário
  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  /// Salva o telefone do usuário
  Future<void> savePhone(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_phoneKey, phone);
  }

  /// Recupera o telefone do usuário
  Future<String?> getPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneKey);
  }

  /// Salva o caminho do avatar local do usuário
  Future<void> saveAvatarPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_avatarKey, path);
  }

  /// Recupera o caminho do avatar local do usuário
  Future<String?> getAvatarPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_avatarKey);
  }

  // ============================
  // Métodos para Beneficiário
  // ============================

  /// Salva o token de beneficiário (concede acesso permanente)
  Future<void> saveBeneficiaryToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_beneficiaryTokenKey, token);
  }

  /// Recupera o token de beneficiário (ou null se não existir)
  Future<String?> getBeneficiaryToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_beneficiaryTokenKey);
  }

  /// Limpa (revoga) o token de beneficiário
  Future<void> clearBeneficiaryToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_beneficiaryTokenKey);
  }

  /// Limpa todas as informações de sessão, incluindo o token de beneficiário
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_nickKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_phoneKey);
    await prefs.remove(_avatarKey);
    await prefs.remove(_beneficiaryTokenKey);
  }
}
