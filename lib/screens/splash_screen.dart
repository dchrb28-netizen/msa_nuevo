
import 'package:flutter/material.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/screens/main_screen.dart';
import 'package:myapp/screens/profile_selection_screen.dart';
import 'package:provider/provider.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkProfileAndNavigate();
  }

  Future<void> _checkProfileAndNavigate() async {
    // We use a short delay to ensure the provider is ready
    await Future.delayed(const Duration(milliseconds: 50));

    // We don't want to listen to changes, just get the provider once.
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Try to load the last active user from storage
    await userProvider.loadCurrentUser();

    // Check if the widget is still in the tree before navigating
    if (mounted) {
      if (userProvider.currentUser != null) {
        // If there's an active user, go to the main screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        // If there's no user, go to the profile selection screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ProfileSelectionScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while we check for the profile
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
