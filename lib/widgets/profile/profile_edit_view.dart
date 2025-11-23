import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/services/achievement_service.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

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
  final VoidCallback onCancel;
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
    required this.onCancel,
    required this.onGenderChanged,
    required this.onActivityLevelChanged,
  });

  String getFrameForTitle(String? title) {
    if (title == null) return 'assets/marcos/marco_bienvenido.png';
    return 'assets/marcos/marco_${title.toLowerCase().replaceAll(' ', '_')}.png';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, AchievementService>(
      builder: (context, userProvider, achievementService, child) {
        final user = userProvider.user;
        if (user == null) {
          return const Center(child: Text("Usuario no encontrado."));
        }

        final selectedTitle = achievementService.userProfile.selectedTitle;
        final frameAsset = getFrameForTitle(selectedTitle);

        return Form(
          key: formKey,
          child: Column(
            children: [
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (user.showProfileFrame ?? true)
                      ClipOval(
                        child: Image.asset(
                          frameAsset,
                          width: 220,
                          height: 220,
                          fit: BoxFit.cover,
                        ),
                      ),
                    CircleAvatar(
                      radius: 60,
                      backgroundColor:
                          Theme.of(context).colorScheme.surface.withAlpha(200),
                      backgroundImage: profileImageBytes != null
                          ? MemoryImage(profileImageBytes!)
                          : (user.profileImageBytes != null
                              ? MemoryImage(user.profileImageBytes!)
                              : null),
                      child: profileImageBytes == null &&
                              user.profileImageBytes == null
                          ? Icon(
                              PhosphorIcons.user(PhosphorIconsStyle.duotone),
                              size: 65,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: FloatingActionButton(
                        mini: true,
                        onPressed: onPickImage,
                        child: Icon(PhosphorIcons.pencilSimple(
                            PhosphorIconsStyle.duotone)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildTextField(
                context: context,
                controller: nameController,
                label: 'Nombre',
                icon: PhosphorIcons.user(PhosphorIconsStyle.duotone),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Introduce tu nombre'
                    : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                context: context,
                controller: ageController,
                label: 'Edad',
                icon: PhosphorIcons.cake(PhosphorIconsStyle.duotone),
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
                context: context,
                controller: heightController,
                label: 'Altura (cm)',
                icon: PhosphorIcons.ruler(PhosphorIconsStyle.duotone),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Introduce tu altura';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Introduce una altura válida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                context: context,
                controller: weightController,
                label: 'Peso (kg)',
                icon: PhosphorIcons.barbell(PhosphorIconsStyle.duotone),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Introduce tu peso';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Introduce un peso válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _buildDropdownField(
                context: context,
                label: 'Género',
                initialValue: selectedGender,
                items: genderOptions,
                onChanged: onGenderChanged,
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                context: context,
                label: 'Nivel de Actividad',
                initialValue: activityLevel,
                items: activityLevelOptions,
                onChanged: onActivityLevelChanged,
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                title: const Text('Mostrar marco de perfil'),
                subtitle: const Text('Activa o desactiva el borde de tu foto.'),
                value: user.showProfileFrame ?? true,
                onChanged: (newValue) {
                  final updatedUser = user.copyWith(showProfileFrame: newValue);
                  userProvider.updateUser(updatedUser);
                },
                secondary:
                    Icon(PhosphorIcons.frameCorners(PhosphorIconsStyle.duotone)),
                activeTrackColor: Theme.of(context).colorScheme.primary.withAlpha(128),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onSaveProfile,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Guardar Cambios'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: onCancel,
                child: const Text('Cancelar'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required BuildContext context,
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
        fillColor: Theme.of(context).colorScheme.surface.withAlpha(200),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required BuildContext context,
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
        fillColor: Theme.of(context).colorScheme.surface.withAlpha(200),
      ),
      items: items.keys.map((String key) {
        return DropdownMenuItem<String>(value: key, child: Text(items[key]!));
      }).toList(),
      onChanged: onChanged,
    );
  }
}
