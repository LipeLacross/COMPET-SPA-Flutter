// lib/screens/profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../components/custom_input.dart';
import '../components/custom_button.dart';
import '../services/session_manager.dart';

class ProfileScreen extends StatefulWidget {
  /// Callback para notificar a mudança de tema no topo (MyApp)
  final ValueChanged<bool> onThemeChanged;
  const ProfileScreen({Key? key, required this.onThemeChanged}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _fullNameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _biographyController = TextEditingController();
  final _sm = SessionManager();

  File? _avatar;
  bool _isDarkMode = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadThemePreference();
  }

  Future<void> _loadProfile() async {
    final fullName = await _sm.getFullName() ?? '';
    final nick = await _sm.getNickname() ?? '';
    final email = await _sm.getEmail() ?? '';
    final phone = await _sm.getPhone() ?? '';
    final bio = await _sm.getBiography() ?? '';

    _fullNameController.text = fullName;
    _nicknameController.text = nick;
    _emailController.text = email;
    _phoneController.text = phone;
    _biographyController.text = bio;
    setState(() {});
  }

  Future<void> _loadThemePreference() async {
    final themePreference = await _sm.getTheme();
    setState(() {
      _isDarkMode = themePreference;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _avatar = File(picked.path));
    }
  }

  Future<void> _saveProfile() async {
    await _sm.saveFullName(_fullNameController.text.trim());
    await _sm.saveNickname(_nicknameController.text.trim());
    await _sm.savePhone(_phoneController.text.trim());
    await _sm.saveBiography(_biographyController.text.trim());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil atualizado com sucesso!')),
    );
    setState(() => _isEditing = false);
  }

  void _toggleTheme() async {
    setState(() => _isDarkMode = !_isDarkMode);
    await _sm.saveTheme(_isDarkMode);
    widget.onThemeChanged(_isDarkMode);
  }

  void _startEditing() {
    setState(() => _isEditing = true);
  }

  void _cancelEditing() {
    _loadProfile();
    setState(() => _isEditing = false);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _biographyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        centerTitle: true,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _startEditing,
              tooltip: 'Editar perfil',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Center(
              child: GestureDetector(
                onTap: _isEditing ? _pickImage : null,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _avatar != null ? FileImage(_avatar!) : null,
                  child: _avatar == null
                      ? Icon(Icons.camera_alt, size: 48, color: primary)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 24),
            CustomInput(
              label: 'Nome Completo',
              controller: _fullNameController,
              readOnly: !_isEditing,
            ),
            const SizedBox(height: 16),
            CustomInput(
              label: 'Apelido',
              controller: _nicknameController,
              readOnly: !_isEditing,
            ),
            const SizedBox(height: 16),
            CustomInput(
              label: 'E-mail',
              controller: _emailController,
              readOnly: true,
            ),
            const SizedBox(height: 16),
            CustomInput(
              label: 'Telefone',
              controller: _phoneController,
              readOnly: !_isEditing,
            ),
            const SizedBox(height: 16),
            CustomInput(
              label: 'Biografia',
              controller: _biographyController,
              readOnly: !_isEditing,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: primary,
                  ),
                  onPressed: _toggleTheme,
                  tooltip: 'Alternar tema',
                ),
                const SizedBox(width: 8),
                const Text('Modo de Exibição'),
              ],
            ),
            const SizedBox(height: 32),
            if (_isEditing)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: CustomButton(
                      label: 'Cancelar',
                      onPressed: _cancelEditing,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      label: 'Salvar',
                      onPressed: _saveProfile,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
