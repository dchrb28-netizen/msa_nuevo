import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:myapp/providers/meditation_provider.dart';
import 'package:myapp/services/time_format_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

// ignore_for_file: unused_field, expected_token, missing_identifier, unexpected_token, expected_class_member, undefined_identifier, expected_executable

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen>
    with TickerProviderStateMixin {
  Timer? _timer;
  int _secondsElapsed = 0;
  int? _selectedDuration; // null = sin límite
  bool _isMeditating = false;
  bool _isPaused = false;
  DateTime? _startTime;
  String _meditationType = 'Libre';
  bool _isFullscreen = false;
  String _breathingLevel = 'Principiante';
  int _breathingSeconds = 4;

  // Animación de respiración
  late AnimationController _breatheController;
  late Animation<double> _breatheAnimation;
  bool _showBreathingGuide = false;

  final List<int> _durations = [
    300,
    600,
    900,
    1200,
    1800
  ]; // 5, 10, 15, 20, 30 min en segundos
  late final List<String> _meditationTypes = [
    'Libre',
    'Mindfulness',
    'Respiración',
    'Body Scan',
    'Gratitud',
    'Visualización',
  ];

  late final Map<String, String> _meditationDescriptions = {
    'Libre':
        'Meditación sin estructura específica. Simplemente siéntate en silencio y observa tu experiencia presente.',
    'Mindfulness':
        'Atención plena al momento presente. Observa tus pensamientos y sensaciones sin juzgar.',
    'Respiración':
        'Enfoca toda tu atención en la respiración. Nota cada inhalación y exhalación.',
    'Body Scan':
        'Escaneo corporal. Lleva tu atención a cada parte del cuerpo, desde los pies hasta la cabeza.',
    'Gratitud':
        'Reflexiona sobre las cosas por las que estás agradecido. Cultiva sentimientos de aprecio.',
    'Visualización':
        'Usa tu imaginación para visualizar escenas, lugares o situaciones que te traigan paz.',
  };

  final Map<String, IconData> _meditationIcons = {
    'Libre': Icons.self_improvement,
    'Mindfulness': Icons.psychology,
    'Respiración': Icons.air,
    'Body Scan': Icons.accessibility_new,
    'Gratitud': Icons.favorite,
    'Visualización': Icons.remove_red_eye,
  };

  @override
  void initState() {
    super.initState();
    _breatheController = AnimationController(
      duration: Duration(seconds: _breathingSeconds),
      vsync: this,
    );
    _breatheAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );
    _loadBreathingGuidePreference();
  }

  Future<void> _loadBreathingGuidePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showBreathingGuide = prefs.getBool('showBreathingGuide') ?? false;
    });
  }

  Future<void> _saveBreathingGuidePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showBreathingGuide', value);
  }

  void _setBreathingLevel(String level) {
    int seconds;
    switch (level) {
      case 'Intermedio':
        seconds = 6;
        break;
      case 'Avanzado':
        seconds = 8;
        break;
      case 'Principiante':
      default:
        seconds = 4;
    }

    setState(() {
      _breathingLevel = level;
      _breathingSeconds = seconds;
      _breatheController.duration = Duration(seconds: _breathingSeconds);
    });

    if (_isMeditating && _showBreathingGuide) {
      _breatheController
        ..reset()
        ..repeat(reverse: true);
    }
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
        if (_selectedDuration != null &&
            _secondsElapsed >= _selectedDuration!) {
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
    final isDark = theme.brightness == Brightness.dark;

    if (_isFullscreen && _isMeditating) {
      return _buildFullscreenMode(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: const SizedBox.shrink(),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        actions: [
          if (_isMeditating)
            IconButton(
              icon: Icon(
                  _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen),
              onPressed: _toggleFullscreen,
              tooltip: _isFullscreen
                  ? 'Salir pantalla completa'
                  : 'Pantalla completa',
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _isMeditating
                ? [
                    const Color(0xFF2d3561),
                    const Color(0xFF3d4a7f),
                  ]
                : (isDark
                    ? [
                        theme.colorScheme.surface,
                        theme.colorScheme.surfaceContainerHighest
                            .withOpacity(0.6),
                      ]
                    : [
                        theme.colorScheme.surface,
                        theme.colorScheme.surface,
                      ]),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Selector de tipo de meditación
              if (!_isMeditating)
                Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.15),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.spa,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Tipo de meditación',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                padding: EdgeInsets.all(4),
                                constraints: BoxConstraints(),
                                icon: Icon(
                                  Icons.help_outline,
                                  size: 16,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                                onPressed: () =>
                                    _showMeditationTypesInfo(context),
                                tooltip:
                                    'Ver información sobre tipos de meditación',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 3.0,
                          children: _meditationTypes.map((type) {
                            final isSelected = _meditationType == type;
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _meditationType = type;
                                });
                                HapticFeedback.lightImpact();
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(
                                          colors: [
                                            theme.colorScheme.primary,
                                            theme.colorScheme.primary
                                                .withOpacity(0.8),
                                          ],
                                        )
                                      : null,
                                  color: isSelected
                                      ? null
                                      : theme
                                          .colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.outline
                                            .withOpacity(0.2),
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: theme.colorScheme.primary
                                                .withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _meditationIcons[type],
                                      size: 15,
                                      color: isSelected
                                          ? theme.colorScheme.onPrimary
                                          : theme.colorScheme.onSurface,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        type,
                                        style: TextStyle(
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                          fontSize: 12,
                                          color: isSelected
                                              ? theme.colorScheme.onPrimary
                                              : theme.colorScheme.onSurface,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        if (_meditationType.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 10.0),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer
                                  .withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color:
                                    theme.colorScheme.primary.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  size: 16,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _meditationDescriptions[_meditationType] ??
                                        '',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.8),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

              // Selector de duración
              if (!_isMeditating)
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.15),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.timer,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Duración',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 3,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 2.2,
                          children: [
                            _buildDurationChip(context, null, 'Libre'),
                            ..._durations.map((seconds) {
                              final minutes = seconds ~/ 60;
                              return _buildDurationChip(
                                  context, seconds, '$minutes min');
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              // Guía de respiración
              if (!_isMeditating)
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.15),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.air,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Guía de respiración',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  Text(
                                    'Animación visual para respiración consciente',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _showBreathingGuide,
                              onChanged: (value) {
                                setState(() {
                                  _showBreathingGuide = value;
                                });
                                _saveBreathingGuidePreference(value);
                              },
                            ),
                          ],
                        ),
                        if (_showBreathingGuide) ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          Text(
                            'Ritmo de respiración',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: ['Principiante', 'Intermedio', 'Avanzado']
                                .map((level) {
                              final isSelected = _breathingLevel == level;
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: level == 'Avanzado' ? 0 : 10,
                                  ),
                                  child: InkWell(
                                    onTap: () => _setBreathingLevel(level),
                                    borderRadius: BorderRadius.circular(12),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: isSelected
                                            ? LinearGradient(
                                                colors: [
                                                  theme.colorScheme.secondary,
                                                  theme.colorScheme.secondary
                                                      .withOpacity(0.8),
                                                ],
                                              )
                                            : null,
                                        color: isSelected
                                            ? null
                                            : theme.colorScheme
                                                .surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected
                                              ? theme.colorScheme.secondary
                                              : theme.colorScheme.outline
                                                  .withOpacity(0.2),
                                          width: isSelected ? 2 : 1,
                                        ),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: theme
                                                      .colorScheme.secondary
                                                      .withOpacity(0.3),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          level,
                                          style: TextStyle(
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? theme.colorScheme.onSecondary
                                                : theme.colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

              // Temporizador y animación
              Container(
                height: _isMeditating
                    ? MediaQuery.of(context).size.height - 180
                    : 200,
                margin: _isMeditating
                    ? EdgeInsets.zero
                    : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _isMeditating
                        ? [
                            const Color(0xFF2d3561),
                            const Color(0xFF3d4a7f),
                          ]
                        : [
                            Colors.black.withOpacity(0.3),
                            Colors.black.withOpacity(0.2),
                          ],
                  ),
                  borderRadius: _isMeditating
                      ? BorderRadius.zero
                      : BorderRadius.circular(30),
                  boxShadow: _isMeditating
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.cyan.withOpacity(0.1),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isMeditating && _showBreathingGuide)
                        _buildBreathingAnimation()
                      else if (_isMeditating)
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.cyan.withOpacity(0.25),
                                Colors.cyan.withOpacity(0.08),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.self_improvement,
                              size: 60,
                              color: Colors.cyan,
                            ),
                          ),
                        ),
                      if (_isMeditating && _showBreathingGuide)
                        const SizedBox(height: 24)
                      else if (_isMeditating)
                        const SizedBox(height: 16)
                      else
                        const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.cyan.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: Text(
                          _formatDuration(_secondsElapsed),
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 36,
                            letterSpacing: 3,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (_selectedDuration != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'de ${_formatDuration(_selectedDuration!)}',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.cyan,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      if (_isMeditating && _meditationType.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Text(
                            'Meditación: $_meditationType',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.cyan,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isMeditating) ...[
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isDark
                                      ? [
                                          theme.colorScheme.secondaryContainer,
                                          theme.colorScheme.secondary
                                              .withOpacity(0.9),
                                        ]
                                      : [
                                          Colors.amber.shade600,
                                          Colors.amber.shade700,
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.amber.withOpacity(0.5),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: _togglePause,
                                icon: Icon(
                                  _isPaused ? Icons.play_arrow : Icons.pause,
                                  size: 28,
                                ),
                                label: Text(
                                  _isPaused ? 'Reanudar' : 'Pausar',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 16),
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.red.shade600,
                                    Colors.red.shade700,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.5),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: () => _toggleMeditation(context),
                                icon: const Icon(Icons.stop, size: 28),
                                label: const Text(
                                  'Finalizar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 16),
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ] else
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.cyan,
                                    Colors.cyan.withOpacity(0.7),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.cyan.withOpacity(0.5),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: () => _toggleMeditation(context),
                                icon: const Icon(Icons.play_arrow, size: 32),
                                label: Text(
                                  _selectedDuration == null
                                      ? 'Iniciar Sesión'
                                      : 'Iniciar ${_selectedDuration! ~/ 60} min',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 20),
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                ),
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
                Container(
                  margin: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Consumer<MeditationProvider>(
                      builder: (context, provider, child) {
                        final logs = provider.meditationLogs;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.history,
                                  color: theme.colorScheme.primary,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Historial de sesiones',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (logs.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 32.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.self_improvement_outlined,
                                        size: 64,
                                        color: theme.colorScheme.primary
                                            .withOpacity(0.3),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No hay sesiones de meditación registradas',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: theme.colorScheme.onSurface
                                              .withOpacity(0.6),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '¡Comienza tu primera sesión!',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: logs.length,
                                separatorBuilder: (context, index) => Divider(
                                  height: 1,
                                  color: theme.colorScheme.outline
                                      .withOpacity(0.2),
                                ),
                                itemBuilder: (context, index) {
                                  final log = logs[index];
                                  return Dismissible(
                                    key: Key(log.id),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 20),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            theme.colorScheme.error,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.delete_sweep,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ),
                                    confirmDismiss: (direction) async {
                                      return await showDialog<bool>(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text(
                                                'Confirmar eliminación'),
                                            content: const Text(
                                              '¿Estás seguro de que deseas eliminar esta sesión de meditación?',
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                child: const Text('Cancelar'),
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(false),
                                              ),
                                              TextButton(
                                                child: Text(
                                                  'Eliminar',
                                                  style: TextStyle(
                                                      color: theme
                                                          .colorScheme.error),
                                                ),
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(true),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    onDismissed: (direction) {
                                      provider.deleteMeditationLog(log.id);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              const Text('Sesión eliminada'),
                                          duration: const Duration(seconds: 2),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: theme
                                            .colorScheme.surfaceContainerHighest
                                            .withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  theme.colorScheme.primary
                                                      .withOpacity(0.2),
                                                  theme.colorScheme.primary
                                                      .withOpacity(0.1),
                                                ],
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.self_improvement,
                                              color: theme.colorScheme.primary,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Meditación de ${_formatDuration(log.durationInSeconds)}',
                                                  style: theme
                                                      .textTheme.titleMedium
                                                      ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${DateFormat.yMMMd('es').format(log.startTime)} ${Provider.of<TimeFormatService>(context).formatTime(log.startTime)}',
                                                  style: theme
                                                      .textTheme.bodySmall
                                                      ?.copyWith(
                                                    color: theme
                                                        .colorScheme.onSurface
                                                        .withOpacity(0.6),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.delete_outline),
                                            color: theme.colorScheme.error
                                                .withOpacity(0.7),
                                            onPressed: () async {
                                              final confirm =
                                                  await showDialog<bool>(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Confirmar eliminación'),
                                                    content: const Text(
                                                      '¿Estás seguro de que deseas eliminar esta sesión de meditación?',
                                                    ),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        child: const Text(
                                                            'Cancelar'),
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(false),
                                                      ),
                                                      TextButton(
                                                        child: Text(
                                                          'Eliminar',
                                                          style: TextStyle(
                                                              color: theme
                                                                  .colorScheme
                                                                  .error),
                                                        ),
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(true),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );

                                              if (confirm == true) {
                                                provider.deleteMeditationLog(
                                                    log.id);
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: const Text(
                                                          'Sesión eliminada'),
                                                      duration: const Duration(
                                                          seconds: 2),
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDurationChip(BuildContext context, int? seconds, String label) {
    final theme = Theme.of(context);
    final isSelected = _selectedDuration == seconds;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedDuration = seconds;
        });
        HapticFeedback.lightImpact();
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.8),
                  ],
                )
              : null,
          color: isSelected ? null : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildFullscreenMode(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF2d3561),
              const Color(0xFF3d4a7f),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_showBreathingGuide)
                      _buildBreathingAnimation()
                    else
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.cyan.withOpacity(0.25),
                              Colors.cyan.withOpacity(0.08),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.self_improvement,
                            size: 80,
                            color: Colors.cyan,
                          ),
                        ),
                      ),
                    const SizedBox(height: 60),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.cyan.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _formatDuration(_secondsElapsed),
                            style: theme.textTheme.displaySmall?.copyWith(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3,
                            ),
                          ),
                          if (_selectedDuration != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'de ${_formatDuration(_selectedDuration!)}',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: Colors.cyan.withOpacity(0.8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (_meditationType.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          'Meditación: $_meditationType',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.cyan,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.cyan.withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isPaused ? Icons.pause_circle : Icons.play_circle,
                            color: Colors.cyan,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isPaused ? 'Pausado' : 'En progreso',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.cyan,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.amber.shade600,
                                Colors.amber.shade700,
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withOpacity(0.6),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: _togglePause,
                            icon: Icon(
                              _isPaused ? Icons.play_arrow : Icons.pause,
                              size: 40,
                              color: Colors.white,
                            ),
                            iconSize: 60,
                          ),
                        ),
                        const SizedBox(width: 50),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.red.shade600,
                                Colors.red.shade700,
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.6),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: () => _toggleMeditation(context),
                            icon: const Icon(
                              Icons.stop,
                              size: 40,
                              color: Colors.white,
                            ),
                            iconSize: 60,
                          ),
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
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _toggleFullscreen,
                    icon: Icon(
                      Icons.fullscreen_exit,
                      color: theme.colorScheme.onSurface,
                    ),
                    iconSize: 28,
                  ),
                ),
              ),
            ],
          ),
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
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        const accent = Colors.cyan;

        return Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 280 * progress,
                  height: 280 * progress,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accent.withOpacity(0.15),
                        accent.withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 240 * progress,
                  height: 240 * progress,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accent.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                ),
                Container(
                  width: 200 * progress,
                  height: 200 * progress,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accent.withOpacity(0.35),
                        accent.withOpacity(0.2),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withOpacity(0.5 * progress),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
                Transform.scale(
                  scale: 0.9 + (progress * 0.1),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          accent.withOpacity(0.45),
                          accent.withOpacity(0.25),
                        ],
                      ),
                      border: Border.all(
                        color: accent.withOpacity(0.8 * progress),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withOpacity(0.6 * progress),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isInhaling
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            color: Colors.white,
                            size: 48,
                            shadows: [
                              Shadow(
                                color: accent,
                                blurRadius: 20,
                              ),
                              Shadow(
                                color: accent.withOpacity(0.8),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isInhaling ? 'Inhala' : 'Exhala',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              letterSpacing: 2,
                              shadows: [
                                Shadow(
                                  color: accent,
                                  blurRadius: 15,
                                ),
                                Shadow(
                                  color: accent.withOpacity(0.8),
                                  blurRadius: 8,
                                ),
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: accent.withOpacity(0.6),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.self_improvement,
                    color: accent,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isInhaling
                        ? 'Inhala ${_breathingSeconds}s'
                        : 'Exhala ${_breathingSeconds}s',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: accent,
                          letterSpacing: 1,
                        ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
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
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
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
