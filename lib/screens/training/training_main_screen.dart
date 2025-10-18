import 'package:flutter/material.dart';
import 'package:myapp/screens/training/add_exercise_screen.dart';
import 'package:myapp/screens/training/exercise_library_screen.dart';
import 'package:myapp/screens/training/exercises_screen.dart';

class TrainingMainScreen extends StatefulWidget {
  final int initialTabIndex;
  const TrainingMainScreen({super.key, this.initialTabIndex = 0});

  @override
  State<TrainingMainScreen> createState() => _TrainingMainScreenState();
}

class _TrainingMainScreenState extends State<TrainingMainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _exerciseLibraryKey = GlobalKey<ExerciseLibraryScreenState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTabIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToAddExercise() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddExerciseScreen()),
    );

    if (result == true && mounted) {
      if (_tabController.index == 1) {
        // Refresh the library
        _exerciseLibraryKey.currentState?.loadExercises();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // No title
        automaticallyImplyLeading: true, // Show back button
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.fitness_center), text: 'Ejercicios'),
            Tab(icon: Icon(Icons.local_library), text: 'Biblioteca'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const ExercisesScreen(),
          ExerciseLibraryScreen(key: _exerciseLibraryKey),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddExercise,
        tooltip: 'Añadir Ejercicio',
        child: const Icon(Icons.add),
      ),
    );
  }
}
