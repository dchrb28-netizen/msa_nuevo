# Blueprint de la Aplicación de Fitness

## Descripción General

Esta es una aplicación de fitness desarrollada en Flutter, diseñada para ayudar a los usuarios a crear, seguir y gestionar sus rutinas de entrenamiento. La aplicación permite a los usuarios construir una biblioteca personal de ejercicios, agruparlos en rutinas personalizadas y registrar su progreso.

## Características Implementadas

- **Gestión de Ejercicios:**
  - Biblioteca de ejercicios con búsqueda y filtrado.
  - Creación, edición y eliminación de ejercicios.
  - Detalle de cada ejercicio con imagen, grupo muscular y equipamiento.

- **Gestión de Rutinas:**
  - Creación de rutinas personalizadas a partir de la biblioteca de ejercicios.
  - Edición de rutinas para añadir, eliminar o reordenar ejercicios.
  - Configuración de series, repeticiones, peso y tiempo de descanso para cada ejercicio dentro de una rutina.

- **Seguimiento de Entrenamientos:**
  - Pantalla para iniciar un entreno basado en una rutina.
  - Historial de entrenamientos completados.

- **Interfaz de Usuario (UI):**
  - Navegación basada en pestañas para separar "Rutinas" y "Biblioteca".
  - Uso de botones de acción flotantes (`FloatingActionButton`) contextuales para cada pestaña.
  - Diseño limpio basado en `Card` y `ListTile` para mostrar la información.

## Plan de Cambios Recientes

**Objetivo:** Solucionar un error visual en la pestaña "Biblioteca" donde aparecían dos botones flotantes superpuestos.

**Pasos Realizados:**

1.  **Diagnóstico:** Se identificó que la pantalla `ExerciseLibraryScreen` contenía su propio `Scaffold` y `FloatingActionButton`, lo que causaba un conflicto con la pantalla principal `TrainingScreen` que la contenía.
2.  **Corrección en `ExerciseLibraryScreen`:**
    - Se eliminó el `Scaffold` y el `FloatingActionButton` redundantes.
    - La pantalla se convirtió en un `Column` simple para actuar como el cuerpo de la pestaña, evitando conflictos estructurales.
    - Se añadió un `padding` inferior a la lista para evitar que el botón flotante principal oculte el último elemento.
3.  **Ajuste en `TrainingScreen`:**
    - Se modificó la lógica del `FloatingActionButton` para que sea contextual a la pestaña seleccionada.
    - En la pestaña "Biblioteca", ahora se muestra un `FloatingActionButton.extended` con el texto "Añadir Ejercicio", proporcionando una única y clara llamada a la acción.
    - En la pestaña "Rutinas", se configuró un botón similar para "Crear Rutina".

**Resultado:** El error de los botones duplicados ha sido resuelto, y la interfaz de usuario ahora es coherente y funcional en ambas pestañas.
