import 'package:flutter/material.dart';
import 'package:myapp/models/exercise.dart';
import 'package:myapp/screens/training/exercise_detail_screen.dart';
import 'package:myapp/services/exercise_service.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  // Make the state public
  State<ExerciseLibraryScreen> createState() => ExerciseLibraryScreenState();
}

// Make the state class public
class ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  final ExerciseService _exerciseService = ExerciseService();
  late Future<List<Exercise>> _exercisesFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  void _loadExercises() {
    _exercisesFuture = _exerciseService.loadExercises();
  }

  // Public method to be called from the parent widget
  void refresh() {
    setState(() {
      _loadExercises();
    });
  }

  IconData _getIconForMuscleGroup(String muscleGroup) {
    switch (muscleGroup.toLowerCase()) {
      case 'pecho':
        return Icons.fitness_center;
      case 'piernas':
        return Icons.airline_seat_legroom_extra;
      case 'espalda':
        return Icons.back_hand;
      case 'hombros':
        return Icons.fitness_center;
      case 'brazos':
        return Icons.fitness_center;
      case 'abdomen':
        return Icons.self_improvement;
      default:
        return Icons.fitness_center;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
          child: FutureBuilder<List<Exercise>>(
            future: _exercisesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error al cargar los ejercicios: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No hay ejercicios en la biblioteca.'));
              }

              final filteredExercises = snapshot.data!.where((exercise) {
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

              final muscleGroups = groupedExercises.keys.toList();

              return ListView.builder(
                itemCount: muscleGroups.length,
                itemBuilder: (context, index) {
                  final muscleGroup = muscleGroups[index];
                  final exercisesInGroup = groupedExercises[muscleGroup]!;

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ExpansionTile(
                      leading: Icon(_getIconForMuscleGroup(muscleGroup), size: 40),
                      title: Text(
                        muscleGroup,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      children: exercisesInGroup.map((exercise) {
                        return ListTile(
                          title: Text(exercise.name),
                          subtitle: Text(exercise.equipment),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ExerciseDetailScreen(exercise: exercise),
                              ),
                            );
                          },
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
