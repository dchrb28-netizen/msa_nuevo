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
  bool _isLoading = true;
  bool _isSaving = false;

  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  String? _selectedGender;
  String? _activityLevel;
  Uint8List? _profileImageBytes;
  bool _showProfileFrame = true;

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
    final bool isNewUser = user == null || user.isGuest;

    if (isNewUser) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const CreateProfileScreen()),
        );
      });
    } else {
      _loadUserData(user);
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadUserData(User? user) {
    _nameController = TextEditingController(text: user?.name ?? '');
    _ageController = TextEditingController(text: user?.age.toString() ?? '0');
    _heightController = TextEditingController(
      text: user?.height.toString() ?? '0',
    );
    _weightController = TextEditingController(
      text: user?.weight.toString() ?? '0',
    );
    _selectedGender = user?.gender ?? _genderOptions.keys.first;
    _activityLevel = user?.activityLevel ?? _activityLevelOptions.keys.first;
    _profileImageBytes = user?.profileImageBytes;
    _showProfileFrame = user?.showProfileFrame ?? true;
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
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _profileImageBytes = bytes;
      });
    }
  }

  void _checkProfileCompletion() {
    final name = _nameController.text;
    final age = int.tryParse(_ageController.text) ?? 0;
    final height = double.tryParse(_heightController.text) ?? 0;
    final weight = double.tryParse(_weightController.text) ?? 0;
    final gender = _selectedGender;
    final activityLevel = _activityLevel;
    final image = _profileImageBytes;

    if (name.isNotEmpty &&
        age > 0 &&
        height > 0 &&
        weight > 0 &&
        gender != null &&
        activityLevel != null &&
        image != null) {
      Provider.of<AchievementService>(context, listen: false)
          .updateProgress('exp_profile_complete', 1);
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final messenger = ScaffoldMessenger.of(context);

      final updatedUser = userProvider.user!.copyWith(
        name: _nameController.text,
        gender: _selectedGender!,
        age: int.tryParse(_ageController.text) ?? 0,
        height: double.tryParse(_heightController.text) ?? 0,
        weight: double.tryParse(_weightController.text) ?? 0,
        activityLevel: _activityLevel!,
        profileImageBytes: _profileImageBytes,
        showProfileFrame: _showProfileFrame,
      );

      try {
        await userProvider.setUser(updatedUser);

        _checkProfileCompletion();

        setState(() {
          _isSaving = false;
          _isEditing = false;
        });
        messenger.showSnackBar(
          const SnackBar(content: Text('¡Perfil actualizado con éxito!')),
        );
      } catch (e) {
        setState(() {
          _isSaving = false;
        });
        messenger.showSnackBar(
          SnackBar(content: Text('Error al guardar el perfil: $e')),
        );
      }
    }
  }

  void _logout() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final navigator = Navigator.of(context);

    userProvider.logout();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const ProfileSelectionScreen()),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Perfil' : 'Mi Perfil'),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: Icon(PhosphorIcons.pencilSimple(PhosphorIconsStyle.duotone)),
              tooltip: 'Editar Perfil',
              onPressed: () => setState(() => _isEditing = true),
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
                child: _isEditing
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
                        showProfileFrame: _showProfileFrame,
                        onPickImage: _pickImage,
                        onSaveProfile: _saveProfile,
                        onGenderChanged: (value) =>
                            setState(() => _selectedGender = value),
                        onActivityLevelChanged: (value) =>
                            setState(() => _activityLevel = value),
                        onShowProfileFrameChanged: (value) =>
                            setState(() => _showProfileFrame = value),
                        user: user!,
                      )
                    : (user != null
                        ? ProfileReadView(
                            user: user,
                            genderOptions: _genderOptions,
                            activityLevelOptions: _activityLevelOptions,
                          )
                        : const SizedBox.shrink()),
              ),
            ),
        ],
      ),
    );
  }
}
