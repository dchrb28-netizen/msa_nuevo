import 'package:flutter/material.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/screens/profile/frames_screen.dart';
import 'package:myapp/services/achievement_service.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class ProfileReadView extends StatelessWidget {
  final Map<String, String> genderOptions;
  final Map<String, String> activityLevelOptions;

  const ProfileReadView({
    super.key,
    required this.genderOptions,
    required this.activityLevelOptions,
  });

  String getFrameForTitle(String? title) {
    if (title == null) return 'assets/marcos/marco_bienvenido.png';
    return 'assets/marcos/marco_${title.toLowerCase().replaceAll(' ', '_')}.png';
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final profileImage =
        user.profileImageBytes != null ? MemoryImage(user.profileImageBytes!) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Center(
          child: Consumer<AchievementService>(
            builder: (context, achievementService, child) {
              final selectedFrame = achievementService.userProfile.selectedTitle;
              final frameAsset = getFrameForTitle(selectedFrame);

              return Stack(
                alignment: Alignment.center,
                children: [
                  if (user.showProfileFrame ?? true)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FramesScreen(),
                          ),
                        );
                      },
                      child: ClipOval(
                        child: Image.asset(
                          frameAsset,
                          width: 238,
                          height: 238,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  child!, 
                ],
              );
            },
            child: CircleAvatar(
              radius: 67,
              backgroundColor: Colors.grey[300],
              backgroundImage: profileImage,
              child: profileImage == null
                  ? const Icon(
                      Icons.person,
                      size: 55,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(user.name, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                PhosphorIcons.frameCorners(PhosphorIconsStyle.duotone),
                color: Theme.of(context).colorScheme.primary,
                size: 32,
              ),
              tooltip: 'Cambiar Marco',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FramesScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 40),
        _buildInfoCard(context, user),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, User user) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    context,
                    PhosphorIcons.cake(PhosphorIconsStyle.duotone),
                    'Edad',
                    '${user.age} años',
                  ),
                ),
                SizedBox(
                  height: 60,
                  child: VerticalDivider(
                    width: 1,
                    thickness: 1,
                    indent: 8,
                    endIndent: 8,
                    color: Colors.grey[300],
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    context,
                    PhosphorIcons.ruler(PhosphorIconsStyle.duotone),
                    'Altura',
                    '${user.height.toStringAsFixed(0)} cm',
                  ),
                ),
              ],
            ),
            const Divider(height: 1, indent: 20, endIndent: 20),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    context,
                    PhosphorIcons.barbell(PhosphorIconsStyle.duotone),
                    'Peso',
                    '${user.weight.toStringAsFixed(1)} kg',
                  ),
                ),
                SizedBox(
                  height: 60,
                  child: VerticalDivider(
                    width: 1,
                    thickness: 1,
                    indent: 8,
                    endIndent: 8,
                    color: Colors.grey[300],
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    context,
                    PhosphorIcons.genderIntersex(PhosphorIconsStyle.duotone),
                    'Género',
                    genderOptions[user.gender] ?? 'No especificado',
                  ),
                ),
              ],
            ),
            const Divider(height: 1, indent: 20, endIndent: 20),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: _buildInfoItem(
                context,
                PhosphorIcons.heartbeat(PhosphorIconsStyle.duotone),
                'Nivel Actividad',
                activityLevelOptions[user.activityLevel] ?? 'No especificado',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(
          value,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
