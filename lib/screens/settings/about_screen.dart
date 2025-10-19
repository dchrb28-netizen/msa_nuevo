import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        // title: const Text('Acerca de Mi Salud Activa'), // Removed title
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mi Salud Activa',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tu compañero de bienestar personal.',
              style: TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Esta aplicación fue creada para ayudarte a tomar el control de tu salud y bienestar. Creemos que el progreso constante, por pequeño que sea, es la clave para un estilo de vida más saludable y activo.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 24),
            
            Text(
              'Funcionalidades',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 12),
            _buildFeatureRow(context, Icons.fitness_center, 'Seguimiento de Entrenamientos'),
            _buildFeatureRow(context, Icons.fastfood, 'Control de Nutrición e Hidratación'),
            _buildFeatureRow(context, Icons.show_chart, 'Visualización de Progreso y Metas'),
            _buildFeatureRow(context, Icons.emoji_events, 'Recompensas para mantener la motivación'),
            
            const SizedBox(height: 24),

            Text(
              'Contacto y Comentarios',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '¿Tienes alguna sugerencia, idea, o encontraste un error? ¡Me encantaría oírte!',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.blueAccent),
              title: const Text('misaludactiva373@gmail.com'),
              onTap: () => _launchUrl('mailto:misaludactiva373@gmail.com', context),
            ),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: const Text('+56964022892'),
              onTap: () => _launchUrl('tel:+56964022892', context),
            ),
             ListTile(
              leading: const Icon(Icons.link, color: Colors.purple),
              title: const Text('Instagram'),
              onTap: () => _launchUrl('https://www.instagram.com/msa37_3', context),
            ),
            ListTile(
              leading: const Icon(Icons.facebook, color: Colors.indigo),
              title: const Text('Facebook'),
              onTap: () => _launchUrl('https://www.facebook.com/profile.php?id=61580423445819', context),
            ),
            
            const SizedBox(height: 32),

            const Center(
              child: Column(
                children: [
                  Text(
                    'Versión 1.0.0',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '© 2025 Mi Salud Activa',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.secondary, size: 28),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
  
  Future<void> _launchUrl(String url, BuildContext context) async {
    final Uri uri = Uri.parse(url);
    try {
       if (!await launchUrl(uri)) {
         if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo abrir $url')));
         }
       }
    } catch (e) {
       if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al intentar abrir el enlace.')));
       }
    }
  }
}