# Blueprint de la Aplicación

## Visión General

Esta aplicación es un asistente de salud y fitness todo en uno. Permite a los usuarios realizar un seguimiento de diversos aspectos de su salud, como la dieta, el ejercicio, el sueño y la hidratación. La aplicación también proporciona planes de comidas, rutinas de ejercicio y seguimiento del progreso.

## Características

### Seguimiento de la Nutrición

*   Registro de la ingesta de alimentos
*   Base de datos de alimentos con información nutricional
*   Planes de comidas y recetas
*   Seguimiento de la ingesta de agua

### Seguimiento del Fitness

*   Registro de los entrenamientos
*   Biblioteca de ejercicios
*   Rutinas de entrenamiento personalizables
*   Registro de las series, las repeticiones y el peso

### Seguimiento de la Salud

*   Registro del sueño
*   Registro del ayuno intermitente
*   Seguimiento de las medidas corporales
*   Recordatorios de hábitos saludables

### Progreso y Motivación

*   Gráficos y estadísticas del progreso
*   Logros y rachas
*   Objetivos y recompensas

## Plan Actual

### Añadir la función de seguimiento del sueño

*   **Modelo:** Crear el modelo `sleep_log.dart` con los campos `id`, `startTime`, `endTime`, `duration` y `quality`.
*   **Interfaz de usuario:** Crear la pantalla `sleep_screen.dart` para mostrar la lista de registros de sueño y un botón para añadir un nuevo registro.
*   **Navegación:** Añadir un nuevo elemento a la barra de navegación inferior para acceder a la `SleepScreen`.
*   **Almacenamiento:** Usar Hive para almacenar los registros de sueño.
