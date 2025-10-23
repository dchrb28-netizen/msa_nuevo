import 'package:flutter/material.dart';
import 'package:myapp/models/routine.dart';
import 'package:myapp/models/routine_log.dart';
import 'package:myapp/models/exercise_log.dart';
import 'package:myapp/models/set_log.dart';
import 'package:myapp/providers/routine_provider.dart';
import 'package:provider/provider.dart';

class WorkoutScreen extends StatefulWidget {
  final Routine routine;

  const WorkoutScreen({super.key, required this.routine});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  late List<ExerciseLog> _exerciseLogs;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _exerciseLogs = widget.routine.exercises.map((exercise) {
      return ExerciseLog(exercise: exercise, sets: [SetLog(reps: 0, weight: 0)]);
    }).toList();
  }

  void _finishWorkout() {
    final routineLog = RoutineLog(
      date: DateTime.now(),
      routineName: widget.routine.name,
      exerciseLogs: _exerciseLogs,
      notes: _notesController.text,
    );
    Provider.of<RoutineProvider>(context, listen: false).addRoutineLog(routineLog);

    // Pop until we get back to the main screen
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _addSet(int exerciseIndex) {
    setState(() {
      _exerciseLogs[exerciseIndex].sets.add(SetLog(reps: 0, weight: 0));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.routine.name),
        actions: [
          TextButton(
            onPressed: _finishWorkout,
            child: const Text('Finalizar', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: _exerciseLogs.length + 1, // +1 for the notes field
          itemBuilder: (context, index) {
            if (index == _exerciseLogs.length) {
              // This is the last item, show the notes field
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notas del entrenamiento (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              );
            }

            // Exercise log item
            final exerciseLog = _exerciseLogs[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ExpansionTile(
                title: Text(exerciseLog.exercise.name, style: Theme.of(context).textTheme.titleLarge),
                children: [
                  _buildSetList(index),
                  TextButton(
                    onPressed: () => _addSet(index),
                    child: const Text('Añadir Serie'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSetList(int exerciseIndex) {
    final sets = _exerciseLogs[exerciseIndex].sets;
    return ListView.builder(
      shrinkWrap: true, // Important to make it work inside ExpansionTile
      physics: const NeverScrollableScrollPhysics(), // Disable scrolling of the inner list
      itemCount: sets.length,
      itemBuilder: (context, setIndex) {
        final currentSet = sets[setIndex];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Serie ${setIndex + 1}'),
              Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: TextFormField(
                      initialValue: currentSet.reps.toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Reps'),
                      onChanged: (value) {
                        setState(() {
                          final reps = int.tryParse(value) ?? 0;
                          sets[setIndex] = SetLog(reps: reps, weight: currentSet.weight);
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 80,
                    child: TextFormField(
                      initialValue: currentSet.weight.toString(),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Peso (kg)'),
                      onChanged: (value) {
                        setState(() {
                          final weight = double.tryParse(value) ?? 0;
                          sets[setIndex] = SetLog(reps: currentSet.reps, weight: weight);
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      setState(() {
                        _exerciseLogs[exerciseIndex].sets.removeAt(setIndex);
                      });
                    },
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
