import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/fasting_log.dart';
import 'package:myapp/models/fasting_phase.dart';
import 'package:myapp/models/fasting_plan.dart';
import 'package:myapp/providers/fasting_provider.dart';
import 'package:provider/provider.dart';
import 'package:timeline_tile/timeline_tile.dart';


class IntermittentFastingScreen extends StatefulWidget {
  const IntermittentFastingScreen({super.key});

  @override
  State<IntermittentFastingScreen> createState() =>
      _IntermittentFastingScreenState();
}

class _IntermittentFastingScreenState extends State<IntermittentFastingScreen> {
  late ScrollController _scrollController;
  FastingPhase? _lastScrolledPhase;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<FastingProvider>(context);
    if (provider.isFasting && provider.currentPhase != _lastScrolledPhase) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrentPhase(provider);
      });
      _lastScrolledPhase = provider.currentPhase;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }


  void _scrollToCurrentPhase(FastingProvider provider) {
    if (provider.currentPhase == null || !_scrollController.hasClients) return;

    final currentPhaseIndex = FastingPhase.phases.indexWhere(
      (p) => p.name == provider.currentPhase!.name,
    );

    if (currentPhaseIndex != -1) {
      const itemWidth = 120.0; // Approximate width of a timeline item
      final screenWidth = MediaQuery.of(context).size.width;
      final scrollPosition =
          (itemWidth * currentPhaseIndex) - (screenWidth / 2) + (itemWidth / 2);

      _scrollController.animateTo(
        scrollPosition.clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }


  Future<void> _showPhaseInfoDialog(
      BuildContext context, FastingPhase phase, ThemeData theme) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Row(
            children: [
              Icon(phase.icon, color: theme.colorScheme.primary, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  phase.name,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(
              phase.description,
              style: theme.textTheme.bodyLarge,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

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
                      if (!context.mounted) return;
                      final date = await showDatePicker(
                        context: context,
                        initialDate: editedStartTime,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date == null) return;

                      if (!context.mounted) return;
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
                      if (!context.mounted) return;
                      final date = await showDatePicker(
                        context: context,
                        initialDate: editedEndTime,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 1)),
                      );
                      if (date == null) return;

                      if (!context.mounted) return;
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

  Future<void> _showStopFastingDialog(
      BuildContext context, FastingProvider provider) async {
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
            ElevatedButton(
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
          _buildPlanSelector(theme, fastingProvider),
          const SizedBox(height: 24),
          _buildCircularTimer(theme, fastingProvider, context),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          _buildFastingTimeline(fastingProvider, theme),
        ],
      ),
    );
  }

  Widget _buildPlanSelector(ThemeData theme, FastingProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: FastingPlan.defaultPlans.map((plan) {
          final isSelected = provider.selectedPlan.name == plan.name;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(plan.name),
              selected: isSelected,
              onSelected: provider.isFasting
                  ? null
                  : (selected) {
                      if (selected) {
                        provider.setPlan(plan);
                      }
                    },
              selectedColor: theme.colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.textTheme.bodyLarge?.color,
              ),
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : Colors.grey.shade300),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCircularTimer(
      ThemeData theme, FastingProvider provider, BuildContext context) {
    final isFasting = provider.isFasting;
    final duration = provider.currentFast?.durationInSeconds ?? 0;
    final goal = provider.goalInSeconds;
    final progress = goal > 0 ? (duration / goal).clamp(0.0, 1.0) : 0.0;

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
            valueColor:
                AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isFasting)
                  Text(
                    provider.formattedFastingDuration,
                    style: theme.textTheme.headlineLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  )
                else
                  Text(
                    provider.formattedFeedingWindowDuration,
                    style: theme.textTheme.headlineLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                const SizedBox(height: 8),
                if (isFasting)
                  Text(
                    provider.currentPhase?.name ?? 'Comenzando...',
                    style: theme.textTheme.titleMedium,
                  )
                else
                  Text('Ventana de alimentación',
                      style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('Objetivo: ${provider.selectedPlan.fastingHours} horas',
                    style: theme.textTheme.titleSmall),
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
                  content: const Text(
                      "¿Estás seguro de que quieres eliminar este ayuno?"),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("CANCELAR")),
                    ElevatedButton(
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
                'Inicio: ${DateFormat('dd/MM/yy HH:mm').format(log.startTime)}\nFin:      ${DateFormat('dd/MM/yy HH:mm').format(log.endTime!)}',
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

  Widget _buildFastingTimeline(FastingProvider provider, ThemeData theme) {
    final currentDurationHours = (provider.currentFast?.durationInSeconds ?? 0) / 3600;
    const phases = FastingPhase.phases;

    return SizedBox(
      height: 150,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: phases.length,
        itemBuilder: (context, index) {
          final phase = phases[index];
          final isFirst = index == 0;
          final isLast = index == phases.length - 1;

          bool isCompleted = currentDurationHours >= phase.endHour;
          bool isCurrent =
              provider.currentPhase != null && provider.currentPhase == phase;
          bool isFuture = currentDurationHours < phase.startHour;

          Color lineColor = isCompleted
              ? theme.colorScheme.primary
              : Colors.grey.shade300;
          Widget indicator;

          if (isCompleted) {
            indicator =
                Icon(Icons.check_circle, color: theme.colorScheme.primary);
          } else if (isCurrent) {
            indicator = Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withAlpha(128),
                    blurRadius: 10.0,
                    spreadRadius: 2.0,
                  ),
                ],
              ),
              child:
                  Icon(phase.icon, color: theme.colorScheme.onPrimary, size: 20),
            );
          } else {
            indicator = Icon(phase.icon, color: Colors.grey.shade400, size: 20);
          }

          return TimelineTile(
            axis: TimelineAxis.horizontal,
            alignment: TimelineAlign.center,
            isFirst: isFirst,
            isLast: isLast,
            beforeLineStyle: LineStyle(color: lineColor, thickness: 3),
            afterLineStyle: LineStyle(
                color: index < phases.length - 1 &&
                        currentDurationHours >= phases[index + 1].startHour
                    ? theme.colorScheme.primary
                    : Colors.grey.shade300,
                thickness: 3),
            indicatorStyle: IndicatorStyle(
              width: 35,
              height: 35,
              indicator: indicator,
            ),
            endChild: InkWell(
              onTap: () => _showPhaseInfoDialog(context, phase, theme),
              child: Container(
                constraints: const BoxConstraints(minWidth: 100, minHeight: 120),
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      phase.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight:
                            isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isFuture
                            ? Colors.grey.shade500
                            : (isCurrent
                                ? theme.colorScheme.primary
                                : theme.textTheme.bodyMedium?.color),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${phase.startHour}h',
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
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
                      ? provider.formatDuration(
                          longestFast.endTime!.difference(longestFast.startTime))
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

  Widget _buildStatCard(ThemeData theme,
      {required IconData icon,
      required String title,
      required String value}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
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
              return Text('${value.toInt()}h',
                  style: const TextStyle(fontSize: 10));
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
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        );
      }).toList(),
    );
  }
}
