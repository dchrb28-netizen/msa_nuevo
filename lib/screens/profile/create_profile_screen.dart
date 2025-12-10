import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/widgets/profile/selection_card.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  CreateProfileScreenState createState() => CreateProfileScreenState();
}

class CreateProfileScreenState extends State<CreateProfileScreen> {
  final PageController _pageController = PageController();
  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];
  int _currentPage = 0;

  // User data
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  String _selectedGender = 'male';
  String _activityLevel = 'sedentary';
  Uint8List? _profileImageBytes;

  final Map<String, Map<String, dynamic>> _genderOptions = {
    'male': {'label': 'Masculino', 'icon': PhosphorIcons.genderMale()},
    'female': {'label': 'Femenino', 'icon': PhosphorIcons.genderFemale()},
    'other': {'label': 'Otro', 'icon': PhosphorIcons.genderNeuter()},
  };

  final Map<String, Map<String, dynamic>> _activityLevelOptions = {
    'sedentary': {'label': 'Sedentario', 'icon': PhosphorIcons.couch()},
    'light': {'label': 'Ligero', 'icon': PhosphorIcons.personSimpleWalk()},
    'moderate': {'label': 'Moderado', 'icon': PhosphorIcons.personSimpleRun()},
    'active': {'label': 'Activo', 'icon': PhosphorIcons.barbell()},
    'very_active': {'label': 'Muy Activo', 'icon': PhosphorIcons.fire()},
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _ageController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() => _profileImageBytes = bytes);
    }
  }

  void _nextPage() {
    if (_formKeys[_currentPage].currentState!.validate()) {
      if (_currentPage < 2) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      } else {
        _saveProfile();
      }
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  Future<void> _saveProfile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final navigator = Navigator.of(context);

    final age = int.tryParse(_ageController.text) ?? 0;
    final height = double.tryParse(_heightController.text) ?? 0;
    final weight = double.tryParse(_weightController.text) ?? 0;

    double bmr;
    if (_selectedGender == 'male') {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }

    final activityMultipliers = {
      'sedentary': 1.2,
      'light': 1.375,
      'moderate': 1.55,
      'active': 1.725,
      'very_active': 1.9,
    };

    final tdee = bmr * (activityMultipliers[_activityLevel] ?? 1.2);

    final updatedUser = User(
        id: DateTime.now().toIso8601String(),
        name: _nameController.text,
        gender: _selectedGender,
        age: age,
        height: height,
        weight: weight,
        activityLevel: _activityLevel,
        profileImageBytes: _profileImageBytes,
        isGuest: false,
        calorieGoal: tdee,
        proteinGoal: (tdee * 0.30) / 4,
        carbGoal: (tdee * 0.40) / 4,
        fatGoal: (tdee * 0.30) / 9);
    await userProvider.setUser(updatedUser);
    navigator.pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          LinearProgressIndicator(value: (_currentPage + 1) / 3),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) => setState(() => _currentPage = page),
              physics: const NeverScrollableScrollPhysics(),
              children: [_buildStep1(), _buildStep2(), _buildStep3()],
            ),
          ),
          _buildNavigation(),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKeys[0],
        child: Column(
          children: [
            const Text(
              'Paso 1 de 3: ¿Quién eres?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 80,
                backgroundImage: _profileImageBytes != null
                    ? MemoryImage(_profileImageBytes!)
                    : null,
                child: _profileImageBytes == null
                    ? Icon(PhosphorIcons.camera(), size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (value) =>
                  value!.isEmpty ? 'Por favor, introduce tu nombre' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKeys[1],
        child: Column(
          children: [
            const Text(
              'Paso 2 de 3: Tus medidas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: _genderOptions.entries.map((entry) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: SelectionCard(
                      title: entry.value['label'],
                      icon: entry.value['icon'],
                      isSelected: _selectedGender == entry.key,
                      onTap: () => setState(() => _selectedGender = entry.key),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _ageController,
              decoration: const InputDecoration(labelText: 'Edad'),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? 'Introduce tu edad' : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _heightController,
              decoration: const InputDecoration(labelText: 'Altura (cm)'),
              keyboardType: TextInputType.number,
              validator: (value) =>
                  value!.isEmpty ? 'Introduce tu altura' : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(labelText: 'Peso (kg)'),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? 'Introduce tu peso' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKeys[2],
        child: Column(
          children: [
            const Text(
              'Paso 3 de 3: Tu estilo de vida',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              alignment: WrapAlignment.center,
              children: _activityLevelOptions.entries.map((entry) {
                return SelectionCard(
                  title: entry.value['label'],
                  icon: entry.value['icon'],
                  isSelected: _activityLevel == entry.key,
                  onTap: () => setState(() => _activityLevel = entry.key),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            TextButton.icon(
              onPressed: _previousPage,
              icon: Icon(PhosphorIcons.arrowLeft()),
              label: const Text('Anterior'),
            ),
          ElevatedButton.icon(
            onPressed: _nextPage,
            icon: Icon(
              _currentPage == 2 ? PhosphorIcons.check() : PhosphorIcons.arrowRight(),
            ),
            label: Text(_currentPage == 2 ? 'Finalizar' : 'Siguiente'),
          ),
        ],
      ),
    );
  }
}
