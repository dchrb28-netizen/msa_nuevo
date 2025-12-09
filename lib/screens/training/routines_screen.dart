import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/routine_provider.dart';
import 'package:myapp/screens/training/edit_routine_screen.dart';
import 'package:myapp/screens/training/preset_routines_screen.dart';
import 'package:myapp/screens/training/workout_history_screen.dart';
import 'package:myapp/screens/training/workout_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class RoutinesScreen extends StatelessWidget {
  const RoutinesScreen({super.key});

  void _navigateAndAddRoutine(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const EditRoutineScreen()));
  }

  void _navigateToPresetRoutines(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const PresetRoutinesScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 12.0,
            ),
            child: Wrap(
              spacing: 8.0, // Space between chips
              runSpacing: 4.0, // Space between rows of chips
              children: [
                ActionChip(
                  avatar: Icon(PhosphorIcons.plusCircle(PhosphorIconsStyle.fill), color: colorScheme.primary, size: 20),
                  label: const Text('Crear Rutina'),
                  onPressed: () => _navigateAndAddRoutine(context),
                ),
                ActionChip(
                  avatar: Icon(PhosphorIcons.books(PhosphorIconsStyle.fill), color: Colors.deepPurple, size: 20),
                  label: const Text('Rutinas Predefinidas'),
                  onPressed: () => _navigateToPresetRoutines(context),
                ),
                ActionChip(
                  avatar: Icon(PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.fill), color: colorScheme.secondary, size: 20),
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
                        horizontal: 8.0,
                        vertical: 6.0,
                      ),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(
                            routine.name,
                            style: theme.textTheme.titleLarge,
                          ),
                          subtitle: Text(routine.description),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  PhosphorIcons.play(PhosphorIconsStyle.fill),
                                  color: colorScheme.primary,
                                  size: 30,
                                ),
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
                                icon: Icon(
                                  PhosphorIcons.pencilSimple(PhosphorIconsStyle.regular),
                                  color: colorScheme.secondary,
                                ),
                                tooltip: 'Editar Rutina',
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => EditRoutineScreen(
                                        routineId: routine.id,
                                      ),
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
                                          title: const Text(
                                            'Confirmar Borrado',
                                          ),
                                          content: Text(
                                            '¿Estás seguro de que quieres eliminar la rutina "${routine.name}"?',
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('Cancelar'),
                                              onPressed: () {
                                                Navigator.of(ctx).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: Text(
                                                'Eliminar',
                                                style: TextStyle(
                                                  color: colorScheme.error,
                                                ),
                                              ),
                                              onPressed: () {
                                                provider.deleteRoutine(
                                                  routine.id,
                                                );
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
                                      PopupMenuItem<String>(
                                        value: 'delete',
                                        child: ListTile(
                                          leading: Icon(
                                            PhosphorIcons.trash(PhosphorIconsStyle.regular),
                                            color: colorScheme.error,
                                          ),
                                          title: Text(
                                            'Eliminar',
                                            style: TextStyle(color: colorScheme.error),
                                            ),
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
