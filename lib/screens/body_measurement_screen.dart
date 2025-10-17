import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:myapp/models/body_measurement.dart';

class BodyMeasurementScreen extends StatefulWidget {
  const BodyMeasurementScreen({super.key});

  @override
  State<BodyMeasurementScreen> createState() => _BodyMeasurementScreenState();
}

class _BodyMeasurementScreenState extends State<BodyMeasurementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipsController = TextEditingController();

  void _saveMeasurement() {
    if (_formKey.currentState!.validate()) {
      final measurement = BodyMeasurement(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        weight: double.tryParse(_weightController.text),
        height: double.tryParse(_heightController.text),
        waist: double.tryParse(_waistController.text),
        hips: double.tryParse(_hipsController.text),
        timestamp: DateTime.now(),
      );
      Hive.box<BodyMeasurement>('body_measurements').add(measurement);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medida guardada')),
      );
      _formKey.currentState!.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Registrar Medidas Corporales', style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildTextField(_weightController, 'Peso (kg)', Icons.monitor_weight_outlined),
            const SizedBox(height: 16),
            _buildTextField(_heightController, 'Altura (cm)', Icons.height_outlined),
            const SizedBox(height: 16),
            _buildTextField(_waistController, 'Cintura (cm)', Icons.straighten_outlined),
            const SizedBox(height: 16),
            _buildTextField(_hipsController, 'Caderas (cm)', Icons.square_foot_outlined),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _saveMeasurement,
              icon: const Icon(Icons.save_alt_outlined),
              label: const Text('Guardar Medida'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
          return 'Por favor, introduce un número válido.';
        }
        return null;
      },
    );
  }
}
