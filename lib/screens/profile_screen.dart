import 'package:flutter/material.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/screens/main_screen.dart';
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

  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  String? _selectedGender;
  String? _activityLevel;

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
    final user = Provider.of<UserProvider>(context, listen: false).user;

    _nameController = TextEditingController(text: user?.name ?? '');
    _ageController = TextEditingController(text: user?.age.toString() ?? '0');
    _heightController = TextEditingController(text: user?.height.toString() ?? '0');
    _weightController = TextEditingController(text: user?.weight.toString() ?? '0');

    // Safely set the initial gender
    final gender = user?.gender;
    if (gender != null && _genderOptions.containsKey(gender)) {
      _selectedGender = gender;
    } else {
      _selectedGender = _genderOptions.keys.first; // Default to the first option
    }

    // Safely set the initial activity level
    final activityLevel = user?.activityLevel;
    if (activityLevel != null && _activityLevelOptions.containsKey(activityLevel)) {
      _activityLevel = activityLevel;
    } else {
      _activityLevel = _activityLevelOptions.keys.first; // Default to the first option
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

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final oldUser = userProvider.user;

      final updatedUser = User(
        id: oldUser?.id ?? DateTime.now().toString(),
        name: _nameController.text,
        gender: _selectedGender ?? _genderOptions.keys.first,
        age: int.tryParse(_ageController.text) ?? 0,
        height: double.tryParse(_heightController.text) ?? 0,
        weight: double.tryParse(_weightController.text) ?? 0,
        activityLevel: _activityLevel ?? _activityLevelOptions.keys.first,
        isGuest: false,
      );

      userProvider.setUser(updatedUser);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil guardado con éxito')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', false);

    if (!mounted) return;
    Provider.of<UserProvider>(context, listen: false).logout();

    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: _logout,
          ),
        ],
      ),
      body: Stack(
        children: [
          const ScreenBackground(screenName: 'perfil'),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, introduce tu nombre';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedGender,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedGender = newValue!;
                      });
                    },
                    items: _genderOptions.keys.map<DropdownMenuItem<String>>((String key) {
                      return DropdownMenuItem<String>(
                        value: key,
                        child: Text(_genderOptions[key]!),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: 'Género',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _ageController,
                    decoration: const InputDecoration(labelText: 'Edad'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _heightController,
                    decoration: const InputDecoration(labelText: 'Altura (cm)'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(labelText: 'Peso (kg)'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _activityLevel,
                    onChanged: (String? newValue) {
                      setState(() {
                        _activityLevel = newValue!;
                      });
                    },
                    items: _activityLevelOptions.keys.map<DropdownMenuItem<String>>((String key) {
                      return DropdownMenuItem<String>(
                        value: key,
                        child: Text(_activityLevelOptions[key]!),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: 'Nivel de Actividad',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Text('Guardar Perfil'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
