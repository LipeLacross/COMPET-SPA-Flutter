import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _tokenKey = 'auth_token';
  static const _roleKey = 'user_role'; // Novo campo para armazenar o papel do usuário
  static const _nickKey = 'user_nickname';
  static const _emailKey = 'user_email';
  static const _phoneKey = 'user_phone';
  static const _avatarKey = 'user_avatar_path';

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

  /// Limpa todas as informações de sessão
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_roleKey); // Limpa também o papel
    await prefs.remove(_nickKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_phoneKey);
    await prefs.remove(_avatarKey);
  }
}
