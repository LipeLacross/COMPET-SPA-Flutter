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
  final _nameController  = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _sm              = SessionManager();
  File? _avatar;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final nick = await _sm.getNickname();
    setState(() {
      _nameController.text = nick ?? '';
      // caso salve e-mail/telefone em SessionManager, carregue aqui também
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _avatar = File(picked.path));
      // opcional: salvar caminho no SessionManager ou storage
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
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
            CustomInput(label: 'Nome', controller: _nameController),
            const SizedBox(height: 16),
            CustomInput(label: 'E-mail', controller: _emailController),
            const SizedBox(height: 16),
            CustomInput(label: 'Telefone', controller: _phoneController),
            const SizedBox(height: 32),
            CustomButton(
              label: 'Salvar',
              onPressed: () {
                // TODO: implementar salvamento de nome, e-mail, telefone e avatar
              },
            ),
          ],
        ),
      ),
    );
  }
}
