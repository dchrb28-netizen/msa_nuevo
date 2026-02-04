import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:myapp/models/body_measurement.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/services/achievement_service.dart';
import 'package:myapp/services/streaks_service.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class BodyMeasurementForm extends StatefulWidget {
  const BodyMeasurementForm({super.key});

  @override
  State<BodyMeasurementForm> createState() => _BodyMeasurementFormState();
}

class _BodyMeasurementFormState extends State<BodyMeasurementForm> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _chestController = TextEditingController();
  final _armController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipsController = TextEditingController();
  final _thighController = TextEditingController();
  final _uuid = const Uuid();

  @override
  void dispose() {
    _weightController.dispose();
    _chestController.dispose();
    _armController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
    _thighController.dispose();
    super.dispose();
  }

  void _saveMeasurement() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final weight = double.tryParse(_weightController.text);
    if (weight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, introduce un peso válido.')),
      );
      return;
    }

    final newMeasurement = BodyMeasurement(
      id: _uuid.v4(),
      timestamp: DateTime.now(),
      weight: weight,
      chest: double.tryParse(_chestController.text),
      arm: double.tryParse(_armController.text),
      waist: double.tryParse(_waistController.text),
      hips: double.tryParse(_hipsController.text),
      thigh: double.tryParse(_thighController.text),
    );

    Hive.box<BodyMeasurement>('body_measurements').add(newMeasurement);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final achievementService = Provider.of<AchievementService>(context, listen: false);
    final streaksService = StreaksService();
    final User? currentUser = userProvider.user;

    if (currentUser != null) {
      // --- Lógica de Logros ---
      achievementService.grantExperience(10);
      achievementService.updateProgress('first_weight_log', 1);

      if (currentUser.weightGoal != null && weight <= currentUser.weightGoal!) {
        achievementService.updateProgress('goal_weight_target', 1);
      }
      // --- Fin Lógica de Logros ---

      // Actualizar el usuario con el peso actual y, si es necesario, el peso inicial.
      final updatedUser = currentUser.copyWith(
        weight: weight,
        initialWeight: currentUser.initialWeight ?? weight, // Guardar el peso inicial si no existe
      );
      userProvider.updateUser(updatedUser);
      
      // Actualizar racha de medidas
      await streaksService.updateMeasurementStreak();
    }

    _formKey.currentState!.reset();
    _weightController.clear();
    _chestController.clear();
    _armController.clear();
    _waistController.clear();
    _hipsController.clear();
    _thighController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Medición guardada con éxito'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                context,
                _weightController,
                'Peso',
                isRequired: true,
                icon: Icons.scale,
                suffix: 'kg',
              ),
              const SizedBox(height: 12),
              _buildTextField(
                context,
                _chestController,
                'Pecho',
                icon: Icons.fitness_center,
                suffix: 'cm',
              ),
              const SizedBox(height: 12),
              _buildTextField(
                context,
                _armController,
                'Brazo',
                icon: Icons.front_hand,
                suffix: 'cm',
              ),
              const SizedBox(height: 12),
              _buildTextField(
                context,
                _waistController,
                'Cintura',
                icon: Icons.straighten,
                suffix: 'cm',
              ),
              const SizedBox(height: 12),
              _buildTextField(
                context,
                _hipsController,
                'Caderas',
                icon: Icons.crop_free,
                suffix: 'cm',
              ),
              const SizedBox(height: 12),
              _buildTextField(
                context,
                _thighController,
                'Muslo',
                icon: Icons.unfold_more_outlined,
                suffix: 'cm',
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: _saveMeasurement,
                child: const Text('Guardar Medición'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    TextEditingController controller,
    String label, {
    bool isRequired = false,
    IconData? icon,
    String? suffix,
  }) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        suffixText: suffix,
        filled: true,
        fillColor: theme.colorScheme.surface.withOpacity(0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.onSurface.withOpacity(0.15),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return 'Este campo es obligatorio.';
        }
        if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
          return 'Por favor, introduce un número válido.';
        }
        return null;
      },
    );
  }
}