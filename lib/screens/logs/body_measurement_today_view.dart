import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/models/body_measurement.dart';
import 'package:intl/intl.dart';

class BodyMeasurementTodayView extends StatelessWidget {
  const BodyMeasurementTodayView({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<BodyMeasurement>('body_measurements').listenable(),
      builder: (context, Box<BodyMeasurement> box, _) {
        final today = DateTime.now();
        final todaysMeasurements = box.values.where((m) {
          return m.timestamp.year == today.year &&
                 m.timestamp.month == today.month &&
                 m.timestamp.day == today.day;
        }).toList();

        if (todaysMeasurements.isEmpty) {
          return const Center(
            child: Text('Aún no has registrado tus medidas de hoy.'),
          );
        }

        // Muestra la última medición del día
        final lastMeasurement = todaysMeasurements.last;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Última medición de hoy - ${DateFormat.yMd().add_jm().format(lastMeasurement.timestamp)}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildMeasurementRow('Peso', '${lastMeasurement.weight} kg'),
                  _buildMeasurementRow('Pecho', '${lastMeasurement.chest} cm'),
                  _buildMeasurementRow('Brazo', '${lastMeasurement.arm} cm'),
                  _buildMeasurementRow('Cintura', '${lastMeasurement.waist} cm'),
                  _buildMeasurementRow('Caderas', '${lastMeasurement.hips} cm'),
                  _buildMeasurementRow('Muslo', '${lastMeasurement.thigh} cm'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMeasurementRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: const TextStyle(fontSize: 16)), Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))],),);
  }
}
