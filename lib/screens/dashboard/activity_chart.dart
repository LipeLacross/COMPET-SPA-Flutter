// lib/screens/dashboard/activity_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../utils/date_helper.dart';
import '../../models/offline_record.dart';

class ActivityChart extends StatelessWidget {
  final List<OfflineRecord> records;

  const ActivityChart({Key? key, required this.records}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Gera um ponto por dia nos últimos 7 dias
    final spots = <FlSpot>[];
    final today = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final day = today.subtract(Duration(days: 6 - i));
      final count = records
          .where((r) => r.payload['type'] == 'activity')
          .where((r) {
        final d = DateTime.parse(r.payload['date'] as String);
        return d.year == day.year && d.month == day.month && d.day == day.day;
      })
          .length;
      spots.add(FlSpot(i.toDouble(), count.toDouble()));
    }

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final day = today.subtract(Duration(days: 6 - v.toInt()));
                  return Text(DateHelper.formatDate(day), style: const TextStyle(fontSize: 10));
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          ),
          lineBarsData: [LineChartBarData(spots: spots)],
        ),
      ),
    );
  }
}
