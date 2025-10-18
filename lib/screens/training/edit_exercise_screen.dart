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
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  String? _selectedType;
  String? _selectedMuscleGroup;
  String? _selectedEquipment;

  final _exerciseService = ExerciseService();

  // Opciones para los desplegables
  final List<String> _exerciseTypes = ['Fuerza', 'Cardio', 'Flexibilidad', 'Equilibrio'];
  final List<String> _muscleGroups = ['Pecho', 'Espalda', 'Piernas', 'Hombros', 'Brazos', 'Abdominales', 'Cuerpo Completo'];
  final List<String> _equipmentTypes = ['Ninguno', 'Mancuernas', 'Barra', 'Kettlebell', 'Bandas de Resistencia', 'Máquina', 'Balón Medicinal'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.exercise.name);
    _descriptionController = TextEditingController(text: widget.exercise.description);
    _selectedType = widget.exercise.type;
    _selectedMuscleGroup = widget.exercise.muscleGroup;
    _selectedEquipment = widget.exercise.equipment;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveExercise() async {
    if (_formKey.currentState!.validate()) {
      final updatedExercise = Exercise(
        id: widget.exercise.id,
        name: _nameController.text,
        description: _descriptionController.text,
        type: _selectedType!,
        muscleGroup: _selectedMuscleGroup!,
        equipment: _selectedEquipment!,
      );

      final exercises = await _exerciseService.loadExercises();
      final index = exercises.indexWhere((e) => e.id == widget.exercise.id);
      if (index != -1) {
        exercises[index] = updatedExercise;
        await _exerciseService.saveExercises(exercises);
      }

      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ejercicio "${updatedExercise.name}" actualizado')),
        );
        Navigator.pop(context, true); // Signal a refresh
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
            icon: const Icon(Icons.save_alt_rounded),
            onPressed: _saveExercise,
            tooltip: 'Guardar Cambios',
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
            _buildDropdown(_selectedType, _exerciseTypes, 'Tipo de Ejercicio', Icons.category_rounded, (value) => setState(() => _selectedType = value)),
            const SizedBox(height: 16),
            _buildDropdown(_selectedMuscleGroup, _muscleGroups, 'Grupo Muscular', Icons.accessibility_new_rounded, (value) => setState(() => _selectedMuscleGroup = value)),
            const SizedBox(height: 16),
            _buildDropdown(_selectedEquipment, _equipmentTypes, 'Equipamiento', Icons.build_rounded, (value) => setState(() => _selectedEquipment = value)),
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

  Widget _buildDropdown(String? initialValue, List<String> items, String label, IconData icon, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: initialValue,
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
