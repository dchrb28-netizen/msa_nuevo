import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:myapp/models/body_measurement.dart';
import 'package:myapp/models/exercise.dart';
import 'package:myapp/models/food.dart';
import 'package:myapp/models/food_log.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/models/water_log.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/screens/main_screen.dart';
import 'package:myapp/screens/welcome_screen.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  if (!Hive.isAdapterRegistered(ExerciseAdapter().typeId)) {
    Hive.registerAdapter(ExerciseAdapter());
  }
  if (!Hive.isAdapterRegistered(UserAdapter().typeId)) {
    Hive.registerAdapter(UserAdapter());
  }

  // Open boxes
  await Hive.openBox<Food>('foods');
  await Hive.openBox<WaterLog>('water_logs');
  await Hive.openBox<FoodLog>('food_logs');
  await Hive.openBox<BodyMeasurement>('body_measurements');
  await Hive.openBox<Exercise>('exercises');
  await Hive.openBox<User>('user_box');
  await Hive.openBox('settings');

  await _populateInitialFoodData();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> _populateInitialFoodData() async {
  final foodBox = Hive.box<Food>('foods');
  if (foodBox.isEmpty) {
    const uuid = Uuid();
    var food1Id = uuid.v4();
    await foodBox.put(food1Id, Food(id: food1Id, name: 'Manzana', calories: 52, proteins: 0.3, carbohydrates: 14, fats: 0.2));
    var food2Id = uuid.v4();
    await foodBox.put(food2Id, Food(id: food2Id, name: 'Plátano', calories: 89, proteins: 1.1, carbohydrates: 23, fats: 0.3));
    var food3Id = uuid.v4();
    await foodBox.put(food3Id, Food(id: food3Id, name: 'Pechuga de Pollo (a la plancha)', calories: 165, proteins: 31, carbohydrates: 0, fats: 3.6));
    var food4Id = uuid.v4();
    await foodBox.put(food4Id, Food(id: food4Id, name: 'Arroz Blanco (cocido)', calories: 130, proteins: 2.7, carbohydrates: 28, fats: 0.3));
    var food5Id = uuid.v4();
    await foodBox.put(food5Id, Food(id: food5Id, name: 'Huevo (cocido)', calories: 155, proteins: 13, carbohydrates: 1.1, fats: 11));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final textTheme = GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme,
        ).copyWith(
          displayLarge: const TextStyle(fontSize: 57, fontWeight: FontWeight.bold),
          displayMedium: const TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
          displaySmall: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          headlineLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          headlineMedium: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          headlineSmall: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          titleLarge: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          titleSmall: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          bodyLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
          bodyMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
          bodySmall: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
          labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          labelMedium: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          labelSmall: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        );

        final lightColorScheme = ColorScheme.fromSeed(
          seedColor: themeProvider.seedColor,
          brightness: Brightness.light,
        );

        final darkColorScheme = ColorScheme.fromSeed(
          seedColor: themeProvider.seedColor,
          brightness: Brightness.dark,
        );

        // Function to determine text color based on background brightness
        Color textColorForBackground(Color backgroundColor) {
            return ThemeData.estimateBrightnessForColor(backgroundColor) == Brightness.dark
                ? Colors.white
                : Colors.black;
        }

        final appBarTextColor = textColorForBackground(themeProvider.seedColor);

        final lightTheme = ThemeData(
          useMaterial3: true,
          colorScheme: lightColorScheme,
          textTheme: textTheme,
          scaffoldBackgroundColor: lightColorScheme.surface,
          appBarTheme: AppBarTheme(
            backgroundColor: themeProvider.seedColor,
            foregroundColor: appBarTextColor,
            elevation: 2,
            titleTextStyle: textTheme.headlineSmall?.copyWith(color: appBarTextColor),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedItemColor: themeProvider.seedColor,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            showUnselectedLabels: true,
          ),
          tabBarTheme: TabBarThemeData(
            labelColor: appBarTextColor,
            unselectedLabelColor: appBarTextColor.withAlpha((255 * 0.7).round()),
            indicatorColor: appBarTextColor,
          ),
        );

        final darkTheme = ThemeData(
          useMaterial3: true,
          colorScheme: darkColorScheme,
          textTheme: textTheme,
          scaffoldBackgroundColor: darkColorScheme.surface,
          appBarTheme: AppBarTheme(
            backgroundColor: themeProvider.seedColor,
            foregroundColor: appBarTextColor,
            elevation: 2,
            titleTextStyle: textTheme.headlineSmall?.copyWith(color: appBarTextColor),
          ),
           bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: darkColorScheme.surface,
            selectedItemColor: themeProvider.seedColor,
            unselectedItemColor: Colors.grey[400],
            type: BottomNavigationBarType.fixed,
            showUnselectedLabels: true,
          ),
           tabBarTheme: TabBarThemeData(
            labelColor: appBarTextColor,
            unselectedLabelColor: appBarTextColor.withAlpha((255 * 0.7).round()),
            indicatorColor: appBarTextColor,
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
          home: userProvider.user != null ? const MainScreen() : const WelcomeScreen(),
        );
      },
    );
  }
}
