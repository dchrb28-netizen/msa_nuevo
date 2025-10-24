import 'package:flutter/material.dart';
import 'package:myapp/models/exercise.dart';

class EditExerciseScreen extends StatefulWidget {
  final Exercise? exercise;

  const EditExerciseScreen({super.key, this.exercise});

  @override
  State<EditExerciseScreen> createState() => _EditExerciseScreenState();
}

class _EditExerciseScreenState extends State<EditExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _muscleGroup;
  late String _equipment;
  late String _description;
  // Add other fields as necessary

  @override
  void initState() {
    super.initState();
    _name = widget.exercise?.name ?? '';
    _muscleGroup = widget.exercise?.muscleGroup ?? '';
    _equipment = widget.exercise?.equipment ?? '';
    _description = widget.exercise?.description ?? '';
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newExercise = Exercise(
        id: widget.exercise?.id ?? DateTime.now().toString(), // Not a great ID, but works for now
        name: _name,
        muscleGroup: _muscleGroup,
        equipment: _equipment,
        description: _description,
        // Initialize other fields
        type: widget.exercise?.type ?? 'strength', 
        measurement: widget.exercise?.measurement ?? 'reps',
      );
      Navigator.of(context).pop(newExercise);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise == null ? 'Crear Ejercicio' : 'Editar Ejercicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Nombre del Ejercicio'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce un nombre';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _muscleGroup,
                decoration: const InputDecoration(labelText: 'Grupo Muscular'),
                 validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce un grupo muscular';
                  }
                  return null;
                },
                onSaved: (value) => _muscleGroup = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _equipment,
                decoration: const InputDecoration(labelText: 'Equipamiento'),
                 validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce el equipamiento';
                  }
                  return null;
                },
                onSaved: (value) => _equipment = value!,
              ),
               const SizedBox(height: 16),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
                onSaved: (value) => _description = value ?? '',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
