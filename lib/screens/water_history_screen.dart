import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/water_log.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:provider/provider.dart';

class WaterHistoryScreen extends StatelessWidget {
  const WaterHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    // Corrected to use the 'user' getter from the provider
    final currentUser = userProvider.user;

    return ValueListenableBuilder(
      valueListenable: Hive.box<WaterLog>('water_logs').listenable(),
      builder: (context, Box<WaterLog> box, _) {
        if (currentUser == null) {
          return const Center(child: Text('Crea un perfil para ver tu historial.'));
        }

        // Corrected to filter by the 'userId' field in WaterLog
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
  }
}
