import 'package:flutter/material.dart';
import 'package:myapp/screens/training/exercise_library_screen.dart';
import 'package:myapp/screens/training/training_screen.dart';

class TrainingMainScreen extends StatelessWidget {
  final int initialTabIndex;

  const TrainingMainScreen({super.key, this.initialTabIndex = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: initialTabIndex,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Entrenamiento'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'MI RUTINA'),
              Tab(text: 'BIBLIOTECA'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            TrainingScreen(),
            ExerciseLibraryScreen(),
          ],
        ),
      ),
    );
  }
}
