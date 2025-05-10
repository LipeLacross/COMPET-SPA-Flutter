// lib/screens/beneficiary_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../components/custom_input.dart';
import '../../components/custom_button.dart';
import '../../services/api_service.dart';
import '../../models/beneficiary.dart';

class BeneficiaryEditScreen extends StatefulWidget {
  final Beneficiary ben;
  const BeneficiaryEditScreen({super.key, required this.ben});

  @override
  State<BeneficiaryEditScreen> createState() => _BeneficiaryEditScreenState();
}

class _BeneficiaryEditScreenState extends State<BeneficiaryEditScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _areaCtrl;
  late final TextEditingController _servCtrl;
  final _api = ApiService();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.ben.name);
    _areaCtrl = TextEditingController(text: widget.ben.areaPreserved.toString());
    _servCtrl = TextEditingController(text: widget.ben.serviceDescription);
  }

  Future<void> _save() async {
    // Validação de campos
    final area = double.tryParse(_areaCtrl.text.trim());
    if (area == null) {
      return showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Área inválida'),
          content: const Text('Por favor informe um valor numérico válido para a área.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
    }
    if (_nameCtrl.text.trim().isEmpty || _servCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nome e Serviço são obrigatórios')),
      );
      return;
    }

    // Cria objeto atualizado
    final updated = Beneficiary(
      name: _nameCtrl.text.trim(),
      areaPreserved: area,
      serviceDescription: _servCtrl.text.trim(),
    );

    // Chamada à API e retorno
    await _api.put('beneficiaries/${widget.ben.name}', updated.toMap());
    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Beneficiário')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomInput(label: 'Nome', controller: _nameCtrl),
            const SizedBox(height: 12),
            CustomInput(
              label: 'Área',
              controller: _areaCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
            ),
            const SizedBox(height: 12),
            CustomInput(label: 'Serviço', controller: _servCtrl),
            const SizedBox(height: 24),
            CustomButton(label: 'Salvar', onPressed: _save),
          ],
        ),
      ),
    );
  }
}