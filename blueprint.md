# Blueprint de la Aplicación Salud Activa

## Descripción General

Salud Activa es una aplicación de seguimiento de salud y fitness diseñada para ayudar a los usuarios a registrar sus comidas, consumo de agua, medidas corporales y entrenamientos. La aplicación proporciona una visión integral del progreso del usuario y ofrece herramientas para establecer y alcanzar objetivos de salud.

## Estructura del Proyecto

El proyecto sigue una estructura de feature-first, donde cada característica principal (como registro de alimentos, perfil, etc.) tiene su propia carpeta dentro de `lib/screens`.

- **`lib/`**
  - **`models/`**: Contiene las clases del modelo de datos (User, Food, FoodLog, etc.).
  - **`providers/`**: Gestiona el estado de la aplicación (ThemeProvider, UserProvider).
  - **`screens/`**: Contiene las pantallas principales de la aplicación.
    - **`achievements/`**: Pantallas relacionadas con logros y objetivos.
    - **`food_logging/`**: Pantallas para el registro de alimentos.
    - **`settings/`**: Pantallas de configuración.
    - **`training/`**: Pantallas para el registro de entrenamientos.
  - **`widgets/`**: Contiene widgets reutilizables.
  - **`main.dart`**: Punto de entrada de la aplicación.

## Estilo y Diseño

- **Tema:** La aplicación utiliza un tema Material 3 personalizable, permitiendo al usuario elegir un color de semilla para generar el esquema de colores. Se admite tanto el modo claro como el oscuro.
- **Tipografía:** Se utiliza `GoogleFonts.montserratTextTheme` para una apariencia de texto consistente y moderna.
- **Navegación:** La navegación principal se realiza a través de un `BottomNavigationBar` en `MainScreen`. Las sub-secciones (como en "Registro") utilizan un `TabBar` integrado en la `AppBar`.

## Características Implementadas

### 1. Onboarding y Perfil de Usuario

- **WelcomeScreen:** Pantalla de bienvenida para nuevos usuarios.
- **ProfileScreen:** Permite a los usuarios introducir y guardar su información personal (nombre, género, edad, altura, peso, nivel de actividad). Los valores de género y nivel de actividad se guardan en inglés para facilitar los cálculos internos.
- **UserProvider:** Gestiona el estado del usuario a lo largo de la aplicación, incluyendo la carga y guardado del usuario en la base de datos local (Hive).

### 2. Registro de Actividades

- **FoodLoggingMainScreen:** Pantalla principal para el registro de alimentos, con pestañas para el registro diario y la biblioteca de alimentos.
- **WaterLogScreen:** Permite registrar el consumo de agua.
- **BodyMeasurementsScreen:** Permite registrar medidas corporales (peso, IMC, etc.).

### 3. Entrenamiento

- **TrainingMainScreen:** Pantalla principal para el registro de entrenamientos, con pestañas para los ejercicios y la biblioteca de ejercicios. La navegación por pestañas (`TabBar`) está integrada en la `AppBar` para mantener la consistencia con otras secciones.
- **AddExerciseScreen:** Permite a los usuarios añadir nuevos ejercicios a su biblioteca.
- **ExerciseLibraryScreen:** Muestra la lista de ejercicios guardados.

### 4. Configuración

- **SettingsScreen:** Menú de configuración con opciones para ir a la pantalla de temas.
- **ThemeSettingsScreen:** Permite al usuario personalizar el tema de la aplicación, incluyendo el color de semilla y el modo (claro/oscuro/sistema).

### 5. Metas y Objetivos

- **ObjectivesScreen:** Muestra el IMC del usuario y su rango de peso ideal.
- **CaloricGoalsScreen:**
    - **Informe automático:** Ya no es un formulario.
    - **Lee datos del perfil:** Toma automáticamente la información del usuario (edad, peso, altura, género, nivel de actividad).
    - **Calcula y muestra:** Presenta las calorías diarias recomendadas para tres objetivos: perder, mantener y ganar peso.
    - **Manejo de perfil incompleto:** Si faltan datos en el perfil, muestra una advertencia y un botón para navegar a la pantalla de perfil.

### 6. Navegación

- Se utiliza un sistema de rutas nominadas en `main.dart` para una navegación más robusta. Se ha definido la ruta `/profile` para facilitar el acceso a la pantalla de perfil desde otras partes de la aplicación.
