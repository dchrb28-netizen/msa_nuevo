import 'package:flutter/material.dart';
import 'package:myapp/widgets/ui/screen_background.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progreso'),
      ),
      body: Stack(
        children: [
          const ScreenBackground(screenName: 'progreso'),
          const Center(
            child: Text('Aquí podrás ver tu progreso.'),
          ),
        ],
      ),
    );
  }
}
