import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProgresoScreen extends StatelessWidget {
  const ProgresoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 20),
          Text(
            'Progreso',
            style: GoogleFonts.oswald(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Aquí podrás visualizar gráficos y estadísticas de tu progreso a lo largo del tiempo.',
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
