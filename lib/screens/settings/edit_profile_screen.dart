
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  String? _selectedGender;
  String? _activityLevel;
  Uint8List? _profileImageBytes;

  final Map<String, String> _genderOptions = {
    'male': 'Masculino',
    'female': 'Femenino',
    'other': 'Otro',
  };

  final Map<String, String> _activityLevelOptions = {
    'sedentary': 'Sedentario',
    'light': 'Ligero',
    'moderate': 'Moderado',
    'active': 'Activo',
    'very_active': 'Muy Activo',
  };

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user!;

    _nameController = TextEditingController(text: user.name);
    _ageController = TextEditingController(text: user.age > 0 ? user.age.toString() : '');
    _heightController = TextEditingController(text: user.height > 0 ? user.height.toString() : '');
    _weightController = TextEditingController(text: user.weight > 0 ? user.weight.toString() : '');
    _selectedGender = user.gender;
    _activityLevel = user.activityLevel;
    _profileImageBytes = user.profileImageBytes;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _profileImageBytes = bytes;
      });
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final oldUser = userProvider.user!;

      final updatedUser = oldUser.copyWith(
        name: _nameController.text,
        gender: _selectedGender,
        age: int.tryParse(_ageController.text) ?? oldUser.age,
        height: double.tryParse(_heightController.text) ?? oldUser.height,
        weight: double.tryParse(_weightController.text) ?? oldUser.weight,
        activityLevel: _activityLevel,
        profileImageBytes: _profileImageBytes,
      );

      userProvider.updateUser(updatedUser);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Perfil actualizado con éxito!')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildImagePicker(),
              const SizedBox(height: 32),
              _buildTextField(
                controller: _nameController,
                label: 'Nombre',
                icon: Icons.person_outline,
                validator: (value) => (value == null || value.isEmpty) ? 'Introduce tu nombre' : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _ageController,
                label: 'Edad',
                icon: Icons.cake_outlined,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Introduce tu edad';
                  if (int.tryParse(value) == null || int.parse(value) <= 0) return 'Introduce una edad válida';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _heightController,
                label: 'Altura (cm)',
                icon: Icons.height_outlined,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Introduce tu altura';
                  if (double.tryParse(value) == null || double.parse(value) <= 0) return 'Introduce una altura válida';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _weightController,
                label: 'Peso (kg)',
                icon: Icons.monitor_weight_outlined,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Introduce tu peso';
                  if (double.tryParse(value) == null || double.parse(value) <= 0) return 'Introduce un peso válido';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _buildDropdown(
                label: 'Género',
                initialValue: _selectedGender,
                items: _genderOptions,
                onChanged: (value) {
                  if (value != null) setState(() => _selectedGender = value);
                },
              ),
              const SizedBox(height: 24),
              _buildDropdown(
                label: 'Nivel de Actividad',
                initialValue: _activityLevel,
                items: _activityLevelOptions,
                onChanged: (value) {
                  if (value != null) setState(() => _activityLevel = value);
                },
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save_alt_outlined),
                label: const Text('Guardar Cambios'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 80,
            backgroundImage: _profileImageBytes != null
                ? MemoryImage(_profileImageBytes!)
                : null,
            child: _profileImageBytes == null
                ? const Icon(Icons.person, size: 80)
                : null,
          ),
          FloatingActionButton(
            onPressed: _pickImage,
            mini: true,
            child: const Icon(Icons.edit),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    T? initialValue,
    required Map<T, String> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: items.entries.map((entry) {
        return DropdownMenuItem<T>(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
