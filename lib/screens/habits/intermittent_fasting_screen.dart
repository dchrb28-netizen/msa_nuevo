import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/fasting_phase.dart';
import 'package:myapp/providers/fasting_provider.dart';
import 'package:provider/provider.dart';

class IntermittentFastingScreen extends StatelessWidget {
  const IntermittentFastingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3, // Now we have 3 tabs
      child: Scaffold(
        body: Consumer<FastingProvider>(
          builder: (context, fastingProvider, child) {
            return Column(
              children: [
                Container(
                  color: theme.colorScheme.surface,
                  child: Material(
                    color: theme.colorScheme.primary.withAlpha(25),
                    child: TabBar(
                      indicatorColor: theme.colorScheme.primary,
                      labelColor: theme.colorScheme.primary,
                      unselectedLabelColor: theme.textTheme.bodyLarge?.color,
                      tabs: const [
                        Tab(icon: Icon(Icons.timer_outlined), text: 'Ayuno'),
                        Tab(icon: Icon(Icons.history_outlined), text: 'Historial'),
                        Tab(
                            icon: Icon(Icons.bar_chart_outlined),
                            text: 'Estadísticas'),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildFastingTab(theme, fastingProvider),
                      _buildHistoryTab(fastingProvider, theme),
                      _buildStatsTab(fastingProvider, theme),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFastingTab(ThemeData theme, FastingProvider fastingProvider) {
    // ... (same as before)
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildFastingControlPanel(theme, fastingProvider),
          const SizedBox(height: 24),
          const Divider(),
          _buildFastingPhases(fastingProvider, theme),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(FastingProvider provider, ThemeData theme) {
    // ... (same as before)
    final history = provider.fastingHistory;

    if (history.isEmpty) {
      return const Center(
        child: Text(
          'Aún no hay registros de ayuno.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final log = history[index];
        final duration = log.endTime!.difference(log.startTime);
        final hours = duration.inHours;
        final minutes = duration.inMinutes.remainder(60);

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              child: const Icon(Icons.check_circle_outline),
            ),
            title: Text(
              'Ayuno de ${hours}h ${minutes}m',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Inicio: ${DateFormat('dd/MM/yy HH:mm').format(log.startTime)}\n'
              'Fin:      ${DateFormat('dd/MM/yy HH:mm').format(log.endTime!)}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsTab(FastingProvider provider, ThemeData theme) {
    // We will build this chart
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Duración de Ayunos (Últimos 7 Días)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: BarChart(
              _buildWeeklyChart(provider, theme),
            ),
          ),
        ],
      ),
    );
  }

  BarChartData _buildWeeklyChart(FastingProvider provider, ThemeData theme) {
    // Helper to process data for the chart
    final Map<int, double> weeklyData = {};
    final today = DateTime.now();
    final weekStart = today.subtract(const Duration(days: 6));

    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      weeklyData[day.weekday] = 0;
    }

    for (final log in provider.fastingHistory) {
      if (log.endTime!.isAfter(weekStart)) {
        final weekday = log.endTime!.weekday;
        final durationHours = log.durationInSeconds / 3600;
        weeklyData[weekday] = (weeklyData[weekday] ?? 0) + durationHours;
      }
    }

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => theme.colorScheme.secondaryContainer,
        ),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text('${value.toInt()}h', style: const TextStyle(fontSize: 10));
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              const style = TextStyle(fontSize: 10);
              String text;
              switch (value.toInt()) {
                case 1: text = 'L'; break;
                case 2: text = 'M'; break;
                case 3: text = 'X'; break;
                case 4: text = 'J'; break;
                case 5: text = 'V'; break;
                case 6: text = 'S'; break;
                case 7: text = 'D'; break;
                default: text = ''; break;
              }
              return Text(text, style: style);
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 4,
        getDrawingHorizontalLine: (value) => FlLine(
          color: theme.dividerColor.withAlpha(25),
          strokeWidth: 1,
        ),
      ),
      borderData: FlBorderData(show: false),
      barGroups: weeklyData.entries.map((entry) {
        return BarChartGroupData(
          x: entry.key,
          barRods: [
            BarChartRodData(
              toY: entry.value,
              color: theme.colorScheme.primary,
              width: 16,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildFastingControlPanel(
      ThemeData theme, FastingProvider fastingProvider) {
    // ... (same as before)
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withAlpha(128),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: fastingProvider.isFasting
              ? theme.colorScheme.primary
              : Colors.transparent,
          width: 2,
        ),
        boxShadow: fastingProvider.isFasting
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withAlpha(77),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ]
            : [],
      ),
      child: Column(
        children: [
          const Text(
            'AYUNO INTERMITENTE',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            fastingProvider.formattedDuration,
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: fastingProvider.isFasting
                    ? null
                    : () => fastingProvider.startFasting(),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Empezar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
              ElevatedButton.icon(
                onPressed: !fastingProvider.isFasting
                    ? null
                    : () => fastingProvider.stopFasting(),
                icon: const Icon(Icons.stop),
                label: const Text('Parar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFastingPhases(FastingProvider provider, ThemeData theme) {
    final currentPhase = provider.currentPhase;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            'Fases del Ayuno',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: FastingPhase.phases.length,
          itemBuilder: (context, index) {
            final phase = FastingPhase.phases[index];
            final isCurrent = phase.name == currentPhase?.name;

            return Card(
              elevation: isCurrent ? 4 : 1,
              margin: const EdgeInsets.symmetric(vertical: 4),
              color: isCurrent
                  ? theme.colorScheme.secondaryContainer.withAlpha(178)
                  : theme.cardColor,
              child: ListTile(
                leading: Icon(
                  phase.icon,
                  color: isCurrent
                      ? theme.colorScheme.primary
                      : theme.iconTheme.color,
                ),
                title: Text(
                  phase.name,
                  style: TextStyle(
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCurrent ? theme.colorScheme.primary : null,
                  ),
                ),
                subtitle: Text(phase.description),
              ),
            );
          },
        ),
      ],
    );
  }
}
