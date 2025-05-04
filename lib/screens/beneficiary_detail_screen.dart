// lib/screens/beneficiary_detail_screen.dart
import 'package:flutter/material.dart';
import '../models/beneficiary.dart';
import '../utils/date_helper.dart';

class BeneficiaryDetailScreen extends StatelessWidget {
  final Beneficiary ben;
  const BeneficiaryDetailScreen({super.key, required this.ben});

  @override
  Widget build(BuildContext context) {
    final areaText = ben.areaPreserved != null
        ? ben.areaPreserved.toStringAsFixed(2)
        : '-';

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes de ${ben.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nome:', style: Theme.of(context).textTheme.titleSmall),
            Text(ben.name, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            Text('Área Preservada (m²):', style: Theme.of(context).textTheme.titleSmall),
            Text(areaText, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            Text('Serviço Prestado:', style: Theme.of(context).textTheme.titleSmall),
            Text(ben.serviceDescription, style: Theme.of(context).textTheme.bodyMedium),
            const Spacer(),
            Text(
              'Última atualização: ${DateHelper.formatDate(DateTime.now())}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
