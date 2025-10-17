
# Blueprint: Salud Activa App

## Visión General

"Salud Activa" es una aplicación de seguimiento de salud para Flutter, diseñada para ayudar a los usuarios a monitorear su ingesta de agua y alimentos, así como sus medidas corporales. La aplicación cuenta con una pantalla de bienvenida, perfiles de usuario (creación y modo invitado), y una pantalla principal con navegación por pestañas.

## Estilo y Diseño

- **Tema:** La aplicación utiliza un sistema de temas claro/oscuro basado en `ColorScheme.fromSeed` de Material 3, permitiendo una paleta de colores personalizable.
- **Tipografía:** Se usa el paquete `google_fonts` con "Lato" y "Oswald" para una apariencia limpia y moderna.
- **UI:** El diseño es limpio, centrado y sigue las guías de Material Design, con botones claros, tarjetas y una navegación intuitiva.
- **Activos:** La pantalla de bienvenida muestra una imagen (`luna_inicio_b.png` o `luna_inicio_w.png`) que se adapta al modo de tema actual (claro/oscuro).

## Características Implementadas

- **Gestión de Tema:**
    - Un `ThemeProvider` gestiona el estado del tema (claro, oscuro, sistema).
    - El color principal (`seedColor`) es personalizable.
- **Pantalla de Bienvenida (`welcome_screen.dart`):**
    - Ofrece dos opciones: "Crear Perfil" o "Continuar como Invitado".
    - Muestra una imagen de bienvenida que se adapta al tema.
    - Navega a la `ProfileScreen` o `HomeScreen` según la elección.
- **Pantalla Principal (`main_screen.dart`):**
    - Utiliza una `BottomNavigationBar` para navegar entre tres secciones principales: Inicio, Registros y Progreso.
    - `MainScreen` actúa como el `Scaffold` principal de la aplicación, gestionando la barra de navegación y el cuerpo de la pantalla activa.
- **Estructura de Pantallas:**
    - `DashboardScreen`: Muestra un resumen general o pantalla de inicio.
    - `RecordsScreen`: Contiene una `TabBar` para navegar entre el registro de Agua, Comida y Medidas. Cada una de estas pestañas, a su vez, tiene sub-pestañas para "Hoy" y "Historial".
    - `ProgresoScreen`: Pantalla dedicada a mostrar el progreso del usuario.
- **Gestión de Perfil:**
    - `ProfileProvider` para gestionar el estado del perfil de usuario.
    - Lógica en `main.dart` para decidir si mostrar la `WelcomeScreen` (si no hay perfil) o la `MainScreen` (si ya existe un perfil).

## Plan de Corrección Actual: Conflicto de `Scaffold` Anidados

Esta sección detalla el diagnóstico y la solución al problema de renderizado causado por múltiples `Scaffold` en el árbol de widgets.

### 1. Diagnóstico
- **Problema:** La aplicación mostraba errores visuales, como texto con subrayado amarillo y un comportamiento inesperado en la interfaz de usuario. Esto era especialmente visible en las pantallas de `RecordsScreen` y sus sub-pantallas.
- **Causa Raíz:** Se descubrió que múltiples pantallas secundarias (ej. `WaterIntakeScreen`, `FoodHistoryScreen`, etc.) tenían su propio widget `Scaffold`. Esto creaba un conflicto con el `Scaffold` principal de `MainScreen`, que se supone que es el único andamiaje de la estructura de la aplicación en ese nivel. Tener `Scaffold` anidados de esta manera es una práctica incorrecta en Flutter y conduce a problemas con el `Theme`, el `MediaQuery` y el correcto renderizado de los widgets de Material Design.

### 2. Solución Implementada
- **Acción:** Se llevó a cabo una refactorización exhaustiva para eliminar todos los `Scaffold` innecesarios de las pantallas secundarias.
- **Archivos Modificados:**
    - `lib/screens/records_screen.dart`: Se eliminaron los `Scaffold` que envolvían cada `TabBarView` de las pestañas de Agua, Comida y Medidas.
    - `lib/screens/water_intake_screen.dart`: Se eliminó el `Scaffold` principal.
    - `lib/screens/food_intake_screen.dart`: Se eliminó el `Scaffold` principal.
    - `lib/screens/body_measurement_screen.dart`: Se eliminó el `Scaffold` principal.
    - `lib/screens/water_history_screen.dart`: Se eliminó el `Scaffold` principal.
    - `lib/screens/food_history_screen.dart`: Se eliminó el `Scaffold` principal.
    - `lib/screens/body_measurement_history_screen.dart`: Se eliminó el `Scaffold` principal.

- **Resultado:** Al eliminar los `Scaffold` anidados, el árbol de widgets se simplificó y se corrigió. `MainScreen` ahora proporciona el único `Scaffold` para la navegación principal, y todas las pantallas secundarias se renderizan correctamente dentro de su `body`. Esto resolvió los problemas de renderizado y restauró la integridad visual de la aplicación.
