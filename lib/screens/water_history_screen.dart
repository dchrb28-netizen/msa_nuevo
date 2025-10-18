import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/water_log.dart';
import 'package:myapp/models/user.dart';

class WaterHistoryScreen extends StatelessWidget {
  const WaterHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to changes in the user box as well to get the current user
    return ValueListenableBuilder(
      valueListenable: Hive.box<User>('users').listenable(),
      builder: (context, Box<User> userBox, _) {
        // Check if there is a current user
        final currentUser = userBox.isNotEmpty ? userBox.getAt(0) : null;

        return ValueListenableBuilder(
          valueListenable: Hive.box<WaterLog>('water_logs').listenable(),
          builder: (context, Box<WaterLog> box, _) {
            if (currentUser == null) {
              return const Center(child: Text('Crea un perfil para ver tu historial.'));
            }

            // Filter logs by the current user's id
            final userLogs = box.values.where((log) => log.userId == currentUser.id).toList();
            final Map<DateTime, double> dailyTotals = {};

            for (var log in userLogs) {
              final day = DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day);
              dailyTotals[day] = (dailyTotals[day] ?? 0) + log.amount;
            }

            final sortedDays = dailyTotals.keys.toList()..sort((a, b) => b.compareTo(a));

            if (sortedDays.isEmpty) {
              return const Center(child: Text('No hay registros de agua todavía.'));
            }

            return ListView.builder(
              itemCount: sortedDays.length,
              itemBuilder: (context, index) {
                final day = sortedDays[index];
                final total = dailyTotals[day]!;
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
                    title: Text(DateFormat.yMMMd('es').format(day), style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
                    trailing: Text('${total.toInt()} ml', style: GoogleFonts.lato(fontSize: 16, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
