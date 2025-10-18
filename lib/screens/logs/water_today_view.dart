import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/models/water_log.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/widgets/dashboard/aquarium_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WaterTodayView extends StatefulWidget {
  const WaterTodayView({super.key});

  @override
  State<WaterTodayView> createState() => _WaterTodayViewState();
}

class _WaterTodayViewState extends State<WaterTodayView> {
  final Box<WaterLog> _waterLogBox = Hive.box<WaterLog>('water_logs');
  DateTime _selectedDate = DateTime.now();
  double _dailyGoal = 2000.0;

  @override
  void initState() {
    super.initState();
    _loadDailyGoal();
  }

  Future<void> _loadDailyGoal() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyGoal = prefs.getDouble('dailyWaterGoal') ?? 2000.0;
    });
  }

  Future<void> _saveDailyGoal(double goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('dailyWaterGoal', goal);
    setState(() {
      _dailyGoal = goal;
    });
  }

  double _getWaterIntakeForDate(User? currentUser, DateTime date) {
    if (currentUser == null) return 0;
    return _waterLogBox.values
        .where((log) =>
            log.userId == currentUser.id &&
            log.timestamp.year == date.year &&
            log.timestamp.month == date.month &&
            log.timestamp.day == date.day)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  void _addWaterLog(double amount, User currentUser) {
    final log = WaterLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: currentUser.id,
      amount: amount,
      timestamp: _selectedDate,
    );
    _waterLogBox.add(log);
  }

  void _showAddWaterDialog(User currentUser) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Añadir Agua'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Cantidad (ml)'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                _addWaterLog(amount, currentUser);
                Navigator.pop(context);
              }
            },
            child: const Text('Añadir'),
          ),
        ],
      ),
    );
  }

  void _editWaterLog(WaterLog log) {
    final TextEditingController controller = TextEditingController(text: log.amount.toString());
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Editar Registro'),
              content: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Cantidad (ml)'),
                autofocus: true,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    final amount = double.tryParse(controller.text);
                    if (amount != null && amount > 0) {
                      log.amount = amount;
                      log.save();
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            ));
  }

  void _deleteWaterLog(WaterLog log) {
    log.delete();
  }

  void _showEditGoalDialog() {
    final TextEditingController controller = TextEditingController(text: _dailyGoal.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Meta Diaria'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Meta (ml)'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                _saveDailyGoal(amount);
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.user;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final String catImagePath = isDarkMode ? 'assets/images/gato_agua_dark.png' : 'assets/images/gato_agua_light.png';


    return ValueListenableBuilder(
      valueListenable: _waterLogBox.listenable(),
      builder: (context, Box<WaterLog> box, _) {
        if (currentUser == null) {
          return const Center(
              child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Por favor, crea un perfil de usuario para poder registrar tu ingesta de agua.', textAlign: TextAlign.center),
          ));
        }

        final intakeForSelectedDate = _getWaterIntakeForDate(currentUser, _selectedDate);
        final logsForSelectedDate = box.values
            .where((log) =>
                log.userId == currentUser.id &&
                log.timestamp.year == _selectedDate.year &&
                log.timestamp.month == _selectedDate.month &&
                log.timestamp.day == _selectedDate.day)
            .toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 250,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    clipBehavior: Clip.antiAlias,
                    child: AquariumWidget(
                      totalWater: intakeForSelectedDate,
                      dailyGoal: _dailyGoal,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                 Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildWaterButton(250, currentUser),
                    _buildWaterButton(500, currentUser),
                    _buildAddCustomButton(currentUser),
                  ],
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: _showEditGoalDialog,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Editar meta diaria'),
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () {
                        setState(() {
                          _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                        });
                      },
                    ),
                    Text(
                      DateFormat.yMMMMd('es').format(_selectedDate),
                      style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        setState(() {
                          _selectedDate = _selectedDate.add(const Duration(days: 1));
                        });
                      },
                    ),
                  ],
                ),
                const Divider(),

                Stack(
                  children: [
                    if (logsForSelectedDate.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 60.0),
                        child: Center(child: Text('Aún no has añadido agua hoy.')),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: logsForSelectedDate.length,
                        itemBuilder: (context, index) {
                          final log = logsForSelectedDate[index];
                          return ListTile(
                            leading: const Icon(Icons.local_drink, color: Colors.blue),
                            title: Text('${log.amount.toInt()} ml', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
                            subtitle: Text(DateFormat.jm('es').format(log.timestamp)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.grey),
                                  onPressed: () => _editWaterLog(log),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () => _deleteWaterLog(log),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Image.asset(catImagePath, width: 100, height: 100, errorBuilder: (c, o, s) => const SizedBox()),
                    ),
                  ]
                ),
                
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaterButton(double amount, User currentUser) {
    return OutlinedButton.icon(
      onPressed: () => _addWaterLog(amount, currentUser),
      icon: const Icon(Icons.local_drink_outlined),
      label: Text('${amount.toInt()} ml'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildAddCustomButton(User currentUser) {
    return OutlinedButton.icon(
      onPressed: () => _showAddWaterDialog(currentUser),
      icon: const Icon(Icons.add),
      label: const Text('Otro'),
       style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
