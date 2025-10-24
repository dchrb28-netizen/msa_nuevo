import 'package:flutter/material.dart';
import 'package:myapp/models/exercise.dart';
import 'package:myapp/services/exercise_service.dart';

class SelectExerciseScreen extends StatefulWidget {
  const SelectExerciseScreen({super.key});

  @override
  State<SelectExerciseScreen> createState() => _SelectExerciseScreenState();
}

class _SelectExerciseScreenState extends State<SelectExerciseScreen> {
  final ExerciseService _exerciseService = ExerciseService();
  List<Exercise> _allExercises = [];
  List<Exercise> _filteredExercises = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExercises();
    _searchController.addListener(() {
      _filterExercises();
    });
  }

  Future<void> _loadExercises() async {
    try {
      final exercises = await _exerciseService.loadExercises();
      if (!mounted) return;
      setState(() {
        _allExercises = exercises;
        _filteredExercises = exercises;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los ejercicios: $e')),
      );
    }
  }

  void _filterExercises() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredExercises = _allExercises.where((exercise) {
        return exercise.name.toLowerCase().contains(query) ||
               exercise.muscleGroup.toLowerCase().contains(query);
      }).toList();
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
      appBar: AppBar(
        title: const Text('Seleccionar Ejercicio'),
      ),
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
          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _filteredExercises.length,
                itemBuilder: (context, index) {
                  final exercise = _filteredExercises[index];
                  return ListTile(
                    title: Text(exercise.name),
                    subtitle: Text('${exercise.muscleGroup} | ${exercise.equipment}'),
                    onTap: () {
                      Navigator.of(context).pop(exercise); // Return the selected exercise
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
