import 'package:flutter/material.dart';
import '../components/custom_input.dart';
import '../components/custom_button.dart';
import '../services/api_service.dart';
import '../models/beneficiary.dart';

class BeneficiaryEditScreen extends StatefulWidget {
  final Beneficiary ben;
  const BeneficiaryEditScreen({Key? key, required this.ben}) : super(key: key);

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
    final updated = Beneficiary(
      name: _nameCtrl.text.trim(),
      areaPreserved: double.tryParse(_areaCtrl.text) ?? 0,
      serviceDescription: _servCtrl.text.trim(),
    );
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
            CustomInput(label: 'Área', controller: _areaCtrl, keyboardType: TextInputType.number),
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
