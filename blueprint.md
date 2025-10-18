# Blueprint: Salud Activa App

## Visión General

"Salud Activa" es una aplicación de seguimiento de salud para Flutter, diseñada para ayudar a los usuarios a monitorear su ingesta de agua y alimentos, así como sus medidas corporales. La aplicación cuenta con una pantalla de bienvenida, perfiles de usuario (creación y modo invitado), y una pantalla principal con navegación por pestañas.

## Estilo y Diseño

- **Tema:** La aplicación utiliza un sistema de temas claro/oscuro basado en `ColorScheme.fromSeed` de Material 3, permitiendo una paleta de colores personalizable.
- **Tipografía:** Se usa el paquete `google_fonts` con "Montserrat" para una apariencia limpia y moderna.
- **UI:** El diseño es limpio, centrado y sigue las guías de Material Design, con botones claros, tarjetas y una navegación intuitiva.
- **Activos:** La pantalla de bienvenida muestra una imagen (`luna_inicio_b.png` o `luna_inicio_w.png`) que se adapta al modo de tema actual (claro/oscuro).

## Características y Flujo de la Aplicación

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
    - `RecipesScreen`: Una pantalla dedicada para la gestión de recetas, con una `TabBar` para las pestañas "Recetas" y "Favoritas".

## Plan de Implementación Actual: Nueva Sección "Mis Recetas"

### 1. Requisito del Usuario

Añadir una nueva categoría "Mis Recetas" en el menú lateral. Esta categoría debe contener tres opciones:
- Ver la lista de todas las recetas.
- Ver las recetas marcadas como favoritas.
- Una opción para añadir una nueva receta.

### 2. Solución Implementada

Siguiendo las directrices de arquitectura de la aplicación, se implementó la nueva sección de la siguiente manera:

- **Pantalla Principal de Recetas (`recipes_screen.dart`):**
    - Se ha creado una nueva pantalla que contiene una `TabBar` con dos pestañas: "Recetas" y "Recetas Favoritas".
    - Se añadió un `FloatingActionButton` en esta pantalla que navega a la `AddRecipeScreen` para permitir al usuario añadir nuevas recetas.

- **Nuevas Pantallas Placeholder:**
    - `recipe_list_screen.dart`: Para mostrar la lista de todas las recetas.
    - `favorite_recipes_screen.dart`: Para mostrar las recetas favoritas.
    - `add_recipe_screen.dart`: Para el formulario de creación de recetas.

- **Actualización del Menú Lateral (`drawer_menu.dart`):**
    - Se ha añadido una nueva sección desplegable titulada "Mis Recetas".
    - Contiene enlaces a "Recetas" y "Recetas Favoritas" (que abren la `RecipesScreen` en la pestaña correspondiente) y un enlace directo a "Añadir Receta".

## Directrices de Diseño y Navegación Futura

Para mantener la consistencia y una arquitectura limpia en la aplicación, cualquier nueva funcionalidad que agrupe varias subsecciones seguirá el siguiente patrón de diseño:

1.  **Pantalla Dedicada con `TabBar`:**
    - Para funcionalidades agrupadas (por ejemplo, "Ejercicios" y "Biblioteca de Ejercicios"), se creará una pantalla principal dedicada.
    - Esta pantalla utilizará una `TabBar` para permitir al usuario navegar fácilmente entre las subsecciones relacionadas.

2.  **Integración en la Navegación Principal:**
    - El acceso a esta nueva pantalla dedicada se integrará de forma lógica en el **menú lateral (`Drawer`)** o en otra ubicación secundaria de la interfaz de usuario.
    - La **barra de navegación inferior** se mantendrá limpia y reservada exclusivamente para las secciones principales de la aplicación: "Inicio", "Menús" y "Progreso".

Este enfoque garantiza que la aplicación siga siendo escalable y que la experiencia de usuario se mantenga intuitiva a medida que se añadan nuevas características.
