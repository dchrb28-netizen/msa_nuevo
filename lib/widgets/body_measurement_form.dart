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

  void _saveMeasurement() {
    if (_formKey.currentState!.validate()) {
      final newMeasurement = BodyMeasurement(
        id: _uuid.v4(),
        timestamp: DateTime.now(),
        weight: double.tryParse(_weightController.text) ?? 0.0,
        chest: double.tryParse(_chestController.text) ?? 0.0,
        arm: double.tryParse(_armController.text) ?? 0.0,
        waist: double.tryParse(_waistController.text) ?? 0.0,
        hips: double.tryParse(_hipsController.text) ?? 0.0,
        thigh: double.tryParse(_thighController.text) ?? 0.0,
      );

      Hive.box<BodyMeasurement>('body_measurements').add(newMeasurement);
      
      // Clear the form
      _formKey.currentState!.reset();
      _weightController.clear();
      _chestController.clear();
      _armController.clear();
      _waistController.clear();
      _hipsController.clear();
      _thighController.clear();

      // Show a confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medición guardada con éxito')),
      );
    }
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Registrar Nueva Medición', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Peso (kg)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) => (value == null || value.isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _chestController,
                decoration: const InputDecoration(labelText: 'Pecho (cm)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) => (value == null || value.isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _armController,
                decoration: const InputDecoration(labelText: 'Brazo (cm)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) => (value == null || value.isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _waistController,
                decoration: const InputDecoration(labelText: 'Cintura (cm)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) => (value == null || value.isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _hipsController,
                decoration: const InputDecoration(labelText: 'Caderas (cm)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) => (value == null || value.isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _thighController,
                decoration: const InputDecoration(labelText: 'Muslo (cm)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) => (value == null || value.isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveMeasurement,
                child: const Text('Guardar Medición'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
