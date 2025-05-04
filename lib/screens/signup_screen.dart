// lib/screens/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../components/custom_input.dart';
import '../components/custom_button.dart';
import '../services/auth_service.dart';
import '../services/session_manager.dart';

/// Formata o CPF na máscara 000.000.000-00
class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    String masked = '';
    for (var i = 0; i < digits.length && i < 11; i++) {
      if (i == 3 || i == 6) masked += '.';
      if (i == 9) masked += '-';
      masked += digits[i];
    }
    return TextEditingValue(
      text: masked,
      selection: TextSelection.collapsed(offset: masked.length),
    );
  }
}

/// Formata a data enquanto digita: DD/MM/AAAA
class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    String masked = '';
    for (var i = 0; i < digits.length && i < 8; i++) {
      if (i == 2 || i == 4) masked += '/';
      masked += digits[i];
    }
    return TextEditingValue(
      text: masked,
      selection: TextSelection.collapsed(offset: masked.length),
    );
  }
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nicknameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _cpfController      = TextEditingController();
  final _dobController      = TextEditingController();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();

  final _auth = AuthService();
  final _sm   = SessionManager();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // para re-renderizar o botão sempre que algo mudar
    for (final ctrl in [
      _nicknameController,
      _fullNameController,
      _cpfController,
      _dobController,
      _emailController,
      _passwordController,
    ]) {
      ctrl.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final ctrl in [
      _nicknameController,
      _fullNameController,
      _cpfController,
      _dobController,
      _emailController,
      _passwordController,
    ]) {
      ctrl.dispose();
    }
    super.dispose();
  }

  bool get _isValidCPF {
    return RegExp(r'^\d{3}\.\d{3}\.\d{3}-\d{2}$')
        .hasMatch(_cpfController.text);
  }

  bool get _isValidDOB {
    try {
      DateFormat('dd/MM/yyyy')
          .parseStrict(_dobController.text);
      return true;
    } catch (_) {
      return false;
    }
  }

  bool get _isValidEmail {
    final email = _emailController.text.trim();
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  bool get _canSubmit {
    return !_loading
        && _nicknameController.text.isNotEmpty
        && _fullNameController.text.isNotEmpty
        && _isValidCPF
        && _isValidDOB
        && _isValidEmail
        && _passwordController.text.length >= 6;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final dob = await showDatePicker(
      context: context,
      initialDate: now.subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (dob != null) {
      _dobController.text = DateFormat('dd/MM/yyyy').format(dob);
    }
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;

    setState(() => _loading = true);
    try {
      await _auth.signup(
        nickname:   _nicknameController.text.trim(),
        fullName:   _fullNameController.text.trim(),
        email:      _emailController.text.trim(),
        password:   _passwordController.text,
        cpf:        _cpfController.text,
        dateOfBirth:_dobController.text,
        role:       'usuario',
      );
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),
      body: SingleChildScrollView(
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
              inputFormatters: [CpfInputFormatter()],
              hintText: '000.000.000-00',
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(
                child: CustomInput(
                  label: 'Data de Nascimento',
                  controller: _dobController,
                  keyboardType: TextInputType.datetime,
                  inputFormatters: [DateInputFormatter()],
                  hintText: 'DD/MM/AAAA',
                ),
              ),
            ),
            const SizedBox(height: 12),
            CustomInput(
              label: 'E-mail',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            CustomInput(
              label: 'Senha (mín. 6 caracteres)',
              controller: _passwordController,
              obscureText: true,
            ),
            const SizedBox(height: 24),
            _loading
                ? const CircularProgressIndicator()
                : CustomButton(
              label: 'Cadastrar',
              onPressed: _canSubmit ? _submit : null,
            ),
          ],
        ),
      ),
    );
  }
}
