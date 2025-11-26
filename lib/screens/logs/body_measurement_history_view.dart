import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/models/body_measurement.dart';
import 'package:intl/intl.dart';
import 'package:myapp/services/time_format_service.dart';
import 'package:provider/provider.dart';

class BodyMeasurementHistoryView extends StatelessWidget {
  const BodyMeasurementHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Historial de Mediciones',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildFullHistory(),
      ],
    );
  }

  Widget _buildFullHistory() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<BodyMeasurement>(
        'body_measurements',
      ).listenable(),
      builder: (context, Box<BodyMeasurement> box, _) {
        final allMeasurements = box.values.toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

        if (allMeasurements.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No hay mediciones registradas.'),
            ),
          );
        }

        // Agrupar mediciones por día
        final Map<DateTime, List<BodyMeasurement>> groupedMeasurements = {};
        for (var m in allMeasurements) {
          final day = DateTime(
            m.timestamp.year,
            m.timestamp.month,
            m.timestamp.day,
          );
          if (groupedMeasurements[day] == null) {
            groupedMeasurements[day] = [];
          }
          groupedMeasurements[day]!.add(m);
        }

        final sortedDays = groupedMeasurements.keys.toList()
          ..sort((a, b) => b.compareTo(a));

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedDays.length,
          separatorBuilder: (context, index) => const SizedBox(height: 24),
          itemBuilder: (context, index) {
            final day = sortedDays[index];
            final measurementsForDay = groupedMeasurements[day]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat.yMMMEd('es').format(day),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...measurementsForDay.map(
                  (measurement) => Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Medición a las ${Provider.of<TimeFormatService>(context).formatTime(measurement.timestamp)}',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const Divider(height: 20),
                          if (measurement.weight != null)
                            _buildMeasurementRow(
                              'Peso',
                              '${measurement.weight} kg',
                            ),
                          if (measurement.chest != null)
                            _buildMeasurementRow(
                              'Pecho',
                              '${measurement.chest} cm',
                            ),
                          if (measurement.arm != null)
                            _buildMeasurementRow(
                              'Brazo',
                              '${measurement.arm} cm',
                            ),
                          if (measurement.waist != null)
                            _buildMeasurementRow(
                              'Cintura',
                              '${measurement.waist} cm',
                            ),
                          if (measurement.hips != null)
                            _buildMeasurementRow(
                              'Caderas',
                              '${measurement.hips} cm',
                            ),
                          if (measurement.thigh != null)
                            _buildMeasurementRow(
                              'Muslo',
                              '${measurement.thigh} cm',
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMeasurementRow(
    String label,
    String value, {
    Color? color,
    TextStyle? valueStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style:
                valueStyle ??
                TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}
