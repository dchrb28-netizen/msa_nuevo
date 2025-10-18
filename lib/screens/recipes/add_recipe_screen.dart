
import 'package:flutter/material.dart';

class AddRecipeScreen extends StatelessWidget {
  const AddRecipeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Nueva Receta'),
      ),
      body: const Center(
        child: Text('Formulario para añadir una nueva receta.'),
      ),
    );
  }
}
