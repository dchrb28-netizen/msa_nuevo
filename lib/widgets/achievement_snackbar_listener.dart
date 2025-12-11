import 'package:flutter/material.dart';
import 'package:myapp/services/achievement_service.dart';
import 'package:provider/provider.dart';

class AchievementSnackbarListener extends StatefulWidget {
  final Widget child;
  const AchievementSnackbarListener({super.key, required this.child});

  @override
  State<AchievementSnackbarListener> createState() => _AchievementSnackbarListenerState();
}

class _AchievementSnackbarListenerState extends State<AchievementSnackbarListener> {
  @override
  void initState() {
    super.initState();
    // Usar post-frame callback para asegurarse de que el context está disponible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // No es necesario llamar a Provider.of aquí si el listener hace todo el trabajo
      final achievementService = Provider.of<AchievementService>(context, listen: false);
      achievementService.addListener(_showAchievementSnackbar);
    });
  }

  @override
  void dispose() {
    final achievementService = Provider.of<AchievementService>(context, listen: false);
    achievementService.removeListener(_showAchievementSnackbar);
    super.dispose();
  }

  void _showAchievementSnackbar() {
    final achievementService = Provider.of<AchievementService>(context, listen: false);
    final achievement = achievementService.lastUnlockedAchievement;
    if (achievement != null && mounted) {
      final snackBar = SnackBar(
        content: Row(
          children: [
            Icon(achievement.icon, color: Colors.amber, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '¡Logro Desbloqueado!',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(achievement.name),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 4),
      );

      // Asegurarse de que el ScaffoldMessenger es del context correcto
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      achievementService.clearLastUnlockedAchievement();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
