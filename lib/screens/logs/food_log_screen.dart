import 'package:flutter/material.dart';

class FoodLogScreen extends StatelessWidget {
  const FoodLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Comida'),
      ),
      body: const Center(
        child: Text('Aquí podrás registrar tus comidas.'),
      ),
    );
  }
}
