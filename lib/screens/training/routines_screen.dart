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
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const EditRoutineScreen()),
    );
  }

  void _navigateToPresetRoutines(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const PresetRoutinesScreen()),
    );
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
              spacing: 8.0,
              runSpacing: 4.0,
              children: [
                ActionChip(
                  avatar: Icon(PhosphorIcons.plusCircle(PhosphorIconsStyle.fill), 
                               color: colorScheme.primary, size: 20),
                  label: const Text('Crear Rutina'),
                  onPressed: () => _navigateAndAddRoutine(context),
                ),
                ActionChip(
                  avatar: Icon(PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.fill), 
                               color: colorScheme.secondary, size: 20),
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
                final userRoutines = provider.routines;
                
                return ListView(
                  children: [
                    // Sección: Rutinas Predeterminadas
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Row(
                        children: [
                          Icon(PhosphorIcons.star(PhosphorIconsStyle.fill), 
                               color: Colors.amber, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Rutinas Predeterminadas',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        leading: Icon(PhosphorIcons.books(PhosphorIconsStyle.fill), 
                                     color: Colors.deepPurple),
                        title: const Text('Ver Rutinas Predefinidas'),
                        subtitle: const Text('8 rutinas profesionales listas para usar'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => _navigateToPresetRoutines(context),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    const Divider(),
                    
                    // Sección: Mis Rutinas
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Row(
                        children: [
                          Icon(PhosphorIcons.user(PhosphorIconsStyle.fill), 
                               color: colorScheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Mis Rutinas',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    if (userRoutines.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(PhosphorIcons.folderOpen(), size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                'No tienes rutinas personalizadas',
                                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '¡Crea tu primera rutina!',
                                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...userRoutines.map((routine) {
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
                                          builder: (context) => WorkoutScreen(routine: routine),
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
                                              title: const Text('Confirmar Borrado'),
                                              content: Text(
                                                '¿Estás seguro de que quieres eliminar la rutina "\${routine.name}"?',
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
                                                    style: TextStyle(color: colorScheme.error),
                                                  ),
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
                      }).toList(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
