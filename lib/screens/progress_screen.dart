import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/analytics_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});
  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  /// 7 = daily bars (Mon–Sun), 30 = weekly buckets (last ~5 weeks)
  int _range = 7;

  @override
  Widget build(BuildContext context) {
    final future = _range == 7
        ? AnalyticsService.instance.last7Days()
        : AnalyticsService.instance.last30DaysAsWeeks();

    return FutureBuilder<List<DayAgg>>(
      future: future,
      builder: (context, snap) {
        final data = snap.data ?? const <DayAgg>[];
        final total = data.fold<int>(0, (s, d) => s + d.workouts);
        final maxCount = data.isEmpty ? 1 : data.map((d) => d.workouts).reduce(math.max);
        final maxY = (maxCount + 1).toDouble();

        // Secondary stats
        final streakFut = AnalyticsService.instance.currentStreakDays();
        final weekFut = AnalyticsService.instance.workoutsThisWeek();

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Workouts',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 7, label: Text('7d')),
                      ButtonSegment(value: 30, label: Text('30d')),
                    ],
                    selected: {_range},
                    onSelectionChanged: (s) => setState(() => _range = s.first),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text('Total: $total workouts', style: const TextStyle(color: Colors.black54, fontSize: 13)),
              const SizedBox(height: 8),

              // Streak + This week chips
              FutureBuilder(
                future: Future.wait([streakFut, weekFut]),
                builder: (_, snap2) {
                  if (snap2.connectionState != ConnectionState.done || !snap2.hasData) {
                    return const SizedBox(height: 8);
                  }
                  final streak = (snap2.data![0]) as int;
                  final thisWeek = (snap2.data![1]) as int;
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text('Streak: $streak day${streak == 1 ? '' : 's'}')),
                      Chip(label: Text('This week: $thisWeek')),
                    ],
                  );
                },
              ),

              const SizedBox(height: 12),
              Expanded(
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 16, 16, 24),
                    child: data.isEmpty
                        ? const Center(child: Text('No data yet. Log some workouts!'))
                        : BarChart(
                      BarChartData(
                        minY: 0,
                        maxY: maxY,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (v) => FlLine(
                            color: Colors.grey.shade200,
                            strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            axisNameWidget: Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Text(
                                'Workouts / ${_range == 7 ? 'day' : 'week'}',
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              interval: 1, // integer steps
                              getTitlesWidget: (v, _) => Text(
                                v.toInt().toString(),
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          ),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            axisNameWidget: const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text('Date', style: TextStyle(fontSize: 11)),
                            ),
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (x, _) {
                                final i = x.toInt();
                                if (i < 0 || i >= data.length) return const SizedBox.shrink();

                                // Rotate a bit for readability; weekly labels are longer
                                return Transform.rotate(
                                  angle: -0.45,
                                  child: Text(
                                    data[i].label,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        barGroups: [
                          for (int i = 0; i < data.length; i++)
                            BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: data[i].workouts.toDouble(),
                                  width: _range == 30 ? 26 : 12, // wider bars for weekly buckets
                                  borderRadius: BorderRadius.circular(6),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xff5cc9f5), Color(0xff4ba8f2)],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                ),
                              ],
                            ),
                        ],
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, _, rod, __) {
                              final label = data[group.x.toInt()].label;
                              final v = rod.toY.toStringAsFixed(0);
                              final unit = _range == 7 ? 'day' : 'week';
                              return BarTooltipItem(
                                '$label\n$v workouts / $unit',
                                const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
