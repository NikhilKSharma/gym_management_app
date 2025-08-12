import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gymanager/src/config/app_colors.dart';
import 'package:gymanager/src/services/api_service.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  late Future<List<Map<String, dynamic>>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = ApiService.getMembershipStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Membership Analytics'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.secondaryText,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _statsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.accent));
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No analytics data available.'));
            }

            final stats = snapshot.data!;

            // In analytics_page.dart, inside the FutureBuilder...

            return BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (stats
                            .map((s) => s['count'])
                            .reduce((a, b) => a > b ? a : b) *
                        1.2)
                    .toDouble(),
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        // The 'meta' argument from here...
                        return SideTitleWidget(
                          meta:
                              meta, // ...needs to be passed here. This is the fix.
                          child: Text(stats[value.toInt()]['month'],
                              style: const TextStyle(
                                  color: AppColors.primaryText, fontSize: 10)),
                        );
                      },
                      reservedSize: 20,
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) =>
                      const FlLine(color: Colors.grey, strokeWidth: 0.5),
                ),
                borderData: FlBorderData(show: false),
                barGroups: stats.asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: (data['count'] as int).toDouble(),
                        color: AppColors.accent,
                        width: 20,
                        borderRadius: BorderRadius.circular(4),
                      )
                    ],
                  );
                }).toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}
