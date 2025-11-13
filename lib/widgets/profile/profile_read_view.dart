
import 'package:flutter/material.dart';
import 'package:myapp/models/user.dart';

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

  @override
  Widget build(BuildContext context) {
    final profileImage = user.profileImageBytes != null
        ? MemoryImage(user.profileImageBytes!)
        : const AssetImage('assets/icons/icon.png') as ImageProvider;

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 80,
            backgroundImage: profileImage,
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
                Expanded(child: _buildInfoItem(context, Icons.cake_outlined, 'Edad', '${user.age} años')),
                SizedBox(
                  height: 60,
                  child: VerticalDivider(width: 1, thickness: 1, indent: 8, endIndent: 8, color: Colors.grey[300]),
                ),
                Expanded(child: _buildInfoItem(context, Icons.height_outlined, 'Altura', '${user.height.toStringAsFixed(0)} cm')),
              ],
            ),
            const Divider(height: 1, indent: 20, endIndent: 20),
            Row(
              children: [
                Expanded(child: _buildInfoItem(context, Icons.monitor_weight_outlined, 'Peso', '${user.weight.toStringAsFixed(1)} kg')),
                SizedBox(
                  height: 60,
                  child: VerticalDivider(width: 1, thickness: 1, indent: 8, endIndent: 8, color: Colors.grey[300]),
                ),
                Expanded(child: _buildInfoItem(context, Icons.person_outline, 'Género', genderOptions[user.gender] ?? 'No especificado')),
              ],
            ),
            const Divider(height: 1, indent: 20, endIndent: 20),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: _buildInfoItem(context, Icons.fitness_center_outlined, 'Nivel Actividad', activityLevelOptions[user.activityLevel] ?? 'No especificado'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
      BuildContext context, IconData icon, String label, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(value,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
