/// Modelo para tareas diarias con soporte para repetición semanal

enum TaskRepeatType {
  /// Tarea única (solo para un día)
  once,

  /// Tarea que se repite todas las semanas
  weekly,
}

/// Franja horaria de la tarea
enum TaskTimeSlot {
  morning,
  afternoon,
  night,
  anytime,
}

class DailyTask {
  String id;
  String title;
  String description;
  bool completed;
  DateTime createdAt;
  DateTime? completedAt;
  DateTime? dueDate; // Fecha de vencimiento para tareas únicas
  TaskRepeatType repeatType;
  List<int>
      repeatDays; // Días de la semana (0=lunes, 6=domingo) para tareas repetidas
  DateTime? startDate; // Fecha de inicio para tareas repetidas
  DateTime? endDate; // Fecha de fin para tareas repetidas (opcional)
  List<String>
      completedDates; // Fechas y horas en que la tarea fue completada (formato ISO 8601 completo) para tareas repetidas
  TaskTimeSlot timeSlot; // Franja horaria

  DailyTask({
    String? id,
    required this.title,
    this.description = '',
    this.completed = false,
    DateTime? createdAt,
    this.completedAt,
    this.dueDate,
    this.repeatType = TaskRepeatType.once,
    this.repeatDays = const [],
    this.startDate,
    this.endDate,
    this.completedDates = const [],
    this.timeSlot = TaskTimeSlot.anytime,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = createdAt ?? DateTime.now();

  /// Convierte el modelo a un mapa para almacenamiento en Hive
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completed': completed,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'repeatType': repeatType.toString(),
      'repeatDays': repeatDays,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'completedDates': completedDates,
      'timeSlot': timeSlot.toString(),
    };
  }

  /// Crea una instancia a partir de un mapa
  factory DailyTask.fromMap(Map<dynamic, dynamic> map) {
    return DailyTask(
      id: map['id'] as String? ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      completed: map['completed'] as bool? ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
      dueDate: map['dueDate'] != null
          ? DateTime.parse(map['dueDate'] as String)
          : null,
      repeatType: map['repeatType'] != null
          ? (map['repeatType'] as String).contains('weekly')
              ? TaskRepeatType.weekly
              : TaskRepeatType.once
          : TaskRepeatType.once,
      repeatDays: map['repeatDays'] != null
          ? List<int>.from(map['repeatDays'] as List)
          : [],
      startDate: map['startDate'] != null
          ? DateTime.parse(map['startDate'] as String)
          : null,
      endDate: map['endDate'] != null
          ? DateTime.parse(map['endDate'] as String)
          : null,
      completedDates: map['completedDates'] != null
          ? List<String>.from(map['completedDates'] as List)
          : [],
      timeSlot: _parseTimeSlot(map['timeSlot'] as String?),
    );
  }

  static TaskTimeSlot _parseTimeSlot(String? value) {
    if (value == null) return TaskTimeSlot.anytime;
    if (value.contains('morning')) return TaskTimeSlot.morning;
    if (value.contains('afternoon')) return TaskTimeSlot.afternoon;
    if (value.contains('night')) return TaskTimeSlot.night;
    return TaskTimeSlot.anytime;
  }

  static String getTimeSlotLabel(TaskTimeSlot slot) {
    switch (slot) {
      case TaskTimeSlot.morning:
        return 'Mañana';
      case TaskTimeSlot.afternoon:
        return 'Tarde';
      case TaskTimeSlot.night:
        return 'Noche';
      case TaskTimeSlot.anytime:
        return 'Cualquier hora';
    }
  }

  /// Verifica si una tarea debe mostrarse en un día específico
  bool shouldShowOnDay(DateTime day) {
    final dayWithoutTime = DateTime(day.year, day.month, day.day);

    if (repeatType == TaskRepeatType.once) {
      // Para tareas únicas:
      // 1. Si tiene dueDate, mostrar solo en esa fecha
      if (dueDate != null) {
        final dueDateWithoutTime =
            DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
        return dueDateWithoutTime == dayWithoutTime;
      }

      // 2. Si NO tiene dueDate, mostrar SIEMPRE (tarea recurrente indefinida)
      // Las tareas sin dueDate son efectivamente "para hoy y siempre"
      return true;
    }

    // Para tareas repetidas
    if (repeatType == TaskRepeatType.weekly) {
      // Verificar que la fecha esté dentro del rango
      if (startDate != null) {
        final startWithoutTime =
            DateTime(startDate!.year, startDate!.month, startDate!.day);
        if (dayWithoutTime.isBefore(startWithoutTime)) {
          return false;
        }
      }

      if (endDate != null) {
        final endWithoutTime =
            DateTime(endDate!.year, endDate!.month, endDate!.day);
        if (dayWithoutTime.isAfter(endWithoutTime)) {
          return false;
        }
      }

      // Verificar que el día de la semana esté en repeatDays
      // weekday: 1=lunes, 7=domingo, convertimos a 0=lunes, 6=domingo
      final dayOfWeek = (day.weekday - 1) % 7;
      return repeatDays.contains(dayOfWeek);
    }

    return false;
  }

  /// Verifica si la tarea fue completada en un día específico
  bool isCompletedOnDay(DateTime day) {
    if (repeatType == TaskRepeatType.once) {
      // Para tareas únicas, solo importa el estado general si coincide con la fecha
      if (!completed) return false;
      if (dueDate == null) return completed;

      final dueDateWithoutTime =
          DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
      final dayWithoutTime = DateTime(day.year, day.month, day.day);
      return dueDateWithoutTime == dayWithoutTime;
    }

    // Para tareas repetidas, verificar si esa fecha está en completedDates
    if (repeatType == TaskRepeatType.weekly) {
      final dayStr = DateTime(day.year, day.month, day.day)
          .toIso8601String()
          .split('T')[0];
      return completedDates.any((dateStr) => dateStr.startsWith(dayStr));
    }

    return false;
  }

  /// Marca la tarea como completada en un día específico
  void markCompletedOnDay(DateTime day) {
    if (repeatType == TaskRepeatType.weekly) {
      // Crear un DateTime con la fecha del día seleccionado pero con la hora actual
      final now = DateTime.now();
      final completedDateTime = DateTime(
        day.year,
        day.month,
        day.day,
        now.hour,
        now.minute,
        now.second,
      );
      // Agregar la fecha con la hora actual SIN eliminar las anteriores
      // Esto permite múltiples completados del mismo día
      completedDates.add(completedDateTime.toIso8601String());
    } else if (repeatType == TaskRepeatType.once) {
      completed = true;
      // Para tareas únicas también usar el día especificado con hora actual
      final now = DateTime.now();
      completedAt = DateTime(
        day.year,
        day.month,
        day.day,
        now.hour,
        now.minute,
        now.second,
      );
    }
  }

  /// Marca la tarea como incompleta en un día específico
  void markUncompletedOnDay(DateTime day) {
    if (repeatType == TaskRepeatType.weekly) {
      final dayStr = DateTime(day.year, day.month, day.day)
          .toIso8601String()
          .split('T')[0];
      // Remover todas las entradas que coincidan con este día
      completedDates.removeWhere((dateStr) => dateStr.startsWith(dayStr));
    } else if (repeatType == TaskRepeatType.once) {
      completed = false;
      completedAt = null;
    }
  }

  /// Obtiene la fecha y hora de completado para un día específico (primera ocurrencia)
  DateTime? getCompletedTimeForDay(DateTime day) {
    if (repeatType == TaskRepeatType.once) {
      return completedAt;
    }

    if (repeatType == TaskRepeatType.weekly) {
      final dayStr = DateTime(day.year, day.month, day.day)
          .toIso8601String()
          .split('T')[0];
      try {
        final matchingDate = completedDates.firstWhere(
          (dateStr) => dateStr.startsWith(dayStr),
          orElse: () => '',
        );
        if (matchingDate.isNotEmpty) {
          return DateTime.parse(matchingDate);
        }
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Obtiene TODAS las fechas y horas de completado para un día específico
  List<DateTime> getAllCompletedTimesForDay(DateTime day) {
    final times = <DateTime>[];

    if (repeatType == TaskRepeatType.once) {
      if (completedAt != null) {
        times.add(completedAt!);
      }
      return times;
    }

    if (repeatType == TaskRepeatType.weekly) {
      final dayStr = DateTime(day.year, day.month, day.day)
          .toIso8601String()
          .split('T')[0];

      for (var dateStr in completedDates) {
        if (dateStr.startsWith(dayStr)) {
          try {
            times.add(DateTime.parse(dateStr));
          } catch (e) {
            // Ignorar fechas mal formateadas
          }
        }
      }
      // Ordenar por hora (más reciente primero)
      times.sort((a, b) => b.compareTo(a));
    }
    return times;
  }

  /// Cuenta cuántas veces se completó la tarea en un día específico
  int getCompletionCountForDay(DateTime day) {
    return getAllCompletedTimesForDay(day).length;
  }

  /// Obtiene el nombre del día de la semana en español
  static String getDayName(int dayIndex) {
    const days = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    return days[dayIndex % 7];
  }
}
