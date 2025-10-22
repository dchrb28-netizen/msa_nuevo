import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:myapp/models/body_measurement.dart';
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

  bool _isSaveButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    // Añade listeners para habilitar/deshabilitar el botón de guardar
    _weightController.addListener(_updateSaveButtonState);
    _chestController.addListener(_updateSaveButtonState);
    _armController.addListener(_updateSaveButtonState);
    _waistController.addListener(_updateSaveButtonState);
    _hipsController.addListener(_updateSaveButtonState);
    _thighController.addListener(_updateSaveButtonState);
  }

  @override
  void dispose() {
    // Limpia los listeners
    _weightController.removeListener(_updateSaveButtonState);
    _chestController.removeListener(_updateSaveButtonState);
    _armController.removeListener(_updateSaveButtonState);
    _waistController.removeListener(_updateSaveButtonState);
    _hipsController.removeListener(_updateSaveButtonState);
    _thighController.removeListener(_updateSaveButtonState);

    _weightController.dispose();
    _chestController.dispose();
    _armController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
    _thighController.dispose();
    super.dispose();
  }

  void _updateSaveButtonState() {
    final hasText = _weightController.text.isNotEmpty ||
        _chestController.text.isNotEmpty ||
        _armController.text.isNotEmpty ||
        _waistController.text.isNotEmpty ||
        _hipsController.text.isNotEmpty ||
        _thighController.text.isNotEmpty;

    if (hasText != _isSaveButtonEnabled) {
      setState(() {
        _isSaveButtonEnabled = hasText;
      });
    }
  }

  void _saveMeasurement() {
    // Oculta el teclado
    FocusScope.of(context).unfocus();

    final weight = double.tryParse(_weightController.text);
    final chest = double.tryParse(_chestController.text);
    final arm = double.tryParse(_armController.text);
    final waist = double.tryParse(_waistController.text);
    final hips = double.tryParse(_hipsController.text);
    final thigh = double.tryParse(_thighController.text);

    // Solo guardar si al menos un campo es válido
    if ([weight, chest, arm, waist, hips, thigh].every((v) => v == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, introduce al menos una medida válida.')),
      );
      return;
    }

    final newMeasurement = BodyMeasurement(
      id: _uuid.v4(),
      timestamp: DateTime.now(),
      weight: weight,
      chest: chest,
      arm: arm,
      waist: waist,
      hips: hips,
      thigh: thigh,
    );

    Hive.box<BodyMeasurement>('body_measurements').add(newMeasurement);
    
    // Limpiar los campos
    _weightController.clear();
    _chestController.clear();
    _armController.clear();
    _waistController.clear();
    _hipsController.clear();
    _thighController.clear();

    // Mostrar mensaje de confirmación
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
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(_weightController, 'Peso (kg)'),
              const SizedBox(height: 12),
              _buildTextField(_chestController, 'Pecho (cm)'),
              const SizedBox(height: 12),
              _buildTextField(_armController, 'Brazo (cm)'),
              const SizedBox(height: 12),
              _buildTextField(_waistController, 'Cintura (cm)'),
              const SizedBox(height: 12),
              _buildTextField(_hipsController, 'Caderas (cm)'),
              const SizedBox(height: 12),
              _buildTextField(_thighController, 'Muslo (cm)'),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: _isSaveButtonEnabled ? _saveMeasurement : null,
                child: const Text('Guardar Medición'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }
}
