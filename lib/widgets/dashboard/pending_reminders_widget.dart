import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/models/reminder.dart';
import 'package:myapp/screens/habits/reminders_screen.dart';
import 'package:myapp/services/time_format_service.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class PendingRemindersWidget extends StatelessWidget {
  const PendingRemindersWidget({super.key});

  List<Reminder> _getPendingRemindersForToday(Box<Reminder> box) {
    final now = DateTime.now();
    final today = now.weekday; // 1=Monday, 7=Sunday
    final todayIndex = today == 7 ? 6 : today - 1; // Convertir a 0-6
    
    debugPrint('[PendingReminders] Today: ${now.toString()}');
    debugPrint('[PendingReminders] Weekday: $today (1=Mon, 7=Sun)');
    debugPrint('[PendingReminders] Today index: $todayIndex');

    final pending = <Reminder>[];
    
    for (var reminder in box.values) {
      debugPrint('[PendingReminders] Checking: ${reminder.title} - active:${reminder.isActive} - days:${reminder.days} - todayEnabled:${reminder.days[todayIndex]}');
      if (!reminder.isActive) continue;
      if (!reminder.days[todayIndex]) continue;
      
      // Mostrar todos los recordatorios activos de hoy
      pending.add(reminder);
    }
    
    // Ordenar por hora
    pending.sort((a, b) {
      final aTime = a.hour * 60 + a.minute;
      final bTime = b.hour * 60 + b.minute;
      return aTime.compareTo(bTime);
    });
    
    return pending;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormatService = Provider.of<TimeFormatService>(context);

    return ValueListenableBuilder(
      valueListenable: Hive.box<Reminder>('reminders').listenable(),
      builder: (context, Box<Reminder> box, _) {
        debugPrint('[PendingReminders] Total reminders in box: ${box.length}');
        debugPrint('[PendingReminders] Box values: ${box.values.map((r) => '${r.title} - active:${r.isActive} - days:${r.days}').toList()}');
        
        final pending = _getPendingRemindersForToday(box);
        final allReminders = box.values.where((r) => r.isActive).toList();
        
        debugPrint('[PendingReminders] Pending for today: ${pending.length}');
        debugPrint('[PendingReminders] All active reminders: ${allReminders.length}');

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          elevation: 0,
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
                  theme.colorScheme.secondaryContainer.withValues(alpha: 0.25),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.18),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RemindersScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primaryContainer,
                                theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            PhosphorIcons.bell(PhosphorIconsStyle.duotone),
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            pending.isEmpty ? 'Recordatorios' : 'Recordatorios de Hoy',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (pending.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.primary.withValues(alpha: 0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '${pending.length}',
                              style: GoogleFonts.montserrat(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (pending.isEmpty)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                                  theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              PhosphorIcons.smileyWink(PhosphorIconsStyle.duotone),
                              size: 50,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No hay recordatorios pendientes',
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            allReminders.isEmpty 
                              ? 'Crea tu primer recordatorio'
                              : 'Todo está bajo control hoy',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 60,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: pending.map((reminder) {
                            final reminderTime = TimeOfDay(
                              hour: reminder.hour,
                              minute: reminder.minute,
                            );
                            final now = TimeOfDay.now();
                            final nowMinutes = now.hour * 60 + now.minute;
                            final reminderMinutes = reminder.hour * 60 + reminder.minute;
                            final isPast = nowMinutes >= reminderMinutes;
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isPast 
                                      ? [
                                          Colors.orange.withValues(alpha: 0.2),
                                          Colors.deepOrange.withValues(alpha: 0.1),
                                        ]
                                      : [
                                          Colors.blue.withValues(alpha: 0.15),
                                          Colors.lightBlue.withValues(alpha: 0.08),
                                        ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isPast 
                                      ? Colors.orange.withValues(alpha: 0.4)
                                      : Colors.blue.withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: isPast 
                                          ? Colors.orange.withValues(alpha: 0.2)
                                          : Colors.blue.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      isPast 
                                          ? PhosphorIcons.bellRinging(PhosphorIconsStyle.duotone)
                                          : PhosphorIcons.clock(PhosphorIconsStyle.duotone),
                                      color: isPast ? Colors.orange.shade700 : Colors.blue.shade700,
                                      size: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          reminder.title,
                                          style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                            letterSpacing: -0.2,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          timeFormatService.formatTimeOfDay(
                                            reminderTime,
                                            context,
                                          ),
                                          style: GoogleFonts.montserrat(
                                            color: theme.colorScheme.onSurfaceVariant,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isPast)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.orange,
                                            Colors.deepOrange,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.orange.withValues(alpha: 0.3),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        'AHORA',
                                        style: GoogleFonts.montserrat(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
