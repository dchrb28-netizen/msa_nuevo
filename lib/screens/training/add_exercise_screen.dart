import 'package:flutter/material.dart';
import 'package:myapp/models/exercise.dart';
import 'package:myapp/services/exercise_service.dart';

class AddExerciseScreen extends StatefulWidget {
  const AddExerciseScreen({super.key});

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _typeController = TextEditingController();
  final _muscleGroupController = TextEditingController();
  final _equipmentController = TextEditingController();

  final ExerciseService _exerciseService = ExerciseService();

  void _saveExercise() async {
    if (_formKey.currentState!.validate()) {
      final newExercise = Exercise(
        id: DateTime.now().toString(),
        name: _nameController.text,
        description: _descriptionController.text,
        type: _typeController.text,
        muscleGroup: _muscleGroupController.text,
        equipment: _equipmentController.text,
      );

      await _exerciseService.addExercise(newExercise);

      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Ejercicio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre del Ejercicio'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce un nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(labelText: 'Tipo (e.g., Fuerza, Cardio)'),
              ),
              TextFormField(
                controller: _muscleGroupController,
                decoration: const InputDecoration(labelText: 'Grupo Muscular'),
              ),
              TextFormField(
                controller: _equipmentController,
                decoration: const InputDecoration(labelText: 'Equipamiento'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveExercise,
                child: const Text('Guardar Ejercicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
