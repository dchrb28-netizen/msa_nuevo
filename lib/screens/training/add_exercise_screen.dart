import 'package:flutter/material.dart';
import 'package:myapp/models/exercise.dart';
import 'package:myapp/services/exercise_service.dart';
import 'package:uuid/uuid.dart';

class AddExerciseScreen extends StatefulWidget {
  const AddExerciseScreen({super.key});

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedType;
  String? _selectedMuscleGroup;
  String? _selectedEquipment;

  final _exerciseService = ExerciseService();
  final _uuid = const Uuid();

  // Opciones para los desplegables
  final List<String> _exerciseTypes = ['Fuerza', 'Cardio', 'Flexibilidad', 'Equilibrio'];
  final List<String> _muscleGroups = ['Pecho', 'Espalda', 'Piernas', 'Hombros', 'Brazos', 'Abdominales', 'Cuerpo Completo'];
  final List<String> _equipmentTypes = ['Ninguno', 'Mancuernas', 'Barra', 'Kettlebell', 'Bandas de Resistencia', 'Máquina', 'Balón Medicinal'];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveExercise() async {
    if (_formKey.currentState!.validate()) {
      final newExercise = Exercise(
        id: _uuid.v4(),
        name: _nameController.text,
        description: _descriptionController.text,
        type: _selectedType!,
        muscleGroup: _selectedMuscleGroup!,
        equipment: _selectedEquipment!,
      );

      final exercises = await _exerciseService.loadExercises();
      exercises.add(newExercise);
      await _exerciseService.saveExercises(exercises);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ejercicio "${newExercise.name}" guardado')),
        );
        Navigator.pop(context, true); // Signal a refresh
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Ejercicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt_rounded),
            onPressed: _saveExercise,
            tooltip: 'Guardar Ejercicio',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            _buildTextField(_nameController, 'Nombre del Ejercicio', Icons.fitness_center_rounded),
            const SizedBox(height: 16),
            _buildDropdown(_exerciseTypes, '¿Qué tipo de ejercicio es?', Icons.category_rounded, (value) => setState(() => _selectedType = value)),
            const SizedBox(height: 16),
             _buildDropdown(_muscleGroups, 'Grupo Muscular Principal', Icons.accessibility_new_rounded, (value) => setState(() => _selectedMuscleGroup = value)),
            const SizedBox(height: 16),
             _buildDropdown(_equipmentTypes, 'Equipamiento Necesario', Icons.build_rounded, (value) => setState(() => _selectedEquipment = value)),
            const SizedBox(height: 24),
            _buildTextField(_descriptionController, 'Descripción (opcional)', Icons.description_rounded, isRequired: false, maxLines: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isRequired = true, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
      validator: isRequired
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Este campo es obligatorio';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildDropdown(List<String> items, String label, IconData icon, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Por favor, selecciona una opción' : null,
    );
  }
}
