import 'package:flutter/material.dart';
import 'package:myapp/screens/training/add_exercise_screen.dart';
import 'package:myapp/screens/training/exercise_library_screen.dart';

class TrainingMainScreen extends StatefulWidget {
  final int initialTabIndex;
  const TrainingMainScreen({super.key, this.initialTabIndex = 0});

  @override
  State<TrainingMainScreen> createState() => _TrainingMainScreenState();
}

class _TrainingMainScreenState extends State<TrainingMainScreen> {
  // Correctly define the GlobalKey with the now public state
  final GlobalKey<ExerciseLibraryScreenState> _libraryKey = GlobalKey<ExerciseLibraryScreenState>();

  void _navigateAndRefresh() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddExerciseScreen()),
    );

    // If a new exercise was added, call the refresh method on the child widget
    if (result == true) {
      _libraryKey.currentState?.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: widget.initialTabIndex,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.fitness_center), text: 'Ejercicios'),
              Tab(icon: Icon(Icons.local_library), text: 'Biblioteca'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _navigateAndRefresh,
              tooltip: 'Añadir Ejercicio',
            ),
          ],
        ),
        body: TabBarView(
          children: [
            // Placeholder for the main exercises/routines screen
            const Center(child: Text('Próximamente: Tus rutinas de ejercicio')),
            // Assign the key to the ExerciseLibraryScreen
            ExerciseLibraryScreen(key: _libraryKey),
          ],
        ),
      ),
    );
  }
}
