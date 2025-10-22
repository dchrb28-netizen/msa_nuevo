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

- **Seguimiento de Ayuno Intermitente:**
  - **Modelo de Datos:** `FastingLog` para almacenar el inicio y fin de cada ayuno en Hive.
  - **Gestor de Estado:** `FastingProvider` para manejar la lógica del temporizador y el estado del ayuno (activo/inactivo).
  - **Interfaz de Usuario:** Una pantalla dedicada (`IntermittentFastingScreen`) con:
    - Un panel de control con un temporizador y botones para iniciar/detener el ayuno.
    - Una lista informativa de las fases del ayuno.
    - Una sección para el historial de ayunos.
  - **Persistencia:** La app recuerda el estado del ayuno incluso después de cerrarla y volverla a abrir.

- **Sección de Menús (Planificación):**
    - **Planificador Semanal:** Vista de calendario para planificar comidas.
    - **Vista Diaria:** Resumen de las comidas del día.
    - **Edición de Comidas:** Pantalla para añadir/eliminar alimentos de una comida específica.
    - **Detalles Nutricionales:** Vista detallada de los macros y calorías de cada comida.

- **Registro Básico de Comidas (Diario):**
    - Flujo completo para buscar un alimento de la base de datos local.
    - Diálogo para introducir cantidad y tipo de comida.
    - Guardado en la base de datos de registros (`food_logs`).
    - Visualización de la lista de comidas y total de calorías en la vista "Hoy".

## Plan de Desarrollo: Módulo de Registro de Comidas

**Objetivo Principal:** Permitir al usuario buscar, registrar y revisar las comidas que consume diariamente para llevar un control preciso de sus calorías y macronutrientes.

--- 

**Paso 1: Finalizar el Flujo Básico de Registro (¡Completado!)**

*   **Tarea:** Asegurar que un usuario pueda seleccionar un alimento de la base de datos local y registrarlo en su diario de hoy.
*   **Estado:** **¡Hecho!**

---

**Paso 2: Mejorar el Registro de "Nuevos Alimentos"**

*   **Tarea:** Enriquecer la pantalla `RegisterFoodScreen` para que los usuarios puedan añadir alimentos a la base de datos con información nutricional completa.
*   **Implementación:**
    1.  Modificar `RegisterFoodScreen` para que, además del nombre, el usuario pueda introducir:
        *   **Calorías** (por 100g).
        *   **Proteínas** (por 100g).
        *   **Carbohidratos** (por 100g).
        *   **Grasas** (por 100g).
    2.  Actualizar el modelo `Food` para incluir estos campos de macronutrientes.
    3.  Guardar el nuevo alimento con toda su información en la base de datos `foods`.
*   **Justificación:** Una base de datos más rica es fundamental para poder ofrecer un seguimiento nutricional completo más allá de las calorías.

---

**Paso 3: Visualización Avanzada en la Pantalla "Hoy"**

*   **Tarea:** Mejorar `FoodTodayView` para ofrecer una vista más organizada y detallada de la ingesta del día.
*   **Implementación:**
    1.  **Agrupar por Comida:** En lugar de una lista simple, agrupar las entradas por "Desayuno", "Almuerzo", "Cena" y "Snack", cada una con su propio subtítulo y subtotal de calorías.
    2.  **Resumen de Macronutrientes:** Mostrar un resumen total del día no solo de calorías, sino también de **Proteínas, Carbohidratos y Grasas** consumidos.
*   **Justificación:** Proporciona al usuario una visión clara y organizada de su nutrición, facilitando la toma de decisiones.

---

**Paso 4: Implementar el "Historial de Comidas"**

*   **Tarea:** Construir la pantalla `FoodHistoryScreen` para que el usuario pueda revisar su consumo en días anteriores.
*   **Implementación:**
    1.  Mostrar una vista de calendario o una lista de fechas pasadas.
    2.  Al seleccionar un día, mostrar un resumen de ese día, similar a la vista "Hoy", con el total de calorías, macros y la lista de alimentos consumidos.
*   **Justificación:** Esencial para que el usuario pueda seguir su progreso y analizar sus hábitos alimenticios a lo largo del tiempo.