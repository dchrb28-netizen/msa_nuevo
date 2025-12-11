import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:myapp/main.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:provider/provider.dart';

void main() {
  group('Login and User Creation', () {
    setUpAll(() async {
      // Initialize Hive for testing
      Hive.init('test');
      // El adaptador debe ser generado con build_runner
      // if (!Hive.isAdapterRegistered(0)) {
      //   Hive.registerAdapter(UserAdapter());
      // }
    });

    tearDownAll(() async {
      await Hive.close();
    });

    testWidgets('Creates a new user and logs in', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(); // Allow providers to initialize

      // We need a context to work with providers, let's find one.
      final BuildContext context = tester.element(find.byType(MaterialApp));
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Manually clear ALL existing users for a clean test run.
      // Create a copy of the list to avoid modification during iteration.
      final List<User> usersToDelete = List.from(userProvider.users);
      for (final user in usersToDelete) {
        await userProvider.deleteUser(user.id);
      }
      await tester.pumpAndSettle(); // Let UI update after deletion

      // Expect to be on the Welcome/Splash screen, which should guide to profile creation
      // After deleting all users, we should land on the screen that allows creating a new one.
      expect(find.text('Crear Perfil'), findsOneWidget, reason: 'Should be on the profile creation prompt screen');

      await tester.tap(find.text('Crear Perfil'));
      await tester.pumpAndSettle();

      // Now we should be on the profile creation screen
      expect(find.text('Crea tu Perfil'), findsOneWidget, reason: 'Should navigate to the profile creation screen');

      // Enter user data.
      await tester.enterText(find.byKey(const Key('nameField')), 'Test User');
      await tester.enterText(find.byKey(const Key('ageField')), '30');
      await tester.enterText(find.byKey(const Key('heightField')), '175');
      await tester.enterText(find.byKey(const Key('weightField')), '70');
      await tester.tap(find.byKey(const Key('genderField')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Masculino').last);
      await tester.pumpAndSettle();

      // Tap the 'Guardar' button.
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle(); // Wait for navigation

      // Verify that the user is redirected to the home screen (e.g., HomeScreen).
      expect(find.text('Resumen del Día'), findsOneWidget, reason: 'Should be on the main dashboard after profile creation');

      // Verify that the user is saved in the UserProvider.
      final finalUserProvider = Provider.of<UserProvider>(context, listen: false);
      expect(finalUserProvider.user, isNotNull);
      expect(finalUserProvider.user!.name, 'Test User');
    });
  });
}
