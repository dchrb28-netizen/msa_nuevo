import 'package:flutter/material.dart';
import 'package:myapp/models/achievement.dart';
import 'package:myapp/services/achievement_service.dart';
import 'package:provider/provider.dart';

class FramesScreen extends StatelessWidget {
  const FramesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final achievementService = Provider.of<AchievementService>(context);

    final allFrames = {
      'Bienvenido': 'welcome_frame',
      'Bienvenido1': 'welcome_frame1',
      'Bienvenido2': 'welcome_frame2',
      'Aprendiz': 'level_up_5',
      'Atleta': 'level_up_10',
      'Competidor': 'level_up_20',
      'Titán': 'level_up_35',
      'Leyenda': 'level_up_50',
      'Meta Cumplida': 'goal_weight_target',
    };

    return Scaffold(
      appBar: AppBar(
        // title removed
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 0.8,
        ),
        itemCount: allFrames.length,
        itemBuilder: (context, index) {
          final frameName = allFrames.keys.elementAt(index);
          final achievementId = allFrames.values.elementAt(index);

          final achievement = achievementService.getAchievements().firstWhere(
                (a) => a.id == achievementId,
                orElse: () => Achievement(
                  id: 'not_found',
                  name: 'Desconocido',
                  description: 'Logro aún no definido en el sistema.',
                  category: AchievementCategory.milestones, // CORREGIDO
                  icon: Icons.lock_outline,
                  isUnlocked: false,
                ),
              );

          final bool isUnlocked = frameName.toLowerCase().contains('bienvenido') || achievement.isUnlocked;
          final String achievementDescription = frameName.toLowerCase().contains('bienvenido') 
              ? 'Disponible desde el inicio.' // CORREGIDO
              : achievement.description;

          final imagePath = 'assets/marcos/marco_${frameName.toLowerCase().replaceAll(' ', '_')}.png';

          return GestureDetector(
            onTap: () {
              if (isUnlocked) {
                achievementService.setSelectedTitle(frameName);
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('¡Aún no has desbloqueado este marco!'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            },
            child: FrameCard(
              frameName: frameName,
              imagePath: imagePath,
              isUnlocked: isUnlocked,
              achievementDescription: achievementDescription,
            ),
          );
        },
      ),
    );
  }
}

class FrameCard extends StatelessWidget {
  final String frameName;
  final String imagePath;
  final bool isUnlocked;
  final String achievementDescription;

  const FrameCard({
    super.key,
    required this.frameName,
    required this.imagePath,
    required this.isUnlocked,
    required this.achievementDescription,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    color: isUnlocked ? null : Colors.grey.withAlpha(100),
                    colorBlendMode: isUnlocked ? null : BlendMode.saturation,
                  ),
                  if (!isUnlocked)
                    Center(
                      child: Icon(
                        Icons.lock,
                        size: 40.0,
                        color: colors.onSurface.withAlpha(200),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            color: colors.surfaceContainer.withAlpha(150),
            child: Column(
              children: [
                Text(
                  frameName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!isUnlocked)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      achievementDescription,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
