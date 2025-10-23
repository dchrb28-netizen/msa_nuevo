
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/routine_log.dart';

class WorkoutLogDetailScreen extends StatelessWidget {
  final RoutineLog log;

  const WorkoutLogDetailScreen({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(log.routineName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat.yMMMMd('es').add_jm().format(log.date),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (log.duration != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Duración: ${_formatDuration(log.duration!)}',
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
                    Text('Notas:', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(log.notes!, style: Theme.of(context).textTheme.bodyLarge),
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

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }
}
