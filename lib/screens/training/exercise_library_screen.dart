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
  String _selectedDifficulty = 'Todos';
  final List<String> _difficultyLevels = [
    'Todos',
    'Principiante',
    'Intermedio',
    'Avanzado',
  ];

  void _navigateToDetail(Exercise exercise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseDetailScreen(exercise: exercise),
      ),
    );
  }

  Future<void> _navigateAndSaveChanges(Exercise? exercise) async {
    final exerciseProvider = Provider.of<ExerciseProvider>(
      context,
      listen: false,
    );

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
    final exerciseProvider = Provider.of<ExerciseProvider>(
      context,
      listen: false,
    );

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Ejercicio'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar este ejercicio?',
        ),
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

  Color _getDifficultyColor(String? difficulty) {
    switch (difficulty) {
      case 'Principiante':
        return Colors.green.shade600;
      case 'Intermedio':
        return Colors.orange.shade600;
      case 'Avanzado':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: _difficultyLevels.map((level) {
              return ChoiceChip(
                label: Text(level),
                selected: _selectedDifficulty == level,
                onSelected: (selected) {
                  setState(() {
                    _selectedDifficulty = level;
                  });
                },
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: Consumer<ExerciseProvider>(
            builder: (context, provider, child) {
              if (provider.exercises.isEmpty) {
                return const Center(
                  child: Text("No hay ejercicios. ¡Añade uno nuevo!"),
                );
              }

              final searchedExercises = provider.exercises.where((exercise) {
                final query = _searchQuery.toLowerCase();
                return exercise.name.toLowerCase().contains(query) ||
                    (exercise.muscleGroup?.toLowerCase() ?? '').contains(
                      query,
                    ) ||
                    (exercise.equipment?.toLowerCase() ?? '').contains(query);
              }).toList();

              final filteredExercises = _selectedDifficulty == 'Todos'
                  ? searchedExercises
                  : searchedExercises.where((exercise) {
                      return exercise.difficulty == _selectedDifficulty;
                    }).toList();

              if (filteredExercises.isEmpty) {
                return const Center(
                  child: Text('No se encontraron ejercicios.'),
                );
              }

              final groupedExercises = <String, List<Exercise>>{};
              for (final exercise in filteredExercises) {
                final muscleGroup = exercise.muscleGroup ?? 'Otros';
                if (groupedExercises.containsKey(muscleGroup)) {
                  groupedExercises[muscleGroup]!.add(exercise);
                } else {
                  groupedExercises[muscleGroup] = [exercise];
                }
              }

              final muscleGroups = groupedExercises.keys.toList()..sort();

              return ListView.builder(
                padding: const EdgeInsets.only(
                  bottom: 80.0,
                ), // Padding for the main FAB
                itemCount: muscleGroups.length,
                itemBuilder: (context, index) {
                  final muscleGroup = muscleGroups[index];
                  final exercisesInGroup = groupedExercises[muscleGroup]!;

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                          isThreeLine: true,
                          leading: exercise.imageUrl != null &&
                                  exercise.imageUrl!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: exercise.imageUrl!.startsWith('http')
                                      ? Image.network(
                                          exercise.imageUrl!,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return SizedBox(
                                              width: 50,
                                              height: 50,
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  value: loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                                ),
                                              ),
                                            );
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                            width: 50,
                                            height: 50,
                                            color: theme
                                                .colorScheme.surfaceContainer,
                                            child: Icon(
                                              Icons.fitness_center,
                                              size: 30,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                        )
                                      : Image.asset(
                                          exercise.imageUrl!,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                            width: 50,
                                            height: 50,
                                            color: theme
                                                .colorScheme.surfaceContainer,
                                            child: Icon(
                                              Icons.fitness_center,
                                              size: 30,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                )
                              : Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surfaceContainer,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Icon(
                                    Icons.fitness_center,
                                    size: 30,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                          title: Text(
                            exercise.name,
                            style: theme.textTheme.titleMedium,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exercise.equipment ?? 'N/A',
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 4),
                              Chip(
                                label: Text(exercise.difficulty ?? 'N/A'),
                                backgroundColor: _getDifficultyColor(
                                  exercise.difficulty,
                                ),
                                labelStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 0,
                                ),
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            ],
                          ),
                          onTap: () => _navigateToDetail(exercise),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blueGrey,
                                ),
                                onPressed: () =>
                                    _navigateAndSaveChanges(exercise),
                                tooltip: 'Editar Ejercicio',
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                ),
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
    );
  }
}
