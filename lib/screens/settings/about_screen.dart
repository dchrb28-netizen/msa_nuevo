import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/services/achievement_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final achievementService = Provider.of<AchievementService>(context, listen: false);
        achievementService.updateProgress('exp_about_page', 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors.primary, colors.primary.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: colors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mi Salud Activa',
                    style: GoogleFonts.montserrat(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tu compañero de bienestar personal.',
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Description Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Text(
                'Esta aplicación fue creada para ayudarte a tomar el control de tu salud y bienestar. Creemos que el progreso constante, por pequeño que sea, es la clave para un estilo de vida más saludable y activo.',
                style: GoogleFonts.lato(
                  fontSize: 15,
                  height: 1.6,
                  color: colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
            const SizedBox(height: 28),

            // Features Section
            Text(
              'Funcionalidades',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 14),
            _buildFeatureCard(
              context,
              Icons.fitness_center,
              'Seguimiento de Entrenamientos',
            ),
            _buildFeatureCard(
              context,
              Icons.restaurant,
              'Control de Nutrición e Hidratación',
            ),
            _buildFeatureCard(
              context,
              Icons.show_chart,
              'Visualización de Progreso y Metas',
            ),
            _buildFeatureCard(
              context,
              Icons.emoji_events,
              'Recompensas para mantener la motivación',
            ),

            const SizedBox(height: 28),

            // Contact Section
            Text(
              'Contacto y Comentarios',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '¿Tienes alguna sugerencia, idea, o encontraste un error? ¡Me encantaría oírte!',
              style: GoogleFonts.lato(
                fontSize: 15,
                color: colors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              context,
              Icons.email,
              'Email',
              'misaludactiva373@gmail.com',
              'mailto:misaludactiva373@gmail.com',
              Colors.blueAccent,
            ),
            const SizedBox(height: 10),
            _buildContactCard(
              context,
              Icons.phone,
              'Teléfono',
              '+56964022892',
              'tel:+56964022892',
              Colors.green,
            ),
            const SizedBox(height: 10),
            _buildContactCard(
              context,
              Icons.camera_alt,
              'Instagram',
              '@msa37_3',
              'https://www.instagram.com/msa37_3',
              Colors.pink,
            ),
            const SizedBox(height: 10),
            _buildContactCard(
              context,
              Icons.facebook,
              'Facebook',
              'Mi Salud Activa',
              'https://www.facebook.com/profile.php?id=61580423445819',
              Colors.indigo,
            ),

            const SizedBox(height: 32),

            // Footer
            Center(
              child: Column(
                children: [
                  Text(
                    'Versión 1.0.0',
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: colors.outlineVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '© 2025 Mi Salud Activa',
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: colors.outlineVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, IconData icon, String text) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: colors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.lato(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    String url,
    Color iconColor,
  ) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _launchUrl(url, context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.lato(
                          fontSize: 13,
                          color: colors.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_outward,
                  color: iconColor,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url, BuildContext context) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri)) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('No se pudo abrir $url')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al intentar abrir el enlace.')),
        );
      }
    }
  }
}
