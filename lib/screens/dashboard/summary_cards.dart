import 'package:flutter/material.dart';
import '../../models/offline_record.dart';
import '../../models/report.dart';

class SummaryCards extends StatelessWidget {
  final List<OfflineRecord> records;
  final List<Report> payments;
  final int beneficiaryCount;

  const SummaryCards({
    super.key,
    required this.records,
    required this.payments,
    required this.beneficiaryCount,
  });

  @override
  Widget build(BuildContext context) {
    final uniqueActivities =
        records.map((r) => r.payload['description']).toSet().length;
    final hrTotal = records.fold<int>(
        0, (sum, r) => sum + (r.payload['humanResources'] as int? ?? 0));

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _card('Beneficiários', beneficiaryCount.toString()),
        _card('Atividades únicas', uniqueActivities.toString()),
        _card('Pagamentos', payments.length.toString()),
        _card('Recursos Humanos', hrTotal.toString()),
      ],
    );
  }

  Widget _card(String title, String value) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(value,
              style:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );
}
