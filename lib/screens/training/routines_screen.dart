import 'package:flutter/material.dart';
import 'package:myapp/screens/training/exercise_library_screen.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/routine_provider.dart';
import 'package:myapp/screens/training/edit_routine_screen.dart';
import 'package:myapp/screens/training/start_workout_screen.dart';
import 'package:myapp/screens/training/workout_history_screen.dart'; // Import history screen

class RoutinesScreen extends StatelessWidget {
  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rutinas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
              child: Wrap(
                spacing: 8.0,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.history),
                    label: const Text('Historial'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const WorkoutHistoryScreen(),
                        ),
                      );
                    },
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.add),
                    label: const Text('Crear Rutina'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const EditRoutineScreen(),
                        ),
                      );
                    },
                  ),
                   ActionChip(
                    avatar: const Icon(Icons.library_books),
                    label: const Text('Biblioteca de Ejercicios'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ExerciseLibraryScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: Consumer<RoutineProvider>(
                builder: (context, provider, child) {
                  final routines = provider.routines;
                  if (routines.isEmpty) {
                    return const Center(
                      child: Text('No tienes rutinas todavía. ¡Crea una!'),
                    );
                  }
                  return ListView.builder(
                    itemCount: routines.length,
                    itemBuilder: (context, index) {
                      final routine = routines[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        child: ListTile(
                          title: Text(routine.name),
                          subtitle: Text(routine.description),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () {
                              // TODO: Implement delete confirmation dialog
                              provider.deleteRoutine(routine.id);
                            },
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditRoutineScreen(routine: routine),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const StartWorkoutScreen(),
            ),
          );
        },
        label: const Text('Empezar Entreno'),
        icon: const Icon(Icons.play_arrow),
      ),
    );
  }
}
