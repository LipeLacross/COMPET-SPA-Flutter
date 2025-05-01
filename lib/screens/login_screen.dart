import 'package:flutter/material.dart';
import '../components/custom_input.dart';
import '../components/custom_button.dart';
import '../services/auth_service.dart';
import '../services/session_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _auth = AuthService();
  final _sm = SessionManager();
  bool _loading = false;

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final token = await _auth.login(_email.text, _pass.text);
      await _sm.saveToken(token);
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text('Login')),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CustomInput(label: 'E-mail', controller: _email),
          const SizedBox(height: 12),
          CustomInput(label: 'Senha', controller: _pass),
          const SizedBox(height: 20),
          _loading
              ? const CircularProgressIndicator()
              : CustomButton(label: 'Entrar', onPressed: _submit),
          TextButton(
            onPressed: () => Navigator.pushNamed(c, '/signup'),
            child: const Text('Criar conta'),
          ),
        ],
      ),
    ),
  );
}
