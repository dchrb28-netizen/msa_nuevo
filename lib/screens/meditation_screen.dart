import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/providers/meditation_provider.dart';
import 'package:myapp/services/time_format_service.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isMeditating = false;
  DateTime? _startTime;

  void _toggleMeditation() {
    setState(() {
      _isMeditating = !_isMeditating;
      if (_isMeditating) {
        _startTime = DateTime.now();
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _secondsElapsed++;
          });
        });
      } else {
        _timer?.cancel();
        if (_startTime != null) {
          Provider.of<MeditationProvider>(context, listen: false)
              .addMeditationLog(_startTime!, DateTime.now());
        }
        _secondsElapsed = 0;
      }
    });
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor().toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Text(
                    _formatDuration(_secondsElapsed),
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _toggleMeditation,
                    child: Text(_isMeditating ? 'Finalizar Sesión' : 'Iniciar Sesión'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Consumer<MeditationProvider>(
              builder: (context, provider, child) {
                final logs = provider.meditationLogs;
                
                if (logs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'No hay sesiones de meditación registradas.\n¡Comienza tu primera sesión!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  );
                }
                
                return ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    return Dismissible(
                      key: Key(log.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirmar eliminación'),
                              content: const Text(
                                '¿Estás seguro de que deseas eliminar esta sesión de meditación?',
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Cancelar'),
                                  onPressed: () => Navigator.of(context).pop(false),
                                ),
                                TextButton(
                                  child: const Text(
                                    'Eliminar',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  onPressed: () => Navigator.of(context).pop(true),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      onDismissed: (direction) {
                        provider.deleteMeditationLog(log.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sesión eliminada'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: ListTile(
                        leading: const Icon(Icons.self_improvement),
                        title: Text('Meditación de ${_formatDuration(log.durationInSeconds)}'),
                        subtitle: Text(
                          '${DateFormat.yMMMd('es').format(log.startTime)} ${Provider.of<TimeFormatService>(context).formatTime(log.startTime)}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Confirmar eliminación'),
                                  content: const Text(
                                    '¿Estás seguro de que deseas eliminar esta sesión de meditación?',
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Cancelar'),
                                      onPressed: () => Navigator.of(context).pop(false),
                                    ),
                                    TextButton(
                                      child: const Text(
                                        'Eliminar',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      onPressed: () => Navigator.of(context).pop(true),
                                    ),
                                  ],
                                );
                              },
                            );
                            
                            if (confirm == true) {
                              provider.deleteMeditationLog(log.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Sesión eliminada'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
