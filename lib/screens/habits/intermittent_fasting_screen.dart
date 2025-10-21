import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/fasting_log.dart';
import 'package:myapp/models/fasting_phase.dart';
import 'package:myapp/providers/fasting_provider.dart';
import 'package:provider/provider.dart';

class IntermittentFastingScreen extends StatelessWidget {
  const IntermittentFastingScreen({super.key});

  Future<void> _showEditDialog(
      BuildContext context, FastingLog log, FastingProvider provider) async {
    DateTime editedStartTime = log.startTime;
    DateTime editedEndTime = log.endTime!;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Editar Ayuno'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(
                        'Inicio: ${DateFormat('dd/MM/yy HH:mm').format(editedStartTime)}'),
                    trailing: const Icon(Icons.edit_calendar),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: editedStartTime,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date == null) return;

                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(editedStartTime),
                      );
                      if (time == null) return;

                      setState(() {
                        editedStartTime = DateTime(date.year, date.month,
                            date.day, time.hour, time.minute);
                      });
                    },
                  ),
                  ListTile(
                    title: Text(
                        'Fin:      ${DateFormat('dd/MM/yy HH:mm').format(editedEndTime)}'),
                    trailing: const Icon(Icons.edit_calendar),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: editedEndTime,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 1)),
                      );
                      if (date == null) return;

                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(editedEndTime),
                      );
                      if (time == null) return;

                      setState(() {
                        editedEndTime = DateTime(date.year, date.month,
                            date.day, time.hour, time.minute);
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (editedEndTime.isBefore(editedStartTime)) {
                   if (dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'La fecha de fin no puede ser anterior a la de inicio.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  return;
                }
                final updatedLog = FastingLog(
                  id: log.id,
                  startTime: editedStartTime,
                  endTime: editedEndTime,
                );
                await provider.updateFastingLog(updatedLog);
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showStopFastingDialog(BuildContext context, FastingProvider provider) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Finalizar Ayuno'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('¿Estás seguro de que quieres finalizar el ayuno?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Finalizar'),
              onPressed: () {
                provider.stopFasting();
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
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
                        Tab(
                            icon: Icon(Icons.history_outlined),
                            text: 'Historial'),
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
                      _buildFastingTab(context, theme, fastingProvider),
                      _buildHistoryTab(context, fastingProvider, theme),
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

  Widget _buildFastingTab(
      BuildContext context, ThemeData theme, FastingProvider fastingProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildCircularTimer(theme, fastingProvider, context),
          const SizedBox(height: 24),
          const Divider(),
          _buildFastingPhases(fastingProvider, theme),
        ],
      ),
    );
  }

  Widget _buildCircularTimer(
      ThemeData theme, FastingProvider provider, BuildContext context) {
    final isFasting = provider.isFasting;
    final duration = provider.currentFast?.durationInSeconds ?? 0;
    const goal = 16 * 3600; // 16 hours goal
    final progress = (duration / goal).clamp(0.0, 1.0);

    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 12,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  provider.formattedDuration,
                  style: theme.textTheme.headlineLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.currentPhase?.name ?? (isFasting ? 'Comenzando...' : 'En espera'),
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                if (isFasting)
                  ElevatedButton.icon(
                    onPressed: () => _showStopFastingDialog(context, provider),
                    icon: const Icon(Icons.stop),
                    label: const Text('Parar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.onError,
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () => provider.startFasting(),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Empezar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(
      BuildContext context, FastingProvider provider, ThemeData theme) {
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

        return Dismissible(
          key: Key(log.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20.0),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Confirmar"),
                  content:
                      const Text("¿Estás seguro de que quieres eliminar este ayuno?"),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("CANCELAR")),
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text("ELIMINAR")),
                  ],
                );
              },
            );
          },
          onDismissed: (direction) async {
            await provider.deleteFastingLog(log.id);
             if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ayuno eliminado')),
              );
            }
          },
          child: Card(
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
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditDialog(context, log, provider),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsTab(FastingProvider provider, ThemeData theme) {
    final longestFast = provider.longestFastLog;
    final averageDuration = provider.averageFastDuration;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  theme,
                  icon: Icons.star_border,
                  title: 'Ayuno Más Largo',
                  value: longestFast != null
                      ? provider.formatDuration(longestFast.endTime!.difference(longestFast.startTime))
                      : 'N/A',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  theme,
                  icon: Icons.av_timer,
                  title: 'Promedio de Ayuno',
                  value: provider.formatDuration(averageDuration),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Duración de Ayunos (Últimos 7 Días)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
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

  Widget _buildStatCard(ThemeData theme, {required IconData icon, required String title, required String value}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(title, style: theme.textTheme.titleMedium, textAlign: TextAlign.center,),
            const SizedBox(height: 4),
            Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),),
          ],
        ),
      ),
    );
  }

  BarChartData _buildWeeklyChart(FastingProvider provider, ThemeData theme) {
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
                case 1:
                  text = 'L';
                  break;
                case 2:
                  text = 'M';
                  break;
                case 3:
                  text = 'X';
                  break;
                case 4:
                  text = 'J';
                  break;
                case 5:
                  text = 'V';
                  break;
                case 6:
                  text = 'S';
                  break;
                case 7:
                  text = 'D';
                  break;
                default:
                  text = '';
                  break;
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
        getDrawingHorizontalLine: (value) =>
            FlLine(color: theme.dividerColor.withAlpha(25), strokeWidth: 1),
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

  Widget _buildFastingPhases(FastingProvider provider, ThemeData theme) {
    final currentPhase = provider.currentPhase;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            'Fases del Ayuno',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
