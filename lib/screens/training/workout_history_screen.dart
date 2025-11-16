import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/workout_session.dart';
import 'package:myapp/providers/workout_history_provider.dart';
import 'package:provider/provider.dart';

class WorkoutHistoryScreen extends StatelessWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Entrenamientos'),
      ),
      body: Consumer<WorkoutHistoryProvider>(
        builder: (context, historyProvider, child) {
          final history = historyProvider.workoutHistory;

          if (history.isEmpty) {
            return const Center(
              child: Text(
                'Aún no has completado ningún entrenamiento.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // Mostrar el más reciente primero
          final reversedHistory = history.reversed.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: reversedHistory.length,
            itemBuilder: (context, index) {
              final session = reversedHistory[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  title: Text(
                    session.routineName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat.yMMMMEEEEd('es').add_jm().format(session.date),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                     _navigateToSessionDetail(context, session);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _navigateToSessionDetail(BuildContext context, WorkoutSession session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutSessionDetailScreen(session: session),
      ),
    );
  }
}

class WorkoutSessionDetailScreen extends StatelessWidget {
  final WorkoutSession session;

  const WorkoutSessionDetailScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(session.routineName),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(25.0),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              DateFormat.yMMMMEEEEd('es').add_jm().format(session.date),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).appBarTheme.foregroundColor?.withOpacity(0.8)),
            ),
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: session.performedExercises.length,
        separatorBuilder: (context, index) => const Divider(height: 32),
        itemBuilder: (context, index) {
          final performedExercise = session.performedExercises[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                performedExercise.exerciseName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...List.generate(performedExercise.sets.length, (setIndex) {
                final set = performedExercise.sets[setIndex];
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, size: 18, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Set ${setIndex + 1}: ${set.reps} reps con ${set.weight} kg',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
