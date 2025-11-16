import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/routine_provider.dart';
import 'package:myapp/screens/training/edit_routine_screen.dart';
import 'package:myapp/screens/training/workout_history_screen.dart';
import 'package:myapp/screens/training/workout_screen.dart';

class RoutinesScreen extends StatelessWidget {
  const RoutinesScreen({super.key});

  void _navigateAndAddRoutine(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EditRoutineScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: Wrap(
              spacing: 8.0, // Space between chips
              runSpacing: 4.0, // Space between rows of chips
              children: [
                ActionChip(
                  avatar: const Icon(Icons.add, size: 20),
                  label: const Text('Crear Rutina'),
                  onPressed: () => _navigateAndAddRoutine(context),
                ),
                ActionChip(
                  avatar: const Icon(Icons.history, size: 20),
                  label: const Text('Historial'),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const WorkoutHistoryScreen(),
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
                          horizontal: 8.0, vertical: 6.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(routine.name,
                              style: Theme.of(context).textTheme.titleLarge),
                          subtitle: Text(routine.description),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.play_arrow_rounded,
                                    color: Colors.green, size: 30),
                                tooltip: 'Iniciar Entrenamiento',
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          WorkoutScreen(routine: routine),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    color: Colors.blueAccent),
                                tooltip: 'Editar Rutina',
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EditRoutineScreen(routineId: routine.id),
                                    ),
                                  );
                                },
                              ),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'delete') {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext ctx) {
                                        return AlertDialog(
                                          title: const Text('Confirmar Borrado'),
                                          content: Text(
                                              '¿Estás seguro de que quieres eliminar la rutina "${routine.name}"?'),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('Cancelar'),
                                              onPressed: () {
                                                Navigator.of(ctx).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: const Text('Eliminar',
                                                  style: TextStyle(
                                                      color: Colors.red)),
                                              onPressed: () {
                                                provider.deleteRoutine(routine.id);
                                                Navigator.of(ctx).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<String>>[
                                  const PopupMenuItem<String>(
                                    value: 'delete',
                                    child: ListTile(
                                      leading: Icon(Icons.delete_outline,
                                          color: Colors.redAccent),
                                      title: Text('Eliminar'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
