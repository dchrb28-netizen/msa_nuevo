import 'package:flutter/material.dart';
import 'package:myapp/models/exercise.dart';
import 'package:myapp/providers/exercise_provider.dart';
import 'package:myapp/screens/training/routines_screen.dart';
import 'package:myapp/screens/training/exercise_library_screen.dart';
import 'package:myapp/widgets/sub_tab_bar.dart';
import 'package:myapp/screens/training/edit_exercise_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({this.initialTabIndex = 0, super.key});

  final int initialTabIndex;

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      initialIndex: widget.initialTabIndex,
      length: 2,
      vsync: this,
    );
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _navigateAndAddExercise() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditExerciseScreen()),
    );

    if (result is Exercise) {
      // ignore: use_build_context_synchronously
      Provider.of<ExerciseProvider>(context, listen: false).addExercise(result);
    }
  }

  Widget? _getFloatingActionButton() {
    switch (_tabController.index) {
      case 0:
        // Floating action button for Routines tab is removed.
        return null;
      case 1:
        return FloatingActionButton.extended(
          onPressed: _navigateAndAddExercise,
          tooltip: 'Añadir Ejercicio',
          label: const Text('Añadir Ejercicio'),
          icon: const Icon(Icons.add),
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          bottom: SubTabBar(
            controller: _tabController,
            tabs: [
              Tab(icon: Icon(PhosphorIcons.listChecks()), text: 'Rutinas'),
              Tab(icon: Icon(PhosphorIcons.books()), text: 'Biblioteca'),
            ],
          ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [RoutinesScreen(), ExerciseLibraryScreen()],
      ),
      floatingActionButton: _getFloatingActionButton(),
    );
  }
}
