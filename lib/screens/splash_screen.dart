import 'package:flutter/material.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/screens/main_screen.dart';
import 'package:myapp/screens/profile_selection_screen.dart';
import 'package:provider/provider.dart';

// The class name was corrected from WelcomeScreen to SplashScreen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure the context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkProfileAndNavigate();
    });
  }

  Future<void> _checkProfileAndNavigate() async {
    // Add a small delay to ensure Hive boxes are fully loaded
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (!mounted) return;
    
    // We get the provider and navigator once before any async gaps.
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final navigator = Navigator.of(context);

    // The UserProvider constructor already calls loadUsers(), 
    // so the data should be available synchronously here.
    await userProvider.loadUsers(); // Recalled to ensure freshness

    if (userProvider.user != null) {
      // If there's an active user, go to the main screen
      navigator.pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else if (userProvider.users.isNotEmpty) {
      // If there are users but no active user selected,
      // automatically select the first user and go to main screen
      await userProvider.switchUser(userProvider.users.first.id);
      navigator.pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      // If there's no user at all, go to the profile selection screen
      navigator.pushReplacement(
        MaterialPageRoute(builder: (context) => const ProfileSelectionScreen()),
      );
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
