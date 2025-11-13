
import 'dart:typed_data';
import 'package:flutter/material.dart';

class ProfileEditView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController ageController;
  final TextEditingController heightController;
  final TextEditingController weightController;
  final String? selectedGender;
  final String? activityLevel;
  final Uint8List? profileImageBytes;
  final Map<String, String> genderOptions;
  final Map<String, String> activityLevelOptions;
  final VoidCallback onPickImage;
  final VoidCallback onSaveProfile;
  final Function(String?) onGenderChanged;
  final Function(String?) onActivityLevelChanged;

  const ProfileEditView({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.ageController,
    required this.heightController,
    required this.weightController,
    required this.selectedGender,
    required this.activityLevel,
    required this.profileImageBytes,
    required this.genderOptions,
    required this.activityLevelOptions,
    required this.onPickImage,
    required this.onSaveProfile,
    required this.onGenderChanged,
    required this.onActivityLevelChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 80,
                  backgroundColor:
                      Theme.of(context).colorScheme.surface.withAlpha(200),
                  backgroundImage:
                      profileImageBytes != null ? MemoryImage(profileImageBytes!) : null,
                  child: profileImageBytes == null
                      ? Icon(Icons.person,
                          size: 80, color: Theme.of(context).colorScheme.primary)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: FloatingActionButton(
                    mini: true,
                    onPressed: onPickImage,
                    child: const Icon(Icons.edit),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildTextField(
            controller: nameController,
            label: 'Nombre',
            icon: Icons.person_outline,
            validator: (value) =>
                (value == null || value.isEmpty) ? 'Introduce tu nombre' : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: ageController,
            label: 'Edad',
            icon: Icons.cake_outlined,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Introduce tu edad';
              }
              if (int.tryParse(value) == null || int.parse(value) <= 0) {
                return 'Introduce una edad válida';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: heightController,
            label: 'Altura (cm)',
            icon: Icons.height_outlined,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Introduce tu altura';
              }
              if (double.tryParse(value) == null || double.parse(value) <= 0) {
                return 'Introduce una altura válida';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: weightController,
            label: 'Peso (kg)',
            icon: Icons.monitor_weight_outlined,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Introduce tu peso';
              }
              if (double.tryParse(value) == null || double.parse(value) <= 0) {
                return 'Introduce un peso válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          _buildDropdownField(
            label: 'Género',
            initialValue: selectedGender,
            items: genderOptions,
            onChanged: onGenderChanged,
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Nivel de Actividad',
            initialValue: activityLevel,
            items: activityLevelOptions,
            onChanged: onActivityLevelChanged,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: onSaveProfile,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text('Guardar Cambios'),
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: const Color.fromARGB(255, 255, 255, 255).withAlpha(200),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? initialValue,
    required Map<String, String> items,
    required void Function(String?)? onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: const Color.fromARGB(255, 255, 255, 255).withAlpha(200),
      ),
      items: items.keys.map((String key) {
        return DropdownMenuItem<String>(
          value: key,
          child: Text(items[key]!),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
