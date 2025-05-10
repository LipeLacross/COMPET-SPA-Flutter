import 'package:flutter/material.dart';
import '../components/whatsapp_button.dart';
import '../services/session_manager.dart';
import 'package:url_launcher/url_launcher.dart'; // Para abrir a URL do edital

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _openEdital() async {
    const url = 'https://desafios.pe.gov.br/portal/home/getchallengedocument/164';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Não foi possível abrir o link';
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Principal'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Perfil',
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              await SessionManager().clear();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Saudação com apelido
            FutureBuilder<String?>(
              future: SessionManager().getNickname(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }
                final nick = snap.data ?? 'Usuário';
                return Text(
                  'Olá, $nick',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: primary,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Título
            Text(
              'Bem-vindo ao Sistema PSA',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),
            const SizedBox(height: 40),

            // Botão para Beneficiário
            ElevatedButton.icon(
              icon: const Icon(Icons.people_outline),
              label: const Text('Beneficiário'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () => Navigator.pushNamed(context, '/beneficiary'),
            ),
            const SizedBox(height: 20),

            // Botão para Dashboard
            ElevatedButton.icon(
              icon: const Icon(Icons.dashboard_outlined),
              label: const Text('Dashboard'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () => Navigator.pushNamed(context, '/dashboard'),
            ),

            const SizedBox(height: 20),

            // Botão para abrir o edital SEMAS-PE
            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Acessar Edital SEMAS-PE'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _openEdital, // Chama a função que abre o edital
            ),

            const Spacer(),

            // Suporte via WhatsApp
            WhatsAppButton(
              phone: '5574981256120',  // DDI + DDD + número
              message: 'Olá, preciso de ajuda com o PSA.',
            ),
          ],
        ),
      ),
    );
  }
}
