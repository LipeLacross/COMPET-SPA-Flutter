import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppButton extends StatelessWidget {
  final String phone;   // ex: '5511998765432'
  final String message; // mensagem inicial opcional

  const WhatsAppButton({
    super.key,
    required this.phone,
    this.message = '',
  });

  Future<void> _openWhatsApp(BuildContext context) async {
    final uri = Uri.parse(
        'https://wa.me/$phone?text=${Uri.encodeComponent(message)}'
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o WhatsApp.'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.chat), // use um ícone genérico
      label: const Text('Suporte via WhatsApp'),
      onPressed: () => _openWhatsApp(context),
    );
  }
}