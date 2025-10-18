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
    - Navega a la `ProfileScreen` o `MainScreen` según la elección.
- **Pantalla Principal (`main_screen.dart`):**
    - Utiliza una `BottomNavigationBar` para navegar entre tres secciones principales: Inicio, Menús y Progreso.
- **Estructura de Pantallas:**
    - `DashboardScreen`: Muestra un resumen general o pantalla de inicio.
    - `MenusScreen`: Una nueva sección dedicada a los menús, independiente de los registros.
    - `LogsScreen`: Una pantalla dedicada que contiene una `TabBar` para navegar entre los registros de Agua, Comida y Medidas.
    - `ProgresoScreen`: Pantalla dedicada a mostrar el progreso del usuario.
- **Gestión de Perfil:**
    - `ProfileProvider` para gestionar el estado del perfil de usuario.
    - Lógica en `main.dart` para decidir si mostrar la `WelcomeScreen` (si no hay perfil) o la `MainScreen` (si ya existe un perfil).

## Plan de Corrección Actual: Reestructuración de la Navegación

Esta sección detalla el diagnóstico y la solución a la reorganización de la navegación principal de la aplicación.

### 1. Diagnóstico
- **Problema de Navegación:** La barra de navegación inferior no reflejaba la estructura deseada. Mostraba "Registros" en lugar de "Menús", y la funcionalidad de registros estaba incorrectamente integrada en la pantalla principal.

### 2. Solución Implementada
- **Acción de Navegación:**
    - Se actualizó la barra de navegación en `main_screen.dart` para mostrar las pestañas "Inicio", "Menús" y "Progreso".
    - Se creó una nueva pantalla `MenusScreen` como un placeholder para el futuro contenido de esta sección.
    - Se creó una pantalla `LogsScreen` dedicada para alojar la `TabBar` con los registros de "Agua", "Comida" y "Medidas".
    - Se modificó el menú lateral (`drawer_menu.dart`) para que las opciones de registro ahora naveguen a la `LogsScreen`, pasando el índice de la pestaña correspondiente.

- **Resultado:** La aplicación ahora tiene una estructura de navegación que separa claramente la sección "Menús" de la sección "Registros", mejorando la organización del código y la experiencia del usuario. El `blueprint.md` se ha actualizado para reflejar estos cambios.
