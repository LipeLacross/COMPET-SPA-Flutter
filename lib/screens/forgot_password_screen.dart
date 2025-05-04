// lib/screens/forgot_password_screen.dart
import 'package:flutter/material.dart';
import '../components/custom_input.dart';
import '../components/custom_button.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool get _isValidEmail {
    final email = _emailController.text.trim();
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return regex.hasMatch(email);
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !_isValidEmail) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um e-mail válido')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await _auth.resetPassword(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link de recuperação enviado por e-mail')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSend = !_loading && _isValidEmail;
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar Senha')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            const Text(
              'Informe seu e-mail para receber o link de recuperação de senha.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomInput(
              label: 'E-mail',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            // Se estiver carregando, mostra indicador; caso contrário, botão (pode estar desabilitado)
            _loading
                ? const Center(child: CircularProgressIndicator())
                : CustomButton(
              label: 'Enviar Link',
              onPressed: canSend
                  ? () {
                _submit();
              }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
