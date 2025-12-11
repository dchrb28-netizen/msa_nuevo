import 'package:flutter/material.dart';
import 'package:myapp/models/routine.dart';
import 'package:myapp/providers/routine_provider.dart';
import 'package:myapp/screens/training/create_routine_screen.dart';
import 'package:myapp/screens/training/workout_screen.dart';
import 'package:provider/provider.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final routineProvider = Provider.of<RoutineProvider>(context);
    final routines = routineProvider.routines;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateRoutineScreen(),
            ),
          );
        },
        label: const Text('Crear Rutina'),
        icon: const Icon(Icons.add),
      ),
      body: routines.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.fitness_center_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No hay rutinas',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Crea tu primera rutina de entrenamiento para empezar a registrar tu progreso.',
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateRoutineScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Crea tu primera rutina'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: routines.length,
              itemBuilder: (context, index) {
                final routine = routines[index];
                return _buildRoutineCard(context, routine);
              },
            ),
    );
  }

  Widget _buildRoutineCard(BuildContext context, Routine routine) {
    final int exerciseCount = routine.exercises?.length ?? 0;

    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      child: InkWell(
        onTap: () {
          // Iniciar entrenamiento
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkoutScreen(routine: routine),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                routine.name,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '$exerciseCount ${exerciseCount == 1 ? 'ejercicio' : 'ejercicios'}',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkoutScreen(routine: routine),
                      ),
                    );
                  },
                  child: const Text('Empezar Entrenamiento'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
