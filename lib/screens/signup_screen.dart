import 'package:flutter/material.dart';
import '../components/custom_input.dart';
import '../components/custom_button.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      await _auth.signup(_name.text, _email.text, _pass.text);
      Navigator.pop(context);
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
    appBar: AppBar(title: const Text('Cadastro')),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CustomInput(label: 'Nome', controller: _name),
          const SizedBox(height: 12),
          CustomInput(label: 'E-mail', controller: _email),
          const SizedBox(height: 12),
          CustomInput(label: 'Senha', controller: _pass),
          const SizedBox(height: 20),
          _loading
              ? const CircularProgressIndicator()
              : CustomButton(label: 'Cadastrar', onPressed: _submit),
        ],
      ),
    ),
  );
}
