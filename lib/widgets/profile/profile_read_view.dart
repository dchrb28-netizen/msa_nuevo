import 'package:flutter/material.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/screens/profile/frames_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ProfileReadView extends StatelessWidget {
  final User user;
  final Map<String, String> genderOptions;
  final Map<String, String> activityLevelOptions;

  const ProfileReadView({
    super.key,
    required this.user,
    required this.genderOptions,
    required this.activityLevelOptions,
  });

  String getFrameForLevel(String? level) {
    switch (level?.toLowerCase()) {
      case 'aprendiz':
        return 'assets/marcos/marco_aprendiz.png';
      case 'atleta':
        return 'assets/marcos/marco_atleta.png';
      case 'competidor':
        return 'assets/marcos/marco_competidor.png';
      case 'leyenda':
        return 'assets/marcos/marco_leyenda.png';
      case 'titán':
        return 'assets/marcos/marco_titán.png';
      default:
        return 'assets/marcos/marco_bienvenido.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileImage = user.profileImageBytes != null
        ? MemoryImage(user.profileImageBytes!)
        : null;
    final frameAsset = getFrameForLevel(user.level);

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              if (user.showProfileFrame ?? true) // Asegura retrocompatibilidad
                ClipOval(
                  child: Image.asset(
                    frameAsset,
                    width: 220,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                ),
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[300],
                backgroundImage: profileImage,
                child: profileImage == null
                    ? const Icon(
                        Icons.person,
                        size: 65,
                        color: Colors.white,
                      )
                    : null,
              ),
            ],
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
      ),
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
