import 'package:flutter/material.dart';
import '../models/beneficiary.dart';
import '../components/custom_input.dart';
import '../components/custom_button.dart';

class BeneficiaryScreen extends StatefulWidget {
  const BeneficiaryScreen({super.key});

  @override
  _BeneficiaryScreenState createState() => _BeneficiaryScreenState();
}

class _BeneficiaryScreenState extends State<BeneficiaryScreen> {
  final _nameController = TextEditingController();
  final _areaController = TextEditingController();
  final _descriptionController = TextEditingController();

  void _registerBeneficiary() {
    final beneficiary = Beneficiary(
      name: _nameController.text,
      areaPreserved: double.tryParse(_areaController.text) ?? 0.0,
      serviceDescription: _descriptionController.text,
    );

    // Aqui você pode chamar a função de envio do beneficiário para o backend ou salvar localmente
    print('Beneficiário registrado: ${beneficiary.name}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar Beneficiário')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomInput(label: 'Nome', controller: _nameController),
            CustomInput(label: 'Área Preservada (m²)', controller: _areaController),
            CustomInput(label: 'Descrição do Serviço', controller: _descriptionController),
            CustomButton(label: 'Cadastrar Beneficiário', onPressed: _registerBeneficiary),
          ],
        ),
      ),
    );
  }
}
