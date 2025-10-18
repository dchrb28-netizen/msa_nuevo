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
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Nueva Medición', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 20),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Peso (kg)'),
                keyboardType: TextInputType.number,
                validator: (value) => (value == null || value.isEmpty) ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _chestController,
                decoration: const InputDecoration(labelText: 'Pecho (cm)'),
                keyboardType: TextInputType.number,
                validator: (value) => (value == null || value.isEmpty) ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _armController,
                decoration: const InputDecoration(labelText: 'Brazo (cm)'),
                keyboardType: TextInputType.number,
                validator: (value) => (value == null || value.isEmpty) ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _waistController,
                decoration: const InputDecoration(labelText: 'Cintura (cm)'),
                keyboardType: TextInputType.number,
                validator: (value) => (value == null || value.isEmpty) ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _hipsController,
                decoration: const InputDecoration(labelText: 'Caderas (cm)'),
                keyboardType: TextInputType.number,
                validator: (value) => (value == null || value.isEmpty) ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _thighController,
                decoration: const InputDecoration(labelText: 'Muslo (cm)'),
                keyboardType: TextInputType.number,
                validator: (value) => (value == null || value.isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveMeasurement,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
