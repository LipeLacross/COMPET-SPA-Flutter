import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../components/custom_input.dart';
import '../components/custom_button.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  _ActivitiesScreenState createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  final _typeController = TextEditingController();
  final _areaController = TextEditingController();

  void _registerActivity() {
    final activity = Activity(
      type: _typeController.text,
      date: DateTime.now(),
      areaPreserved: double.tryParse(_areaController.text) ?? 0.0,
    );

    // Aqui você pode chamar a função de envio da atividade para o backend ou salvar localmente
    print('Atividade registrada: ${activity.type}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Atividade')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomInput(label: 'Tipo de Atividade', controller: _typeController),
            CustomInput(label: 'Área Preservada (m²)', controller: _areaController),
            CustomButton(label: 'Registrar Atividade', onPressed: _registerActivity),
          ],
        ),
      ),
    );
  }
}
