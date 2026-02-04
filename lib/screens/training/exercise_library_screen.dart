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
  Set<String> _selectedMuscleGroups = {}; // Multi-selección de músculos
  final List<String> _difficultyLevels = [
    'Todos',
    'Principiante',
    'Intermedio',
    'Avanzado',
  ];

  final Map<String, IconData> _difficultyIcons = {
    'Todos': Icons.done_all,
    'Principiante': Icons.trending_up,
    'Intermedio': Icons.bar_chart,
    'Avanzado': Icons.whatshot,
  };

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
        return Icons.favorite;
      case 'piernas':
        return Icons.directions_run;
      case 'espalda':
        return Icons.architecture;
      case 'brazos':
        return Icons.fitness_center;
      case 'abdomen':
        return Icons.shield;
      case 'glúteos':
        return Icons.emoji_nature;
      case 'hombros':
        return Icons.accessibility;
      case 'cardio':
        return Icons.favorite_border;
      case 'yoga':
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

  void _showFiltersModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final exerciseProvider = Provider.of<ExerciseProvider>(context);
            final allMuscleGroups = <String>{};
            for (var exercise in exerciseProvider.exercises) {
              if (exercise.muscleGroup != null) {
                allMuscleGroups.add(exercise.muscleGroup!);
              }
            }
            final sortedMuscles = allMuscleGroups.toList()..sort();

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Filtrar por Dificultad',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12.0,
                        crossAxisSpacing: 12.0,
                        childAspectRatio: 2.5,
                      ),
                      itemCount: _difficultyLevels.length,
                      itemBuilder: (context, index) {
                        final level = _difficultyLevels[index];
                        final isSelected = _selectedDifficulty == level;
                        final icon = _difficultyIcons[level] ?? Icons.fitness_center;
                        return _FilterButton(
                          label: level,
                          icon: icon,
                          isSelected: isSelected,
                          onTap: () {
                            setModalState(() {
                              setState(() {
                                _selectedDifficulty = level;
                              });
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Filtrar por Grupo Muscular',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12.0,
                        crossAxisSpacing: 12.0,
                        childAspectRatio: 2.5,
                      ),
                      itemCount: sortedMuscles.length,
                      itemBuilder: (context, index) {
                        final muscle = sortedMuscles[index];
                        final isSelected = _selectedMuscleGroups.contains(muscle);
                        final icon = _getIconForMuscleGroup(muscle);
                        return _FilterButton(
                          label: muscle,
                          icon: icon,
                          isSelected: isSelected,
                          onTap: () {
                            setModalState(() {
                              setState(() {
                                if (isSelected) {
                                  _selectedMuscleGroups.remove(muscle);
                                } else {
                                  _selectedMuscleGroups.add(muscle);
                                }
                              });
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Listo'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
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
              const SizedBox(width: 8),
              FloatingActionButton.small(
                onPressed: () => _showFiltersModal(context),
                child: const Icon(Icons.filter_list),
              ),
            ],
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

              // Aplicar filtro de grupos musculares si hay seleccionados
              final exercisesAfterMuscleFilter = _selectedMuscleGroups.isEmpty
                  ? filteredExercises
                  : filteredExercises.where((exercise) {
                      return _selectedMuscleGroups.contains(exercise.muscleGroup);
                    }).toList();

              if (exercisesAfterMuscleFilter.isEmpty) {
                return const Center(
                  child: Text('No se encontraron ejercicios.'),
                );
              }

              final groupedExercises = <String, List<Exercise>>{};
              for (final exercise in exercisesAfterMuscleFilter) {
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
                                exercise.imageUrl!.isNotEmpty &&
                                !exercise.imageUrl!
                                  .toLowerCase()
                                  .endsWith('.gif')
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

class _FilterButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        splashColor: colorScheme.primary.withAlpha(51),
        highlightColor: colorScheme.primary.withAlpha(26),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : colorScheme.surface,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : Theme.of(context).dividerColor,
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withAlpha(77),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color:
                    isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                size: 18,
              ),
              const SizedBox(width: 8.0),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

