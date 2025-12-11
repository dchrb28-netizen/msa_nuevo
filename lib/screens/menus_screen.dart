import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/screens/menus/today_menu_screen.dart';
import 'package:myapp/screens/menus/weekly_planner_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MenusScreen extends StatefulWidget {
  const MenusScreen({super.key});

  @override
  MenusScreenState createState() => MenusScreenState();
}

class MenusScreenState extends State<MenusScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild to update icon styles
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isTodaySelected = _tabController.index == 0;

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.onSurface,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withAlpha((255 * 0.6).round()),
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelStyle: GoogleFonts.lato(fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.lato(),
          tabs: [
            Tab(
              icon: Icon(
                isTodaySelected
                    ? PhosphorIcons.calendarCheck(PhosphorIconsStyle.fill)
                    : PhosphorIcons.calendarCheck(PhosphorIconsStyle.regular),
              ),
              text: 'Menú de Hoy',
            ),
            Tab(
              icon: Icon(
                !isTodaySelected
                    ? PhosphorIcons.calendar(PhosphorIconsStyle.fill)
                    : PhosphorIcons.calendar(PhosphorIconsStyle.regular),
              ),
              text: 'Planificador Semanal',
            ),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              TodayMenuScreen(),
              WeeklyPlannerScreen(),
            ],
          ),
        ),
      ],
    );
  }
}
