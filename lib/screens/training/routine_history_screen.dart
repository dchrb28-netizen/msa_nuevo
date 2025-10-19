import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/routine_log.dart';
import 'package:myapp/services/routine_history_service.dart';

class RoutineHistoryScreen extends StatefulWidget {
  const RoutineHistoryScreen({super.key});

  @override
  State<RoutineHistoryScreen> createState() => _RoutineHistoryScreenState();
}

class _RoutineHistoryScreenState extends State<RoutineHistoryScreen> {
  final RoutineHistoryService _historyService = RoutineHistoryService();
  List<RoutineLog> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await _historyService.getRoutineHistory();
    setState(() {
      _history = history.reversed.toList(); // Mostrar las más recientes primero
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Rutinas'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? const Center(
                  child: Text(
                    'Aún no has completado ninguna rutina.',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final log = _history[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text('Rutina del ${DateFormat('dd/MM/yyyy').format(log.date)}'),
                        subtitle: Text('${log.exercises.length} ejercicios'),
                        onTap: () {
                          // Opcional: Mostrar detalles de la rutina de ese día
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Ejercicios del ${DateFormat('dd/MM/yyyy').format(log.date)}'),
                              content: SizedBox(
                                width: double.maxFinite,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: log.exercises.length,
                                  itemBuilder: (context, i) {
                                    final exercise = log.exercises[i];
                                    return ListTile(title: Text(exercise.exerciseName));
                                  },
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cerrar'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
