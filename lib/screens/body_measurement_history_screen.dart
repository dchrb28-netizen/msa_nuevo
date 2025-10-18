import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/body_measurement.dart';

class BodyMeasurementHistoryScreen extends StatelessWidget {
  const BodyMeasurementHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Box<BodyMeasurement> measurementBox = Hive.box<BodyMeasurement>('body_measurements');

    return ValueListenableBuilder(
      valueListenable: measurementBox.listenable(),
      builder: (context, Box<BodyMeasurement> box, _) {
        final allLogs = box.values.toList();

        return ListView.builder(
          itemCount: allLogs.length,
          itemBuilder: (context, index) {
            final log = allLogs[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ExpansionTile(
                title: Text('Medición - ${DateFormat.yMMMd('es').format(log.timestamp)}', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        if (log.weight != null) _buildMeasurementRow('Peso', log.weight, 'kg'),
                        if (log.height != null) _buildMeasurementRow('Altura', log.height, 'cm'),
                        if (log.waist != null) _buildMeasurementRow('Cintura', log.waist, 'cm'),
                        if (log.hips != null) _buildMeasurementRow('Caderas', log.hips, 'cm'),
                        if (log.chest != null) _buildMeasurementRow('Pecho', log.chest, 'cm'),
                        if (log.arm != null) _buildMeasurementRow('Brazo', log.arm, 'cm'),
                        if (log.thigh != null) _buildMeasurementRow('Muslo', log.thigh, 'cm'),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMeasurementRow(String label, double? value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.lato()),
          Text('$value $unit', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
