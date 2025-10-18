import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/water_log.dart';
import 'package:hive/hive.dart';

class WaterLogList extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;
  final List<WaterLog> entries;

  const WaterLogList({super.key, required this.selectedDate, required this.onDateChanged, required this.entries});

  void _deleteWaterLog(WaterLog log) {
    final box = Hive.box<WaterLog>('water_logs');
    box.delete(log.key);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDateSelector(context),
        Expanded(
          child: entries.isEmpty
              ? _buildEmptyState(context)
              : _buildLogListView(),
        ),
      ],
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => onDateChanged(selectedDate.subtract(const Duration(days: 1)))),
          Text(DateFormat.yMMMMd('es').format(selectedDate), style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(icon: const Icon(Icons.arrow_forward_ios), onPressed: () => onDateChanged(selectedDate.add(const Duration(days: 1)))),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final catImagePath = isDarkMode ? 'assets/luna_png/luna_b.png' : 'assets/luna_png/luna_w.png';
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(catImagePath, height: 150),
          const SizedBox(height: 20),
          Text(
            'Aún no hay registros para esta fecha.',
            style: GoogleFonts.lato(fontSize: 16, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildLogListView() {
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          child: ListTile(
            leading: const Icon(Icons.local_drink, color: Colors.blueAccent),
            title: Text('${entry.amount} ml', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
            subtitle: Text(DateFormat.jm().format(entry.timestamp)),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => _deleteWaterLog(entry),
            ),
          ),
        );
      },
    );
  }
}
