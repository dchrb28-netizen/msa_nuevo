import 'package:flutter/material.dart';
import 'package:myapp/providers/exercise_provider.dart';
import 'package:provider/provider.dart';

class SelectExerciseScreen extends StatefulWidget {
  const SelectExerciseScreen({super.key});

  @override
  State<SelectExerciseScreen> createState() => _SelectExerciseScreenState();
}

class _SelectExerciseScreenState extends State<SelectExerciseScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar por nombre o músculo',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: Consumer<ExerciseProvider>(
              builder: (context, exerciseProvider, child) {
                final allExercises = exerciseProvider.exercises;
                final filteredExercises = allExercises.where((exercise) {
                  final query = _searchQuery.toLowerCase();
                  final nameMatch = exercise.name.toLowerCase().contains(query);
                  final muscleMatch =
                      (exercise.muscleGroup?.toLowerCase() ?? '').contains(
                        query,
                      );
                  return nameMatch || muscleMatch;
                }).toList();

                if (filteredExercises.isEmpty) {
                  return const Center(
                    child: Text(
                      'No se encontraron ejercicios. Puedes añadirlos en la biblioteca.',
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = filteredExercises[index];
                    return ListTile(
                      title: Text(exercise.name),
                      subtitle: Text(
                        '${exercise.muscleGroup ?? 'N/A'} | ${exercise.equipment ?? 'N/A'}',
                      ),
                      onTap: () {
                        Navigator.of(context).pop(exercise);
                      },
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
