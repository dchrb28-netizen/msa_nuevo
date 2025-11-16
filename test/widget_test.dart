import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:myapp/models/body_measurement.dart';
import 'package:myapp/models/daily_meal_plan.dart';
import 'package:myapp/models/exercise.dart';
import 'package:myapp/models/exercise_log.dart';
import 'package:myapp/models/fasting_log.dart';
import 'package:myapp/models/food.dart';
import 'package:myapp/models/food_log.dart';
import 'package:myapp/models/meal_entry.dart';
import 'package:myapp/models/meal_type.dart';
import 'package:myapp/models/recipe.dart';
import 'package:myapp/models/reminder.dart';
import 'package:myapp/models/routine.dart';
import 'package:myapp/models/routine_exercise.dart';
import 'package:myapp/models/routine_log.dart';
import 'package:myapp/models/set_log.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/models/user_recipe.dart';
import 'package:myapp/models/water_log.dart';
import 'package:myapp/providers/exercise_provider.dart';
import 'package:myapp/providers/fasting_provider.dart';
import 'package:myapp/providers/meal_plan_provider.dart';
import 'package:myapp/providers/routine_provider.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/main.dart';
import 'package:provider/provider.dart';

// Helper to safely register adapters in a test environment
void _tryRegisterAdapter<T>(TypeAdapter<T> adapter) {
  if (!Hive.isAdapterRegistered(adapter.typeId)) {
    Hive.registerAdapter(adapter);
  }
}

void main() {
  // This runs once before all tests
  setUpAll(() async {
    // Tests need a path to initialize Hive.
    // A temporary directory is perfect for this to avoid side effects.
    final tempDir = await Directory.systemTemp.createTemp('hive_test');
    Hive.init(tempDir.path);

    // Register all the same adapters as in main.dart
    _tryRegisterAdapter(UserAdapter());
    _tryRegisterAdapter(FoodAdapter());
    _tryRegisterAdapter(WaterLogAdapter());
    _tryRegisterAdapter(FoodLogAdapter());
    _tryRegisterAdapter(BodyMeasurementAdapter());
    _tryRegisterAdapter(MealTypeAdapter());
    _tryRegisterAdapter(DailyMealPlanAdapter());
    _tryRegisterAdapter(RecipeAdapter());
    _tryRegisterAdapter(UserRecipeAdapter());
    _tryRegisterAdapter(ReminderAdapter());
    _tryRegisterAdapter(FastingLogAdapter());
    _tryRegisterAdapter(RoutineAdapter());
    _tryRegisterAdapter(SetLogAdapter());
    _tryRegisterAdapter(ExerciseLogAdapter());
    _tryRegisterAdapter(RoutineLogAdapter());
    _tryRegisterAdapter(ExerciseAdapter());
    _tryRegisterAdapter(RoutineExerciseAdapter());
    _tryRegisterAdapter(MealEntryAdapter());

    // Open all the boxes the app needs
    await Hive.openBox<User>('user_box');
    await Hive.openBox<Food>('foods');
    await Hive.openBox<WaterLog>('water_logs');
    await Hive.openBox<FoodLog>('food_logs');
    await Hive.openBox<BodyMeasurement>('body_measurements');
    await Hive.openBox<DailyMealPlan>('daily_meal_plans');
    await Hive.openBox('settings');
    await Hive.openBox<Recipe>('favorite_recipes');
    await Hive.openBox<UserRecipe>('user_recipes');
    await Hive.openBox<Reminder>('reminders');
    await Hive.openBox<FastingLog>('fasting_logs');
    await Hive.openBox<Routine>('routines');
    await Hive.openBox<RoutineLog>('routine_logs');
    await Hive.openBox<Exercise>('exercises');
    await Hive.openBox<RoutineExercise>('routine_exercises');
    await Hive.openBox<MealEntry>('meal_entries');
  });

  // This runs once after all tests
  tearDownAll(() async {
    await Hive.close();
  });

  testWidgets('App loads main screen without crashing', (WidgetTester tester) async {
    // Provide a dummy user with all required fields
    final userBox = Hive.box<User>('user_box');
    await userBox.put('activeUser', 
      User(
        id: 'test', 
        name: 'Test User',
        gender: 'Masculino',
        age: 30,
        height: 180,
        weight: 75,
      )
    );

    // Build our app with all necessary providers and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ThemeProvider()),
          ChangeNotifierProvider(create: (context) => UserProvider()),
          ChangeNotifierProvider(create: (context) => FastingProvider()),
          ChangeNotifierProvider(create: (context) => MealPlanProvider()),
          ChangeNotifierProvider(create: (context) => RoutineProvider()),
          ChangeNotifierProvider(create: (context) => ExerciseProvider()),
        ],
        child: const MyApp(initialRoute: '/'),
      ),
    );

    // Let the UI settle.
    await tester.pumpAndSettle();

    // Verify that the main screen has loaded by finding a key widget.
    // The BottomNavigationBar is a good candidate.
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // Verify that a piece of text from the Dashboard is visible.
    expect(find.text('Calorías'), findsOneWidget);
  });
}
