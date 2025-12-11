import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _MeditationScreenState extends State<MeditationScreen> with TickerProviderStateMixin {
  Timer? _timer;
  int _secondsElapsed = 0;
  int? _selectedDuration; // null = sin límite
  bool _isMeditating = false;
  bool _isPaused = false;
  DateTime? _startTime;
  String _meditationType = 'Libre';
  bool _isFullscreen = false;
  
  // Animación de respiración
  late AnimationController _breatheController;
  late Animation<double> _breatheAnimation;
  bool _showBreathingGuide = false;

  final List<int> _durations = [300, 600, 900, 1200, 1800]; // 5, 10, 15, 20, 30 min en segundos
  final List<String> _meditationTypes = [
    'Libre',
    'Mindfulness',
    'Respiración',
    'Body Scan',
    'Gratitud',
    'Visualización',
  ];

  final Map<String, String> _meditationDescriptions = {
    'Libre': 'Meditación sin estructura específica. Simplemente siéntate en silencio y observa tu experiencia presente.',
    'Mindfulness': 'Atención plena al momento presente. Observa tus pensamientos y sensaciones sin juzgar.',
    'Respiración': 'Enfoca toda tu atención en la respiración. Nota cada inhalación y exhalación.',
    'Body Scan': 'Escaneo corporal. Lleva tu atención a cada parte del cuerpo, desde los pies hasta la cabeza.',
    'Gratitud': 'Reflexiona sobre las cosas por las que estás agradecido. Cultiva sentimientos de aprecio.',
    'Visualización': 'Usa tu imaginación para visualizar escenas, lugares o situaciones que te traigan paz.',
  };

  @override
  void initState() {
    super.initState();
    _breatheController = AnimationController(
      duration: const Duration(seconds: 8), // 4s inhalar, 4s exhalar
      vsync: this,
    );
    _breatheAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );
  }

  void _toggleMeditation(BuildContext context) {
    if (_isMeditating) {
      _stopMeditation(context);
    } else {
      _startMeditation();
    }
  }

  void _startMeditation() {
    setState(() {
      _isMeditating = true;
      _isPaused = false;
      _secondsElapsed = 0;
      _startTime = DateTime.now();
    });

    if (_showBreathingGuide) {
      _breatheController.repeat(reverse: true);
    }

    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _secondsElapsed++;
        });

        // Verificar si se alcanzó la duración seleccionada
        if (_selectedDuration != null && _secondsElapsed >= _selectedDuration!) {
          _stopMeditation(context);
        }
      }
    });
  }

  void _stopMeditation(BuildContext context) {
    _timer?.cancel();
    _breatheController.stop();

    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }

    if (_secondsElapsed > 0) {
      // Vibración al finalizar
      HapticFeedback.mediumImpact();
      
      final provider = Provider.of<MeditationProvider>(context, listen: false);
      final endTime = DateTime.now();
      final startTime = endTime.subtract(Duration(seconds: _secondsElapsed));
      
      provider.addMeditationLog(startTime, endTime);

      // Mostrar mensaje de finalización
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '¡Sesión completada! ${_formatDuration(_secondsElapsed)} - $_meditationType',
              style: const TextStyle(fontSize: 16),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }

    setState(() {
      _isMeditating = false;
      _isPaused = false;
      _secondsElapsed = 0;
      _startTime = null;
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _breatheController.stop();
      } else {
        if (_showBreathingGuide) {
          _breatheController.repeat(reverse: true);
        }
      }
    });
    HapticFeedback.lightImpact();
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
    HapticFeedback.lightImpact();
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor().toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breatheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isFullscreen && _isMeditating) {
      return _buildFullscreenMode(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: null,
        actions: [
          if (_isMeditating)
            IconButton(
              icon: Icon(_isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen),
              onPressed: _toggleFullscreen,
              tooltip: _isFullscreen ? 'Salir pantalla completa' : 'Pantalla completa',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Selector de tipo de meditación
            if (!_isMeditating)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Tipo de meditación',
                          style: theme.textTheme.titleMedium,
                        ),
                        IconButton(
                          icon: const Icon(Icons.help_outline, size: 20),
                          onPressed: () => _showMeditationTypesInfo(context),
                          tooltip: 'Ver información sobre tipos de meditación',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _meditationTypes.map((type) {
                        final isSelected = _meditationType == type;
                        return FilterChip(
                          label: Text(
                            type,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          selectedColor: theme.colorScheme.primaryContainer,
                          checkmarkColor: theme.colorScheme.primary,
                          onSelected: (selected) {
                            setState(() {
                              _meditationType = type;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    if (_meditationType.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _meditationDescriptions[_meditationType] ?? '',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

          // Selector de duración
          if (!_isMeditating)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Duración',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: Text(
                          'Libre',
                          style: TextStyle(
                            fontWeight: _selectedDuration == null ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        selected: _selectedDuration == null,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        selectedColor: theme.colorScheme.primaryContainer,
                        checkmarkColor: theme.colorScheme.primary,
                        onSelected: (selected) {
                          setState(() {
                            _selectedDuration = null;
                          });
                        },
                      ),
                      ..._durations.map((seconds) {
                        final minutes = seconds ~/ 60;
                        final isSelected = _selectedDuration == seconds;
                        return FilterChip(
                          label: Text(
                            '$minutes min',
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          selectedColor: theme.colorScheme.primaryContainer,
                          checkmarkColor: theme.colorScheme.primary,
                          onSelected: (selected) {
                            setState(() {
                              _selectedDuration = seconds;
                            });
                          },
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),

          // Guía de respiración
          if (!_isMeditating)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SwitchListTile(
                title: const Text('Guía de respiración'),
                subtitle: const Text('Animación visual para respiración consciente'),
                value: _showBreathingGuide,
                onChanged: (value) {
                  setState(() {
                    _showBreathingGuide = value;
                  });
                },
              ),
            ),

          // Temporizador y animación
          SizedBox(
            height: _isMeditating ? MediaQuery.of(context).size.height - 200 : 300,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isMeditating && _showBreathingGuide)
                    _buildBreathingAnimation(),
                  
                  if (_isMeditating && _showBreathingGuide)
                    const SizedBox(height: 40)
                  else
                    const SizedBox(height: 20),
                  
                  Text(
                    _formatDuration(_secondsElapsed),
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  if (_selectedDuration != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'de ${_formatDuration(_selectedDuration!)}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 40),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isMeditating) ...[
                        ElevatedButton.icon(
                          onPressed: _togglePause,
                          icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                          label: Text(_isPaused ? 'Reanudar' : 'Pausar'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () => _toggleMeditation(context),
                          icon: const Icon(Icons.stop),
                          label: const Text('Finalizar'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            backgroundColor: theme.colorScheme.error,
                            foregroundColor: theme.colorScheme.onError,
                          ),
                        ),
                      ] else
                        ElevatedButton.icon(
                          onPressed: () => _toggleMeditation(context),
                          icon: const Icon(Icons.play_arrow),
                          label: Text(_selectedDuration == null 
                            ? 'Iniciar Sesión'
                            : 'Iniciar ${_selectedDuration! ~/ 60} min'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Historial de sesiones
          if (!_isMeditating)
            Padding(
              padding: const EdgeInsets.all(16.0),
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
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
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
      ),
    );
  }

  Widget _buildBreathingAnimation() {
    return AnimatedBuilder(
      animation: _breatheAnimation,
      builder: (context, child) {
        final progress = _breatheAnimation.value;
        final isInhaling = _breatheController.status == AnimationStatus.forward;
        
        return Column(
          children: [
            Container(
              width: 200 * progress,
              height: 200 * progress,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isInhaling ? 'Inhala...' : 'Exhala...',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFullscreenMode(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_showBreathingGuide)
                    _buildBreathingAnimation(),
                  
                  if (_showBreathingGuide)
                    const SizedBox(height: 60)
                  else
                    const SizedBox(height: 0),
                  
                  Text(
                    _formatDuration(_secondsElapsed),
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 72,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                  
                  if (_selectedDuration != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Text(
                        'de ${_formatDuration(_selectedDuration!)}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white.withOpacity(0.6),
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 80),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _togglePause,
                        icon: Icon(
                          _isPaused ? Icons.play_arrow : Icons.pause,
                          size: 48,
                        ),
                        color: Colors.white,
                        iconSize: 48,
                      ),
                      const SizedBox(width: 40),
                      IconButton(
                        onPressed: () => _toggleMeditation(context),
                        icon: const Icon(Icons.stop, size: 48),
                        color: Colors.redAccent,
                        iconSize: 48,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Botón salir pantalla completa
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                onPressed: _toggleFullscreen,
                icon: const Icon(Icons.fullscreen_exit),
                color: Colors.white.withOpacity(0.7),
                iconSize: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMeditationTypesInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tipos de Meditación'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: _meditationTypes.map((type) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _meditationDescriptions[type] ?? '',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}
