import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/daily_task.dart';
import 'package:myapp/services/achievement_service.dart';
import 'package:myapp/services/streaks_service.dart';
import 'package:myapp/services/time_format_service.dart';
import 'package:myapp/widgets/empty_state_widget.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:myapp/widgets/sub_tab_bar.dart';
import 'package:myapp/screens/habits/month_calendar_screen.dart';

class DailyTasksScreen extends StatefulWidget {
  const DailyTasksScreen({super.key});

  @override
  State<DailyTasksScreen> createState() => _DailyTasksScreenState();
}

class _DailyTasksScreenState extends State<DailyTasksScreen>
    with SingleTickerProviderStateMixin {
  late Box tasksBox;
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final AchievementService _achievementService = AchievementService();
  final StreaksService _streaksService = StreaksService();
  bool _isLoading = true;
  late TabController _tabController;
  TaskRepeatType _selectedRepeatType = TaskRepeatType.once;
  List<int> _selectedDays = [];
  DateTime? _selectedDueDate;
  DateTime? _repeatStartDate;
  DateTime? _repeatEndDate;
  TaskTimeSlot _selectedTimeSlot = TaskTimeSlot.anytime;

  final List<Map<String, dynamic>> _taskTemplates = const [
    {
      'title': 'Beber agua',
      'description': 'Tomar un vaso de agua',
      'slot': TaskTimeSlot.morning,
    },
    {
      'title': 'Ejercicio',
      'description': 'Actividad física ligera',
      'slot': TaskTimeSlot.afternoon,
    },
    {
      'title': 'Lectura',
      'description': 'Leer 10-15 minutos',
      'slot': TaskTimeSlot.night,
    },
    {
      'title': 'Meditación',
      'description': 'Respiración consciente',
      'slot': TaskTimeSlot.night,
    },
  ];

  // Para el calendario
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.week;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _initializeBox();
  }

  Future<void> _initializeBox() async {
    try {
      tasksBox = await Hive.openBox('daily_tasks');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar tareas')),
        );
      }
    }
  }

  void _addTask() {
    if (_taskController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa una tarea')),
      );
      return;
    }

    final task = DailyTask(
      title: _taskController.text.trim(),
      description: _descriptionController.text.trim(),
      repeatType: _selectedRepeatType,
      dueDate: _selectedDueDate,
      repeatDays: _selectedDays,
      startDate: _repeatStartDate,
      endDate: _repeatEndDate,
      timeSlot: _selectedTimeSlot,
    );

    print('📝 Guardando tarea: ${task.title} (tipo: ${task.repeatType})');
    tasksBox.add(task.toMap());
    print('✅ Tarea guardada en Hive. Total tareas: ${tasksBox.length}');

    _taskController.clear();
    _descriptionController.clear();
    _resetFormFields();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Tarea añadida')),
    );
  }

  void _updateTask(int index) {
    if (_taskController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa una tarea')),
      );
      return;
    }

    final taskData = tasksBox.getAt(index) as Map;
    final task = DailyTask.fromMap(taskData);

    // Actualizar campos
    task.title = _taskController.text.trim();
    task.description = _descriptionController.text.trim();
    task.repeatType = _selectedRepeatType;
    task.dueDate = _selectedDueDate;
    task.repeatDays = _selectedDays;
    task.startDate = _repeatStartDate;
    task.endDate = _repeatEndDate;
    task.timeSlot = _selectedTimeSlot;

    print('📝 Actualizando tarea: ${task.title} (tipo: ${task.repeatType})');
    tasksBox.putAt(index, task.toMap());
    print('✅ Tarea actualizada en Hive');

    _taskController.clear();
    _descriptionController.clear();
    _resetFormFields();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Tarea actualizada')),
    );
  }

  void _resetFormFields() {
    setState(() {
      _selectedRepeatType = TaskRepeatType.once;
      _selectedDays = [];
      _selectedDueDate = null;
      _repeatStartDate = null;
      _repeatEndDate = null;
      _selectedTimeSlot = TaskTimeSlot.anytime;
    });
  }

  String _getNextTaskDay(DailyTask task) {
    final today = DateTime.now();

    // Si no hay días seleccionados, asumir que es hoy (todos los días)
    if (task.repeatDays.isEmpty) {
      return DailyTask.getDayName((today.weekday - 1) % 7);
    }

    // Buscar el próximo día en la lista de días repetidos
    for (int i = 1; i <= 7; i++) {
      final nextDay = today.add(Duration(days: i));
      final dayOfWeek = (nextDay.weekday - 1) % 7;

      if (task.repeatDays.contains(dayOfWeek)) {
        // Verificar también que esté dentro del rango de fechas (si existen)
        if (task.startDate != null && nextDay.isBefore(task.startDate!)) {
          continue;
        }
        if (task.endDate != null && nextDay.isAfter(task.endDate!)) {
          continue;
        }
        return DailyTask.getDayName(dayOfWeek);
      }
    }

    // Si no encuentra nada, devolver el día actual (fallback)
    return DailyTask.getDayName((today.weekday - 1) % 7);
  }

  void _toggleTask(int index, [DateTime? specificDay]) {
    final taskData = tasksBox.getAt(index) as Map;
    final task = DailyTask.fromMap(taskData);
    final targetDay = specificDay ?? DateTime.now();

    // Para tareas repetidas, usar el sistema de completedDates
    if (task.repeatType == TaskRepeatType.weekly) {
      if (task.isCompletedOnDay(targetDay)) {
        task.markUncompletedOnDay(targetDay);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔄 Tarea marcada como pendiente.'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        task.markCompletedOnDay(targetDay);

        // Actualizar rachas y logros
        _streaksService.updateDailyTasksStreak();
        _achievementService.grantExperience(10);
        _achievementService.updateProgress('first_daily_task', 1);

        // Contar total de tareas completadas
        final totalCompleted = _countTotalCompletedTasks();
        _achievementService.updateProgress('cum_tasks_50', totalCompleted,
            cumulative: true);
        _achievementService.updateProgress('cum_tasks_200', totalCompleted,
            cumulative: true);

        final nextDayName = _getNextTaskDay(task);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '✅ Tarea completada. Reaparecerá el próximo $nextDayName.'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Para tareas únicas, comportamiento original
      task.completed = !task.completed;
      if (task.completed) {
        task.completedAt = DateTime.now();

        // Actualizar rachas y logros para tareas únicas también
        _streaksService.updateDailyTasksStreak();
        _achievementService.grantExperience(5);
        _achievementService.updateProgress('first_daily_task', 1);

        final totalCompleted = _countTotalCompletedTasks();
        _achievementService.updateProgress('cum_tasks_50', totalCompleted,
            cumulative: true);
        _achievementService.updateProgress('cum_tasks_200', totalCompleted,
            cumulative: true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Tarea completada.'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        task.completedAt = null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔄 Tarea marcada como pendiente.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }

    tasksBox.putAt(index, task.toMap());
    setState(() {}); // Forzar rebuild para reflejar cambios inmediatamente
  }

  void _deleteTask(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: const Text('¿Estás seguro de que deseas eliminar esta tarea?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              tasksBox.deleteAt(index);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('❌ Tarea eliminada')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
            ),
            child:
                const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _editTask(int index) {
    final taskData = tasksBox.getAt(index) as Map;
    final task = DailyTask.fromMap(taskData);

    // Cargar datos en los controladores
    _taskController.text = task.title;
    _descriptionController.text = task.description;
    _selectedRepeatType = task.repeatType;
    _selectedDays = List.from(task.repeatDays);
    _selectedDueDate = task.dueDate;
    _repeatStartDate = task.startDate;
    _repeatEndDate = task.endDate;
    _selectedTimeSlot = task.timeSlot;

    _showEditTaskDialog(index, task);
  }

  List<Map> _getPendingTasks() {
    final today = DateTime.now();
    return List.generate(
      tasksBox.length,
      (index) => {
        'index': index,
        'data': tasksBox.getAt(index),
      },
    ).where((task) {
      final taskData = task['data'] as Map;
      final dailyTask = DailyTask.fromMap(taskData);

      // Verificar si la tarea debe mostrarse hoy
      if (!dailyTask.shouldShowOnDay(today)) {
        return false;
      }

      // Para tareas repetidas, verificar con el sistema de completedDates
      if (dailyTask.repeatType == TaskRepeatType.weekly) {
        return !dailyTask.isCompletedOnDay(today);
      }

      // Para tareas únicas, usar el campo completed
      return !dailyTask.completed;
    }).toList();
  }

  int _countTotalCompletedTasks() {
    int count = 0;
    for (int index = 0; index < tasksBox.length; index++) {
      final taskData = tasksBox.getAt(index) as Map;
      final dailyTask = DailyTask.fromMap(taskData);

      if (dailyTask.repeatType == TaskRepeatType.weekly) {
        // Para tareas repetidas, contar el número de fechas completadas
        count += dailyTask.completedDates.length;
      } else if (dailyTask.completed) {
        // Para tareas únicas completadas
        count += 1;
      }
    }
    return count;
  }

  bool isSameDay(DateTime day1, DateTime day2) {
    return day1.year == day2.year &&
        day1.month == day2.month &&
        day1.day == day2.day;
  }

  Map<String, List<Map>> _getCompletedTasksByDate() {
    final completed = <Map>[];

    // Procesar todas las tareas
    for (int index = 0; index < tasksBox.length; index++) {
      final taskData = tasksBox.getAt(index) as Map;
      final dailyTask = DailyTask.fromMap(taskData);

      if (dailyTask.repeatType == TaskRepeatType.weekly) {
        // Para tareas repetidas, crear una entrada por cada completedDate
        for (final dateStr in dailyTask.completedDates) {
          completed.add({
            'index': index,
            'data': taskData,
            'completedDate': dateStr,
          });
        }
      } else if (dailyTask.completed) {
        // Para tareas únicas completadas
        completed.add({
          'index': index,
          'data': taskData,
        });
      }
    }

    final grouped = <String, List<Map>>{};

    for (var task in completed) {
      try {
        final taskData = task['data'] as Map;
        final dailyTask = DailyTask.fromMap(taskData);

        DateTime completedDateTime;
        if (task.containsKey('completedDate')) {
          // Para tareas repetidas, usar la fecha del completedDates
          completedDateTime = DateTime.parse(task['completedDate'] as String);
        } else {
          // Para tareas únicas, usar completedAt
          completedDateTime = dailyTask.completedAt ?? dailyTask.createdAt;
        }

        final dateStr = DateFormat('dd/MM/yyyy').format(completedDateTime);

        if (!grouped.containsKey(dateStr)) {
          grouped[dateStr] = [];
        }
        grouped[dateStr]!.add(task);
      } catch (e) {
        // Si hay error en el formato de fecha, lo agrupamos como "Sin fecha"
        if (!grouped.containsKey('Sin fecha')) {
          grouped['Sin fecha'] = [];
        }
        grouped['Sin fecha']!.add(task);
      }
    }

    return grouped;
  }

  @override
  void dispose() {
    _taskController.dispose();
    _descriptionController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          SubTabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                icon: Icon(Icons.pending_actions, size: 18),
                text: 'Pendientes',
              ),
              Tab(
                icon: Icon(Icons.check_circle, size: 18),
                text: 'Completadas',
              ),
              Tab(
                icon: Icon(Icons.calendar_month, size: 18),
                text: 'Mes',
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPendingTasksView(),
                _buildCompletedTasksView(),
                _buildCalendarView(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (context, _) {
          if (_tabController.index != 0) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton.extended(
            onPressed: () => _showAddTaskDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Nueva tarea'),
          );
        },
      ),
    );
  }

  Widget _buildPendingTasksView() {
    return ValueListenableBuilder(
      valueListenable: tasksBox.listenable(),
      builder: (context, Box box, _) {
        final pendingTasks = _getPendingTasks();

        if (pendingTasks.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.task_alt,
            title: '¡Sin tareas pendientes!',
            subtitle: 'Descansa o añade nuevas tareas',
            iconColor: Colors.green[400],
          );
        }

        final grouped = _groupPendingTasksBySlot(pendingTasks);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildPendingSection(TaskTimeSlot.morning, grouped),
            _buildPendingSection(TaskTimeSlot.afternoon, grouped),
            _buildPendingSection(TaskTimeSlot.night, grouped),
            _buildPendingSection(TaskTimeSlot.anytime, grouped),
          ].whereType<Widget>().toList(),
        );
      },
    );
  }

  Map<TaskTimeSlot, List<Map<String, dynamic>>> _groupPendingTasksBySlot(
    List<Map> pendingTasks,
  ) {
    final map = <TaskTimeSlot, List<Map<String, dynamic>>>{
      TaskTimeSlot.morning: [],
      TaskTimeSlot.afternoon: [],
      TaskTimeSlot.night: [],
      TaskTimeSlot.anytime: [],
    };

    for (final task in pendingTasks) {
      final taskData = task['data'] as Map;
      final dailyTask = DailyTask.fromMap(taskData);
      map[dailyTask.timeSlot]!.add({
        'index': task['index'] as int,
        'data': taskData,
      });
    }
    return map;
  }

  Widget? _buildPendingSection(
    TaskTimeSlot slot,
    Map<TaskTimeSlot, List<Map<String, dynamic>>> grouped,
  ) {
    final tasks = grouped[slot] ?? [];
    if (tasks.isEmpty) return null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 8),
          child: Text(
            DailyTask.getTimeSlotLabel(slot),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...tasks.map((task) {
          final taskData = task['data'] as Map;
          final taskIndex = task['index'] as int;
          final dailyTask = DailyTask.fromMap(taskData);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Checkbox(
                value: false,
                onChanged: (_) => _toggleTask(taskIndex),
              ),
              title: Text(dailyTask.title),
              subtitle: dailyTask.description.isNotEmpty
                  ? Text(
                      dailyTask.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : null,
              trailing: SizedBox(
                width: 100,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _editTask(taskIndex),
                      color: Colors.blue[400],
                      tooltip: 'Editar',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _deleteTask(taskIndex),
                      color: Colors.red[400],
                      tooltip: 'Eliminar',
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildCompletedTasksView() {
    return ValueListenableBuilder(
      valueListenable: tasksBox.listenable(),
      builder: (context, Box box, _) {
        final completedByDate = _getCompletedTasksByDate();
        final theme = Theme.of(context);

        // Mostrar meta mensual al inicio
        final now = DateTime.now();
        final settingsBox = Hive.box('settings');
        final currentMonthGoalKey = 'monthly_tasks_goal_${now.year}_${now.month}';
        final monthlyGoal = settingsBox.get(currentMonthGoalKey, defaultValue: 20) as int;
        final totalCompletedThisMonth = _countTotalCompletedTasks();
        final goalProgress = monthlyGoal > 0 ? (totalCompletedThisMonth / monthlyGoal).clamp(0.0, 1.0) : 0.0;

        final widgets = <Widget>[];
        
        // Agregar meta mensual al inicio
        widgets.add(
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Meta mensual - ${DateFormat('MMMM', 'es_ES').format(now)}',
                    style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Objetivo: $monthlyGoal tareas',
                    style: theme.textTheme.bodySmall,
                  ),
                  Slider(
                    value: monthlyGoal.toDouble(),
                    min: 0,
                    max: 60,
                    divisions: 60,
                    label: '$monthlyGoal',
                    onChanged: (value) {
                      final newGoal = value.round();
                      settingsBox.put(currentMonthGoalKey, newGoal);
                      setState(() {});
                    },
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      value: goalProgress,
                      backgroundColor: theme.colorScheme
                          .surfaceContainerHighest
                          .withAlpha(100),
                      valueColor:
                          AlwaysStoppedAnimation(theme.colorScheme.primary),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Progreso: $totalCompletedThisMonth/$monthlyGoal',
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ),
        );

        if (completedByDate.isEmpty) {
          return ListView(
            children: widgets + [
              EmptyStateWidget(
                icon: Icons.history,
                title: 'Sin tareas completadas',
                subtitle: 'Tus tareas completadas aparecerán aquí',
                iconColor: Colors.blue[400],
              ),
            ],
          );
        }

        // Ordenar fechas de forma descendente (más recientes primero)
        final sortedDates = completedByDate.keys.toList();
        sortedDates.sort((a, b) {
          try {
            final dateA = DateFormat('dd/MM/yyyy').parse(a);
            final dateB = DateFormat('dd/MM/yyyy').parse(b);
            return dateB.compareTo(dateA);
          } catch (e) {
            return 0;
          }
        });

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sortedDates.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return widgets[0];
            }
            
            final dateIndex = index - 1;
            final dateKey = sortedDates[dateIndex];
            final tasksForDate = completedByDate[dateKey]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    dateKey,
                    style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                ...tasksForDate.map((task) {
                  final taskData = task['data'] as Map;
                  final taskIndex = task['index'] as int;
                  final dailyTask = DailyTask.fromMap(taskData);

                  // Obtener TODAS las horas de completado para este día
                  List<DateTime> completedTimes = [];

                  if (task.containsKey('completedDate')) {
                    final completedDateStr = task['completedDate'] as String;
                    final dayStr = completedDateStr.split('T')[0];

                    // Para tareas repetidas, obtener todas las veces que se completó ese día
                    completedTimes = dailyTask.completedDates
                        .where((d) => d.startsWith(dayStr))
                        .map((d) {
                          try {
                            return DateTime.parse(d);
                          } catch (e) {
                            return null;
                          }
                        })
                        .whereType<DateTime>()
                        .toList();
                    completedTimes
                        .sort((a, b) => b.compareTo(a)); // Más reciente primero
                  } else {
                    // Para tareas únicas
                    if (dailyTask.completedAt != null) {
                      completedTimes = [dailyTask.completedAt!];
                    }
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Checkbox(
                        value: true,
                        onChanged: (_) => _toggleTask(taskIndex),
                      ),
                      title: Text(
                        dailyTask.title,
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (dailyTask.timeSlot != TaskTimeSlot.anytime)
                            Text(
                              DailyTask.getTimeSlotLabel(dailyTask.timeSlot),
                              style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          if (dailyTask.description.isNotEmpty)
                            Text(dailyTask.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey[400],
                                )),
                          if (completedTimes.isNotEmpty)
                            ..._buildCompletionTimes(completedTimes),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deleteTask(taskIndex),
                        color: Colors.red[400],
                        tooltip: 'Eliminar',
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCalendarView() {
    return const MonthCalendarTab();
  }

  Widget _buildSelectedDayTasks(List<DailyTask> allTasks) {
    final tasksForDay =
        allTasks.where((task) => task.shouldShowOnDay(_selectedDay)).toList();

    final today = DateTime.now();
    final isToday = isSameDay(_selectedDay, today);

    if (tasksForDay.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.task_alt,
        title: isToday ? '¡Sin tareas para hoy!' : 'Sin tareas',
        subtitle: isToday
            ? 'Descansa o añade nuevas tareas'
            : 'Nada programado para ese día',
        iconColor: Colors.blue[400],
      );
    }

    final dateStr = DateFormat('EEEE, d MMMM', 'es_ES').format(_selectedDay);
    final headerText = isToday ? 'Hoy - $dateStr' : dateStr;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  headerText,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: tasksForDay.length,
            itemBuilder: (context, index) {
              final task = tasksForDay[index];
              final taskIndex = tasksBox.values
                  .toList()
                  .indexWhere((t) => DailyTask.fromMap(t as Map).id == task.id);

              final isCompleted = task.repeatType == TaskRepeatType.weekly
                  ? task.isCompletedOnDay(_selectedDay)
                  : task.completed;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Checkbox(
                    value: isCompleted,
                    onChanged: (value) {
                      if (taskIndex >= 0) {
                        _toggleTask(taskIndex, _selectedDay);
                      }
                    },
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: isCompleted ? Colors.grey : Colors.black,
                    ),
                  ),
                  subtitle: task.description.isNotEmpty
                      ? Text(
                          task.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color: isCompleted ? Colors.grey[400] : Colors.grey,
                          ),
                        )
                      : null,
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () {
                            if (taskIndex >= 0) _editTask(taskIndex);
                          },
                          color: Colors.blue[400],
                          tooltip: 'Editar',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            if (taskIndex >= 0) _deleteTask(taskIndex);
                          },
                          color: Colors.red[400],
                          tooltip: 'Eliminar',
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCompletionTimes(List<DateTime> times) {
    if (times.isEmpty) return [];
    final timeFormatService = TimeFormatService();

    if (times.length == 1) {
      final timeStr = timeFormatService.formatTime(times[0]);
      return [
        Text(
          'Completada a las $timeStr',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontStyle: FontStyle.italic,
          ),
        ),
      ];
    }

    // Múltiples completados
    return [
      Text(
        'Completada ${times.length} veces:',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[500],
          fontWeight: FontWeight.bold,
        ),
      ),
      ...times.map((time) {
        final timeStr = timeFormatService.formatTime(time);
        return Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 2.0),
          child: Text(
            '• $timeStr',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      }).toList(),
    ];
  }

  Widget _buildCompactWeekCalendar() {
    final today = DateTime.now();
    // Obtener el lunes de la semana actual
    final mondayOfWeek = today.subtract(Duration(days: today.weekday - 1));
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Semana del ${DateFormat('d MMM', 'es_ES').format(mondayOfWeek)}',
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _calendarFormat = CalendarFormat.month;
                });
                _showFullCalendarDialog();
              },
              icon: const Icon(Icons.expand_more, size: 18),
              label: const Text('Ver más', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Mostrar los 7 días de la semana
        Row(
          children: List.generate(7, (index) {
            final day = mondayOfWeek.add(Duration(days: index));
            final isToday = isSameDay(day, today);
            final isSelected = isSameDay(day, _selectedDay);
            
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDay = day;
                    _focusedDay = day;
                  });
                },
                child: Column(
                  children: [
                    Text(
                      DailyTask.getDayName(index).substring(0, 3),
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : isToday
                                ? Theme.of(context).colorScheme.secondary
                                : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isToday
                              ? Theme.of(context).colorScheme.secondary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          day.day.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  void _showFullCalendarDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TableCalendar<DailyTask>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  locale: 'es_ES',
                  calendarFormat: _calendarFormat,
                  onDaySelected: (selectedDay, focusedDay) {
                    setDialogState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setDialogState(() {
                      _calendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    setDialogState(() {
                      _focusedDay = focusedDay;
                    });
                  },
                  headerStyle: HeaderStyle(
                    formatButtonVisible: true,
                    formatButtonTextStyle: const TextStyle().copyWith(
                      color: Colors.white,
                    ),
                    formatButtonDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    titleCentered: true,
                  ),
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    todayDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: Colors.orange[400],
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cerrar'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((_) {
      setState(() {
        _calendarFormat = CalendarFormat.week;
      });
    });
  }

  void _showAddTaskDialog() {
    _resetFormFields();
    _taskController.clear();
    _descriptionController.clear();
    _showTaskDialog('Añadir tarea', null);
  }

  void _showEditTaskDialog(int index, DailyTask task) {
    _showTaskDialog('Editar tarea', index);
  }

  void _showTaskDialog(String title, int? editIndex) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _taskController,
                  decoration: const InputDecoration(
                    hintText: 'Título de la tarea',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    hintText: 'Descripción (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Text('Plantillas rápidas',
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _taskTemplates.map((template) {
                    return ActionChip(
                      label: Text(template['title'] as String),
                      onPressed: () {
                        setState(() {
                          _taskController.text =
                              template['title'] as String;
                          _descriptionController.text =
                              template['description'] as String;
                          _selectedTimeSlot =
                              template['slot'] as TaskTimeSlot;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text('Franja horaria',
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: TaskTimeSlot.values.map((slot) {
                    return ChoiceChip(
                      label: Text(DailyTask.getTimeSlotLabel(slot)),
                      selected: _selectedTimeSlot == slot,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedTimeSlot = slot;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text('Tipo de tarea',
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                ListTile(
                  title: const Text('Tarea única'),
                  leading: Radio<TaskRepeatType>(
                    value: TaskRepeatType.once,
                    groupValue: _selectedRepeatType,
                    onChanged: (value) {
                      setState(() {
                        _selectedRepeatType = value!;
                        _selectedDays = [];
                      });
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Repetida en la semana'),
                  leading: Radio<TaskRepeatType>(
                    value: TaskRepeatType.weekly,
                    groupValue: _selectedRepeatType,
                    onChanged: (value) {
                      setState(() {
                        _selectedRepeatType = value!;
                      });
                    },
                  ),
                ),
                if (_selectedRepeatType == TaskRepeatType.once) ...[
                  const SizedBox(height: 12),
                  Text('Fecha de la tarea',
                      style: Theme.of(context).textTheme.bodySmall),
                  TextButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDueDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _selectedDueDate = date;
                        });
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      _selectedDueDate != null
                          ? DateFormat('dd/MM/yyyy').format(_selectedDueDate!)
                          : 'Seleccionar fecha',
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 12),
                  Text('Días de repetición',
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: List.generate(7, (index) {
                      return FilterChip(
                        label: Text(DailyTask.getDayName(index)),
                        selected: _selectedDays.contains(index),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedDays.add(index);
                              _selectedDays.sort();
                            } else {
                              _selectedDays.remove(index);
                            }
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  Text('Rango de fechas (opcional)',
                      style: Theme.of(context).textTheme.bodySmall),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _repeatStartDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              setState(() {
                                _repeatStartDate = date;
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_today, size: 18),
                          label: Text(
                            _repeatStartDate != null
                                ? DateFormat('dd/MM').format(_repeatStartDate!)
                                : 'Desde',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _repeatEndDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              setState(() {
                                _repeatEndDate = date;
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_today, size: 18),
                          label: Text(
                            _repeatEndDate != null
                                ? DateFormat('dd/MM').format(_repeatEndDate!)
                                : 'Hasta',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _resetFormFields();
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_selectedRepeatType == TaskRepeatType.weekly &&
                    _selectedDays.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Selecciona al menos un día de la semana')),
                  );
                  return;
                }

                if (editIndex != null) {
                  _updateTask(editIndex);
                } else {
                  _addTask();
                }

                _resetFormFields();
                Navigator.pop(context);
              },
              child: Text(editIndex != null ? 'Guardar cambios' : 'Añadir'),
            ),
          ],
        ),
      ),
    );
  }
}


