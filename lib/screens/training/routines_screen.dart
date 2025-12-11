import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/routine_provider.dart';
import 'package:myapp/screens/training/edit_routine_screen.dart';
import 'package:myapp/screens/training/preset_routines_screen.dart';
import 'package:myapp/screens/training/workout_history_screen.dart';
import 'package:myapp/screens/training/workout_screen.dart';
import 'package:myapp/utils/clear_routines.dart';
import 'package:myapp/widgets/routine_preview_dialog.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({super.key});

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  @override
  void initState() {
    super.initState();
    // Limpiar rutinas predeterminadas al iniciar
    _clearDefaultRoutines();
  }

  Future<void> _clearDefaultRoutines() async {
    await ClearRoutines.clearDefaultRoutines();
    if (mounted) {
      setState(() {});
    }
  }

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
                  avatar: Icon(PhosphorIcons.star(PhosphorIconsStyle.fill), 
                               color: Colors.amber, size: 20),
                  label: const Text('Rutinas Predeterminadas'),
                  onPressed: () => _navigateToPresetRoutines(context),
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
                debugPrint('[RoutinesScreen] Consumer rebuild - routines count=${provider.routines.length}');
                final userRoutines = provider.routines;
                
                if (userRoutines.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(PhosphorIcons.folderOpen(), size: 80, color: Colors.grey),
                          const SizedBox(height: 24),
                          Text(
                            'No tienes rutinas personalizadas',
                            style: theme.textTheme.titleLarge?.copyWith(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '¡Crea tu primera rutina o elige una predeterminada!',
                            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  itemCount: userRoutines.length,
                  itemBuilder: (context, index) {
                    final routine = userRoutines[index];
                    final exerciseCount = routine.exercises?.length ?? 0;
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          // Mostrar previsualización
                          final result = await showDialog<String>(
                            context: context,
                            builder: (context) => RoutinePreviewDialog(routine: routine),
                          );
                          
                          if (result == 'start' && mounted) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => WorkoutScreen(routine: routine),
                              ),
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(
                              routine.name,
                              style: theme.textTheme.titleLarge,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(routine.description),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      PhosphorIcons.barbell(PhosphorIconsStyle.fill),
                                      size: 14,
                                      color: colorScheme.secondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$exerciseCount ejercicio${exerciseCount != 1 ? 's' : ''}',
                                      style: TextStyle(
                                        color: colorScheme.secondary,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
