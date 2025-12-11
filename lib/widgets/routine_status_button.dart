import 'package:flutter/material.dart';
import 'package:myapp/models/routine.dart';
import 'package:myapp/providers/routine_provider.dart';
import 'package:myapp/screens/training/workout_screen.dart';
import 'package:provider/provider.dart';

class RoutineStatusButton extends StatelessWidget {
  final Routine routine;
  const RoutineStatusButton({required this.routine, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final routineProvider = Provider.of<RoutineProvider>(context, listen: false);
    final logs = routineProvider.getRoutineLogsByDate(DateTime.now());
    final isDone = logs.any((log) => log.routineName == routine.name);
    return isDone
        ? Chip(
            label: const Text('Hecha', style: TextStyle(color: Colors.green)),
            backgroundColor: Colors.green.withOpacity(0.1),
          )
        : ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WorkoutScreen(routine: routine),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              textStyle: const TextStyle(fontSize: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Entrenar'),
          );
  }
}
