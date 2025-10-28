# Blueprint de la Aplicación de Fitness

## Propósito y Capacidades

Esta aplicación de fitness está diseñada para ser un asistente de salud y bienestar integral. Permite a los usuarios gestionar sus rutinas de entrenamiento, registrar su ingesta de alimentos y agua, y monitorear su progreso a lo largo del tiempo.

## Restricciones de Diseño

- **Navegación Principal:** La estructura, el estilo y la funcionalidad de la `AppBar`, `BottomNavigationBar` y `Drawer` (menú lateral) se consideran **fijos**. No se realizarán cambios en estos componentes sin la solicitud y aprobación explícita del usuario.

## Estilo y Diseño

- **Tema:** Material 3, con un esquema de color dinámico y soporte para modo claro y oscuro gestionado a través de `provider`.
- **Tipografía:** Uso del paquete `google_fonts` para una identidad visual consistente y legible.
- **Iconografía:** Iconos claros y funcionales para una navegación intuitiva.
- **Componentes:**
  - **Tarjetas (`Card`):** Usadas extensivamente para presentar información de forma limpia y organizada (rutinas, ejercicios, registros).
  - **Componentes Interactivos:** Uso de `TextFormField` para la entrada de datos, `IconButton` para acciones rápidas y `ElevatedButton` para acciones principales.

## Navegación

### AppBar

- **Función:** La `AppBar` es dinámica y sensible al contexto.
- **Título:** Muestra el título de la pantalla actual, proporcionando al usuario una clara indicación de su ubicación dentro de la aplicación.
- **Menú Lateral:** En las pantallas principales, incluye un `IconButton` que abre el `Drawer` (menú lateral), permitiendo el acceso a secciones secundarias.
- **Acciones Contextuales:** Muestra botones de acción relevantes para la pantalla actual. Por ejemplo, en la pantalla de una rutina, puede mostrar un botón para "Iniciar Entrenamiento".

### BottomNavigationBar

- **Función:** Es la principal herramienta de navegación, fija en la parte inferior, que permite al usuario cambiar entre las tres secciones clave de la aplicación.
- **Estructura:**
  - **Ítem 1: Inicio (`DashboardScreen`)**
    - **Icono:** `Icons.home`
    - **Etiqueta:** "Inicio"
  - **Ítem 2: Menús (`MenusScreen`)**
    - **Icono:** `Icons.restaurant_menu`
    - **Etiqueta:** "Menús"
  - **Ítem 3: Progreso (`ProgresoScreen`)**
    - **Icono:** `Icons.show_chart`
    - **Etiqueta:** "Progreso"
- **Comportamiento:** La selección de un ítem actualiza el cuerpo de la pantalla principal (`MainScreen`) para mostrar la vista correspondiente.

### Drawer (Menú Lateral)

- **Función:** Proporciona acceso a funcionalidades y pantallas secundarias que no forman parte del flujo de navegación principal.
- **Estructura:**
  - **Encabezado (`UserAccountsDrawerHeader`):**
    - Muestra el nombre y el email del usuario.
    - Utiliza una imagen de fondo (`luna_splash_b.png` o `luna_splash_w.png` según el tema) para un diseño atractivo.
  - **Secciones (Agrupadas con `ExpansionTile`):**
    - **Hábitos:**
      - **Recordatorios:** `Icons.notifications_active`
      - **Ayuno Intermitente:** `Icons.fasting`
    - **Registros:**
      - **Historial de Agua:** `Icons.history`
      - **Historial de Comida:** `Icons.history`
      - **Medidas Corporales:** `Icons.history`
    - **Logros:**
      - **Objetivos:** `Icons.flag`
      - **Recompensas:** `Icons.emoji_events`
  - **Opciones Adicionales (`ListTile`):**
    - **Configuración:** `Icons.settings`
    - **Cerrar Sesión:** `Icons.logout`
- **Comportamiento:** Cada opción de navegación cierra el `Drawer` y lleva al usuario a la pantalla correspondiente. Las secciones agrupadas se pueden expandir o contraer para una mejor organización.

## Características Implementadas

### Módulo de Entrenamiento y Rutinas

- **Gestión de Biblioteca de Ejercicios:**
  - **Creación y Edición:** Los usuarios pueden crear sus propios ejercicios, especificando el nombre, el grupo muscular al que pertenece y una descripción.
  - **Visualización:** Se presenta una lista completa de ejercicios, filtrable y buscable, para una fácil consulta.
- **Gestión de Rutinas:**
  - **Creación y Edición:** Los usuarios pueden crear múltiples rutinas de entrenamiento.
  - **Composición de Rutinas:**
    - **Añadir Ejercicios:** Los usuarios pueden añadir ejercicios de su base de datos a cualquier rutina.
    - **Personalización de Series:** Para cada ejercicio dentro de una rutina, se puede especificar:
      - Número de **series**.
      - Número de **repeticiones** objetivo.
      - **Peso** inicial recomendado.
      - **Tiempo de descanso** en segundos después de cada serie.
    - **Reordenamiento:** Los ejercicios dentro de una rutina se pueden reordenar fácilmente mediante una interfaz de arrastrar y soltar (`ReorderableListView`).
- **Flujo de Entrenamiento Guiado (`WorkoutScreen`):**
  - **Inicio de Sesión:** El usuario selecciona una rutina para comenzar una sesión de entrenamiento.
  - **Vista por Ejercicio:** La pantalla se centra en un solo ejercicio a la vez para minimizar distracciones.
  - **Registro de Series:** El usuario puede registrar los datos reales de cada serie:
    - **Peso** levantado.
    - **Repeticiones** completadas.
  - **Marcar como Completado:** Un botón de check permite marcar cada serie como finalizada.
  - **Temporizador de Descanso Automático:** Tras completar una serie, se muestra una pantalla de descanso con una cuenta atrás visual, utilizando el tiempo definido en la rutina. El usuario puede saltar el descanso.
  - **Navegación:** Botones para moverse al ejercicio "Siguiente" o "Anterior".
  - **Finalización y Resumen:** Al completar todos los ejercicios, se muestra un resumen del entrenamiento y los datos se guardan en el historial.

### Módulo de Nutrición

- **Registro de Ingesta de Agua (`WaterIntakeScreen`):**
  - **Objetivo Diario:** El usuario puede establecer un objetivo diario de consumo de agua.
  - **Registro Rápido:** Botones para añadir cantidades predefinidas de agua (e.g., 250ml, 500ml).
  - **Visualización del Progreso:** Una animación de un acuario que se llena progresivamente con cada registro y una barra de progreso circular en el dashboard.
- **Registro de Comidas (`FoodIntakeScreen`):**
  - **Búsqueda de Alimentos:** Permite buscar en una base de datos de alimentos.
  - **Registro por Comida:** Los usuarios pueden registrar alimentos en diferentes momentos del día (Desayuno, Almuerzo, Cena, Snacks).
  - **Información Nutricional:** Muestra un resumen de las calorías y macronutrientes consumidos.

### Módulo de Seguimiento y Progreso

- **Dashboard Principal (`DashboardScreen`):**
  - **Tarjetas de Acceso Rápido:**
    - **Agua:** Muestra el progreso actual y permite añadir nuevos registros.
    - **Comida:** Muestra las calorías consumidas y permite añadir nuevos registros.
    - **Entrenamiento:** Acceso rápido para iniciar una rutina.
  - **Gráficas de Progreso:** Visualización del progreso de peso y otras métricas clave.
- **Historial Detallado:**
  - **Entrenamientos Pasados:** Lista de todos los entrenamientos completados, con detalles de cada uno.
  - **Registros de Comida y Agua:** Historial completo de la ingesta diaria.

### Gestión de Perfil y Ajustes

- **Perfil de Usuario:** Permite al usuario ver y editar su información personal (nombre, email, etc.).
- **Configuración de la Aplicación (`SettingsScreen`):**
  - **Tema:** Opción para cambiar entre modo claro, oscuro o seguir la configuración del sistema.
  - **Notificaciones:** Ajustes para activar o desactivar recordatorios.

## Estructura del Proyecto

El proyecto sigue una arquitectura limpia y organizada por capas, separando la UI, la lógica de negocio y los datos.

- **`lib/`**
  - **`main.dart`**: Punto de entrada de la aplicación, configuración de `provider` y temas.
  - **`models/`**: Clases de modelo que representan los datos de la aplicación (e.g., `Routine`, `Exercise`, `FoodLog`).
  - **`providers/`**: Gestiona el estado de la aplicación utilizando el paquete `provider` (e.g., `ThemeProvider`, `WorkoutProvider`).
  - **`screens/`**: Contiene los widgets de pantalla completa, organizados por funcionalidad (e.g., `training/`, `nutrition/`, `profile/`).
  - **`widgets/`**: Widgets reutilizables utilizados en múltiples pantallas (e.g., `DashboardCard`, `DrawerMenu`).
  - **`services/`**: Lógica de negocio y comunicación con fuentes de datos (e.g., `DatabaseService`).
  - **`data/`**: Datos estáticos o iniciales, como la lista de ejercicios precargada.
