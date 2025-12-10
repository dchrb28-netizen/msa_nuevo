import 'package:flutter/material.dart';
import 'package:myapp/models/routine.dart';
import 'package:myapp/providers/routine_provider.dart';
import 'package:myapp/screens/training/workout_screen.dart';
import 'package:provider/provider.dart';

class StartWorkoutScreen extends StatelessWidget {
  const StartWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Consumer<RoutineProvider>(
        builder: (context, provider, child) {
          if (provider.routines.isEmpty) {
            return const Center(
              child: Text('No hay rutinas disponibles. Crea una primero.'),
            );
          }
          return ListView.builder(
            itemCount: provider.routines.length,
            itemBuilder: (context, index) {
              final Routine routine = provider.routines[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    routine.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  subtitle: Text(routine.description),
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => WorkoutScreen(routine: routine),
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
