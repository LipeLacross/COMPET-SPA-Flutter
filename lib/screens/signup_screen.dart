//signup_screen.dart
import 'package:flutter/material.dart';
import '../components/custom_input.dart';
import '../components/custom_button.dart';
import '../services/auth_service.dart';
import '../services/session_manager.dart';
import 'package:intl/intl.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nicknameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _dobController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _auth = AuthService();
  final _sm = SessionManager();

  bool _loading = false;

  // Função para validar o formato do CPF
  bool _isValidCPF(String cpf) {
    RegExp cpfRegex = RegExp(r'^\d{3}\.\d{3}\.\d{3}-\d{2}$');
    return cpfRegex.hasMatch(cpf);
  }

  // Função para validar o formato da data de nascimento
  bool _isValidDOB(String dob) {
    try {
      DateFormat('dd/MM/yyyy').parseStrict(dob);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _submit() async {
    // Validações
    String cpf = _cpfController.text.trim();
    String dob = _dobController.text.trim();

    if (!_isValidCPF(cpf)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CPF inválido. Formato esperado: 000.000.000-00')),
      );
      return;
    }

    if (!_isValidDOB(dob)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data de nascimento inválida. Formato esperado: DD/MM/AAAA')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      // Define o role como "usuário" por padrão
      String role = "usuario"; // Usuário padrão

      await _auth.signup(
        nickname: _nicknameController.text.trim(),
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        cpf: cpf,
        dateOfBirth: dob,
        role: role,
      );

      // salva apelido em sessão
      await _sm.saveNickname(_nicknameController.text.trim());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastro realizado com sucesso!')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _fullNameController.dispose();
    _cpfController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomInput(
              label: 'Apelido',
              controller: _nicknameController,
            ),
            const SizedBox(height: 12),
            CustomInput(
              label: 'Nome Completo',
              controller: _fullNameController,
            ),
            const SizedBox(height: 12),
            CustomInput(
              label: 'CPF',
              controller: _cpfController,
              keyboardType: TextInputType.number,
              hintText: '000.000.000-00',
            ),
            const SizedBox(height: 12),
            CustomInput(
              label: 'Data de Nascimento',
              controller: _dobController,
              keyboardType: TextInputType.datetime,
              hintText: 'DD/MM/AAAA',
            ),
            const SizedBox(height: 12),
            CustomInput(
              label: 'E-mail',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            CustomInput(
              label: 'Senha',
              controller: _passwordController,
              obscureText: true,
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : CustomButton(label: 'Cadastrar', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
