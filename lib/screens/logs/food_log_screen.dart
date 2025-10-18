import 'package:flutter/material.dart';
import 'package:myapp/widgets/ui/screen_background.dart';

class FoodLogScreen extends StatelessWidget {
  const FoodLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Comida'),
      ),
      body: Stack(
        children: [
          const ScreenBackground(screenName: 'comida'),
          const Center(
            child: Text('Aquí podrás registrar tus comidas.'),
          ),
        ],
      ),
    );
  }
}
