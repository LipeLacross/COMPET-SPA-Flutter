import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/offline_record.dart';

class ActivityChart extends StatefulWidget {
  final List<OfflineRecord> records;

  const ActivityChart({Key? key, required this.records}) : super(key: key);

  @override
  State<ActivityChart> createState() => _ActivityChartState();
}

class _ActivityChartState extends State<ActivityChart> {
  late List<DateTime> _months;
  DateTime? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _initMonths();
  }

  void _initMonths() {
    final dates = widget.records
        .where((r) => r.payload['type'] == 'activity')
        .map((r) => DateTime.parse(r.payload['date'] as String));
    final monthsSet = dates
        .map((d) => DateTime(d.year, d.month))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    _months = monthsSet;
    if (_months.isNotEmpty) {
      _selectedMonth = _months.first;
    }
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
    if (_selectedMonth == null || _months.isEmpty) {
      return const Center(child: Text('Nenhuma atividade registrada.'));
    }
    final counts = _countByDay(_selectedMonth!);
    final maxY = (counts.isEmpty ? 1 : counts.reduce((a, b) => a > b ? a : b)) + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Text('Mês:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              DropdownButton<DateTime>( // Dropdown para selecionar o mês
                value: _selectedMonth,
                items: _months.map((m) {
                  return DropdownMenuItem(
                    value: m,
                    child: Text(DateFormat('MMMM/yyyy').format(m)),
                  );
                }).toList(),
                onChanged: (m) {
                  setState(() => _selectedMonth = m);
                },
              ),
            ],
          ),
        ),
        SizedBox(
          height: 250,
          child: BarChart(
            BarChartData(
              maxY: maxY.toDouble(),
              barGroups: counts.asMap().entries.map((e) {
                return BarChartGroupData(
                  x: e.key + 1, // X representa o dia do mês (1-based)
                  barRods: [BarChartRodData(toY: e.value.toDouble(), width: 12)],
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
                    getTitlesWidget: (value, _) {
                      return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
                    },
                    interval: 1,
                  ),
                ),
                leftTitles: AxisTitles(
                  axisNameWidget: const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Text('Quantidade', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  sideTitles: SideTitles(showTitles: true, interval: (maxY / 5).floorToDouble()),
                ),
              ),
              gridData: FlGridData(show: true, horizontalInterval: (maxY / 5).floorToDouble()),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      ],
    );
  }
}
