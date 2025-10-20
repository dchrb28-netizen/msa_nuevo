
import 'package:flutter/material.dart';

class WebRecipesScreen extends StatelessWidget {
  const WebRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recetas de la Web'),
      ),
      body: const Center(
        child: Text('Aquí se mostrarán las recetas de la web.'),
      ),
    );
  }
}
