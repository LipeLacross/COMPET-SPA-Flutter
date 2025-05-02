import 'package:flutter/material.dart';
import '../components/custom_input.dart';
import '../components/custom_button.dart';
import '../services/auth_service.dart';
import '../services/session_manager.dart';
import 'home_screen.dart';
import 'admin_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifierController = TextEditingController();
  final _passController = TextEditingController();
  final _auth = AuthService();
  final _sm = SessionManager();

  bool _loading = false;
  bool _obscurePassword = true;

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final result = await _auth.login(
        _identifierController.text.trim(),
        _passController.text,
      );

      // Salva o token e o papel (role) no SessionManager
      await _sm.saveToken(result['token']);
      await _sm.saveUserRole(result['role']);
      await _sm.saveNickname(_identifierController.text.trim());

      // Verifica o papel (role) e navega para a tela correta
      if (result['role'] == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
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
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Serviços de Pagamentos Ambientais COMPET',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: primary, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            CustomInput(
              label: 'E-mail ou Apelido',
              controller: _identifierController,
            ),
            const SizedBox(height: 12),
            CustomInput(
              label: 'Senha',
              controller: _passController,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () => setState(() {
                  _obscurePassword = !_obscurePassword;
                }),
              ),
            ),
            const SizedBox(height: 20),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : CustomButton(label: 'Entrar', onPressed: _submit),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              child: const Text('Criar conta'),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/forgot_password'),
              child: const Text('Esqueceu a senha?'),
            ),
          ],
        ),
      ),
    );
  }
}
