import 'package:flutter/material.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/screens/profile/frames_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ProfileReadView extends StatelessWidget {
  final User user;
  final Map<String, String> genderOptions;
  final Map<String, String> activityLevelOptions;
  final String? selectedFrame;

  const ProfileReadView({
    super.key,
    required this.user,
    required this.genderOptions,
    required this.activityLevelOptions,
    this.selectedFrame,
  });

  @override
  Widget build(BuildContext context) {
    final profileImage = user.profileImageBytes != null
        ? MemoryImage(user.profileImageBytes!)
        : null;

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              // 1. El marco (agrandado) se dibuja en el fondo.
              if (selectedFrame != null)
                Image.asset(
                  'assets/marcos/marco_${selectedFrame!.toLowerCase().replaceAll(' ', '_')}.png',
                  width: 220,
                  height: 220,
                  fit: BoxFit.contain,
                ),

              // 2. Contenedor circular con la foto de perfil, dibujado encima.
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300], // Fondo para el caso de que no haya imagen
                  image: profileImage != null
                      ? DecorationImage(
                          image: profileImage,
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                // Si no hay imagen de perfil, muestra un ícono.
                child: profileImage == null
                    ? const Icon(
                        Icons.person,
                        size: 80,
                        color: Colors.white,
                      )
                    : null,
              ),

              // 3. Botón para cambiar marcos, siempre visible.
              Positioned(
                bottom: 0,
                left: 0,
                child: Material(
                  color: Colors.transparent,
                  child: IconButton(
                    icon: Icon(PhosphorIcons.frameCorners(PhosphorIconsStyle.duotone), color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8)),
                    tooltip: 'Ver Marcos',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FramesScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(user.name, style: Theme.of(context).textTheme.headlineMedium),
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
