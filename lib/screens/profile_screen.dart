
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/widgets/profile/profile_edit_view.dart';
import 'package:myapp/widgets/profile/profile_read_view.dart';
import 'package:myapp/widgets/ui/watermark_image.dart';
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

    _loadUserData(isNewUser);

    if (isNewUser) {
      setState(() {
        _isEditing = true;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _loadUserData(bool isNewUser) {
    final user = Provider.of<UserProvider>(context, listen: false).user;

    if (isNewUser) {
      _nameController = TextEditingController();
      _ageController = TextEditingController();
      _heightController = TextEditingController();
      _weightController = TextEditingController();
      _selectedGender = _genderOptions.keys.first;
      _activityLevel = _activityLevelOptions.keys.first;
      _profileImageBytes = null;
    } else {
      _nameController = TextEditingController(text: user?.name ?? '');
      _ageController = TextEditingController(text: user?.age.toString() ?? '0');
      _heightController = TextEditingController(text: user?.height.toString() ?? '0');
      _weightController = TextEditingController(text: user?.weight.toString() ?? '0');
      _selectedGender = user?.gender ?? _genderOptions.keys.first;
      _activityLevel = user?.activityLevel ?? _activityLevelOptions.keys.first;
      _profileImageBytes = user?.profileImageBytes;
    }
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

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);
      final isNewUser = userProvider.user == null || userProvider.user!.isGuest;

      final updatedUser = User(
        id: userProvider.user?.id ?? DateTime.now().toString(),
        name: _nameController.text,
        gender: _selectedGender!,
        age: int.tryParse(_ageController.text) ?? 0,
        height: double.tryParse(_heightController.text) ?? 0,
        weight: double.tryParse(_weightController.text) ?? 0,
        activityLevel: _activityLevel!,
        profileImageBytes: _profileImageBytes,
        isGuest: false,
      );

      await userProvider.setUser(updatedUser);

      setState(() {
        _isSaving = false;
      });

      if (isNewUser) {
        navigator.pushNamedAndRemoveUntil('/', (route) => false);
      } else {
        setState(() {
          _isEditing = false;
        });
        messenger.showSnackBar(
          const SnackBar(content: Text('¡Perfil actualizado con éxito!')),
        );
      }
    }
  }

  void _logout() {
    final navigator = Navigator.of(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.logout();
    navigator.pushNamedAndRemoveUntil('/welcome', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final bool profileExists = user != null && !user.isGuest;

    return Scaffold(
      appBar: AppBar(
        title: Text(profileExists ? 'Mi Perfil' : 'Crea tu Perfil'),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (profileExists && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Editar Perfil',
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          if (profileExists)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Cerrar Sesión',
              onPressed: _logout,
            ),
        ],
      ),
      body: Stack(
        children: [
          const WatermarkImage(imageName: 'perfil'),
          if (_isLoading || _isSaving)
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
                        onPickImage: _pickImage,
                        onSaveProfile: _saveProfile,
                        onGenderChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                        onActivityLevelChanged: (value) {
                          setState(() {
                            _activityLevel = value;
                          });
                        },
                      )
                    : (user != null
                        ? ProfileReadView(
                            user: user,
                            genderOptions: _genderOptions,
                            activityLevelOptions: _activityLevelOptions,
                          )
                        : _buildNoProfileView()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNoProfileView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Aún no has creado tu perfil.',
              style: TextStyle(fontSize: 18)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isEditing = true;
              });
            },
            child: const Text('Crear Perfil'),
          )
        ],
      ),
    );
  }
}
