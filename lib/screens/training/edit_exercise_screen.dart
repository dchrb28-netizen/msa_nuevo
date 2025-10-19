import 'package:flutter/material.dart';
import 'package:myapp/models/exercise.dart';
import 'package:myapp/services/exercise_service.dart';

class EditExerciseScreen extends StatefulWidget {
  final Exercise exercise;

  const EditExerciseScreen({super.key, required this.exercise});

  @override
  State<EditExerciseScreen> createState() => _EditExerciseScreenState();
}

class _EditExerciseScreenState extends State<EditExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedMuscleGroup;
  String? _selectedEquipment;
  String? _selectedType;

  final _muscleGroups = ['Pecho', 'Espalda', 'Piernas', 'Hombros', 'Brazos', 'Abdominales', 'Cuerpo Completo'];
  final _equipmentTypes = ['Barra', 'Mancuernas', 'Peso Corporal', 'Máquina', 'Kettlebell', 'Otro'];
  final _exerciseTypes = ['Fuerza', 'Cardio', 'Flexibilidad', 'Equilibrio'];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.exercise.name;
    _descriptionController.text = widget.exercise.description;
    _selectedMuscleGroup = widget.exercise.muscleGroup;
    _selectedEquipment = widget.exercise.equipment;
    _selectedType = widget.exercise.type;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final updatedExercise = Exercise(
        id: widget.exercise.id,
        name: _nameController.text,
        type: _selectedType!,
        muscleGroup: _selectedMuscleGroup!,
        equipment: _selectedEquipment!,
        description: _descriptionController.text,
      );
      
      final exerciseService = ExerciseService();
      await exerciseService.updateExercise(updatedExercise);
      
      if (mounted) {
        Navigator.of(context).pop(updatedExercise);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Ejercicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submitForm,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre del Ejercicio'),
                validator: (value) => value!.isEmpty ? 'Este campo es obligatorio' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedMuscleGroup,
                items: _muscleGroups.map((group) => DropdownMenuItem(value: group, child: Text(group))).toList(),
                onChanged: (value) => setState(() => _selectedMuscleGroup = value),
                decoration: const InputDecoration(labelText: 'Grupo Muscular'),
                validator: (value) => value == null ? 'Selecciona un grupo' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedEquipment,
                items: _equipmentTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: (value) => setState(() => _selectedEquipment = value),
                decoration: const InputDecoration(labelText: 'Equipamiento'),
                validator: (value) => value == null ? 'Selecciona un tipo de equipamiento' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                items: _exerciseTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: (value) => setState(() => _selectedType = value),
                decoration: const InputDecoration(labelText: 'Tipo de Ejercicio'),
                validator: (value) => value == null ? 'Selecciona un tipo de ejercicio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 4,
                validator: (value) => value!.isEmpty ? 'Este campo es obligatorio' : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
