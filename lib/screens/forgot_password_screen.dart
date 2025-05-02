import 'package:flutter/material.dart';
import '../components/custom_input.dart';
import '../components/custom_button.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      await _auth.resetPassword(_emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link de recuperação enviado por e-mail')),
      );
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar Senha')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Informe seu e-mail para receber o link de recuperação de senha.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            CustomInput(label: 'E-mail', controller: _emailController),
            const SizedBox(height: 20),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : CustomButton(label: 'Enviar Link', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
