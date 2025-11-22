
import 'package:flutter/material.dart';
import 'package:myapp/models/achievement.dart';
import 'package:myapp/services/achievement_service.dart';
import 'package:provider/provider.dart';

class FramesScreen extends StatelessWidget {
  const FramesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final achievementService = Provider.of<AchievementService>(context);

    // Lista de todos los marcos disponibles y sus logros asociados
    final allFrames = {
      'Aprendiz': 'level_up_5',
      'Atleta': 'level_up_10',
      'Competidor': 'level_up_20',
      'Titán': 'level_up_35',
      'Leyenda': 'level_up_50',
      'Meta Cumplida': 'goal_weight_target',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marcos de Perfil'),
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
          final achievement = achievementService.getAchievements()
              .firstWhere((a) => a.id == achievementId, orElse: () => Achievement(id: '', name: '', description: '', icon: Icons.lock, category: AchievementCategory.milestones, isUnlocked: false));
          
          final isUnlocked = achievement.isUnlocked;
          final imagePath =
              'assets/marcos/marco_${frameName.toLowerCase().replaceAll(' ', '_')}.png';

          return GestureDetector(
            onTap: () {
              if (isUnlocked) {
                achievementService.setSelectedTitle(frameName);
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('¡Desbloquea el logro para usar este marco!'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: FrameCard(
              frameName: frameName,
              imagePath: imagePath,
              isUnlocked: isUnlocked,
              achievementDescription: achievement.description,
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
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
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
                    color: isUnlocked ? null : Colors.grey.withAlpha(128),
                    colorBlendMode: isUnlocked ? null : BlendMode.saturation,
                  ),
                   if (!isUnlocked)
                    Center(
                      child: Icon(
                        Icons.lock,
                        size: 40.0,
                        color: Colors.white.withAlpha(204),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  frameName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (!isUnlocked)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      achievementDescription,
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
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
