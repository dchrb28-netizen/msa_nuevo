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
  late String _imageUrl;

  @override
  void initState() {
    super.initState();
    _name = widget.exercise?.name ?? '';
    _muscleGroup = widget.exercise?.muscleGroup ?? '';
    _equipment = widget.exercise?.equipment ?? '';
    _description = widget.exercise?.description ?? '';
    _imageUrl = widget.exercise?.imageUrl ?? '';
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newExercise = Exercise(
        id: widget.exercise?.id ?? DateTime.now().toString(),
        name: _name,
        muscleGroup: _muscleGroup,
        equipment: _equipment,
        description: _description,
        imageUrl: _imageUrl,
        type: widget.exercise?.type ?? 'strength',
        measurement: widget.exercise?.measurement ?? 'reps',
      );
      Navigator.of(context).pop(newExercise);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise == null ? 'Crear Ejercicio' : 'Editar Ejercicio'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    _imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => 
                      const Center(child: Icon(Icons.image_not_supported, size: 50)),
                  ),
                ),
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: _name,
                        decoration: const InputDecoration(labelText: 'Nombre del Ejercicio'),
                        validator: (value) => (value == null || value.isEmpty) ? 'Por favor, introduce un nombre' : null,
                        onSaved: (value) => _name = value!,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _muscleGroup,
                        decoration: const InputDecoration(labelText: 'Grupo Muscular'),
                        validator: (value) => (value == null || value.isEmpty) ? 'Por favor, introduce un grupo muscular' : null,
                        onSaved: (value) => _muscleGroup = value!,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _equipment,
                        decoration: const InputDecoration(labelText: 'Equipamiento'),
                        validator: (value) => (value == null || value.isEmpty) ? 'Por favor, introduce el equipamiento' : null,
                        onSaved: (value) => _equipment = value!,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _description,
                        decoration: const InputDecoration(labelText: 'Descripción'),
                        maxLines: 3,
                        onSaved: (value) => _description = value ?? '',
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _imageUrl,
                        decoration: const InputDecoration(labelText: 'URL de la Imagen'),
                        onSaved: (value) => _imageUrl = value ?? '',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _saveForm,
                icon: const Icon(Icons.save_alt_rounded),
                label: const Text('Guardar Cambios'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
