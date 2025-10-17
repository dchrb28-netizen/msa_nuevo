import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/screens/main_screen.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  String? _gender;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;

  File? _profileImage;
  bool _isEditing = false;
  bool _isGuest = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    
    _nameController = TextEditingController();
    _ageController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();

    if (user != null) {
      _isGuest = user.isGuest;
      _isEditing = !user.isGuest;
      
      _nameController.text = user.isGuest ? '' : user.name;
      _gender = user.gender;
      
      _ageController.text = user.age > 0 ? user.age.toString() : '';
      _heightController.text = user.height > 0 ? user.height.toString() : '';
      _weightController.text = user.weight > 0 ? user.weight.toString() : '';

      if (user.profileImagePath != null) {
        _profileImage = File(user.profileImagePath!);
      }
    } else {
      // Default state for a completely new user (should not happen if coming from guest)
      _isGuest = false;
      _isEditing = false;
      _gender = null;
    }
  }


  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _saveProfile() {
    // First, validate the form.
    if (!_formKey.currentState!.validate()) {
        // If the form is not valid, do not proceed.
        return;
    }

    // If the form is valid, proceed with saving the data.
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.user;

    // Use the existing user's ID if it exists, otherwise generate a new one.
    final userId = currentUser != null && !currentUser.isGuest 
                   ? currentUser.id 
                   : DateTime.now().millisecondsSinceEpoch.toString();
    
    final user = User(
      id: userId,
      name: _nameController.text,
      gender: _gender!,
      age: int.tryParse(_ageController.text) ?? 0,
      height: double.tryParse(_heightController.text) ?? 0.0,
      weight: double.tryParse(_weightController.text) ?? 0.0,
      profileImagePath: _profileImage?.path,
      isGuest: false, // When saving, user is no longer a guest
    );

    // Use the setUser method which handles saving to Hive
    userProvider.setUser(user);

    // After saving, navigate.
    if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (Route<dynamic> route) => false,
        );
    }
}


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
       appBar: _isEditing ? AppBar(
        title: const Text('Editar Perfil'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ) : null,
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [colorScheme.surface, colorScheme.surface.withAlpha(150)]
                : [colorScheme.primary.withAlpha(50), colorScheme.surface],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  _buildAvatar(),
                  const SizedBox(height: 24),
                  Text(
                     _isEditing ? 'Edita tu Perfil' : 'Crea tu Perfil',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Completa tus datos para personalizar tu experiencia.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildTextField(_nameController, 'Nombre', Icons.person_outline),
                  const SizedBox(height: 16),
                  _buildGenderDropdown(colorScheme),
                  const SizedBox(height: 16),
                  _buildTextField(_ageController, 'Edad', Icons.cake_outlined, keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  _buildTextField(_heightController, 'Altura (cm)', Icons.height_outlined, keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  _buildTextField(_weightController, 'Peso (kg)', Icons.monitor_weight_outlined, keyboardType: TextInputType.number),
                  const SizedBox(height: 40),
                  _buildSaveButton(colorScheme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 70,
            backgroundColor: Theme.of(context).colorScheme.secondary.withAlpha(50),
            backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
            child: _profileImage == null
                ? Icon(
                    Icons.camera_alt_outlined,
                    size: 50,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
          ),
          Positioned(
            bottom: 0, 
            right: 0,
            child: Material(
              color: Theme.of(context).colorScheme.primary,
              shape: const CircleBorder(),
              elevation: 4,
              child: InkWell(
                onTap: _pickImage,
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.edit, color: Colors.white, size: 24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface.withAlpha(180),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, introduce tu $label';
        }
        if (label == 'Nombre' && value.length < 2) {
          return 'El nombre debe tener al menos 2 caracteres.';
        }
        return null;
      },
    );
  }

  Widget _buildGenderDropdown(ColorScheme colorScheme) {
    // The list of all possible gender options.
    final List<String> genderOptions = ['Masculino', 'Femenino', 'Otro', 'No especificado'];

    return DropdownButtonFormField<String>(
      value: _gender,
      hint: const Text('Selecciona tu género'),
      decoration: InputDecoration(
        labelText: 'Género',
        prefixIcon: Icon(Icons.wc_outlined, color: colorScheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: colorScheme.surface.withAlpha(180),
      ),
      // The items are always the full list.
      items: genderOptions.map((label) => DropdownMenuItem(
            value: label,
            child: Text(label),
          )).toList(),
      onChanged: (value) {
        setState(() {
          _gender = value;
        });
      },
      // Validation ensures a real gender is selected.
      validator: (value) {
        if (value == null || value == 'No especificado') {
          return 'Por favor, selecciona un género válido';
        }
        return null;
      },
    );
  }

  Widget _buildSaveButton(ColorScheme colorScheme) {
    return ElevatedButton(
      onPressed: _saveProfile,
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
        textStyle: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      child: const Text('Guardar Perfil'),
    );
  }
}
