import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/routine_log.dart';
import 'package:myapp/services/time_format_service.dart';
import 'package:provider/provider.dart';

class WorkoutLogDetailScreen extends StatelessWidget {
  final RoutineLog log;

  const WorkoutLogDetailScreen({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${DateFormat.yMMMMd('es').format(log.date)} ${Provider.of<TimeFormatService>(context).formatTime(log.date)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (log.durationInMinutes > 0) // Condición actualizada
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Duración: ${_formatDuration(log.durationInMinutes)}', // Campo y función actualizados
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 24),
            if (log.notes != null && log.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notas:',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      log.notes!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            Text('Ejercicios:', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...log.exerciseLogs.map((exerciseLog) {
              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exerciseLog.exercise.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      DataTable(
                        columns: const [
                          DataColumn(label: Text('Serie')),
                          DataColumn(label: Text('Reps')),
                          DataColumn(label: Text('Peso')),
                        ],
                        rows: exerciseLog.sets.asMap().entries.map((entry) {
                          final index = entry.key;
                          final set = entry.value;
                          return DataRow(
                            cells: [
                              DataCell(Text('${index + 1}')),
                              DataCell(Text('${set.reps}')),
                              DataCell(Text('${set.weight} kg')),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // La función ahora acepta un entero (minutos) y devuelve un string formateado
  String _formatDuration(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}
