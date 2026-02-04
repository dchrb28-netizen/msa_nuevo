import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/services/achievement_service.dart';
import 'package:myapp/screens/habits/habits_screen.dart';
import 'package:myapp/screens/logs/logs_screen.dart';
import 'package:myapp/screens/main_screen.dart';
import 'package:myapp/screens/profile_screen.dart';
import 'package:myapp/screens/recipes/recipes_screen.dart';
import 'package:myapp/screens/rewards_goals/rewards_and_streaks_screen.dart';
import 'package:myapp/screens/settings/about_screen.dart';
import 'package:myapp/screens/settings_screen.dart';
import 'package:myapp/screens/training/training_screen.dart';
import 'package:myapp/screens/backup_screen.dart';
import 'package:myapp/screens/help/help_manual_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu({super.key});

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String? _hoveredItem;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color textColorForBackground(Color backgroundColor) {
    return ThemeData.estimateBrightnessForColor(backgroundColor) ==
            Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  String getFrameForTitle(String? title) {
    if (title == null) return 'assets/marcos/marco_bienvenido.png';
    return 'assets/marcos/marco_${title.toLowerCase().replaceAll(' ', '_')}.png';
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    Widget buildLogListTile(
      BuildContext context, {
      required IconData icon,
      required Color iconColor,
      required String title,
      required int tabIndex,
    }) {
      final isHovered = _hoveredItem == '$title-$tabIndex';
      return MouseRegion(
        onEnter: (_) => setState(() => _hoveredItem = '$title-$tabIndex'),
        onExit: (_) => setState(() => _hoveredItem = null),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isHovered ? iconColor.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(
                color: isHovered ? iconColor : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: ListTile(
            leading: AnimatedScale(
              scale: isHovered ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(icon, color: iconColor),
            ),
            title: Text(
              title,
              style: GoogleFonts.lato(
                fontWeight: isHovered ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            dense: true,
            visualDensity: VisualDensity.compact,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LogsScreen(initialIndex: tabIndex),
                ),
              );
            },
          ),
        ),
      );
    }

    Widget buildListTile(
      BuildContext context, {
      required IconData icon,
      required Color iconColor,
      required String title,
      required Widget destination,
    }) {
      final isHovered = _hoveredItem == title;
      return MouseRegion(
        onEnter: (_) => setState(() => _hoveredItem = title),
        onExit: (_) => setState(() => _hoveredItem = null),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isHovered ? iconColor.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(
                color: isHovered ? iconColor : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: ListTile(
            leading: AnimatedScale(
              scale: isHovered ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(icon, color: iconColor),
            ),
            title: Text(
              title,
              style: GoogleFonts.lato(
                fontWeight: isHovered ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            dense: true,
            visualDensity: VisualDensity.compact,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => destination),
              );
            },
          ),
        ),
      );
    }

    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface.withOpacity(0.95),
              ],
            ),
          ),
          child: SafeArea(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                Consumer2<UserProvider, AchievementService>(
                  builder: (context, userProvider, achievementService, child) {
                    final user = userProvider.user;
                    final selectedTitle =
                        achievementService.userProfile.selectedTitle;
                    final frameAsset = getFrameForTitle(selectedTitle);
                    final headerTextColor =
                      textColorForBackground(themeProvider.seedColor);
                    final placeholderAvatarColor =
                      Theme.of(context).brightness == Brightness.dark
                        ? Colors.black.withOpacity(0.6)
                        : Colors.white.withOpacity(0.9);

                    return ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(16)),
                      child: Container(
                        height: 160,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              themeProvider.seedColor,
                              themeProvider.seedColor.withOpacity(0.8),
                              themeProvider.seedColor.withOpacity(0.6),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: themeProvider.seedColor.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Efecto de brillo animado
                            Positioned(
                              top: -50,
                              right: -50,
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: 1),
                                duration: const Duration(seconds: 3),
                                builder: (context, value, child) {
                                  return Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          Colors.white.withOpacity(0.2 * value),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Glassmorphism overlay
                            BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withOpacity(0.1),
                                      Colors.white.withOpacity(0.05),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            DrawerHeader(
                              padding: EdgeInsets.zero,
                              decoration: const BoxDecoration(),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ProfileScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0, vertical: 12.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // Borde circular exterior
                                          if (user?.showProfileFrame ?? true)
                                            Container(
                                              width: 140,
                                              height: 140,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: headerTextColor.withValues(alpha: 0.3),
                                                  width: 2.5,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: headerTextColor.withValues(alpha: 0.15),
                                                    blurRadius: 12,
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          // Anillo decorativo
                                          if (user?.showProfileFrame ?? true)
                                            Container(
                                              width: 133,
                                              height: 133,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: LinearGradient(
                                                  colors: [
                                                    themeProvider.seedColor.withValues(alpha: 0.3),
                                                    themeProvider.seedColor.withValues(alpha: 0.1),
                                                    Colors.white.withValues(alpha: 0.5),
                                                    themeProvider.seedColor.withValues(alpha: 0.3),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                              ),
                                            ),
                                          // Marco del perfil
                                          if (user?.showProfileFrame ?? true)
                                            Container(
                                              width: 115,
                                              height: 115,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withValues(alpha: 0.2),
                                                    blurRadius: 15,
                                                    spreadRadius: 1,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: ClipOval(
                                                child: Image.asset(
                                                  frameAsset,
                                                  width: 115,
                                                  height: 115,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            CircleAvatar(
                                            radius: 32,
                                            backgroundColor: user
                                                  ?.profileImageBytes !=
                                                null
                                              ? Colors.transparent
                                              : placeholderAvatarColor,
                                            backgroundImage: user
                                                  ?.profileImageBytes !=
                                                null
                                              ? MemoryImage(
                                                user!.profileImageBytes!)
                                              : null,
                                            child: user?.profileImageBytes ==
                                                null
                                              ? Icon(
                                                PhosphorIcons.person(),
                                                size: 30,
                                                color:
                                                  themeProvider.seedColor,
                                                )
                                              : null,
                                            ),
                                          // Badge con nivel
                                          Positioned(
                                            bottom: -2,
                                            right: -2,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.amber.shade400,
                                                    Colors.amber.shade700,
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                  color: headerTextColor,
                                                  width: 2,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.amber
                                                        .withOpacity(0.6),
                                                    blurRadius: 8,
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    PhosphorIcons.star(
                                                        PhosphorIconsStyle
                                                            .fill),
                                                    size: 10,
                                                    color: Colors.white,
                                                  ),
                                                  const SizedBox(width: 2),
                                                  Text(
                                                    '${achievementService.userProfile.level}',
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              user?.name ?? 'Invitado',
                                              style: GoogleFonts.montserrat(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: headerTextColor,
                                                shadows: [
                                                  Shadow(
                                                    color: Colors.black
                                                        .withOpacity(0.3),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Toca para ver o editar tu perfil',
                                              style: GoogleFonts.lato(
                                                fontSize: 11,
                                                color: headerTextColor
                                                    .withOpacity(0.85),
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: true,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                MouseRegion(
                  onEnter: (_) => setState(() => _hoveredItem = 'Inicio'),
                  onExit: (_) => setState(() => _hoveredItem = null),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _hoveredItem == 'Inicio'
                          ? themeProvider.seedColor.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border(
                        left: BorderSide(
                          color: _hoveredItem == 'Inicio'
                              ? themeProvider.seedColor
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: ListTile(
                      leading: AnimatedScale(
                        scale: _hoveredItem == 'Inicio' ? 1.2 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(PhosphorIcons.house(),
                            color: themeProvider.seedColor),
                      ),
                      title: Text(
                        'Inicio',
                        style: GoogleFonts.lato(
                          fontWeight: _hoveredItem == 'Inicio'
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MainScreen()),
                        );
                      },
                    ),
                  ),
                ),
                const Divider(),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Text(
                    'Secciones',
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                  ),
                ),
                _buildExpansionTile(
                  context,
                  title: 'Registro',
                  icon: PhosphorIcons.notebook(),
                  iconColor: Colors.deepPurple,
                  children: [
                    buildLogListTile(
                      context,
                      icon: PhosphorIcons.drop(),
                      iconColor: Colors.blue,
                      title: 'Ingesta de Agua',
                      tabIndex: 0,
                    ),
                    buildLogListTile(
                      context,
                      icon: PhosphorIcons.hamburger(),
                      iconColor: Colors.yellow[700]!,
                      title: 'Comidas',
                      tabIndex: 1,
                    ),
                    buildLogListTile(
                      context,
                      icon: PhosphorIcons.ruler(),
                      iconColor: Colors.teal,
                      title: 'Medidas',
                      tabIndex: 2,
                    ),
                  ],
                ),
                _buildExpansionTile(
                  context,
                  title: 'Mis Recetas',
                  icon: PhosphorIcons.bookOpen(),
                  iconColor: Colors.brown[600]!,
                  children: [
                    buildListTile(
                      context,
                      icon: PhosphorIcons.magnifyingGlass(),
                      iconColor: Colors.orange[800]!,
                      title: 'Buscar Recetas',
                      destination: const RecipesScreen(initialTabIndex: 0),
                    ),
                    buildListTile(
                      context,
                      icon: PhosphorIcons.heart(),
                      iconColor: Colors.red[400]!,
                      title: 'Recetas Favoritas',
                      destination: const RecipesScreen(initialTabIndex: 1),
                    ),
                  ],
                ),
                _buildExpansionTile(
                  context,
                  title: 'Entrenamiento',
                  icon: PhosphorIcons.barbell(),
                  iconColor: Colors.red[700]!,
                  children: [
                    buildListTile(
                      context,
                      icon: PhosphorIcons.listChecks(),
                      iconColor: Colors.blue[700]!,
                      title: 'Rutinas',
                      destination: const TrainingScreen(initialTabIndex: 0),
                    ),
                    buildListTile(
                      context,
                      icon: PhosphorIcons.books(),
                      iconColor: Colors.pink,
                      title: 'Biblioteca',
                      destination: const TrainingScreen(initialTabIndex: 1),
                    ),
                  ],
                ),
                _buildExpansionTile(
                  context,
                  title: 'Hábitos',
                  icon: PhosphorIcons.checkCircle(),
                  iconColor: Colors.lightGreen[800]!,
                  children: [
                    buildListTile(
                      context,
                      icon: PhosphorIcons.bell(),
                      iconColor: Colors.amber[600]!,
                      title: 'Recordatorios',
                      destination: const HabitsScreen(initialTabIndex: 0),
                    ),
                    buildListTile(
                      context,
                      icon: PhosphorIcons.clipboardText(),
                      iconColor: Colors.blue[600]!,
                      title: 'Tareas Diarias',
                      destination: const HabitsScreen(initialTabIndex: 1),
                    ),
                    buildListTile(
                      context,
                      icon: PhosphorIcons.hourglass(),
                      iconColor: Colors.lime[700]!,
                      title: 'Ayuno Intermitente',
                      destination: const HabitsScreen(initialTabIndex: 2),
                    ),
                  ],
                ),
                _buildExpansionTile(
                  context,
                  title: 'Hitos',
                  icon: PhosphorIcons.trophy(),
                  iconColor: Colors.amber[900]!,
                  children: [
                    buildListTile(
                      context,
                      icon: PhosphorIcons.medal(),
                      iconColor: Colors.yellow[600]!,
                      title: 'Mis Logros',
                      destination:
                          const RewardsAndStreaksScreen(initialTabIndex: 0),
                    ),
                    buildListTile(
                      context,
                      icon: PhosphorIcons.fire(),
                      iconColor: Colors.deepOrange[400]!,
                      title: 'Rachas',
                      destination:
                          const RewardsAndStreaksScreen(initialTabIndex: 1),
                    ),
                  ],
                ),
                _buildExpansionTile(
                  context,
                  title: 'Configuración',
                  icon: PhosphorIcons.gear(),
                  iconColor: Colors.grey[700]!,
                  children: [
                    buildListTile(
                      context,
                      icon: PhosphorIcons.calculator(),
                      iconColor: Colors.green,
                      title: 'Metas Calóricas',
                      destination: const SettingsScreen(initialIndex: 0),
                    ),
                    buildListTile(
                      context,
                      icon: PhosphorIcons.heartbeat(),
                      iconColor: Colors.purple,
                      title: 'Objetivos de Peso',
                      destination: const SettingsScreen(initialIndex: 1),
                    ),
                    buildListTile(
                      context,
                      icon: PhosphorIcons.palette(),
                      iconColor: Colors.orange,
                      title: 'Temas',
                      destination: const SettingsScreen(initialIndex: 2),
                    ),
                  ],
                ),
                const Divider(),
                MouseRegion(
                  onEnter: (_) => setState(() => _hoveredItem = 'Acerca de'),
                  onExit: (_) => setState(() => _hoveredItem = null),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    decoration: BoxDecoration(
                      color: _hoveredItem == 'Acerca de'
                          ? Colors.blueGrey.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border(
                        left: BorderSide(
                          color: _hoveredItem == 'Acerca de'
                              ? Colors.blueGrey.shade500
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: ListTile(
                      leading: AnimatedScale(
                        scale: _hoveredItem == 'Acerca de' ? 1.2 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(PhosphorIcons.info(),
                            color: Colors.blueGrey[500]!),
                      ),
                      title: Text(
                        'Acerca de',
                        style: GoogleFonts.lato(
                          fontWeight: _hoveredItem == 'Acerca de'
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AboutScreen()),
                        );
                      },
                    ),
                  ),
                ),
                MouseRegion(
                  onEnter: (_) => setState(() => _hoveredItem = 'Respaldo'),
                  onExit: (_) => setState(() => _hoveredItem = null),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    decoration: BoxDecoration(
                      color: _hoveredItem == 'Respaldo'
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border(
                        left: BorderSide(
                          color: _hoveredItem == 'Respaldo'
                              ? Colors.blue.shade800
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: ListTile(
                      leading: AnimatedScale(
                        scale: _hoveredItem == 'Respaldo' ? 1.2 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          PhosphorIcons.cloudArrowUp(),
                          color: Colors.blue[800]!,
                        ),
                      ),
                      title: Text(
                        'Respaldo',
                        style: GoogleFonts.lato(
                          fontWeight: _hoveredItem == 'Respaldo'
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const BackupScreen()),
                        );
                      },
                    ),
                  ),
                ),
                MouseRegion(
                  onEnter: (_) => setState(() => _hoveredItem = 'Manual'),
                  onExit: (_) => setState(() => _hoveredItem = null),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    decoration: BoxDecoration(
                      color: _hoveredItem == 'Manual'
                          ? Colors.green.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border(
                        left: BorderSide(
                          color: _hoveredItem == 'Manual'
                              ? Colors.green.shade700
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: ListTile(
                      leading: AnimatedScale(
                        scale: _hoveredItem == 'Manual' ? 1.2 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          PhosphorIcons.bookOpen(),
                          color: Colors.green[700]!,
                        ),
                      ),
                      title: Text(
                        'Manual de Usuario',
                        style: GoogleFonts.lato(
                          fontWeight: _hoveredItem == 'Manual'
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HelpManualScreen()),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpansionTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: iconColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          title: Text(
            title,
            style: GoogleFonts.lato(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          childrenPadding:
              const EdgeInsets.only(left: 4, right: 4, bottom: 8, top: 4),
          collapsedIconColor: iconColor.withOpacity(0.7),
          iconColor: iconColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          collapsedShape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: iconColor.withOpacity(0.03),
          collapsedBackgroundColor: Colors.transparent,
          children: children,
        ),
      ),
    );
  }
}
