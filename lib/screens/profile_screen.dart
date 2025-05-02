// lib/screens/profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../components/custom_input.dart';
import '../components/custom_button.dart';
import '../services/session_manager.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _fullNameController = TextEditingController();  // Para o nome completo
  final _nicknameController = TextEditingController();  // Para o apelido
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _biographyController = TextEditingController();
  final _sm = SessionManager();
  File? _avatar;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // Carrega o perfil (nome completo, apelido, email, telefone)
  Future<void> _loadProfile() async {
    final fullName = await _sm.getFullName();
    final nick = await _sm.getNickname();
    final email = await _sm.getEmail();
    final phone = await _sm.getPhone();
    final bio = await _sm.getBiography(); // Para biografia

    setState(() {
      _fullNameController.text = fullName ?? '';
      _nicknameController.text = nick ?? '';
      _emailController.text = email ?? '';
      _phoneController.text = phone ?? '';
      _biographyController.text = bio ?? ''; // Carrega a biografia
    });
  }

  // Função para escolher uma nova imagem de avatar
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _avatar = File(picked.path));
      // Opcional: salvar caminho no SessionManager ou storage
    }
  }

  // Função de salvar as alterações no perfil
  Future<void> _saveProfile() async {
    final newFullName = _fullNameController.text.trim();
    final newNickname = _nicknameController.text.trim();
    final newPhone = _phoneController.text.trim();
    final newBio = _biographyController.text.trim();

    // Atualizando os dados no SessionManager
    await _sm.saveFullName(newFullName);
    await _sm.saveNickname(newNickname);
    await _sm.savePhone(newPhone);
    await _sm.saveBiography(newBio);

    // TODO: Se você tiver um backend, envie as alterações para o servidor
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil atualizado com sucesso!')),
    );
  }

  // Função para alterar o modo de exibição (Claro/Oscuro)
  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
      // Aqui você pode salvar a preferência do usuário se necessário
    });
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
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
              label: 'Nome Completo',  // Nome completo
              controller: _fullNameController,
            ),
            const SizedBox(height: 16),
            CustomInput(
              label: 'Apelido',  // Apelido
              controller: _nicknameController,
            ),
            const SizedBox(height: 16),
            CustomInput(
              label: 'E-mail',  // E-mail (não editável)
              controller: _emailController,
              // Não use 'enabled' diretamente, adicione um parâmetro 'enabled' no CustomInput ou apenas faça o campo não-editável
              readOnly: true,  // Modifique para 'readOnly' ou adicione 'enabled' no widget
            ),
            const SizedBox(height: 16),
            CustomInput(
              label: 'Telefone',  // Telefone
              controller: _phoneController,
            ),
            const SizedBox(height: 16),
            CustomInput(
              label: 'Biografia',  // Biografia
              controller: _biographyController,
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
                ),
                const Text('Modo de Exibição'),
              ],
            ),
            const SizedBox(height: 32),
            CustomButton(
              label: 'Salvar',
              onPressed: _saveProfile,
            ),
          ],
        ),
      ),
    );
  }
}

