# Blueprint de la Aplicación de Fitness

## Plan de Cambios Actuales: Coherencia en el Registro de Peso

**Objetivo:** Eliminar la inconsistencia en el registro de peso entre la planificación de una rutina y la ejecución de un entrenamiento. El peso objetivo definido en la rutina se usará como valor predeterminado durante el entrenamiento.

**Pasos Planificados:**

1.  **Actualizar el Modelo `RoutineExercise`:**
    *   Añadir un campo `weight` de tipo `double` para almacenar el peso objetivo para cada ejercicio dentro de una rutina.

2.  **Modificar la UI de Creación/Edición de Rutinas:**
    *   En el diálogo donde se definen las series, repeticiones y descanso, añadir un campo de texto para que el usuario pueda introducir el peso objetivo.

3.  **Pre-rellenar el Peso en la Pantalla de Entrenamiento:**
    *   Modificar el diálogo de registro de series (`_showLogSetDialog` en `workout_screen.dart`) para que el campo de peso se inicialice con el valor guardado en la rutina.
    *   El usuario podrá mantener ese peso o modificarlo si levanta una cantidad diferente.

---

## Descripción General

Esta es una aplicación de fitness desarrollada en Flutter, diseñada para ayudar a los usuarios a crear, seguir y gestionar sus rutinas de entrenamiento. La aplicación permite a los usuarios construir una biblioteca personal de ejercicios, agruparlos en rutinas personalizadas y registrar su progreso.

## Características Implementadas

- **Gestión de Ejercicios:**
  - Biblioteca de ejercicios con búsqueda y filtrado.
  - Creación, edición y eliminación de ejercicios.
- **Gestión de Rutinas:**
  - Creación y edición de rutinas personalizadas.
- **Seguimiento de Entrenamientos:**
  - Inicio de entrenamientos basados en rutinas.
  - Historial de entrenamientos con borrado, deshacer y filtro por fecha.

## Plan de Cambios Anteriores

- **Funcionalidades Avanzadas para el Historial:** Se implementó el borrado de sesiones con gesto de deslizar, la opción de "Deshacer" y el filtrado por fecha.
- **Mejora Visual del Historial:** Se rediseñó la pantalla del historial con tarjetas de resumen y un estado vacío mejorado.
- **Corrección de UI en Biblioteca:** Se solucionó un error de botones flotantes duplicados y se mejoró la coherencia de la interfaz.
