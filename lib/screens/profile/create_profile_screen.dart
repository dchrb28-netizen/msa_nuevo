
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/widgets/profile/selection_card.dart';
import 'package:provider/provider.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  _CreateProfileScreenState createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final PageController _pageController = PageController();
  final _formKeys = [GlobalKey<FormState>(), GlobalKey<FormState>(), GlobalKey<FormState>()];
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
    'male': {'label': 'Masculino', 'icon': Icons.male},
    'female': {'label': 'Femenino', 'icon': Icons.female},
    'other': {'label': 'Otro', 'icon': Icons.question_mark},
  };

  final Map<String, Map<String, dynamic>> _activityLevelOptions = {
    'sedentary': {'label': 'Sedentario', 'icon': Icons.weekend},
    'light': {'label': 'Ligero', 'icon': Icons.directions_walk},
    'moderate': {'label': 'Moderado', 'icon': Icons.directions_run},
    'active': {'label': 'Activo', 'icon': Icons.fitness_center},
    'very_active': {'label': 'Muy Activo', 'icon': Icons.local_fire_department},
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
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() => _profileImageBytes = bytes);
    }
  }

  void _nextPage() {
    if (_formKeys[_currentPage].currentState!.validate()) {
      if (_currentPage < 2) {
        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
      } else {
        _saveProfile();
      }
    }
  }

  void _previousPage() {
    _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
  }

  Future<void> _saveProfile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final navigator = Navigator.of(context);

    final updatedUser = User(
      id: DateTime.now().toIso8601String(),
      name: _nameController.text,
      gender: _selectedGender,
      age: int.tryParse(_ageController.text) ?? 0,
      height: double.tryParse(_heightController.text) ?? 0,
      weight: double.tryParse(_weightController.text) ?? 0,
      activityLevel: _activityLevel,
      profileImageBytes: _profileImageBytes,
      isGuest: false,
    );
    await userProvider.setUser(updatedUser);
    navigator.pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crea tu Perfil')),
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
            const Text('Paso 1 de 3: ¿Quién eres?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 80,
                backgroundImage: _profileImageBytes != null ? MemoryImage(_profileImageBytes!) : null,
                child: _profileImageBytes == null ? const Icon(Icons.camera_alt, size: 50) : null,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (value) => value!.isEmpty ? 'Por favor, introduce tu nombre' : null,
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
            const Text('Paso 2 de 3: Tus medidas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
             GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: _genderOptions.entries.map((entry) {
                  return SelectionCard(
                    title: entry.value['label'],
                    icon: entry.value['icon'],
                    isSelected: _selectedGender == entry.key,
                    onTap: () => setState(() => _selectedGender = entry.key),
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
              validator: (value) => value!.isEmpty ? 'Introduce tu altura' : null,
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
            const Text('Paso 3 de 3: Tu estilo de vida', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              childAspectRatio: 2.5,
              physics: const NeverScrollableScrollPhysics(),
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
              icon: const Icon(Icons.arrow_back_ios),
              label: const Text('Anterior'),
            ),
          ElevatedButton.icon(
            onPressed: _nextPage,
            icon: Icon(_currentPage == 2 ? Icons.check : Icons.arrow_forward_ios),
            label: Text(_currentPage == 2 ? 'Finalizar' : 'Siguiente'),
          ),
        ],
      ),
    );
  }
}
