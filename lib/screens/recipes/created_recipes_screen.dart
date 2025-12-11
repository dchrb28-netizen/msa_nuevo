import 'package:flutter/material.dart';

class CreatedRecipesScreen extends StatelessWidget {
  const CreatedRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(
        child: Text('Aquí se mostrarán las recetas creadas por el usuario.'),
      ),
    );
  }
}
