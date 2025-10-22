import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/models/body_measurement.dart';
import 'package:intl/intl.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/widgets/body_measurement_form.dart';
import 'package:provider/provider.dart';

class BodyMeasurementTodayView extends StatelessWidget {
  const BodyMeasurementTodayView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Resumen de progreso de peso
        _buildWeightGoalSummary(),

        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 24),

        // 1. Formulario para añadir nueva medición
        const Text('Registra tus medidas de hoy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const BodyMeasurementForm(),
        
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 24),

        // 2. Última medición registrada hoy
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
          return const SizedBox.shrink();
        }

        return ValueListenableBuilder(
          valueListenable: Hive.box<BodyMeasurement>('body_measurements').listenable(),
          builder: (context, Box<BodyMeasurement> box, _) {
            final lastMeasurementWithWeight = box.values.lastWhere(
              (m) => m.weight != null && m.weight! > 0,
              orElse: () => BodyMeasurement(id: '', timestamp: DateTime.now()),
            );
            final lastWeight = lastMeasurementWithWeight.weight;

            if (lastWeight == null) {
              return const Card(
                elevation: 4,
                margin: EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Aún no has registrado ningún peso para ver tu progreso.', textAlign: TextAlign.center,),
                ),
              );
            }
            
            final weightDifference = lastWeight - weightGoal;

            return Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      'Tu Progreso de Peso',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Último peso registrado: ${DateFormat.yMd().format(lastMeasurementWithWeight.timestamp)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    _buildMeasurementRow('Último Peso', '${lastWeight.toStringAsFixed(1)} kg'),
                    const Divider(height: 24),
                    _buildMeasurementRow('Objetivo de Peso', '${weightGoal.toStringAsFixed(1)} kg'),
                    const SizedBox(height: 8),
                    _buildMeasurementRow(
                      'Diferencia',
                      '${weightDifference > 0 ? '+' : ''}${weightDifference.toStringAsFixed(1)} kg para tu meta',
                      color: weightDifference <= 0 ? Colors.green.shade600 : Colors.red.shade600,
                      valueStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: weightDifference <= 0 ? Colors.green.shade600 : Colors.red.shade600,
                      )
                    ),
                  ],
                ),
              ),
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
