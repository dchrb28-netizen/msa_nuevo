import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/body_measurement.dart';
import 'package:myapp/models/routine_log.dart';
import 'package:myapp/models/water_log.dart';
import 'package:myapp/widgets/ui/watermark_image.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 40), // Added padding to compensate for appbar
                _buildDateFilter(),
                const SizedBox(height: 24),
                _buildWeightProgressCard(),
                const SizedBox(height: 24),
                _buildWaterIntakeCard(),
                const SizedBox(height: 24),
                _buildBodyMeasurementCard(),
                const SizedBox(height: 24),
                _buildWorkoutSummaryCard(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBodyMeasurementCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(PhosphorIcons.ruler(PhosphorIconsStyle.duotone),
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Medidas Corporales ($_selectedPeriod)',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
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
    );
  }

  Widget _buildDateFilter() {
    final periods = ['Últimos 7 Días', 'Último Mes', 'Último Año'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: periods.map((period) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(period),
              selected: _selectedPeriod == period,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedPeriod = period;
                  });
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWaterIntakeCard() {
    const double waterGoal = 2000; // Objetivo de ejemplo: 2000 ml

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(PhosphorIcons.drop(PhosphorIconsStyle.duotone),
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Consumo de Agua ($_selectedPeriod)',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
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
                      extraLinesData: ExtraLinesData(
                        horizontalLines: [
                          HorizontalLine(
                            y: waterGoal,
                            color: Colors.green.withAlpha(204),
                            strokeWidth: 2,
                            dashArray: [5, 5],
                            label: HorizontalLineLabel(
                              show: true,
                              alignment: Alignment.topRight,
                              padding: const EdgeInsets.only(
                                right: 5,
                                bottom: 2,
                              ),
                              style: TextStyle(
                                color: Colors.green[100],
                                fontSize: 10,
                              ),
                              labelResolver: (line) =>
                                  'Meta: ${line.y.toInt()} ml',
                            ),
                          ),
                        ],
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
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              final isGoalMet =
                                  barData.spots[index].y >= waterGoal;
                              return FlDotCirclePainter(
                                radius: 6,
                                color: isGoalMet
                                    ? Colors.greenAccent
                                    : Theme.of(context).colorScheme.secondary,
                                strokeWidth: 1,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
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
    );
  }

  Widget _buildWeightProgressCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(PhosphorIcons.chartLineUp(PhosphorIconsStyle.duotone),
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Progreso de Peso ($_selectedPeriod)',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
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

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(PhosphorIcons.barbell(PhosphorIconsStyle.duotone),
                        color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Resumen de Ejercicio ($periodText)',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Icon(
                          PhosphorIcons.calendarCheck(PhosphorIconsStyle.duotone),
                          color: Theme.of(context).colorScheme.secondary,
                          size: 28,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          workoutsThisWeek.toString(),
                          style: GoogleFonts.montserrat(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const Text('Entrenamientos'),
                      ],
                    ),
                    Column(
                      children: [
                        Icon(
                          PhosphorIcons.timer(PhosphorIconsStyle.duotone),
                          color: Theme.of(context).colorScheme.secondary,
                          size: 28,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          timeSpent,
                          style: GoogleFonts.montserrat(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const Text('Tiempo total'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
