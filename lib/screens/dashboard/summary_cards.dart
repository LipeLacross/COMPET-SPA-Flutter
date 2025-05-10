import 'package:flutter/material.dart';
import '../../models/offline_record.dart';

/// Cartões de resumo no Dashboard
/// Exibe:
/// - Beneficiários (tipo 'beneficiary')
/// - Usuários que não são beneficiários (tipo 'user')
/// - Recursos Humanos totais
/// - Atividades do dia, da semana e do mês
class SummaryCards extends StatelessWidget {
  final List<OfflineRecord> records;
  final int beneficiaryCount; // Adicionando parâmetro de contagem de beneficiários

  const SummaryCards({
    super.key,
    required this.records,
    required this.beneficiaryCount, // Passando este parâmetro
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = now.subtract(const Duration(days: 7));
    final monthStart = DateTime(now.year, now.month);

    // Beneficiários
    final beneficiaryCount = records
        .where((r) => r.payload['type'] == 'beneficiary')
        .length;
    // Usuários não beneficiários
    final userCount = records
        .where((r) => r.payload['type'] == 'user')
        .length;
    // Recursos Humanos totais
    final hrTotal = records.fold<int>(
      0,
          (sum, r) => sum + (r.payload['humanResources'] as int? ?? 0),
    );
    // Datas de atividades
    final activityDates = records
        .where((r) => r.payload['type'] == 'activity')
        .map((r) => DateTime.parse(r.payload['date'] as String));
    // Contagem de atividades hoje
    final activitiesToday = activityDates
        .where((d) => d.year == today.year && d.month == today.month && d.day == today.day)
        .length;
    // Contagem de atividades na última semana
    final activitiesWeek = activityDates
        .where((d) => d.isAfter(weekAgo))
        .length;
    // Contagem de atividades no mês
    final activitiesMonth = activityDates
        .where((d) => d.isAfter(monthStart.subtract(const Duration(seconds: 1)))).length;

    const spacing = 12.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            _card('Beneficiários', beneficiaryCount.toString(), cardWidth),
            _card('Usuários (não-benef)', userCount.toString(), cardWidth),
            _card('Recursos Humanos', hrTotal.toString(), cardWidth),
            _card('Atividades Hoje', activitiesToday.toString(), cardWidth),
            _card('Atividades Semana', activitiesWeek.toString(), cardWidth),
            _card('Atividades Mês', activitiesMonth.toString(), cardWidth),
          ],
        );
      },
    );
  }

  Widget _card(String title, String value, double width) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}