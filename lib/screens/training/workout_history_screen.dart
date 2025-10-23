import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/routine_log.dart';
import 'package:myapp/providers/routine_provider.dart';
import 'package:myapp/screens/training/workout_log_detail_screen.dart';
import 'package:provider/provider.dart';

class WorkoutHistoryScreen extends StatelessWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Entrenamientos'),
      ),
      body: Consumer<RoutineProvider>(
        builder: (context, provider, child) {
          final logs = provider.routineLogs;

          if (logs.isEmpty) {
            return const Center(
              child: Text('Aún no has registrado ningún entrenamiento.'),
            );
          }

          // Sort logs by date, most recent first
          logs.sort((a, b) => b.date.compareTo(a.date));

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final RoutineLog log = logs[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(log.routineName),
                  subtitle: Text(DateFormat.yMMMd('es').add_jm().format(log.date)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => WorkoutLogDetailScreen(log: log),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
