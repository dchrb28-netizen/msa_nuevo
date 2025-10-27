import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:myapp/models/body_measurement.dart';
import 'package:myapp/models/daily_meal_plan.dart';
import 'package:myapp/models/fasting_log.dart';
import 'package:myapp/models/food.dart';
import 'package:myapp/models/food_log.dart';
import 'package:myapp/models/meal_type.dart';
import 'package:myapp/models/recipe.dart';
import 'package:myapp/models/reminder.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/models/user_recipe.dart';
import 'package:myapp/models/water_log.dart';
import 'package:myapp/providers/fasting_provider.dart';
import 'package:myapp/providers/meal_plan_provider.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/screens/main_screen.dart';
import 'package:myapp/screens/profile_screen.dart';
import 'package:myapp/screens/welcome_screen.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:url_strategy/url_strategy.dart';

// Import the new models and providers
import 'package:myapp/models/routine.dart';
import 'package:myapp/models/set_log.dart';
import 'package:myapp/models/exercise.dart';
import 'package:myapp/models/exercise_log.dart';
import 'package:myapp/models/routine_exercise.dart';
import 'package:myapp/models/routine_log.dart';
import 'package:myapp/providers/exercise_provider.dart';
import 'package:myapp/providers/routine_provider.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service
  await NotificationService().init();

  // Remove the # from the URL
  setPathUrlStrategy();

  await initializeDateFormatting('es', null);
  await Hive.initFlutter();

  // Register adapters
  if (!Hive.isAdapterRegistered(FoodAdapter().typeId)) {
    Hive.registerAdapter(FoodAdapter());
  }
  if (!Hive.isAdapterRegistered(WaterLogAdapter().typeId)) {
    Hive.registerAdapter(WaterLogAdapter());
  }
  if (!Hive.isAdapterRegistered(FoodLogAdapter().typeId)) {
    Hive.registerAdapter(FoodLogAdapter());
  }
  if (!Hive.isAdapterRegistered(BodyMeasurementAdapter().typeId)) {
    Hive.registerAdapter(BodyMeasurementAdapter());
  }
  if (!Hive.isAdapterRegistered(UserAdapter().typeId)) {
    Hive.registerAdapter(UserAdapter());
  }
  if (!Hive.isAdapterRegistered(MealTypeAdapter().typeId)) {
    Hive.registerAdapter(MealTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(DailyMealPlanAdapter().typeId)) {
    Hive.registerAdapter(DailyMealPlanAdapter());
  }
  if (!Hive.isAdapterRegistered(RecipeAdapter().typeId)) {
    Hive.registerAdapter(RecipeAdapter());
  }
  if (!Hive.isAdapterRegistered(UserRecipeAdapter().typeId)) {
    Hive.registerAdapter(UserRecipeAdapter());
  }
  if (!Hive.isAdapterRegistered(ReminderAdapter().typeId)) {
    Hive.registerAdapter(ReminderAdapter());
  }
  if (!Hive.isAdapterRegistered(FastingLogAdapter().typeId)) {
    Hive.registerAdapter(FastingLogAdapter());
  }

  // Register the new training adapters
  if (!Hive.isAdapterRegistered(RoutineAdapter().typeId)) {
    Hive.registerAdapter(RoutineAdapter());
  }
  if (!Hive.isAdapterRegistered(SetLogAdapter().typeId)) {
    Hive.registerAdapter(SetLogAdapter());
  }
  if (!Hive.isAdapterRegistered(ExerciseLogAdapter().typeId)) {
    Hive.registerAdapter(ExerciseLogAdapter());
  }
  if (!Hive.isAdapterRegistered(RoutineLogAdapter().typeId)) {
    Hive.registerAdapter(RoutineLogAdapter());
  }
  if (!Hive.isAdapterRegistered(ExerciseAdapter().typeId)) {
    Hive.registerAdapter(ExerciseAdapter());
  }
  if (!Hive.isAdapterRegistered(RoutineExerciseAdapter().typeId)) {
    Hive.registerAdapter(RoutineExerciseAdapter());
  }

  // Open boxes
  await Hive.openBox<Food>('foods');
  await Hive.openBox<WaterLog>('water_logs');
  await Hive.openBox<FoodLog>('food_logs');
  await Hive.openBox<BodyMeasurement>('body_measurements');
  await Hive.openBox<User>('user_box');
  await Hive.openBox<DailyMealPlan>('daily_meal_plans');
  await Hive.openBox('settings');
  await Hive.openBox<Recipe>('favorite_recipes');
  await Hive.openBox<UserRecipe>('user_recipes');
  await Hive.openBox<Reminder>('reminders');
  await Hive.openBox<FastingLog>('fasting_logs');

  // Open the new training boxes
  await Hive.openBox<Routine>('routines');
  await Hive.openBox<RoutineLog>('routine_logs');
  await Hive.openBox<Exercise>('exercises');
  await Hive.openBox<RoutineExercise>('routine_exercises');

  await _populateInitialFoodData();

  final prefs = await SharedPreferences.getInstance();
  final bool profileExists = prefs.getBool('profile_exists') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => FastingProvider()),
        ChangeNotifierProvider(create: (context) => MealPlanProvider()),
        ChangeNotifierProvider(create: (context) => RoutineProvider()),
        ChangeNotifierProvider(create: (context) => ExerciseProvider()),
      ],
      child: MyApp(profileExists: profileExists),
    ),
  );
}

Future<void> _populateInitialFoodData() async {
  final foodBox = Hive.box<Food>('foods');
  if (foodBox.isEmpty) {
    const uuid = Uuid();
    var food1Id = uuid.v4();
    await foodBox.put(
        food1Id,
        Food(
            id: food1Id,
            name: 'Manzana',
            calories: 52,
            proteins: 0.3,
            carbohydrates: 14,
            fats: 0.2));
    var food2Id = uuid.v4();
    await foodBox.put(
        food2Id,
        Food(
            id: food2Id,
            name: 'Plátano',
            calories: 89,
            proteins: 1.1,
            carbohydrates: 23,
            fats: 0.3));
    var food3Id = uuid.v4();
    await foodBox.put(
        food3Id,
        Food(
            id: food3Id,
            name: 'Pechuga de Pollo (a la plancha)',
            calories: 165,
            proteins: 31,
            carbohydrates: 0,
            fats: 3.6));
    var food4Id = uuid.v4();
    await foodBox.put(
        food4Id,
        Food(
            id: food4Id,
            name: 'Arroz Blanco (cocido)',
            calories: 130,
            proteins: 2.7,
            carbohydrates: 28,
            fats: 0.3));
    var food5Id = uuid.v4();
    await foodBox.put(
        food5Id,
        Food(
            id: food5Id,
            name: 'Huevo (cocido)',
            calories: 155,
            proteins: 13,
            carbohydrates: 1.1,
            fats: 11));
  }
}

class MyApp extends StatelessWidget {
  final bool profileExists;
  const MyApp({super.key, required this.profileExists});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final textTheme = GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme,
        ).copyWith(
          displayLarge:
              const TextStyle(fontSize: 57, fontWeight: FontWeight.bold),
          displayMedium:
              const TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
          displaySmall:
              const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          headlineLarge:
              const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          headlineMedium:
              const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          headlineSmall:
              const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          titleLarge:
              const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          titleMedium:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          titleSmall:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          bodyLarge:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
          bodyMedium:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
          bodySmall:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
          labelLarge:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          labelMedium:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          labelSmall:
              const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        );

        // Generate the base color scheme from the seed color
        var lightColorScheme = ColorScheme.fromSeed(
          seedColor: themeProvider.seedColor,
          brightness: Brightness.light,
        );

        // Force the primary color to be the vibrant seed color
        lightColorScheme = lightColorScheme.copyWith(
          primary: themeProvider.seedColor,
        );

        var darkColorScheme = ColorScheme.fromSeed(
          seedColor: themeProvider.seedColor,
          brightness: Brightness.dark,
        );

        // Force the primary color to be the vibrant seed color
        darkColorScheme = darkColorScheme.copyWith(
          primary: themeProvider.seedColor,
        );

        // Function to determine text color based on background brightness
        Color textColorForBackground(Color backgroundColor) {
          return ThemeData.estimateBrightnessForColor(backgroundColor) ==
                  Brightness.dark
              ? Colors.white
              : Colors.black;
        }

        final lightAppBarTextColor = textColorForBackground(lightColorScheme.primary);
        final darkAppBarTextColor = textColorForBackground(darkColorScheme.primary);

        final lightTheme = ThemeData(
          useMaterial3: true,
          colorScheme: lightColorScheme,
          textTheme: textTheme,
          scaffoldBackgroundColor: lightColorScheme.surface,
          appBarTheme: AppBarTheme(
            backgroundColor: lightColorScheme.primary, // Use scheme's primary color
            foregroundColor: lightAppBarTextColor,
            elevation: 2,
            titleTextStyle:
                textTheme.headlineSmall?.copyWith(color: lightAppBarTextColor),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedItemColor: lightColorScheme.primary, // Use scheme's primary color
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            showUnselectedLabels: true,
          ),
          tabBarTheme: TabBarThemeData(
            labelColor: lightAppBarTextColor,
            unselectedLabelColor:
                lightAppBarTextColor.withAlpha((255 * 0.7).round()),
            indicatorColor: lightAppBarTextColor,
          ),
           elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: lightColorScheme.primary,
              foregroundColor: lightColorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        );

        final darkTheme = ThemeData(
          useMaterial3: true,
          colorScheme: darkColorScheme,
          textTheme: textTheme,
          scaffoldBackgroundColor: darkColorScheme.surface,
          appBarTheme: AppBarTheme(
            backgroundColor: darkColorScheme.primary, // Use scheme's primary color
            foregroundColor: darkAppBarTextColor,
            elevation: 2,
            titleTextStyle:
                textTheme.headlineSmall?.copyWith(color: darkAppBarTextColor),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: darkColorScheme.surface,
            selectedItemColor: darkColorScheme.primary, // Use scheme's primary color
            unselectedItemColor: Colors.grey[400],
            type: BottomNavigationBarType.fixed,
            showUnselectedLabels: true,
          ),
          tabBarTheme: TabBarThemeData(
            labelColor: darkAppBarTextColor,
            unselectedLabelColor:
                darkAppBarTextColor.withAlpha((255 * 0.7).round()),
            indicatorColor: darkAppBarTextColor,
          ),
           elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: darkColorScheme.primary,
              foregroundColor: darkColorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        );

        return MaterialApp(
          title: 'Salud Activa',
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('es', ''),
          ],
          locale: const Locale('es'),
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: profileExists ? '/' : '/welcome',
          routes: {
            '/': (context) => const MainScreen(),
            '/welcome': (context) => const WelcomeScreen(),
            '/profile': (context) => const ProfileScreen(),
          },
        );
      },
    );
  }
}
