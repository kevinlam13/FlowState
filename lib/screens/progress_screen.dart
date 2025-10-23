import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../services/analytics_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});
  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AnalyticsService.instance.last7Days(),
      builder: (_, snap) {
        final data = snap.data ?? const [];
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Workouts (last 7 days)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Expanded(
                child: BarChart(BarChartData(
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (x, _) => Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(data[x.toInt()].label, style: const TextStyle(fontSize: 10)),
                      ),
                    )),
                  ),
                  barGroups: [
                    for (int i=0;i<data.length;i++)
                      BarChartGroupData(x: i, barRods: [BarChartRodData(toY: data[i].workouts.toDouble())]),
                  ],
                )),
              ),
            ],
          ),
        );
      },
    );
  }
}
