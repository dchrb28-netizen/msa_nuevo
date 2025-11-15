import 'package:flutter/material.dart';
import 'package:myapp/models/exercise.dart';
import 'package:myapp/providers/exercise_provider.dart';
import 'package:myapp/screens/training/edit_exercise_screen.dart';
import 'package:myapp/screens/training/exercise_detail_screen.dart';
import 'package:provider/provider.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  String _searchQuery = '';

  void _navigateToDetail(Exercise exercise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseDetailScreen(exercise: exercise),
      ),
    );
  }

  Future<void> _navigateAndSaveChanges(Exercise? exercise) async {
    final exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditExerciseScreen(exercise: exercise),
      ),
    );

    if (result is Exercise) {
      if (exercise == null) {
        await exerciseProvider.addExercise(result);
      } else {
        await exerciseProvider.updateExercise(result);
      }
    }
  }

  Future<void> _deleteExercise(Exercise exercise) async {
    final exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Ejercicio'),
        content: const Text('¿Estás seguro de que quieres eliminar este ejercicio?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await exerciseProvider.deleteExercise(exercise.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ejercicio eliminado correctamente')),
      );
    }
  }

  IconData _getIconForMuscleGroup(String muscleGroup) {
    switch (muscleGroup.toLowerCase()) {
      case 'pecho':
        return Icons.fitness_center;
      case 'piernas':
        return Icons.airline_seat_legroom_extra;
      case 'espalda':
        return Icons.back_hand;
      case 'brazos':
        return Icons.fitness_center;
      case 'abdomen':
        return Icons.self_improvement;
      case 'glúteos':
        return Icons.self_improvement;
      default:
        return Icons.fitness_center;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Buscar ejercicio',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: Consumer<ExerciseProvider>(
              builder: (context, provider, child) {
                if (provider.exercises.isEmpty) {
                  return const Center(child: Text("No hay ejercicios. ¡Añade uno nuevo!"));
                }

                final filteredExercises = provider.exercises.where((exercise) {
                  final query = _searchQuery.toLowerCase();
                  return exercise.name.toLowerCase().contains(query) ||
                      exercise.muscleGroup.toLowerCase().contains(query) ||
                      exercise.equipment.toLowerCase().contains(query);
                }).toList();

                if (filteredExercises.isEmpty) {
                  return const Center(child: Text('No se encontraron ejercicios.'));
                }

                final groupedExercises = <String, List<Exercise>>{};
                for (final exercise in filteredExercises) {
                  if (groupedExercises.containsKey(exercise.muscleGroup)) {
                    groupedExercises[exercise.muscleGroup]!.add(exercise);
                  } else {
                    groupedExercises[exercise.muscleGroup] = [exercise];
                  }
                }

                final muscleGroups = groupedExercises.keys.toList()..sort();

                return ListView.builder(
                  itemCount: muscleGroups.length,
                  itemBuilder: (context, index) {
                    final muscleGroup = muscleGroups[index];
                    final exercisesInGroup = groupedExercises[muscleGroup]!;

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: ExpansionTile(
                        leading: Icon(
                          _getIconForMuscleGroup(muscleGroup),
                          size: 40,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(
                          muscleGroup,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        children: exercisesInGroup.map((exercise) {
                          return ListTile(
                            leading: exercise.imageUrl != null && exercise.imageUrl!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network(
                                      exercise.imageUrl!,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => 
                                        const Icon(Icons.image, size: 30),
                                    ),
                                  )
                                : const Icon(Icons.image, size: 30),
                            title: Text(exercise.name, style: theme.textTheme.titleMedium),
                            subtitle: Text(exercise.equipment, style: theme.textTheme.bodyMedium),
                            onTap: () => _navigateToDetail(exercise),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blueGrey),
                                  onPressed: () => _navigateAndSaveChanges(exercise),
                                  tooltip: 'Editar Ejercicio',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () => _deleteExercise(exercise),
                                  tooltip: 'Eliminar Ejercicio',
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateAndSaveChanges(null),
        icon: const Icon(Icons.add),
        label: const Text('Añadir Ejercicio'),
        tooltip: 'Añadir un nuevo ejercicio',
      ),
    );
  }
}
