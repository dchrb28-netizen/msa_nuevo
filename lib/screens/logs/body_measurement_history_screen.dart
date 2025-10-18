import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/models/body_measurement.dart';
import 'package:intl/intl.dart';

class BodyMeasurementHistoryScreen extends StatelessWidget {
  const BodyMeasurementHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<BodyMeasurement>('body_measurements').listenable(),
      builder: (context, Box<BodyMeasurement> box, _) {
        if (box.values.isEmpty) {
          return const Center(
            child: Text('No hay mediciones registradas.'),
          );
        }

        // Ordenar las mediciones de la más reciente a la más antigua
        final sortedMeasurements = box.values.toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: sortedMeasurements.length,
          itemBuilder: (context, index) {
            final measurement = sortedMeasurements[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ExpansionTile(
                title: Text(
                  DateFormat.yMMMMd('es').format(measurement.timestamp),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text('Peso: ${measurement.weight} kg'),
                children: [
                  _buildMeasurementRow('Pecho', '${measurement.chest} cm'),
                  _buildMeasurementRow('Brazo', '${measurement.arm} cm'),
                  _buildMeasurementRow('Cintura', '${measurement.waist} cm'),
                  _buildMeasurementRow('Caderas', '${measurement.hips} cm'),
                  _buildMeasurementRow('Muslo', '${measurement.thigh} cm'),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Registrado a las: ${DateFormat.jm().format(measurement.timestamp)}'),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMeasurementRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: const TextStyle(fontSize: 16)), Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))],),);
  }
}
