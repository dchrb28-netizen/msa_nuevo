import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/screens/profile/create_profile_screen.dart';
import 'package:myapp/screens/profile_selection_screen.dart';
import 'package:myapp/services/achievement_service.dart';
import 'package:myapp/widgets/profile/profile_edit_view.dart';
import 'package:myapp/widgets/profile/profile_read_view.dart';
import 'package:myapp/widgets/ui/watermark_image.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isSaving = false;

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
    _initializeProfile();
  }

  void _initializeProfile() {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null || user.isGuest) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const CreateProfileScreen()),
          );
        }
      });
    } else {
      _loadUserData(user);
    }
  }

  void _loadUserData(User user) {
    _nameController = TextEditingController(text: user.name);
    _ageController = TextEditingController(text: user.age.toString());
    _heightController = TextEditingController(text: user.height.toString());
    _weightController = TextEditingController(text: user.weight.toString());
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

  void _checkProfileCompletion(User user) {
    if (user.name.isNotEmpty &&
        user.age > 0 &&
        user.height > 0 &&
        user.weight > 0 &&
        user.gender.isNotEmpty &&
        user.activityLevel.isNotEmpty &&
        user.profileImageBytes != null) {
      Provider.of<AchievementService>(context, listen: false).updateProgress('exp_profile_complete', 1);
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final messenger = ScaffoldMessenger.of(context);

      final updatedUser = userProvider.user!.copyWith(
        name: _nameController.text,
        gender: _selectedGender,
        age: int.tryParse(_ageController.text),
        height: double.tryParse(_heightController.text),
        weight: double.tryParse(_weightController.text),
        activityLevel: _activityLevel,
        profileImageBytes: _profileImageBytes,
      );

      try {
        await userProvider.updateUser(updatedUser);
        _checkProfileCompletion(updatedUser);

        if (mounted) {
          setState(() {
            _isSaving = false;
            _isEditing = false;
          });
          messenger.showSnackBar(
            const SnackBar(content: Text('¡Perfil actualizado con éxito!')),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSaving = false);
          messenger.showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
        }
      }
    }
  }

  void _logout() {
    Provider.of<UserProvider>(context, listen: false).logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const ProfileSelectionScreen()),
      (route) => false,
    );
  }

 @override
Widget build(BuildContext context) {
  // This outer consumer handles user changes (like logging out).
  return Consumer<UserProvider>(
    builder: (context, userProvider, child) {
      final user = userProvider.user;

      if (user == null || user.isGuest) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          actions: [
            if (!_isEditing)
              IconButton(
                icon: Icon(PhosphorIcons.pencilSimple(PhosphorIconsStyle.duotone)),
                tooltip: 'Editar Perfil',
                onPressed: () {
                  _loadUserData(user);
                  setState(() => _isEditing = true);
                },
              ),
            IconButton(
              icon: Icon(PhosphorIcons.signOut(PhosphorIconsStyle.duotone)),
              tooltip: 'Cerrar Sesión',
              onPressed: _logout,
            ),
          ],
        ),
        body: Stack(
          children: [
            const WatermarkImage(imageName: 'perfil'),
            if (_isSaving)
              const Center(child: CircularProgressIndicator())
            else
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  // This inner consumer specifically listens for achievement changes,
                  // ensuring that ProfileReadView rebuilds when the frame/title changes.
                  child: Consumer<AchievementService>(
                    builder: (context, achievementService, child) {
                      return _isEditing
                          ? ProfileEditView(
                              formKey: _formKey,
                              nameController: _nameController,
                              ageController: _ageController,
                              heightController: _heightController,
                              weightController: _weightController,
                              selectedGender: _selectedGender,
                              activityLevel: _activityLevel,
                              profileImageBytes: _profileImageBytes,
                              genderOptions: _genderOptions,
                              activityLevelOptions: _activityLevelOptions,
                              onPickImage: _pickImage,
                              onSaveProfile: _saveProfile,
                              onCancel: () => setState(() => _isEditing = false),
                              onGenderChanged: (value) => setState(() => _selectedGender = value),
                              onActivityLevelChanged: (value) => setState(() => _activityLevel = value),
                            )
                          : ProfileReadView(
                              // Pass the necessary data down to the view
                              genderOptions: _genderOptions,
                              activityLevelOptions: _activityLevelOptions,
                            );
                    },
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}
}
