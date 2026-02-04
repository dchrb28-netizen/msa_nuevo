import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:file_saver/file_saver.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/models/daily_task.dart';
import 'package:intl/intl.dart';

// Widget que se usa como Tab en la pantalla de Tareas
class MonthCalendarTab extends StatefulWidget {
  const MonthCalendarTab({super.key});

  @override
  State<MonthCalendarTab> createState() => _MonthCalendarTabState();
}

class _MonthCalendarTabState extends State<MonthCalendarTab> {
  late DateTime _currentMonth;
  int? _selectedDay;
  bool _showRing = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
    
    // Cargar la preferencia de vista guardada
    final settingsBox = Hive.box('settings');
    _showRing = settingsBox.get('month_view_ring', defaultValue: false) as bool;
  }

  List<DailyTask> _getDayTasks(List<DailyTask> tasks, DateTime date) {
    return tasks.where((task) {
      if (task.repeatType == TaskRepeatType.weekly) {
        return task.shouldShowOnDay(date);
      } else {
        // Para tareas únicas (TaskRepeatType.once)
        if (task.dueDate == null) {
          // Si no tiene fecha específica, mostrarla hoy
          final today = DateTime.now();
          return date.year == today.year && 
                 date.month == today.month && 
                 date.day == today.day;
        }
        final taskDate = DateFormat('yyyy-MM-dd').format(task.dueDate!);
        final dateStr = DateFormat('yyyy-MM-dd').format(date);
        return taskDate == dateStr;
      }
    }).toList();
  }

  _DayStats _getDayStats(List<DailyTask> tasks, DateTime date) {
    final dayTasks = _getDayTasks(tasks, date);
    if (dayTasks.isEmpty) {
      return const _DayStats(total: 0, completed: 0);
    }
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final completed = dayTasks.where((task) {
      if (task.repeatType == TaskRepeatType.weekly) {
        // Para tareas repetidas, verificar completedDates
        return task.completedDates
            .any((completedDate) => completedDate.startsWith(dateStr));
      } else {
        // Para tareas únicas, verificar el campo completed
        return task.completed;
      }
    }).length;
    return _DayStats(total: dayTasks.length, completed: completed);
  }

  String _goalKey(DateTime month) {
    return 'monthly_tasks_goal_${month.year}_${month.month}';
  }

  int _getMonthlyGoal(Box settingsBox, DateTime month, int fallback) {
    return settingsBox.get(_goalKey(month), defaultValue: fallback) as int;
  }

  Future<void> _exportMonthCsv(
    List<DailyTask> tasks,
    DateTime month,
  ) async {
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final rows = <List<String>>[
      ['Fecha', 'Total', 'Completadas', 'Pendientes', 'Tareas'],
    ];

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      final stats = _getDayStats(tasks, date);
      final dayTasks = _getDayTasks(tasks, date);
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final completedTitles = dayTasks.where((task) {
        if (task.repeatType == TaskRepeatType.weekly) {
          return task.completedDates
              .any((completedDate) => completedDate.startsWith(dateStr));
        } else {
          return task.completed;
        }
      }).map((t) => t.title).toList();
      final pendingTitles = dayTasks.where((task) {
        if (task.repeatType == TaskRepeatType.weekly) {
          return !task.completedDates
              .any((completedDate) => completedDate.startsWith(dateStr));
        } else {
          return !task.completed;
        }
      }).map((t) => t.title).toList();
      final tasksText = [
        if (completedTitles.isNotEmpty)
          'Completadas: ${completedTitles.join(" | ")}',
        if (pendingTitles.isNotEmpty)
          'Pendientes: ${pendingTitles.join(" | ")}',
      ].join(' / ');

      rows.add([
        dateStr,
        stats.total.toString(),
        stats.completed.toString(),
        (stats.total - stats.completed).toString(),
        tasksText,
      ]);
    }

    final csv = rows.map((row) => row.map(_escapeCsv).join(',')).join('\n');
    final bytes = Uint8List.fromList(utf8.encode(csv));
    await FileSaver.instance.saveFile(
      name:
          'tareas_${month.year}_${month.month.toString().padLeft(2, '0')}.csv',
      bytes: bytes,
      mimeType: MimeType.csv,
    );
  }

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  List<DateTime> _getWeekDays(DateTime date) {
    final weekday = date.weekday; // 1=Mon..7=Sun
    final monday = date.subtract(Duration(days: weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  Widget _buildWeekSummary(
    List<DailyTask> tasks,
    DateTime referenceDate,
    ColorScheme colorScheme,
  ) {
    final weekDays = _getWeekDays(referenceDate);
    const labels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen semanal',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final day = weekDays[index];
                final stats = _getDayStats(tasks, day);
                final ratio = stats.total == 0
                    ? 0.0
                    : stats.completed / stats.total;
                return Column(
                  children: [
                    Text(labels[index],
                        style: Theme.of(context).textTheme.labelSmall),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        value: ratio,
                        strokeWidth: 4,
                        backgroundColor:
                            colorScheme.surfaceContainerHighest.withAlpha(100),
                        valueColor:
                            AlwaysStoppedAnimation(colorScheme.primary),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${stats.completed}/${stats.total}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthRing(
    List<_DayStatus> statuses,
    ColorScheme colorScheme,
  ) {
    final daysInMonth = statuses.length;
    final completedDays = statuses.where((s) => s == _DayStatus.completed).length;
    final pendingDays = statuses.where((s) => s == _DayStatus.pending).length;
    final noDaysTasks = statuses.where((s) => s == _DayStatus.none).length;
    final percentage = daysInMonth > 0 ? ((completedDays / daysInMonth) * 100).toInt() : 0;
    
    return Column(
      children: [
        SizedBox(
          height: 320,
          child: CustomPaint(
            painter: _MonthRingPainter(statuses, colorScheme, daysInMonth),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$percentage%',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                  ),
                  Text(
                    DateFormat('MMMM', 'es_ES').format(_currentMonth),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Estadísticas
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withAlpha(80),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(height: 4),
                  Text(
                    '$completedDays',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'Completados',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
              Column(
                children: [
                  Icon(Icons.radio_button_unchecked, color: Colors.red.withAlpha(200), size: 20),
                  const SizedBox(height: 4),
                  Text(
                    '$pendingDays',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'Pendientes',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
              Column(
                children: [
                  Icon(Icons.remove_circle_outline, color: colorScheme.onSurface.withAlpha(120), size: 20),
                  const SizedBox(height: 4),
                  Text(
                    '$noDaysTasks',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'Sin tareas',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ValueListenableBuilder(
      valueListenable: Hive.box('daily_tasks').listenable(),
      builder: (context, box, _) {
        final taskValues = box.values.toList();
        final tasks = taskValues.map((item) {
          if (item is DailyTask) {
            return item;
          } else if (item is Map<dynamic, dynamic>) {
            return DailyTask.fromMap(item);
          }
          return null;
        }).whereType<DailyTask>().toList();

        final settingsBox = Hive.box('settings');

        final daysInMonth =
            DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);

        // Calcular estadísticas del mes
        int totalDays = 0;
        int completedDays = 0;
        int currentStreak = 0;
        int maxStreak = 0;
        int tempStreak = 0;
        final dayStatuses = <_DayStatus>[];

        for (int day = 1; day <= daysInMonth; day++) {
          final date = DateTime(_currentMonth.year, _currentMonth.month, day);
          final stats = _getDayStats(tasks, date);
          final hasTasks = stats.total > 0;
          if (!hasTasks) {
            dayStatuses.add(_DayStatus.none);
            continue;
          }

          totalDays++;
          final allCompleted = stats.completed == stats.total;
          dayStatuses.add(allCompleted ? _DayStatus.completed : _DayStatus.pending);

          if (allCompleted) {
            completedDays++;
            tempStreak++;
            if (date.isBefore(DateTime.now())) {
              currentStreak = tempStreak;
            }
          } else {
            if (tempStreak > maxStreak) {
              maxStreak = tempStreak;
            }
            tempStreak = 0;
            if (date.isBefore(DateTime.now())) {
              currentStreak = 0;
            }
          }
        }

        if (tempStreak > maxStreak) {
          maxStreak = tempStreak;
        }

        final monthlyGoal =
            _getMonthlyGoal(settingsBox, _currentMonth, totalDays);
        final goalProgress = monthlyGoal == 0
            ? 0.0
            : (completedDays / monthlyGoal).clamp(0.0, 1.0);
        final safeDay = _selectedDay ?? DateTime.now().day;
        final clampedDay =
          safeDay > daysInMonth ? daysInMonth : (safeDay < 1 ? 1 : safeDay);
        final referenceDay =
          DateTime(_currentMonth.year, _currentMonth.month, clampedDay);

        // Si hoy no ha completado, reinicia la racha
        final today = DateTime.now();
        if (today.month == _currentMonth.month &&
            today.year == _currentMonth.year) {
          final todayStr = DateFormat('yyyy-MM-dd').format(today);
          final todayTasks = _getDayTasks(tasks, today);

          if (todayTasks.isNotEmpty) {
            final allCompleted = todayTasks.every((task) =>
                task.completedDates.any((dateStr) => dateStr.startsWith(todayStr)));
            if (!allCompleted) {
              currentStreak = 0;
            }
          }
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado con navegación de meses
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        setState(() {
                          _currentMonth = DateTime(
                            _currentMonth.year,
                            _currentMonth.month - 1,
                          );
                        });
                      },
                    ),
                    Text(
                      DateFormat('MMMM yyyy', 'es_ES').format(_currentMonth),
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Exportar CSV',
                          icon: const Icon(Icons.download),
                          onPressed: () => _exportMonthCsv(tasks, _currentMonth),
                        ),
                        IconButton(
                          icon: const Icon(Icons.today),
                          onPressed: () {
                            final now = DateTime.now();
                            setState(() {
                              _currentMonth = DateTime(now.year, now.month);
                              _selectedDay = now.day;
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () {
                            setState(() {
                              _currentMonth = DateTime(
                                _currentMonth.year,
                                _currentMonth.month + 1,
                              );
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Center(
                  child: ToggleButtons(
                    isSelected: [_showRing, !_showRing],
                    onPressed: (index) {
                      setState(() {
                        _showRing = index == 0;
                        // Guardar la preferencia del usuario
                        final settingsBox = Hive.box('settings');
                        settingsBox.put('month_view_ring', _showRing);
                      });
                    },
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('Circular'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('Grid'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Tarjeta de estadísticas
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatCard(
                              label: 'Completados',
                              value: '$completedDays/$totalDays',
                              color: colorScheme.primary,
                            ),
                            _StatCard(
                              label: 'Racha Actual',
                              value: '$currentStreak',
                              color: Colors.amber,
                            ),
                            _StatCard(
                              label: 'Mejor Racha',
                              value: '$maxStreak',
                              color: Colors.green,
                            ),
                          ],
                        ),
                        if (totalDays > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    minHeight: 8,
                                    value: totalDays > 0
                                        ? completedDays / totalDays
                                        : 0,
                                    backgroundColor: colorScheme
                                        .surfaceContainerHighest
                                        .withAlpha(100),
                                    valueColor: AlwaysStoppedAnimation(
                                        colorScheme.primary),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${((completedDays / totalDays) * 100).toStringAsFixed(0)}% de progreso',
                                  style: theme.textTheme.labelSmall,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildWeekSummary(
                  tasks,
                  referenceDay,
                  colorScheme,
                ),
                const SizedBox(height: 16),
                if (_showRing) ...[
                  const SizedBox(height: 16),
                  _buildMonthRing(dayStatuses, colorScheme),
                ] else ...[
                  const SizedBox(height: 24),
                  // Grid de días
                  Text(
                    'Progreso del Mes',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: daysInMonth,
                    itemBuilder: (context, index) {
                      final day = index + 1;
                      final date = DateTime(
                        _currentMonth.year,
                        _currentMonth.month,
                        day,
                      );
                      final dateStr = DateFormat('yyyy-MM-dd').format(date);

                      final stats = _getDayStats(tasks, date);
                      final allCompleted =
                        stats.total > 0 && stats.completed == stats.total;

                      Color backgroundColor;
                      Color textColor;

                      if (stats.total == 0) {
                        backgroundColor = colorScheme.surfaceContainerHighest
                            .withAlpha(50);
                        textColor = colorScheme.onSurface.withAlpha(100);
                      } else if (allCompleted) {
                        backgroundColor = Colors.green;
                        textColor = Colors.white;
                      } else if (date.isBefore(DateTime.now())) {
                        backgroundColor = Colors.red.withAlpha(200);
                        textColor = Colors.white;
                      } else {
                        backgroundColor = colorScheme.surfaceContainerHighest;
                        textColor = colorScheme.onSurface;
                      }

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDay = _selectedDay == day ? null : day;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border: _selectedDay == day
                                ? Border.all(
                                    color: colorScheme.primary,
                                    width: 3,
                                  )
                                : null,
                            boxShadow: _selectedDay == day
                                ? [
                                    BoxShadow(
                                      color: colorScheme.primary.withAlpha(100),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$day',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              if (stats.total > 0)
                                Text(
                                  '${stats.completed}/${stats.total}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: textColor,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
                if (!_showRing) ...[
                  const SizedBox(height: 24),
                  // Detalle del día seleccionado
                  if (_selectedDay != null)
                    _DayDetailCard(
                      date: DateTime(
                        _currentMonth.year,
                        _currentMonth.month,
                        _selectedDay!,
                      ),
                      tasks: tasks,
                    ),
                  const SizedBox(height: 16),
                  // Leyenda
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Leyenda',
                            style: theme.textTheme.labelMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Completado',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Pendiente',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest
                                      .withAlpha(50),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Sin tareas',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _DayDetailCard extends StatelessWidget {
  final DateTime date;
  final List<DailyTask> tasks;

  const _DayDetailCard({
    required this.date,
    required this.tasks,
  });

  void _toggleTask(BuildContext context, DailyTask task, int taskIndex) {
    final tasksBox = Hive.box('daily_tasks');
    
    // Para tareas repetidas, usar el sistema de completedDates
    if (task.repeatType == TaskRepeatType.weekly) {
      if (task.isCompletedOnDay(date)) {
        task.markUncompletedOnDay(date);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔄 Tarea marcada como pendiente.'),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        task.markCompletedOnDay(date);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Tarea completada.'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } else {
      // Para tareas únicas
      task.completed = !task.completed;
      if (task.completed) {
        task.completedAt = DateTime.now();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Tarea completada.'),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        task.completedAt = null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔄 Tarea marcada como pendiente.'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
    
    tasksBox.putAt(taskIndex, task.toMap());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final tasksBox = Hive.box('daily_tasks');

    final dayTasks = tasks.where((task) {
      if (task.repeatType == TaskRepeatType.weekly) {
        return task.shouldShowOnDay(date);
      } else {
        if (task.dueDate == null) {
          // Tareas sin fecha aparecen hoy
          final today = DateTime.now();
          return date.year == today.year && 
                 date.month == today.month && 
                 date.day == today.day;
        }
        final taskDate = DateFormat('yyyy-MM-dd').format(task.dueDate!);
        return taskDate == dateStr;
      }
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('EEEE, d MMMM', 'es_ES').format(date),
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (dayTasks.isEmpty)
              const Text(
                'Sin tareas para este día',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dayTasks.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 12),
                itemBuilder: (context, index) {
                  final task = dayTasks[index];
                  final bool isCompleted;
                  
                  if (task.repeatType == TaskRepeatType.weekly) {
                    isCompleted = task.completedDates
                        .any((completedDate) => completedDate.startsWith(dateStr));
                  } else {
                    isCompleted = task.completed;
                  }
                  
                  // Encontrar el índice real en Hive
                  final taskIndex = List.generate(tasksBox.length, (i) => i)
                      .firstWhere(
                        (i) {
                          final t = DailyTask.fromMap(tasksBox.getAt(i) as Map);
                          return t.id == task.id;
                        },
                        orElse: () => -1,
                      );

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: taskIndex >= 0
                              ? () => _toggleTask(context, task, taskIndex)
                              : null,
                          child: Icon(
                            isCompleted
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: isCompleted ? Colors.green : Colors.grey,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  decoration: isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: isCompleted ? Colors.grey : null,
                                ),
                              ),
                              if (task.timeSlot != TaskTimeSlot.anytime)
                                Text(
                                  DailyTask.getTimeSlotLabel(task.timeSlot),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isCompleted
                                        ? Colors.grey
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withAlpha(120),
                                  ),
                                ),
                              if (task.description.isNotEmpty)
                                Text(
                                  task.description,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isCompleted
                                        ? Colors.grey
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withAlpha(120),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          onPressed: taskIndex >= 0
                              ? () {
                                  // Navegar a la pestaña de Pendientes y editar
                                  final tabController = DefaultTabController.of(context);
                                  if (tabController != null) {
                                    tabController.animateTo(0);
                                    // Dar tiempo para que se renderice
                                    Future.delayed(const Duration(milliseconds: 100), () {
                                      // La función de edición está en DailyTasksScreen
                                      // Por ahora mostramos un mensaje
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Ve a Pendientes para editar la tarea'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    });
                                  }
                                }
                              : null,
                          color: Colors.blue[400],
                          tooltip: 'Editar',
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

// Pantalla completa (para mantener compatibilidad)
class MonthCalendarScreen extends StatelessWidget {
  const MonthCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MonthCalendarTab();
  }
}

class _DayStats {
  final int total;
  final int completed;

  const _DayStats({required this.total, required this.completed});
}

enum _DayStatus { none, completed, pending }

class _MonthRingPainter extends CustomPainter {
  final List<_DayStatus> statuses;
  final ColorScheme colorScheme;
  final int daysInMonth;

  _MonthRingPainter(this.statuses, this.colorScheme, this.daysInMonth);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - 40;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    final total = statuses.length;
    
    // Dibujar los segmentos de días
    for (int i = 0; i < total; i++) {
      final status = statuses[i];
      switch (status) {
        case _DayStatus.completed:
          paint.color = Colors.green;
          break;
        case _DayStatus.pending:
          paint.color = Colors.red.withAlpha(200);
          break;
        case _DayStatus.none:
        default:
          paint.color = colorScheme.surfaceContainerHighest.withAlpha(120);
      }

      final startAngle = (-90 + (360 / total) * i) * 0.0174533;
      final sweepAngle = (360 / total - 3) * 0.0174533;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
    
    // Dibujar números de días cada 5 días
    final textPainter = TextPainter(
      textDirection: ui.TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    
    for (int day = 1; day <= total; day++) {
      if (day % 5 == 0 || day == 1 || day == total) {
        final angle = (-90 + (360 / total) * (day - 1)) * 0.0174533;
        final textRadius = radius + 25;
        final x = center.dx + textRadius * cos(angle);
        final y = center.dy + textRadius * sin(angle);
        
        textPainter.text = TextSpan(
          text: '$day',
          style: TextStyle(
            color: colorScheme.onSurface.withAlpha(180),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, y - textPainter.height / 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MonthRingPainter oldDelegate) {
    return oldDelegate.statuses != statuses ||
        oldDelegate.colorScheme != colorScheme;
  }
}
