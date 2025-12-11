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
  late String _difficulty;
  late String _beginnerSets;
  late String _beginnerReps;
  late String _intermediateSets;
  late String _intermediateReps;
  late String _advancedSets;
  late String _advancedReps;
  late String _recommendations; // Nuevo campo

  @override
  void initState() {
    super.initState();
    _name = widget.exercise?.name ?? '';
    _muscleGroup = widget.exercise?.muscleGroup ?? '';
    _equipment = widget.exercise?.equipment ?? '';
    _description = widget.exercise?.description ?? '';
    _imageUrl = widget.exercise?.imageUrl ?? '';
    _difficulty = widget.exercise?.difficulty ?? 'Principiante';
    _beginnerSets = widget.exercise?.beginnerSets ?? '';
    _beginnerReps = widget.exercise?.beginnerReps ?? '';
    _intermediateSets = widget.exercise?.intermediateSets ?? '';
    _intermediateReps = widget.exercise?.intermediateReps ?? '';
    _advancedSets = widget.exercise?.advancedSets ?? '';
    _advancedReps = widget.exercise?.advancedReps ?? '';
    _recommendations = widget.exercise?.recommendations ?? ''; // Inicializar
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
        type: widget.exercise?.type ?? 'Fuerza',
        measurement: widget.exercise?.measurement ?? 'reps',
        difficulty: _difficulty,
        beginnerSets: _beginnerSets,
        beginnerReps: _beginnerReps,
        intermediateSets: _intermediateSets,
        intermediateReps: _intermediateReps,
        advancedSets: _advancedSets,
        advancedReps: _advancedReps,
        recommendations: _recommendations, // Guardar
      );
      Navigator.of(context).pop(newExercise);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        // title removed
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
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.image_not_supported, size: 50),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: _name,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del Ejercicio',
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Por favor, introduce un nombre'
                            : null,
                        onSaved: (value) => _name = value!,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _muscleGroup,
                        decoration: const InputDecoration(
                          labelText: 'Grupo Muscular',
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Por favor, introduce un grupo muscular'
                            : null,
                        onSaved: (value) => _muscleGroup = value!,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _equipment,
                        decoration: const InputDecoration(
                          labelText: 'Equipamiento',
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Por favor, introduce el equipamiento'
                            : null,
                        onSaved: (value) => _equipment = value!,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _description,
                        decoration: const InputDecoration(
                          labelText: 'Descripción',
                        ),
                        maxLines: 3,
                        onSaved: (value) => _description = value ?? '',
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _imageUrl,
                        decoration: const InputDecoration(
                          labelText: 'URL de la Imagen',
                        ),
                        onSaved: (value) => _imageUrl = value ?? '',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _difficulty,
                        decoration: const InputDecoration(
                          labelText: 'Dificultad',
                        ),
                        items: ['Principiante', 'Intermedio', 'Avanzado']
                            .map(
                              (label) => DropdownMenuItem(
                                value: label,
                                child: Text(label),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _difficulty = value!;
                          });
                        },
                        onSaved: (value) => _difficulty = value!,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _recommendations,
                        decoration: const InputDecoration(
                          labelText: 'Recomendaciones Generales',
                        ),
                        maxLines: 3,
                        onSaved: (value) => _recommendations = value ?? '',
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Recomendaciones por Nivel',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      // Beginner
                      Text('Principiante', style: theme.textTheme.titleMedium),
                      TextFormField(
                        initialValue: _beginnerSets,
                        decoration: const InputDecoration(
                          labelText: 'Series (Principiante)',
                        ),
                        onSaved: (value) => _beginnerSets = value ?? '',
                      ),
                      TextFormField(
                        initialValue: _beginnerReps,
                        decoration: const InputDecoration(
                          labelText: 'Reps/Tiempo (Principiante)',
                        ),
                        onSaved: (value) => _beginnerReps = value ?? '',
                      ),
                      const Divider(height: 32),
                      // Intermediate
                      Text('Intermedio', style: theme.textTheme.titleMedium),
                      TextFormField(
                        initialValue: _intermediateSets,
                        decoration: const InputDecoration(
                          labelText: 'Series (Intermedio)',
                        ),
                        onSaved: (value) => _intermediateSets = value ?? '',
                      ),
                      TextFormField(
                        initialValue: _intermediateReps,
                        decoration: const InputDecoration(
                          labelText: 'Reps/Tiempo (Intermedio)',
                        ),
                        onSaved: (value) => _intermediateReps = value ?? '',
                      ),
                      const Divider(height: 32),
                      // Advanced
                      Text('Avanzado', style: theme.textTheme.titleMedium),
                      TextFormField(
                        initialValue: _advancedSets,
                        decoration: const InputDecoration(
                          labelText: 'Series (Avanzado)',
                        ),
                        onSaved: (value) => _advancedSets = value ?? '',
                      ),
                      TextFormField(
                        initialValue: _advancedReps,
                        decoration: const InputDecoration(
                          labelText: 'Reps/Tiempo (Avanzado)',
                        ),
                        onSaved: (value) => _advancedReps = value ?? '',
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
                  textStyle: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
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
