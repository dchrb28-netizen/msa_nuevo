import 'package:flutter/material.dart';
import 'package:myapp/models/exercise.dart';
import 'package:myapp/models/exercise_log.dart';
import 'package:myapp/models/routine_log.dart';
import 'package:myapp/models/set_log.dart';
import 'package:myapp/screens/training/create_routine_screen.dart';
import 'package:myapp/screens/training/exercise_library_screen.dart';
import 'package:myapp/screens/training/routine_history_screen.dart';
import 'package:myapp/services/routine_history_service.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  final RoutineHistoryService _historyService = RoutineHistoryService();
  List<ExerciseLog> _activeRoutine = [];

  void _createRoutine() async {
    final selectedExercises = await Navigator.push<List<Exercise>>(
      context,
      MaterialPageRoute(builder: (context) => const CreateRoutineScreen()),
    );

    if (selectedExercises != null) {
      setState(() {
        _activeRoutine = selectedExercises
            .map((e) => ExerciseLog(exerciseId: e.id, exerciseName: e.name, sets: []))
            .toList();
      });
    }
  }

  Future<void> _finishRoutine() async {
    final log = RoutineLog(date: DateTime.now(), exercises: _activeRoutine);
    await _historyService.saveRoutineLog(log);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Rutina finalizada! ¡Felicidades!')),
      );
    }

    setState(() {
      _activeRoutine = [];
    });
  }

  void _navigateToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RoutineHistoryScreen()),
    );
  }

  void _showAddSetDialog(ExerciseLog exerciseLog) {
    final repsController = TextEditingController();
    final weightController = TextEditingController();
    final timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Añadir Serie a ${exerciseLog.exerciseName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: repsController, decoration: const InputDecoration(labelText: 'Repeticiones'), keyboardType: TextInputType.number),
              TextField(controller: weightController, decoration: const InputDecoration(labelText: 'Peso (kg)'), keyboardType: TextInputType.number),
              TextField(controller: timeController, decoration: const InputDecoration(labelText: 'Tiempo (min)'), keyboardType: TextInputType.number),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
            TextButton(
              onPressed: () {
                final reps = int.tryParse(repsController.text);
                final weight = double.tryParse(weightController.text);
                final time = int.tryParse(timeController.text);

                if (reps != null || weight != null || time != null) {
                  setState(() {
                    exerciseLog.sets.add(SetLog(
                      reps: reps,
                      weight: weight,
                      time: time != null ? Duration(minutes: time) : null,
                    ));
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('Añadir'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // El Scaffold y la AppBar ahora se gestionan en MainScreen.
    // Este widget solo necesita devolver el TabBarView.
    return Scaffold(
      body: TabBarView(
        children: [
          _buildMyRoutineTab(),
          const ExerciseLibraryScreen(),
        ],
      ),
      floatingActionButton: DefaultTabController.of(context).index == 0
          ? FloatingActionButton(
              onPressed: _navigateToHistory,
              tooltip: 'Ver Historial',
              child: const Icon(Icons.history),
            )
          : null,
    );
  }

  Widget _buildMyRoutineTab() {
    final bool canFinish = _activeRoutine.isNotEmpty && _activeRoutine.every((log) => log.sets.isNotEmpty);

    if (_activeRoutine.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '¡Aún no has creado una rutina para hoy!',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createRoutine,
              child: const Text('Crear Rutina'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _activeRoutine.length,
            itemBuilder: (context, index) {
              final exerciseLog = _activeRoutine[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ExpansionTile(
                  title: Text(exerciseLog.exerciseName),
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: exerciseLog.sets.length,
                      itemBuilder: (context, setIndex) {
                        final set = exerciseLog.sets[setIndex];
                        return ListTile(
                          title: Text('Serie ${setIndex + 1}'),
                          subtitle: Text(
                            'Reps: ${set.reps ?? 'N/A'}, '
                            'Peso: ${set.weight ?? 'N/A'} kg, '
                            'Tiempo: ${set.time?.inMinutes ?? 'N/A'} min'
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Añadir Serie'),
                        onPressed: () => _showAddSetDialog(exerciseLog),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: canFinish ? _finishRoutine : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              textStyle: const TextStyle(fontSize: 16),
            ),
            child: const Text('Finalizar Rutina'),
          ),
        ),
      ],
    );
  }
}
