import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MenusScreen extends StatelessWidget {
  const MenusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu_outlined,
            size: 100,
            color: colorScheme.primary.withAlpha(128),
          ),
          const SizedBox(height: 20),
          Text(
            'Próximamente',
            style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Aquí podrás planificar y ver tus menús semanales.',
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(fontSize: 16, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
