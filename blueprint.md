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

- **Sección de Menús:**
    - **Planificador Semanal:** Vista de calendario para planificar comidas.
    - **Vista Diaria:** Resumen de las comidas del día.
    - **Edición de Comidas:** Pantalla para añadir/eliminar alimentos de una comida específica.
    - **Detalles Nutricionales:** Vista detallada de los macros y calorías de cada comida.

## Plan Actual (Última Petición)

**Petición del Usuario:** "revisa TODOS los botones de la app tomando esos de ejemplo y mejoralos todos incluyendo los de esa pantalla"

**Plan de Ejecución:**

1.  **Analizar Botones Actuales:** Realizar una revisión exhaustiva de todos los botones de la aplicación, incluyendo `ElevatedButton`, `TextButton`, `IconButton` y los botones de la barra de navegación.
2.  **Proponer Estilo Unificado:** Definir un estilo de botón moderno y consistente que se alinee con la identidad visual de la aplicación. Esto incluye:
    - **`ElevatedButton`:** Botones primarios con una sombra sutil, esquinas redondeadas y un efecto de "glow" al interactuar.
    - **`TextButton`:** Botones secundarios o de menor énfasis, con un color de texto claro y sin fondo.
    - **`IconButton`:** Iconos limpios y consistentes, con un área táctil adecuada para una buena experiencia de usuario.
3.  **Implementar Mejoras (Archivo por Archivo):**
    - **`weekly_planner_screen.dart`:**
        - Rediseñar los `IconButton` de "Ver" y "Editar" para que sean más prominentes y visualmente atractivos.
        - Mejorar el estilo del botón "Repetir Semana".
    - **`today_menu_screen.dart`:**
        - Aplicar el nuevo estilo a los botones "Editar" y "Ver".
    - **Otras pantallas:**
        - Recorrer sistemáticamente el resto de la aplicación y aplicar los nuevos estilos de botones para garantizar la coherencia.
4.  **Actualizar `blueprint.md`:** Documentar los cambios de diseño y el nuevo estilo de los botones.
5.  **Verificación Final:** Realizar una última revisión visual y de `flutter analyze` para asegurar que todo funciona como se espera.
