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

## Plan de Implementación Actual: Reorganización de la Navegación y Menús

### 1. Requisito del Usuario

El usuario solicitó los siguientes cambios:
- Modificar la barra de navegación inferior para que contenga "Inicio", "Menús" y "Progreso".
- Mover la funcionalidad de registro (Agua, Comida, Medidas) fuera de la barra de navegación principal y ubicarla en una sección accesible desde un menú lateral o una acción en la pantalla principal.
- Crear una nueva sección "Menús" que será desarrollada en el futuro.

### 2. Solución Implementada

- **Acción de Navegación:**
    - Se actualizó la barra de navegación en `main_screen.dart` para mostrar las pestañas "Inicio", "Menús" y "Progreso".
    - Se creó una nueva pantalla `MenusScreen` como un placeholder para el futuro contenido de esta sección.
    - Se creó una pantalla `LogsScreen` dedicada para alojar la `TabBar` con los registros de "Agua", "Comida" y "Medidas".
    - Se modificó el menú lateral (`drawer_menu.dart`) para que las opciones de registro ahora naveguen a la `LogsScreen`, pasando el índice de la pestaña correspondiente.

- **Resultado:** La aplicación ahora tiene una estructura de navegación que separa claramente la sección "Menús" de la sección "Registros", mejorando la organización del código y la experiencia del usuario. El `blueprint.md` se ha actualizado para reflejar estos cambios.

## Plan para la Sección de Medidas

### 1. Requisito del Usuario

Definir y construir la funcionalidad de la pantalla "Medidas", permitiendo al usuario registrar y visualizar sus medidas corporales. Las medidas a registrar son:
- Peso (kg)
- Pecho (cm)
- Brazo (cm)
- Cintura (cm)
- Caderas (cm)
- Muslo (cm)

### 2. Plan de Implementación

- **Formulario de Entrada:**
    - Se añadirá un `FloatingActionButton` a la pantalla `BodyMeasurementScreen`.
    - Al tocarlo, se mostrará un `BottomSheet` con un formulario para introducir las seis medidas corporales.
    - El formulario usará campos de texto numéricos con validación.
- **Visualización de Datos:**
    - La pestaña "Hoy" mostrará la medición más reciente del día actual.
    - La pestaña "Historial" mostrará una lista de todas las mediciones anteriores, ordenadas por fecha.
- **Almacenamiento:**
    - Las mediciones se guardarán en la caja de Hive `body_measurements` utilizando el modelo `BodyMeasurement`.
