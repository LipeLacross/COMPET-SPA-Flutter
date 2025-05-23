import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _tokenKey = 'auth_token';
  static const _roleKey = 'user_role';
  static const _nickKey = 'user_nickname';
  static const _emailKey = 'user_email';
  static const _phoneKey = 'user_phone';
  static const _avatarKey = 'user_avatar_path';
  static const _fullNameKey = 'user_full_name';  // Nome completo
  static const _biographyKey = 'user_biography';  // Biografia
  static const _themeKey = 'user_theme';  // Tema (escuro/claro)

  // New keys for beneficiary data
  static const _beneficiaryIdKey = 'beneficiary_id';
  static const _beneficiaryNameKey = 'beneficiary_name';

  /// Salva a preferência de tema
  Future<void> saveTheme(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDarkMode);
  }

  /// Recupera a preferência de tema
  Future<bool> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }

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

  /// Salva o nome completo do usuário
  Future<void> saveFullName(String fullName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fullNameKey, fullName);
  }

  /// Recupera o nome completo do usuário
  Future<String?> getFullName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_fullNameKey);
  }

  /// Salva a biografia do usuário
  Future<void> saveBiography(String biography) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_biographyKey, biography);
  }

  /// Recupera a biografia do usuário
  Future<String?> getBiography() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_biographyKey);
  }

  // New methods to save and retrieve beneficiary data:
  /// Salva o ID do beneficiário
  Future<void> saveBeneficiaryId(String beneficiaryId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_beneficiaryIdKey, beneficiaryId);
  }

  /// Recupera o ID do beneficiário
  Future<String?> getBeneficiaryId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_beneficiaryIdKey);
  }

  /// Salva o nome do beneficiário
  Future<void> saveBeneficiaryName(String beneficiaryName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_beneficiaryNameKey, beneficiaryName);
  }

  /// Recupera o nome do beneficiário
  Future<String?> getBeneficiaryName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_beneficiaryNameKey);
  }

  /// Limpa todas as informações de sessão (logout)
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_nickKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_phoneKey);
    await prefs.remove(_avatarKey);
    await prefs.remove(_fullNameKey);
    await prefs.remove(_biographyKey);
    await prefs.remove(_themeKey);
    await prefs.remove(_beneficiaryIdKey);  // Removed beneficiaryId during logout
    await prefs.remove(_beneficiaryNameKey);  // Removed beneficiaryName during logout
  }
}
