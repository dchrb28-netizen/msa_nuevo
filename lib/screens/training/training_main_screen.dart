import 'package:flutter/material.dart';
import 'package:myapp/screens/training/add_exercise_screen.dart';
import 'package:myapp/screens/training/exercise_library_screen.dart';

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
              Tab(icon: Icon(Icons.fitness_center), text: 'Ejercicios'),
              Tab(icon: Icon(Icons.local_library), text: 'Biblioteca'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddExerciseScreen()),
                );
              },
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            // Placeholder for the main exercises/routines screen
            Center(child: Text('Próximamente: Tus rutinas de ejercicio')),
            ExerciseLibraryScreen(),
          ],
        ),
      ),
    );
  }
}
