# Blueprint: Salud Activa App

## Visión General

"Salud Activa" es una aplicación de seguimiento de salud para Flutter, diseñada para ayudar a los usuarios a monitorear su ingesta de agua y alimentos, así como sus medidas corporales y rutinas de ejercicio. La aplicación cuenta con una pantalla de bienvenida, perfiles de usuario, y una pantalla principal con navegación por pestañas y un menú lateral.

## Estilo y Diseño

- **Tema:** La aplicación utiliza un sistema de temas claro/oscuro basado en `ColorScheme.fromSeed` de Material 3.
- **Tipografía:** Se usa el paquete `google_fonts` con "Montserrat" para una apariencia limpia y moderna.
- **UI:** El diseño es limpio, centrado y sigue las guías de Material Design, con botones claros, tarjetas y una navegación intuitiva.
- **Activos:** La pantalla de bienvenida muestra una imagen que se adapta al modo de tema actual.
- **Navegación por Pestañas (`TabBar`):** Para mantener la consistencia, cualquier nueva implementación de `TabBar` debe:
    1.  Estar integrada en la propiedad `bottom` de una `AppBar`.
    2.  Contener un `Icon` y un `Text` en cada `Tab`.
    3.  Gestionar su estilo de forma global en `lib/main.dart` a través del `TabBarTheme`.

## Características y Flujo de la Aplicación

- **Gestión de Tema:** Un `ThemeProvider` gestiona el estado del tema (claro, oscuro, sistema).
- **Pantalla de Bienvenida:** Ofrece "Crear Perfil" o "Continuar como Invitado".
- **Pantalla Principal (`main_screen.dart`):** Utiliza una `BottomNavigationBar` para navegar entre: **Inicio**, **Entrenamiento**, **Menús** y **Progreso**.
- **Menú Lateral (`drawer_menu.dart`):** Proporciona acceso a secciones secundarias como "Mis Recetas" y los registros de "Agua", "Comida" y "Medidas".

---

### Funcionalidad Actual: Gestión de Ejercicios (CRUD Completo)

Se ha implementado una sección completamente funcional para la gestión de ejercicios, permitiendo a los usuarios crear, ver, editar y eliminar sus propios ejercicios personalizados.

- **Integración en la Navegación Principal:**
    - Se ha añadido una nueva sección **"Entrenamiento"** a la barra de navegación inferior (`BottomNavigationBar`) en `main_screen.dart`.

- **Pantalla Principal de Entrenamiento (`training_main_screen.dart`):**
    - Actúa como el centro de la sección de entrenamiento.
    - Utiliza una `TabBar` con dos pestañas: "Ejercicios" (placeholder para futuras rutinas) y "Biblioteca".
    - Incluye un `FloatingActionButton` (+) para navegar a la pantalla de añadir ejercicio.

- **Biblioteca de Ejercicios (`exercise_library_screen.dart`):**
    - Muestra una lista de todos los ejercicios que el usuario ha guardado.
    - Cada ejercicio es una tarjeta clicable que navega a la pantalla de detalles.
    - La lista se actualiza automáticamente cuando se añade, edita o elimina un ejercicio.

- **Crear, Editar y Eliminar Ejercicios (Flujo CRUD):**
    - **`add_exercise_screen.dart`:** Un formulario para introducir los datos de un nuevo ejercicio.
    - **`edit_exercise_screen.dart`:** Un formulario pre-rellenado para modificar un ejercicio existente.
    - **`exercise_detail_screen.dart`:** Muestra la información completa de un ejercicio y contiene los botones de **Editar** y **Eliminar**. La eliminación está protegida por un diálogo de confirmación.

- **Persistencia de Datos (`exercise_service.dart`):**
    - Un `ExerciseService` centraliza la lógica de guardado y carga de datos.
    - Los ejercicios se guardan en un archivo `exercises.json` en el directorio de documentos de la aplicación, utilizando `path_provider`, asegurando la persistencia de los datos.

- **Modelo de Datos (`exercise.dart`):**
    - Se ha definido el modelo `Exercise` con todos los campos necesarios (`id`, `name`, `description`, etc.).
    - El modelo incluye los métodos `fromJson` y `toJson` para una fácil serialización, lo que es clave para el `ExerciseService`.

---

## Directrices de Diseño y Navegación Futura

Para mantener la consistencia, cualquier nueva funcionalidad que agrupe varias subsecciones seguirá el patrón de una **pantalla dedicada con `TabBar`**, cuyo acceso se integrará en el **menú lateral (`Drawer`)** o en la **barra de navegación inferior**, según su importancia y frecuencia de uso.
