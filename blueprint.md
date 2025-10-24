# Blueprint de la Aplicación de Fitness y Salud

## Descripción General

Esta es una aplicación de Flutter diseñada para ser un asistente de fitness y salud todo en uno. Permite a los usuarios crear y seguir rutinas de entrenamiento personalizadas, registrar su progreso detalladamente y, en futuras versiones, monitorizar otros aspectos de su bienestar como la nutrición y los hábitos. La app se centra en una experiencia de usuario guiada, moderna y motivadora.

## Estilo y Diseño

- **Tema:** Material 3, con un esquema de color dinámico y soporte para modo claro y oscuro gestionado a través de `provider`.
- **Tipografía:** Uso del paquete `google_fonts` para una identidad visual consistente y legible.
- **Iconografía:** Iconos claros y funcionales para una navegación intuitiva.
- **Componentes:**
  - **`AppBar` principal:** Título de la pantalla y acciones contextuales.
  - **`BottomNavigationBar`:** Navegación principal de la aplicación. **(No modificar)**. Las secciones definidas son: "Inicio", "Menús" y "Progreso".
  - **Tarjetas (`Card`):** Usadas extensivamente para presentar información de forma limpia y organizada (rutinas, ejercicios, registros).
  - **Componentes Interactivos:** Uso de `TextFormField` para la entrada de datos, `IconButton` para acciones rápidas y `ElevatedButton` para acciones principales.

## Características Implementadas

### Módulo de Entrenamiento y Rutinas

Este es el núcleo de la aplicación. Proporciona un flujo completo desde la creación de un plan hasta la ejecución y el registro del mismo.

- **Gestión de Ejercicios (CRUD):**
  - Los usuarios pueden crear, ver, editar y eliminar ejercicios en una base de datos persistente (`Hive`).
  - Cada ejercicio tiene un nombre, descripción y un tipo asignado.

- **Gestión de Rutinas (CRUD):**
  - Los usuarios pueden crear, ver, editar y eliminar rutinas.
  - Cada rutina tiene un nombre y una descripción.

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

- **Persistencia de Datos (`Hive`):**
  - Se utiliza Hive para el almacenamiento local y eficiente de:
    - `Exercise`: La base de datos de todos los ejercicios.
    - `Routine`: Todas las rutinas creadas por el usuario.
    - `RoutineLog`: El historial de todos los entrenamientos completados.

### Módulo de Historial

- **Vista de Historial (`WorkoutLogScreen`):**
  - Muestra una lista cronológica de todos los entrenamientos guardados.
  - Cada entrada muestra el nombre de la rutina, la fecha y la duración.
- **Detalle del Entrenamiento (`WorkoutLogDetailScreen`):**
  - Al seleccionar un registro del historial, se muestra una vista detallada con:
    - Resumen (fecha, duración, notas).
    - Una tabla detallada para cada ejercicio, mostrando las repeticiones y el peso de cada serie registrada.

## Estructura del Código y Proveedores

- **`Provider` para State Management:**
  - **`ExerciseProvider`:** Gestiona el estado y las operaciones CRUD de los ejercicios.
  - **`RoutineProvider`:** Gestiona el estado y las operaciones CRUD de las rutinas y los registros de historial (`RoutineLog`).
- **Modelos de Datos:**
  - Clases bien definidas (`Exercise`, `Routine`, `RoutineExercise`, `RoutineLog`, `ExerciseLog`, `SetLog`) con adaptadores de `Hive` para la persistencia.
  - Se utiliza `json_serializable` para facilitar la conversión de objetos a JSON si fuera necesario en el futuro (e.g., para APIs o backups).

## Plan de Desarrollo Actual

**Objetivo:** Revisión y consolidación de la aplicación.

**Acciones:**
- El usuario (`revisare`) está actualmente probando la aplicación para evaluar la funcionalidad y la experiencia de usuario.
- El `blueprint.md` ha sido actualizado para reflejar el estado actual y completo del desarrollo.

**Próximos Pasos Potenciales (A discutir):**

1.  **Visualización Gráfica del Progreso:** Añadir gráficos que muestren la evolución del peso levantado o las repeticiones para ejercicios específicos a lo largo del tiempo.
2.  **Mejoras de UI/UX:** Pulir animaciones, mejorar la retroalimentación visual durante el entrenamiento o refinar el diseño de alguna pantalla.
3.  **Metas y Objetivos:** Permitir a los usuarios establecer metas (e.g., "levantar X peso en 3 meses").
4.  **Módulo de Nutrición:** Integrar el seguimiento de comidas y macronutrientes.
