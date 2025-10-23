import 'package:flutter/material.dart';
import 'package:myapp/models/exercise.dart';

class SelectExerciseScreen extends StatefulWidget {
  const SelectExerciseScreen({super.key});

  @override
  State<SelectExerciseScreen> createState() => _SelectExerciseScreenState();
}

class _SelectExerciseScreenState extends State<SelectExerciseScreen> {
  // TODO: Replace with a real list of exercises from a provider/service
  final List<Exercise> _predefinedExercises = [
    Exercise(id: '1', name: 'Press de Banca', type: 'strength', description: 'Ejercicio de pecho con barra.', equipment: 'Barra', muscleGroup: 'Pecho'),
    Exercise(id: '2', name: 'Sentadillas', type: 'strength', description: 'Ejercicio de piernas con barra.', equipment: 'Barra', muscleGroup: 'Piernas'),
    Exercise(id: '3', name: 'Correr en cinta', type: 'cardio', description: 'Cardio en cinta.', equipment: 'Cinta de correr', muscleGroup: 'Cardio'),
  ];

  List<Exercise> _filteredExercises = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredExercises = _predefinedExercises;
    _searchController.addListener(() {
      _filterExercises();
    });
  }

  void _filterExercises() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredExercises = _predefinedExercises.where((exercise) {
        return exercise.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Ejercicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Crear Nuevo Ejercicio',
            onPressed: () {
              // TODO: Navigate to a form to create a new exercise
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar ejercicio',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
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
