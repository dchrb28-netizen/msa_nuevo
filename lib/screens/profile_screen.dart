import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/screens/main_screen.dart';
import 'package:myapp/widgets/ui/screen_background.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;

  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  String? _selectedGender;
  String? _activityLevel;
  String? _profileImagePath;

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
    _profileImagePath = user?.profileImagePath;

    _selectedGender = user?.gender ?? _genderOptions.keys.first;
    _activityLevel = user?.activityLevel ?? _activityLevelOptions.keys.first;

    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (image != null) {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = path.basename(image.path);
      final File newImage = await File(image.path).copy('${appDir.path}/$fileName');

      setState(() {
        _profileImagePath = newImage.path;
      });
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final oldUser = userProvider.user;

      final updatedUser = User(
        id: oldUser?.id ?? DateTime.now().toString(),
        name: _nameController.text,
        gender: _selectedGender!,
        age: int.tryParse(_ageController.text) ?? 0,
        height: double.tryParse(_heightController.text) ?? 0,
        weight: double.tryParse(_weightController.text) ?? 0,
        activityLevel: _activityLevel!,
        profileImagePath: _profileImagePath,
        isGuest: false,
      );

      userProvider.setUser(updatedUser);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Perfil guardado con éxito!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos requeridos.')),
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
    final List<Widget> pages = _buildPages();
    final isLastPage = _currentPage == pages.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crea tu Perfil'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
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
          Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    children: pages,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    children: [
                       SmoothPageIndicator(
                          controller: _pageController,
                          count: pages.length,
                          effect: WormEffect(
                            dotHeight: 10,
                            dotWidth: 10,
                            activeDotColor: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (_currentPage > 0)
                              TextButton(
                                onPressed: () {
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                child: const Text('ATRÁS'),
                              )
                            else
                              const SizedBox(width: 60), // Placeholder to balance the row

                            ElevatedButton(
                                onPressed: () {
                                  if (isLastPage) {
                                    _saveProfile();
                                  } else {
                                    _pageController.nextPage(
                                      duration: const Duration(milliseconds: 400),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  )
                                ),
                                child: Text(isLastPage ? 'GUARDAR' : 'SIGUIENTE'),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPages() {
    return [
      _buildPage(
        title: '¡Bienvenido! Empecemos con una foto.',
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 100,
                backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                backgroundImage: _profileImagePath != null ? FileImage(File(_profileImagePath!)) : null,
                child: _profileImagePath == null
                    ? Icon(Icons.person, size: 100, color: Theme.of(context).colorScheme.primary)
                    : null,
              ),
              Positioned(
                bottom: 5,
                right: 5,
                child: FloatingActionButton(
                  onPressed: _pickImage,
                  tooltip: 'Elegir foto',
                  child: const Icon(Icons.edit),
                ),
              ),
            ],
          ),
        ),
      ),
      _buildPage(
        title: 'Cuéntanos un poco sobre ti.',
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
               _buildChoiceChipGroup(
                label: 'Género',
                options: _genderOptions,
                selectedValue: _selectedGender!,
                onSelected: (newValue) => setState(() => _selectedGender = newValue),
              ),
          ],
        ),
      ),
      _buildPage(
        title: 'Tus medidas actuales.',
        child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
          ],
        ),
      ),
      _buildPage(
        title: '¿Cuál es tu nivel de actividad física?',
        child: _buildChoiceChipGroup(
          label: '', // No label needed here as it's in the title
          options: _activityLevelOptions,
          selectedValue: _activityLevel!,
          onSelected: (newValue) => setState(() => _activityLevel = newValue),
        ),
      ),
    ];
  }
  
  Widget _buildPage({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: child,
            ),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.7),
      ),
      validator: validator,
    );
  }

  Widget _buildChoiceChipGroup<T>({
    required String label,
    required Map<T, String> options,
    required T selectedValue,
    required ValueChanged<T> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if(label.isNotEmpty)
          Text(label, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        if(label.isNotEmpty) 
        const SizedBox(height: 12),
        Wrap(
          spacing: 10.0,
          runSpacing: 10.0,
          alignment: WrapAlignment.center,
          children: options.keys.map((key) {
            final isSelected = selectedValue == key;
            return ChoiceChip(
              label: Text(options[key]!),
              selected: isSelected,
              onSelected: (bool selected) {
                if (selected) onSelected(key);
              },
              backgroundColor: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Colors.transparent,
              selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              labelStyle: TextStyle(
                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              avatar: isSelected ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary, size: 18) : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: BorderSide(
                  width: isSelected ? 2.0 : 1.0,
                  color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline.withOpacity(0.4),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              elevation: 0,
              pressElevation: 0,
            );
          }).toList(),
        ),
      ],
    );
  }
}
