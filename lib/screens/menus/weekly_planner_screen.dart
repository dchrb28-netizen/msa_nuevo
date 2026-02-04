import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:myapp/providers/meal_plan_provider.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/screens/menus/edit_meal_screen.dart';
import 'package:myapp/screens/menus/meal_plan_suggestions_screen.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class WeeklyPlannerScreen extends StatefulWidget {
  const WeeklyPlannerScreen({super.key});

  @override
  State<WeeklyPlannerScreen> createState() => _WeeklyPlannerScreenState();
}

class _WeeklyPlannerScreenState extends State<WeeklyPlannerScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.week;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MealPlanSuggestionsScreen(),
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.event_note, size: 24),
              const Text('Planes Sugeridos', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          // Opciones para repetir semana + export/import + undo
          PopupMenuButton<String>(
            onSelected: (value) async {
              final mealPlan = Provider.of<MealPlanProvider>(context, listen: false);
              final visibleStart = _focusedDay.subtract(Duration(days: _focusedDay.weekday - 1)); // lunes visible
              if (value == 'repeat_visible') {
                final source = visibleStart;
                final target = source.add(const Duration(days: 7));
                mealPlan.repeatWeekDates(source, target, overwrite: true);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semana mostrada repetida a la siguiente semana')));
              } else if (value == 'repeat_previous') {
                final source = visibleStart.subtract(const Duration(days: 7));
                final target = visibleStart;
                mealPlan.repeatWeekDates(source, target, overwrite: true);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semana anterior repetida a la semana mostrada')));
              } else if (value == 'export') {
                final json = mealPlan.exportDailyPlanJson();
                // Mostrar dialog con JSON y opción copiar
                await showDialog(
                  context: context,
                  builder: (ctx) {
                    return AlertDialog(
                      title: const Text('Exportar planes (JSON)'),
                      content: SizedBox(
                        width: double.maxFinite,
                        child: SingleChildScrollView(
                          child: SelectableText(json),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          },
                          child: const Text('Cerrar'),
                        ),
                      ],
                    );
                  },
                );
              } else if (value == 'import') {
                final controller = TextEditingController();
                bool overwrite = true;
                await showDialog(
                  context: context,
                  builder: (ctx) {
                    return StatefulBuilder(builder: (ctx, setState) {
                      return AlertDialog(
                        title: const Text('Importar planes (pega JSON)'),
                        content: SizedBox(
                          width: double.maxFinite,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: controller,
                                maxLines: 12,
                                decoration: const InputDecoration(hintText: 'Pega aquí el JSON exportado'),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Checkbox(
                                      value: overwrite,
                                      onChanged: (v) {
                                        setState(() {
                                          overwrite = v ?? true;
                                        });
                                      }),
                                  const Expanded(child: Text('Sobrescribir entradas existentes (si no marcado, solo rellenar huecos)')),
                                ],
                              )
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
                          TextButton(
                              onPressed: () {
                                mealPlan.importDailyPlanJson(controller.text, overwrite: overwrite);
                                Navigator.of(ctx).pop();
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Importación completada')));
                              },
                              child: const Text('Importar')),
                        ],
                      );
                    });
                  },
                );
              } else if (value == 'undo') {
                mealPlan.undoLastChange();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Último cambio deshecho')));
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'repeat_visible', child: Text('Repetir semana mostrada → siguiente semana')),
              const PopupMenuItem(value: 'repeat_previous', child: Text('Repetir semana anterior → mostrada')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'export', child: Text('Exportar planes (JSON)')),
              const PopupMenuItem(value: 'import', child: Text('Importar planes (JSON)')),
              const PopupMenuItem(value: 'undo', child: Text('Deshacer último cambio')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'es_ES',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerStyle: HeaderStyle(
              titleCentered: true,
              titleTextStyle: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              formatButtonDecoration: BoxDecoration(
                color: themeProvider.seedColor,
                borderRadius: BorderRadius.circular(20.0),
              ),
              formatButtonTextStyle: const TextStyle(color: Colors.white),
              formatButtonShowsNext: false,
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: themeProvider.seedColor.withAlpha(128),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: themeProvider.seedColor,
                shape: BoxShape.circle,
              ),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          Expanded(
            child: Consumer<MealPlanProvider>(
              builder: (context, mealPlan, child) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    final firstDayOfWeek = _focusedDay.subtract(
                      Duration(days: _focusedDay.weekday - 1),
                    );
                    final day = firstDayOfWeek.add(Duration(days: index));
                    final formattedDay = DateFormat(
                      'EEEE, d MMMM',
                      'es_ES',
                    ).format(day);
                    final isSelected = isSameDay(day, _selectedDay);

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: isSelected ? 6 : 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      clipBehavior: Clip.antiAlias,
                      color: isSelected
                          ? themeProvider.seedColor.withAlpha(26)
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formattedDay,
                              style: GoogleFonts.lato(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: themeProvider.seedColor,
                              ),
                            ),
                            const Divider(height: 20),
                            _buildMealRow(
                              context,
                              'Desayuno',
                              Icons.free_breakfast,
                              day,
                              mealPlan,
                            ),
                            _buildMealRow(
                              context,
                              'Almuerzo',
                              Icons.lunch_dining,
                              day,
                              mealPlan,
                            ),
                            _buildMealRow(
                              context,
                              'Cena',
                              Icons.dinner_dining,
                              day,
                              mealPlan,
                            ),
                            _buildMealRow(
                              context,
                              'Snacks',
                              Icons.fastfood,
                              day,
                              mealPlan,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealRow(
    BuildContext context,
    String meal,
    IconData icon,
    DateTime day,
    MealPlanProvider mealPlan,
  ) {
    final mealText = mealPlan.getMealTextForDay(day, meal);
    final isMealPlanned = mealText.isNotEmpty;

    final mealRowContent = InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditMealScreen(mealType: meal, date: day),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary.withAlpha(204),
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal,
                    style: GoogleFonts.lato(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isMealPlanned ? mealText : 'Toca para añadir una comida',
                    style: GoogleFonts.lato(
                      fontSize: 15,
                      color: isMealPlanned
                          ? Colors.grey[700]
                          : Colors.grey[500],
                      fontStyle: isMealPlanned
                          ? FontStyle.normal
                          : FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit_outlined, size: 22, color: Colors.blueGrey),
          ],
        ),
      ),
    );

    if (isMealPlanned) {
      return Dismissible(
        key: Key('${day.toIso8601String()}-$meal'),
        direction: DismissDirection.horizontal,
        background: Container(
          color: Colors.redAccent.withAlpha(230),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          alignment: Alignment.centerLeft,
          child: const Icon(
            Icons.delete_outline,
            color: Colors.white,
            size: 30,
          ),
        ),
        secondaryBackground: Container(
          color: Colors.redAccent.withAlpha(230),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          alignment: Alignment.centerRight,
          child: const Icon(
            Icons.delete_outline,
            color: Colors.white,
            size: 30,
          ),
        ),
        onDismissed: (direction) {
          final originalMealText = mealPlan.getMealTextForDay(day, meal);

          mealPlan.updateMealText(day, meal, '');

          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Menú de "$meal" eliminado.'),
              action: SnackBarAction(
                label: 'DESHACER',
                onPressed: () {
                  mealPlan.updateMealText(day, meal, originalMealText);
                },
              ),
            ),
          );
        },
        child: mealRowContent,
      );
    }

    return mealRowContent;
  }
}
