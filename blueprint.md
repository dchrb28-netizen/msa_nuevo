# Plan de Desarrollo de la Aplicación de Salud y Fitness

## Visión General

Esta aplicación está diseñada para ser un asistente integral de salud y fitness, permitiendo a los usuarios registrar sus comidas, planificar sus menús semanales, seguir sus rutinas de entrenamiento y monitorizar su progreso físico. La aplicación contará con una interfaz moderna, intuitiva y personalizable, con un fuerte enfoque en la experiencia de usuario y la accesibilidad.

## Características Implementadas

### Estilo y Diseño

*   **Tema Moderno y Personalizable**: Uso de `ColorScheme.fromSeed`, `google_fonts`, y componentes de Material 3 para una estética moderna y coherente.
*   **Interfaz de Usuario Atractiva**: Diseño limpio, con tarjetas, iconografía clara y una buena organización visual.

### Funcionalidades Clave

*   **Navegación Principal**:
    *   Barra de navegación inferior y menú lateral (Drawer) para un acceso rápido a todas las secciones.
    *   Sistema de pestañas (`TabBar`) en Menús y Entrenamiento.
*   **Dashboard (Pantalla de Inicio)**:
    *   Saludo de bienvenida atractivo y tarjetas de resumen para calorías y peso.
*   **Gestión de Perfil de Usuario**:
    *   Modelo de datos (`User`), pantalla de edición de perfil y persistencia con `shared_preferences`.
*   **Planificación de Comidas**:
    *   **Menú del Día (`TodayMenuScreen`)**: Vista detallada de las comidas del día con sus alimentos y total de calorías.
    *   **Planificador Semanal (`WeeklyPlannerScreen`)**: Calendario interactivo para planificar las comidas de la semana.
    *   **Detalle de Comida (`MealDetailScreen`)**:
        *   Muestra un desglose de los alimentos de una comida específica.
        *   Calcula y presenta un resumen de macronutrientes (calorías, proteínas, carbohidratos, grasas).
    *   **Edición de Comida (`EditMealScreen`)**:
        *   Permite al usuario añadir o eliminar alimentos de una comida (funcionalidad simulada por ahora).

## Plan de Trabajo Reciente

1.  **Rediseño de Pantallas de Menús**: Se ha mejorado la estructura y el diseño de `today_menu_screen.dart` y `weekly_planner_screen.dart` para una mejor experiencia de usuario.
2.  **Implementación de Calendario Semanal**: Se ha integrado el paquete `table_calendar` para ofrecer una vista de planificación semanal interactiva y navegable.
3.  **Corrección de Errores y Advertencias**:
    *   Se han solucionado errores de modelos de datos y advertencias de funciones obsoletas.
    *   Se ha corregido un error de desbordamiento visual (overflow) en el Dashboard, mejorando el diseño del saludo.
4.  **Implementación de la funcionalidad "Ver" y "Editar" en el Planificador Semanal**:
    *   **Creación de la Pantalla de Detalles (`meal_details_screen.dart`)**: Para mostrar un resumen detallado de una comida.
    *   **Creación de la Pantalla de Edición (`edit_meal_screen.dart`)**: Para (simular) la edición de los alimentos de una comida.
    *   **Integración de la Navegación**: Se han conectado los botones "Ver" y "Editar" del planificador para que naveguen a las nuevas pantallas, pasando el tipo de comida y la fecha correspondiente.
