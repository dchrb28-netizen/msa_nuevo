# Blueprint de la Aplicación de Salud y Bienestar

## Descripción General

Esta es una aplicación de Flutter diseñada para el seguimiento de la salud y el bienestar. Permite a los usuarios registrar y visualizar su consumo de agua y alimentos, así como sus medidas corporales y progreso en ayuno intermitente. La app cuenta con un diseño moderno, temas claro y oscuro, y una navegación intuitiva.

## Estilo y Diseño

- **Tema:** Material 3, con un esquema de color dinámico basado en un color semilla (`seedColor`).
- **Tipografía:** Se utiliza el paquete `google_fonts` para una apariencia visual consistente y moderna.
- **Componentes:**
  - **`AppBar` principal:** Muestra el título de la pantalla actual y un menú de opciones.
  - **`BottomNavigationBar`:** Permite la navegación entre las secciones principales: "Registros", "Favoritos" y "Ejercicios".
  - **`TabBar` secundaria:** Utilizada en las secciones de "Registros" y "Favoritos" para navegar entre vistas. Estas barras de pestañas tienen un fondo de color distintivo e iconos para mejorar la usabilidad.

## Características Implementadas

- **Tema Dinámico:**
  - El tema de la aplicación (claro/oscuro) se gestiona con el paquete `provider`.
  - El color principal de la app se puede cambiar dinámicamente.

- **Navegación Principal (BottomNavigationBar):**
  - **Registros:** Pantalla principal para el seguimiento de agua, comida y medidas.
  - **Favoritos:** Sección para gestionar rutinas o alimentos preferidos.
  - **Ejercicios:** Espacio dedicado al registro de actividad física.
  - **Hábitos:** Nueva sección que incluye el seguimiento de "Ayuno Intermitente".

- **Sección de Registros (`LogsScreen`):**
  - Contiene una `TabBar` para navegar entre "Agua", "Comida" y "Medidas".
  - Cada sub-sección tiene su propia `TabBar` para "Hoy" e "Historial".

- **Seguimiento de Ayuno Intermitente:**
  - **Modelo de Datos:** `FastingLog` para almacenar el inicio y fin de cada ayuno en Hive.
  - **Gestor de Estado:** `FastingProvider` para manejar la lógica del temporizador y el estado del ayuno (activo/inactivo).
  - **Interfaz de Usuario:** Una pantalla dedicada (`IntermittentFastingScreen`) con:
    - Un panel de control con un temporizador y botones para iniciar/detener el ayuno.
    - Una lista informativa de las fases del ayuno.
    - Una sección para el historial de ayunos.
  - **Persistencia:** La app recuerda el estado del ayuno incluso después de cerrarla y volverla a abrir.

## Plan Actual (Última Petición)

**Petición del Usuario:** "vamos a trabajar en ayuno intermitente, solo hay que actualizar el archivo existente, ya esta en la barra lateral en habitos y ya tiene una barra superior junto a recordatorios, quiero que me des sugerencias de como trabajaremos alli y que tambien muestre las fases del ayuno, como por ejemplo en las primeras 4 horas sucede esto, no se que pero seguramente tu si sabes"

**Plan de Ejecución:**

1.  **Proponer Diseño:** Sugerir una estructura para la pantalla de ayuno intermitente, incluyendo un panel de control con temporizador, una sección para las fases del ayuno y un historial.
2.  **Crear Modelo de Datos (`FastingLog`):**
    - Definir la clase `FastingLog` con `startTime`, `endTime` y un `typeId` de Hive.
    - Añadir el `part 'fasting_log.g.dart';`.
3.  **Registrar Modelo en `main.dart`:**
    - Importar `FastingLog`.
    - Registrar el `FastingLogAdapter`.
    - Abrir la caja `fasting_logs`.
4.  **Generar Adaptador de Hive:**
    - Ejecutar `dart run build_runner build --delete-conflicting-outputs` para crear `fasting_log.g.dart`.
5.  **Construir Interfaz Inicial:**
    - Crear la estructura visual de `IntermittentFastingScreen` con placeholders para el temporizador, las fases y el historial.
6.  **Crear `FastingProvider`:**
    - Implementar la lógica para iniciar, detener y cargar el estado del ayuno.
    - Añadir un `Timer` para actualizar la duración cada segundo.
    - Crear un getter `formattedDuration` para mostrar el tiempo en formato `HH:MM:SS`.
7.  **Integrar Provider con la UI:**
    - Añadir `FastingProvider` al `MultiProvider` en `main.dart`.
    - Usar un `Consumer<FastingProvider>` en `IntermittentFastingScreen` para conectar la UI a los datos y acciones del proveedor.
    - Vincular los botones "Empezar" y "Parar" a los métodos `startFasting()` y `stopFasting()`.
    - Mostrar la duración del ayuno usando `formattedDuration`.
8.  **Actualizar Documentación:** Modificar el `blueprint.md` para reflejar los cambios y el nuevo plan.
