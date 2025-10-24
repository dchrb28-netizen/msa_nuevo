
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/widgets/ui/screen_background.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isLoading = true;

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

  Future<void> _initializeProfile() async {
    _loadUserData();
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('profile_exists') ?? false)) {
      setState(() {
        _isEditing = true;
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _loadUserData() {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _ageController = TextEditingController(text: user?.age.toString() ?? '0');
    _heightController = TextEditingController(text: user?.height.toString() ?? '0');
    _weightController = TextEditingController(text: user?.weight.toString() ?? '0');
    _selectedGender = user?.gender ?? _genderOptions.keys.first;
    _activityLevel = user?.activityLevel ?? _activityLevelOptions.keys.first;
    _profileImageBytes = user?.profileImageBytes;
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

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final navigator = Navigator.of(context); // Capture navigator
      final messenger = ScaffoldMessenger.of(context); // Capture messenger
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

      userProvider.setUser(updatedUser); // Removed await

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('profile_exists', true);

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

  void _logout() async {
    final navigator = Navigator.of(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('profile_exists', false);

    userProvider.logout(); // Removed await

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
        backgroundColor: Colors.transparent,
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
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const ScreenBackground(screenName: 'perfil'),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: _isEditing
                        ? _buildEditView()
                        : (user != null
                            ? _buildReadView(user)
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

  Widget _buildReadView(User user) {
    final profileImage = user.profileImageBytes != null
        ? MemoryImage(user.profileImageBytes!)
        : const AssetImage('assets/icons/icon.png') as ImageProvider;

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 80,
            backgroundImage: profileImage,
          ),
          const SizedBox(height: 24),
          Text(user.name, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 40),
          _buildInfoCard(context, user),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, User user) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.5,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            _buildInfoItem(context, Icons.cake_outlined, 'Edad', '${user.age} años'),
            _buildInfoItem(context, Icons.height_outlined, 'Altura', '${user.height} cm'),
            _buildInfoItem(context, Icons.monitor_weight_outlined, 'Peso', '${user.weight} kg'),
            _buildInfoItem(context, Icons.person_outline, 'Género', _genderOptions[user.gender] ?? 'No especificado'),
            _buildInfoItem(context, Icons.fitness_center_outlined, 'Nivel Actividad', _activityLevelOptions[user.activityLevel] ?? 'No especificado'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
      BuildContext context, IconData icon, String label, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildEditView() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 80,
                  backgroundColor: Theme.of(context).colorScheme.surface.withAlpha(200),
                  backgroundImage: _profileImageBytes != null ? MemoryImage(_profileImageBytes!) : null,
                  child: _profileImageBytes == null
                      ? Icon(Icons.person, size: 80, color: Theme.of(context).colorScheme.primary)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: FloatingActionButton(
                    mini: true,
                    onPressed: _pickImage,
                    child: const Icon(Icons.edit),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildTextField(
            controller: _nameController,
            label: 'Nombre',
            icon: Icons.person_outline,
            validator: (value) => (value == null || value.isEmpty) ? 'Introduce tu nombre' : null,
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
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
          _buildDropdownField(
            label: 'Género',
            initialValue: _selectedGender,
            items: _genderOptions,
            onChanged: (value) {
              setState(() {
                _selectedGender = value;
              });
            },
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Nivel de Actividad',
            initialValue: _activityLevel,
            items: _activityLevelOptions,
            onChanged: (value) {
              setState(() {
                _activityLevel = value;
              });
            },
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _saveProfile,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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
        fillColor: Theme.of(context).colorScheme.surface.withAlpha(200),
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
        fillColor: Theme.of(context).colorScheme.surface.withAlpha(200),
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
