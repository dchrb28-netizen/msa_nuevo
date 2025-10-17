import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/water_log.dart';

class WaterHistoryScreen extends StatelessWidget {
  const WaterHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Box<WaterLog> waterLogBox = Hive.box<WaterLog>('water_logs');

    return ValueListenableBuilder(
      valueListenable: waterLogBox.listenable(),
      builder: (context, Box<WaterLog> box, _) {
        final allLogs = box.values.toList();
        final Map<DateTime, double> dailyTotals = {};

        for (var log in allLogs) {
          final day = DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day);
          dailyTotals[day] = (dailyTotals[day] ?? 0) + log.amount;
        }

        final sortedDays = dailyTotals.keys.toList()..sort((a, b) => b.compareTo(a));

        return ListView.builder(
          itemCount: sortedDays.length,
          itemBuilder: (context, index) {
            final day = sortedDays[index];
            final total = dailyTotals[day]!;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
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
