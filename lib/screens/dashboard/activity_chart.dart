import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/offline_record.dart';

class ActivityChart extends StatefulWidget {
  final List<OfflineRecord> records;

  const ActivityChart({super.key, required this.records});

  @override
  State<ActivityChart> createState() => _ActivityChartState();
}

class _ActivityChartState extends State<ActivityChart> {
  late List<DateTime> _months;
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _initMonths();
  }

  void _initMonths() {
    // Extrai apenas registros de atividade e transforma em ano+mes
    final dates = widget.records
        .where((r) => r.payload['type'] == 'activity')
        .map((r) => DateTime.parse(r.payload['date'] as String));
    final monthsSet = dates
        .map((d) => DateTime(d.year, d.month))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    // Se não houver meses, usa o mês atual para mostrar gráfico zerado
    if (monthsSet.isEmpty) {
      final now = DateTime.now();
      _months = [DateTime(now.year, now.month)];
    } else {
      _months = monthsSet;
    }

    _selectedMonth = _months.first;
  }

  List<int> _countByDay(DateTime month) {
    final year = month.year;
    final mon = month.month;
    final daysInMonth = DateTime(year, mon + 1, 0).day;
    final counts = List<int>.filled(daysInMonth, 0);

    for (var rec in widget.records) {
      if (rec.payload['type'] != 'activity') continue;
      final d = DateTime.parse(rec.payload['date'] as String);
      if (d.year == year && d.month == mon) {
        counts[d.day - 1]++;
      }
    }

    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final counts = _countByDay(_selectedMonth);
    final maxCount = counts.isEmpty
        ? 1
        : counts.reduce((a, b) => a > b ? a : b);
    final maxY = maxCount + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Título explicativo
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Quantidade de Atividades Durante o Mês',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        // Seletor de mês
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Text('Mês:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              DropdownButton<DateTime>(
                value: _selectedMonth,
                items: _months.map((m) {
                  return DropdownMenuItem(
                    value: m,
                    child: Text(DateFormat('MMMM yyyy').format(m)),
                  );
                }).toList(),
                onChanged: (m) {
                  if (m != null) {
                    setState(() => _selectedMonth = m);
                  }
                },
              ),
            ],
          ),
        ),
        // Gráfico de barras
        SizedBox(
          height: 250,
          child: BarChart(
            BarChartData(
              maxY: maxY.toDouble(),
              barGroups: counts.asMap().entries.map((e) {
                return BarChartGroupData(
                  x: e.key + 1,
                  barRods: [
                    BarChartRodData(toY: e.value.toDouble(), width: 12),
                  ],
                );
              }).toList(),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  axisNameWidget: const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('Dia', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) =>
                        Text(value.toInt().toString(), style: const TextStyle(fontSize: 10)),
                    interval: 1,
                  ),
                ),
                leftTitles: AxisTitles(
                  axisNameWidget: const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Text('Quantidade', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: (maxY / 5).floorToDouble().clamp(1, maxY.toDouble()),
                  ),
                ),
              ),
              gridData: FlGridData(
                show: true,
                horizontalInterval: (maxY / 5).floorToDouble().clamp(1, maxY.toDouble()),
              ),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      ],
    );
  }
}
