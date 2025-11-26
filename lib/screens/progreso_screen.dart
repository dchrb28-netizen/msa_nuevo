import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/body_measurement.dart';
import 'package:myapp/models/daily_meal_plan.dart';
import 'package:myapp/models/fasting_log.dart';
import 'package:myapp/models/routine_log.dart';
import 'package:myapp/models/water_log.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/widgets/ui/watermark_image.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class ProgresoScreen extends StatefulWidget {
  const ProgresoScreen({super.key});

  @override
  State<ProgresoScreen> createState() => _ProgresoScreenState();
}

class _ProgresoScreenState extends State<ProgresoScreen> {
  String _selectedPeriod = 'Últimos 7 Días';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const WatermarkImage(imageName: 'progreso'),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildDateFilter(),
                const SizedBox(height: 28),
                _buildWeightProgressCard(),
                const SizedBox(height: 20),
                _buildWaterIntakeCard(),
                const SizedBox(height: 20),
                _buildMealsSummaryCard(),
                const SizedBox(height: 20),
                _buildFastingSummaryCard(),
                const SizedBox(height: 20),
                _buildMeditationSummaryCard(),
                const SizedBox(height: 20),
                _buildBodyMeasurementCard(),
                const SizedBox(height: 20),
                _buildWorkoutSummaryCard(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBodyMeasurementCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      PhosphorIcons.ruler(PhosphorIconsStyle.duotone),
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Medidas Corporales',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 56),
                child: Text(
                  _selectedPeriod,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: ValueListenableBuilder(
                  valueListenable: Hive.box<BodyMeasurement>(
                    'body_measurements',
                  ).listenable(),
                  builder: (context, Box<BodyMeasurement> box, _) {
                    final now = DateTime.now();
                    DateTime startDate;
                    switch (_selectedPeriod) {
                      case 'Último Mes':
                        startDate = now.subtract(const Duration(days: 30));
                        break;
                      case 'Último Año':
                        startDate = now.subtract(const Duration(days: 365));
                        break;
                      default:
                        startDate = now.subtract(const Duration(days: 7));
                    }

                    final measurements = box.values
                        .where((m) => m.timestamp.isAfter(startDate))
                        .toList()
                      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

                    if (measurements.length < 2) {
                      return const Center(
                        child: Text(
                          'No hay suficientes datos de medidas corporales.',
                        ),
                      );
                    }

                    final first = measurements.first;
                    final last = measurements.last;

                    final data = [
                      last.chest ?? 0,
                      last.arm ?? 0,
                      last.waist ?? 0,
                      last.hips ?? 0,
                      last.thigh ?? 0,
                    ];

                    final initialData = [
                      first.chest ?? 0,
                      first.arm ?? 0,
                      first.waist ?? 0,
                      first.hips ?? 0,
                      first.thigh ?? 0,
                    ];

                    return RadarChart(
                      RadarChartData(
                        dataSets: [
                          RadarDataSet(
                            dataEntries: initialData
                                .map((d) => RadarEntry(value: d))
                                .toList(),
                            borderColor: Colors.grey,
                            borderWidth: 1,
                          ),
                          RadarDataSet(
                            dataEntries:
                                data.map((d) => RadarEntry(value: d)).toList(),
                            borderColor: Theme.of(context).colorScheme.primary,
                            fillColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withAlpha(100),
                            borderWidth: 2,
                          ),
                        ],
                        tickCount: 5,
                        ticksTextStyle: const TextStyle(
                          color: Colors.transparent,
                          fontSize: 10,
                        ),
                        getTitle: (index, angle) {
                          final titles = [
                            'Pecho',
                            'Brazo',
                            'Cintura',
                            'Cadera',
                            'Muslo',
                          ];
                          return RadarChartTitle(
                            text: titles[index],
                            angle: angle,
                          );
                        },
                        gridBorderData: const BorderSide(
                          color: Colors.grey,
                          width: 1,
                        ),
                        radarShape: RadarShape.circle,
                        radarBackgroundColor: Colors.transparent,
                        borderData: FlBorderData(show: false),
                        radarBorderData: const BorderSide(
                          color: Colors.transparent,
                        ),
                        tickBorderData: const BorderSide(
                          color: Colors.transparent,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateFilter() {
    final periods = ['Últimos 7 Días', 'Último Mes', 'Último Año'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: periods.map((period) {
            final isSelected = _selectedPeriod == period;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedPeriod = period;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                              ],
                            )
                          : null,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      period,
                      style: GoogleFonts.montserrat(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildWaterIntakeCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.secondaryContainer,
                          Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      PhosphorIcons.drop(PhosphorIconsStyle.duotone),
                      color: Theme.of(context).colorScheme.secondary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Consumo de Agua',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 56),
                child: Text(
                  _selectedPeriod,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: ValueListenableBuilder(
                  valueListenable: Hive.box<WaterLog>('water_logs').listenable(),
                  builder: (context, Box<WaterLog> box, _) {
                    final now = DateTime.now();
                    DateTime startDate;
                    switch (_selectedPeriod) {
                      case 'Último Mes':
                        startDate = now.subtract(const Duration(days: 30));
                        break;
                      case 'Último Año':
                        startDate = now.subtract(const Duration(days: 365));
                        break;
                      default:
                        startDate = now.subtract(const Duration(days: 7));
                    }

                    final logs = box.values
                        .where((log) => log.timestamp.isAfter(startDate))
                        .toList();

                    if (logs.isEmpty) {
                      return const Center(
                        child: Text('No hay datos de consumo de agua.'),
                      );
                    }

                    final dailyTotals = <DateTime, double>{};
                    for (var log in logs) {
                      final day = DateTime(
                        log.timestamp.year,
                        log.timestamp.month,
                        log.timestamp.day,
                      );
                      dailyTotals[day] = (dailyTotals[day] ?? 0) + log.amount;
                    }

                    final chartData = dailyTotals.entries.toList()
                      ..sort((a, b) => a.key.compareTo(b.key));

                    return LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          getDrawingHorizontalLine: (value) =>
                              const FlLine(color: Colors.white10, strokeWidth: 1),
                          getDrawingVerticalLine: (value) =>
                              const FlLine(color: Colors.white10, strokeWidth: 1),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < chartData.length) {
                                  final date = chartData[index].key;
                                  if (chartData.length > 7 &&
                                      index % (chartData.length / 7).round() !=
                                          0) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      DateFormat.MMMd().format(date),
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                            color: const Color(0xff37434d),
                            width: 1,
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: chartData
                                .asMap()
                                .entries
                                .map(
                                  (e) => FlSpot(e.key.toDouble(), e.value.value),
                                )
                                .toList(),
                            isCurved: true,
                            color: Theme.of(context).colorScheme.secondary,
                            barWidth: 4,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withAlpha(50),
                            ),
                          ),
                        ],
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                              return touchedBarSpots.map((barSpot) {
                                final flSpot = barSpot;
                                final index = flSpot.x.toInt();
                                final data = chartData[index];
                                return LineTooltipItem(
                                  '${data.value.toInt()} ml ',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: DateFormat.yMMMd().format(data.key),
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                );
                              }).toList();
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeightTrackingCard() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final user = userProvider.user;
        final hasGoal = user?.waterGoal != null && (user?.waterGoal ?? 0) > 0;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showEditWaterGoalDialog(context, user?.waterGoal),
            borderRadius: BorderRadius.circular(14),
            child: Ink(
              decoration: BoxDecoration(
                gradient: hasGoal
                    ? LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primaryContainer,
                          Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.7),
                        ],
                      )
                    : LinearGradient(
                        colors: [
                          Colors.orange.withValues(alpha: 0.15),
                          Colors.deepOrange.withValues(alpha: 0.1),
                        ],
                      ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: hasGoal
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                      : Colors.orange.withValues(alpha: 0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (hasGoal
                        ? Theme.of(context).colorScheme.primary
                        : Colors.orange).withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: hasGoal
                            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
                            : Colors.orange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        hasGoal
                            ? PhosphorIcons.target(PhosphorIconsStyle.duotone)
                            : PhosphorIcons.plus(PhosphorIconsStyle.duotone),
                        size: 18,
                        color: hasGoal
                            ? Theme.of(context).colorScheme.primary
                            : Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      hasGoal
                          ? 'Meta: ${(user?.waterGoal ?? 0).toInt()} ml'
                          : 'Establecer meta diaria',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: hasGoal
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Colors.orange.shade700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (hasGoal) ...[
                      const SizedBox(width: 6),
                      Icon(
                        PhosphorIcons.pencilSimple(PhosphorIconsStyle.duotone),
                        size: 16,
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showEditWaterGoalDialog(BuildContext context, double? currentGoal) async {
    final controller = TextEditingController(
      text: currentGoal != null && currentGoal > 0 ? currentGoal.toInt().toString() : '2000',
    );

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          currentGoal != null && currentGoal > 0 ? 'Editar Meta Diaria' : 'Establecer Meta Diaria',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ingresa tu meta de consumo de agua en mililitros:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Meta (ml)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixText: 'ml',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final value = double.tryParse(controller.text);
              if (value != null && value > 0) {
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                final user = userProvider.user;
                if (user != null) {
                  final updatedUser = user.copyWith(waterGoal: value);
                  await userProvider.updateUser(updatedUser);
                }
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightProgressCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      PhosphorIcons.chartLineUp(PhosphorIconsStyle.duotone),
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Progreso de Peso',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 56),
                child: Text(
                  _selectedPeriod,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: ValueListenableBuilder(
                  valueListenable: Hive.box<BodyMeasurement>(
                    'body_measurements',
                  ).listenable(),
                  builder: (context, Box<BodyMeasurement> box, _) {
                    final now = DateTime.now();
                    DateTime startDate;
                    switch (_selectedPeriod) {
                    case 'Último Mes':
                      startDate = now.subtract(const Duration(days: 30));
                      break;
                    case 'Último Año':
                      startDate = now.subtract(const Duration(days: 365));
                      break;
                    default:
                      startDate = now.subtract(const Duration(days: 7));
                    }

                    final measurements = box.values
                        .where(
                          (m) =>
                              m.timestamp.isAfter(startDate) && m.weight != null,
                        )
                        .toList()
                      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

                    if (measurements.length < 2) {
                      return const Center(
                        child: Text(
                          'No hay suficientes datos para mostrar el progreso.',
                        ),
                      );
                    }

                    double minY = double.infinity;
                    double maxY = double.negativeInfinity;
                    int minIndex = -1;
                    int maxIndex = -1;

                    for (int i = 0; i < measurements.length; i++) {
                      final weight = measurements[i].weight!;
                      if (weight < minY) {
                        minY = weight;
                        minIndex = i;
                      }
                      if (weight > maxY) {
                        maxY = weight;
                        maxIndex = i;
                      }
                    }

                    final spots = measurements
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value.weight!))
                        .toList();

                    return LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          getDrawingHorizontalLine: (value) =>
                              const FlLine(color: Colors.white10, strokeWidth: 1),
                          getDrawingVerticalLine: (value) =>
                              const FlLine(color: Colors.white10, strokeWidth: 1),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < measurements.length) {
                                  final date = measurements[index].timestamp;
                                  if (measurements.length > 7 &&
                                      index %
                                              (measurements.length / 7).round() !=
                                          0) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      DateFormat.MMMd().format(date),
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                            color: const Color(0xff37434d),
                            width: 1,
                          ),
                        ),
                        minX: 0,
                        maxX: (measurements.length - 1).toDouble(),
                        minY: minY - 5,
                        maxY: maxY + 5,
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            color: Theme.of(context).colorScheme.primary,
                            barWidth: 4,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                if (index == minIndex || index == maxIndex) {
                                  return FlDotCirclePainter(
                                    radius: 8,
                                    color: index == minIndex
                                        ? Colors.redAccent
                                        : Colors.greenAccent,
                                    strokeWidth: 2,
                                    strokeColor: Colors.white,
                                  );
                                }
                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: Theme.of(context).colorScheme.primary,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withAlpha(50),
                            ),
                          ),
                        ],
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                              return touchedBarSpots.map((barSpot) {
                                final flSpot = barSpot;
                                final index = flSpot.x.toInt();
                                final measurement = measurements[index];
                                return LineTooltipItem(
                                  '${measurement.weight} kg ',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: DateFormat.yMMMd()
                                          .format(measurement.timestamp),
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                );
                              }).toList();
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutSummaryCard() {
    String formatDuration(int totalMinutes) {
      final hours = totalMinutes ~/ 60;
      final minutes = totalMinutes % 60;
      return '${hours}h ${minutes}m';
    }

    return ValueListenableBuilder(
      valueListenable: Hive.box<RoutineLog>('routine_logs').listenable(),
      builder: (context, Box<RoutineLog> box, _) {
        final now = DateTime.now();
        DateTime startDate;
        String periodText;
        switch (_selectedPeriod) {
          case 'Último Mes':
            startDate = now.subtract(const Duration(days: 30));
            periodText = 'en el último mes';
            break;
          case 'Último Año':
            startDate = now.subtract(const Duration(days: 365));
            periodText = 'en el último año';
            break;
          default:
            startDate = now.subtract(const Duration(days: 7));
            periodText = 'en los últimos 7 días';
        }

        final weeklyLogs = box.values
            .where((log) => log.date.isAfter(startDate))
            .toList();

        final workoutsThisWeek = weeklyLogs.length;
        // CORRECCIÓN: Usar el campo correcto `durationInMinutes`
        final totalMinutes = weeklyLogs.fold<int>(
          0,
          (sum, log) => sum + log.durationInMinutes,
        );
        final timeSpent = formatDuration(totalMinutes);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Card(
            elevation: 0,
            color: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.red.withValues(alpha: 0.2),
                              Colors.red.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          PhosphorIcons.barbell(PhosphorIconsStyle.duotone),
                          color: Colors.red,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Resumen de Ejercicio',
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 56),
                    child: Text(
                      periodText,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        icon: PhosphorIcons.calendarCheck(PhosphorIconsStyle.duotone),
                        value: workoutsThisWeek.toString(),
                        label: 'Entrenamientos',
                        color: Colors.red,
                      ),
                      _buildStatCard(
                        icon: PhosphorIcons.timer(PhosphorIconsStyle.duotone),
                        value: timeSpent,
                        label: 'Tiempo total',
                        color: Colors.deepOrange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMealsSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.withValues(alpha: 0.2),
                          Colors.orange.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      PhosphorIcons.forkKnife(PhosphorIconsStyle.duotone),
                      color: Colors.orange,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Comidas Registradas',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 56),
                child: Text(
                  _selectedPeriod,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder(
                valueListenable: Hive.box<DailyMealPlan>('daily_meal_plans').listenable(),
                builder: (context, Box<DailyMealPlan> box, _) {
                  final now = DateTime.now();
                  DateTime startDate;
                  switch (_selectedPeriod) {
                    case 'Último Mes':
                      startDate = now.subtract(const Duration(days: 30));
                      break;
                    case 'Último Año':
                      startDate = now.subtract(const Duration(days: 365));
                      break;
                    default:
                      startDate = now.subtract(const Duration(days: 7));
                  }

                  final mealPlans = box.values
                      .where((plan) => plan.date.isAfter(startDate))
                      .toList();

                  if (mealPlans.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No hay comidas registradas en este período.'),
                      ),
                    );
                  }

                  int totalDaysWithMeals = mealPlans.length;
                  int totalMeals = 0;
                  double totalCalories = 0;
                  double totalProtein = 0;
                  double totalCarbs = 0;
                  double totalFat = 0;

                  for (var plan in mealPlans) {
                    for (var foods in plan.meals.values) {
                      totalMeals += foods.length;
                      for (var food in foods) {
                        totalCalories += food.calories ?? 0;
                        totalProtein += food.proteins ?? 0;
                        totalCarbs += food.carbohydrates ?? 0;
                        totalFat += food.fats ?? 0;
                      }
                    }
                  }

                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCard(
                            icon: PhosphorIcons.calendar(PhosphorIconsStyle.duotone),
                            value: totalDaysWithMeals.toString(),
                            label: 'Días con registro',
                            color: Colors.blue,
                          ),
                          _buildStatCard(
                            icon: PhosphorIcons.bowlFood(PhosphorIconsStyle.duotone),
                            value: totalMeals.toString(),
                            label: 'Comidas totales',
                            color: Colors.green,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                              Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Promedio diario',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildNutrientColumn(
                            'Calorías',
                            (totalCalories / totalDaysWithMeals).toStringAsFixed(0),
                            'kcal',
                            Colors.orange,
                          ),
                          _buildNutrientColumn(
                            'Proteína',
                            (totalProtein / totalDaysWithMeals).toStringAsFixed(1),
                            'g',
                            Colors.red,
                          ),
                          _buildNutrientColumn(
                            'Carbos',
                            (totalCarbs / totalDaysWithMeals).toStringAsFixed(1),
                            'g',
                            Colors.blue,
                          ),
                          _buildNutrientColumn(
                            'Grasa',
                            (totalFat / totalDaysWithMeals).toStringAsFixed(1),
                            'g',
                            Colors.green,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutrientColumn(String label, String value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color.withValues(alpha: 0.8),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFastingSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple.withValues(alpha: 0.2),
                          Colors.purple.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.duotone),
                      color: Colors.purple,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ayuno Intermitente',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 56),
                child: Text(
                  _selectedPeriod,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder(
                valueListenable: Hive.box<FastingLog>('fasting_logs').listenable(),
                builder: (context, Box<FastingLog> box, _) {
                  final now = DateTime.now();
                  DateTime startDate;
                  switch (_selectedPeriod) {
                    case 'Último Mes':
                      startDate = now.subtract(const Duration(days: 30));
                      break;
                    case 'Último Año':
                      startDate = now.subtract(const Duration(days: 365));
                      break;
                    default:
                      startDate = now.subtract(const Duration(days: 7));
                  }

                  final fastingLogs = box.values
                      .where((log) => log.startTime.isAfter(startDate) && log.endTime != null)
                      .toList();

                  if (fastingLogs.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No hay registros de ayuno en este período.'),
                      ),
                    );
                  }

                  int totalFasts = fastingLogs.length;
                  int totalSeconds = fastingLogs.fold<int>(
                    0,
                    (sum, log) => sum + log.durationInSeconds,
                  );
                  
                  double avgHours = (totalSeconds / totalFasts / 3600);
                  int longestSeconds = fastingLogs.map((log) => log.durationInSeconds).reduce((a, b) => a > b ? a : b);
                  
                  String formatDuration(int seconds) {
                    final hours = seconds ~/ 3600;
                    final minutes = (seconds % 3600) ~/ 60;
                    return '${hours}h ${minutes}m';
                  }

                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCard(
                            icon: PhosphorIcons.listChecks(PhosphorIconsStyle.duotone),
                            value: totalFasts.toString(),
                            label: 'Ayunos completados',
                            color: Colors.purple,
                          ),
                          _buildStatCard(
                            icon: PhosphorIcons.chartBar(PhosphorIconsStyle.duotone),
                            value: avgHours.toStringAsFixed(1),
                            label: 'Promedio (horas)',
                            color: Colors.deepPurple,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber.withValues(alpha: 0.2),
                              Colors.orange.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              PhosphorIcons.trophy(PhosphorIconsStyle.duotone),
                              color: Colors.amber,
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Récord: ${formatDuration(longestSeconds)}',
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade800,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeditationSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.teal.withValues(alpha: 0.2),
                          Colors.teal.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      PhosphorIcons.brain(PhosphorIconsStyle.duotone),
                      color: Colors.teal,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Meditación',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 56),
                child: Text(
                  _selectedPeriod,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder(
                valueListenable: Hive.box<String>('meditation_logs_json').listenable(),
                builder: (context, Box<String> box, _) {
                  // Obtener la fecha de inicio según el período seleccionado
                  final now = DateTime.now();
                  final startDate = _selectedPeriod == 'Semana'
                      ? now.subtract(const Duration(days: 7))
                      : _selectedPeriod == 'Mes'
                          ? DateTime(now.year, now.month - 1, now.day)
                          : DateTime(now.year - 1, now.month, now.day);

                  // Convertir strings JSON a objetos MeditationLog
                  final allLogs = box.values.map((jsonString) {
                    final map = json.decode(jsonString);
                    return {
                      'startTime': DateTime.parse(map['startTime']),
                      'durationInSeconds': map['durationInSeconds'] as int,
                    };
                  }).toList();

                  // Filtrar por período
                  final meditationLogs = allLogs
                      .where((log) => (log['startTime'] as DateTime).isAfter(startDate))
                      .toList();

                  if (meditationLogs.isEmpty) {
                    return const Center(
                      child: Text('No hay registros de meditación en este período.'),
                    );
                  }

                  // Calcular estadísticas
                  int totalSessions = meditationLogs.length;
                  int totalSeconds = meditationLogs.fold<int>(
                    0,
                    (sum, log) => sum + (log['durationInSeconds'] as int),
                  );
                  double avgMinutes = totalSeconds / totalSessions / 60;

                  // Obtener días únicos con meditación
                  final uniqueDays = meditationLogs
                      .map((log) {
                        final dt = log['startTime'] as DateTime;
                        return DateTime(dt.year, dt.month, dt.day);
                      })
                      .toSet()
                      .length;

                  // Sesión más larga
                  int longestSeconds = meditationLogs.fold<int>(
                    0,
                    (max, log) {
                      final duration = log['durationInSeconds'] as int;
                      return duration > max ? duration : max;
                    },
                  );

                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              icon: PhosphorIcons.calendarCheck(PhosphorIconsStyle.duotone),
                              value: '$uniqueDays',
                              label: 'Días activos',
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              icon: PhosphorIcons.list(PhosphorIconsStyle.duotone),
                              value: '$totalSessions',
                              label: 'Sesiones',
                              color: Colors.cyan,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              icon: PhosphorIcons.chartBar(PhosphorIconsStyle.duotone),
                              value: avgMinutes.toStringAsFixed(1),
                              label: 'Promedio (min)',
                              color: Colors.lightBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber.withValues(alpha: 0.2),
                              Colors.orange.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              PhosphorIcons.trophy(PhosphorIconsStyle.duotone),
                              color: Colors.amber,
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Récord: ${(longestSeconds / 60).toStringAsFixed(0)} min',
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade800,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
