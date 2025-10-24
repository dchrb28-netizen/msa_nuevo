import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/models/body_measurement.dart';
import 'package:intl/intl.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/widgets/body_measurement_form.dart';
import 'package:myapp/widgets/weight_progress_card.dart'; // Import the new widget
import 'package:provider/provider.dart';

class BodyMeasurementTodayView extends StatelessWidget {
  const BodyMeasurementTodayView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // 1. Weight Goal Summary (now using the new widget)
        _buildWeightGoalSummary(),

        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 24),

        // 2. Form to add a new measurement
        const Text('Registra tus medidas de hoy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const BodyMeasurementForm(),
        
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 24),

        // 3. Last measurement registered today
        const Text('Última medición de hoy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildLastMeasurementCard(),
      ],
    );
  }

  Widget _buildWeightGoalSummary() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;
        final weightGoal = user?.weightGoal;

        if (weightGoal == null || weightGoal <= 0) {
          return const SizedBox.shrink(); // No goal set, show nothing.
        }

        return ValueListenableBuilder(
          valueListenable: Hive.box<BodyMeasurement>('body_measurements').listenable(),
          builder: (context, Box<BodyMeasurement> box, _) {
            final measurementsWithWeight = box.values.where((m) => m.weight != null && m.weight! > 0).toList();
            BodyMeasurement? lastMeasurementWithWeight;
            if(measurementsWithWeight.isNotEmpty) {
                measurementsWithWeight.sort((a,b) => b.timestamp.compareTo(a.timestamp));
                lastMeasurementWithWeight = measurementsWithWeight.first;
            }
            
            final lastWeight = lastMeasurementWithWeight?.weight;

            // Use the new WeightProgressCard widget
            return WeightProgressCard(
              lastWeight: lastWeight,
              weightGoal: weightGoal,
            );
          },
        );
      },
    );
  }

  Widget _buildLastMeasurementCard() {
     return ValueListenableBuilder(
          valueListenable: Hive.box<BodyMeasurement>('body_measurements').listenable(),
          builder: (context, Box<BodyMeasurement> box, _) {
            final today = DateTime.now();
            final todaysMeasurements = box.values.where((m) {
              return m.timestamp.year == today.year &&
                  m.timestamp.month == today.month &&
                  m.timestamp.day == today.day;
            }).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));

            if (todaysMeasurements.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Aún no has registrado medidas hoy.'),
                ),
              );
            }
            
            final lastMeasurement = todaysMeasurements.first;

            return Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Medición a las ${DateFormat.jm().format(lastMeasurement.timestamp)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const Divider(height: 20),
                      if (lastMeasurement.weight != null) _buildMeasurementRow('Peso', '${lastMeasurement.weight} kg'),
                      if (lastMeasurement.chest != null) _buildMeasurementRow('Pecho', '${lastMeasurement.chest} cm'),
                      if (lastMeasurement.arm != null) _buildMeasurementRow('Brazo', '${lastMeasurement.arm} cm'),
                      if (lastMeasurement.waist != null) _buildMeasurementRow('Cintura', '${lastMeasurement.waist} cm'),
                      if (lastMeasurement.hips != null) _buildMeasurementRow('Caderas', '${lastMeasurement.hips} cm'),
                      if (lastMeasurement.thigh != null) _buildMeasurementRow('Muslo', '${lastMeasurement.thigh} cm'),
                    ],
                  ),
                ),
              );
          },
        );
  }

  Widget _buildMeasurementRow(String label, String value, {Color? color, TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: valueStyle ?? TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          )
        ],
      ),
    );
  }
}
