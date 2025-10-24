import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/screens/main_screen.dart'; 
import 'package:myapp/screens/profile_screen.dart';
import 'package:provider/provider.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final colorScheme = Theme.of(context).colorScheme;

        final lunaImagePath = isDarkMode
            ? 'assets/luna_png/luna_splash_b.png'
            : 'assets/luna_png/luna_splash_w.png';

        return Container(
          color: isDarkMode ? Colors.black : Colors.white,
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      lunaImagePath,
                      height: 180,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 40),
                    _buildContent(context, colorScheme),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildContent(BuildContext context, ColorScheme colorScheme) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        
        const SizedBox(height: 16),
        Text(
          'Tu compañero personal de salud',
          textAlign: TextAlign.center,
          style: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: (isDarkMode ? Colors.white : Colors.black).withAlpha(178), // 70% opacity
          ),
        ),
        const SizedBox(height: 48),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 5,
          ),
          child: Text(
            'Crear Perfil',
            style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () {
            userProvider.setGuestUser();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          },
          style: TextButton.styleFrom(
            foregroundColor: colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            'Continuar como Invitado',
            style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
