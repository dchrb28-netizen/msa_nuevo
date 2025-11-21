# Blueprint de la Aplicación de Fitness

## Sistema de Recompensas y Gamificación (v2)

**Objetivo:** Implementar un sistema de gamificación completo para aumentar la motivación y el compromiso del usuario, recompensando tanto las acciones diarias como los logros a largo plazo.

El sistema se basa en 3 pilares fundamentales:

1.  **Puntos de Experiencia (XP):** Otorgados por acciones pequeñas y frecuentes. Son el combustible para subir de nivel. Hay 19 acciones recurrentes que otorgan XP.
2.  **Niveles y Títulos:** Al acumular XP, el usuario sube de nivel y desbloquea 6 Títulos cosméticos para su perfil (Novato → Aprendiz → Atleta → Competidor → Titán → Leyenda).
3.  **Logros (Medallas):** Son 49 insignias únicas y coleccionables que se otorgan al alcanzar hitos importantes.

---

### Categorías de los 49 Logros Únicos

1.  **Logros de "Primera Vez" (Iniciación)**
    *   **Propósito:** Premiar al usuario por explorar y probar cada funcionalidad.
    *   **Ejemplos:**
        *   🏋️ **Primer Sudor** (Primer entrenamiento completado)
        *   🍎 **Bocado Inicial** (Primera comida registrada)
        *   ⏳ **Reloj Suizo** (Primer ayuno completado)
        *   ⚖️ **En la Balanza** (Primer registro de peso)
        *   🛠️ **Arquitecto Fitness** (Primera rutina creada)
        *   🧑‍🍳 **Chef Creativo** (Primera receta creada)

2.  **Logros de Rachas (Consistencia Diaria)**
    *   **Propósito:** Fomentar la creación de hábitos diarios.
    *   **Ejemplos:**
        *   🌊 **Río de Vida** (Racha de 7 días de hidratación)
        *   🧘 **Maestro Zen** (Racha de 7 días de ayuno)
        *   🔥 **Imparable** (Tener las 5 rachas activas a la vez)
        *   ☄️ **Llama Eterna** (Alcanzar una racha de 30 días en cualquier categoría)

3.  **Logros Acumulativos (Progreso a Largo Plazo)**
    *   **Propósito:** Mostrar el resultado del esfuerzo sostenido en el tiempo.
    *   **Ejemplos:**
        *   🏞️ **Océano Vital** (Consumir 1,000 litros de agua en total)
        *   🌋 **Fuerza Volcánica** (Levantar 50,000 kg en total en entrenamientos)
        *   📖 **Enciclopedia Gastronómica** (Registrar 500 comidas en total)
        *   🗓️ **Disciplina Mensual** (Acumular 720 horas de ayuno en total)

4.  **Logros de Hitos de Progreso (Metas Personales)**
    *   **Propósito:** Recompensar el alcance de metas personales de salud.
    *   **Ejemplos:**
        *   🎯 **Primer Kilo Menos** (Perder 1 kg de peso)
        *   🎯 **5 Kilos Abajo** (Perder 5 kg de peso)
        *   🏆 **Meta Cumplida** (Alcanzar el peso objetivo establecido)

5.  **Logros de Exploración y Personalización**
    *   **Propósito:** Premiar la curiosidad y el uso de funciones secundarias.
    *   **Ejemplos:**
        *   🎨 **Sastre Digital** (Personalizar el tema de la app)
        *   🧐 **Analista de Datos** (Usar los filtros del historial)
        *   ❓ **Curioso** (Visitar la pantalla "Acerca de")
        *   👤 **Identidad Definida** (Completar el perfil de usuario)

---
## Descripción General

Esta es una aplicación de fitness desarrollada en Flutter, diseñada para ayudar a los usuarios a crear, seguir y gestionar sus rutinas de entrenamiento. La aplicación permite a los usuarios construir una biblioteca personal de ejercicios, agruparlos en rutinas personalizadas y registrar su progreso.

## Características Implementadas

- **Navegación Unificada de Recompensas y Rachas:** Las secciones de "Logros" y "Rachas" se han unificado bajo una única pantalla con una barra de navegación inferior, mejorando la experiencia de usuario.
- **Gráficos de Progreso Avanzados:** Gráficos de línea interactivos para el seguimiento del peso y el consumo de agua, con indicadores de máximo/mínimo y líneas de objetivo.
- **Seguimiento de Progreso a Largo Plazo:** Pantalla dedicada para visualizar el progreso de peso y el resumen de actividad semanal.
- **Dashboard Diario:** Vista principal centrada en el progreso del día actual (calorías, agua, entrenamiento).
- **Plan de Entrenamiento Semanal por Día:** La aplicación incluye un plan de entrenamiento semanal precargado y asignado a días específicos.
- **Gestión de Ejercicios y Rutinas:** Biblioteca de ejercicios y creación de rutinas personalizadas.
- **Seguimiento de Entrenamientos:** Historial de entrenamientos con funcionalidades avanzadas.
- **Rachas de Hábitos:** Sistema de seguimiento de rachas para hidratación, registro de comidas, entrenamientos, calorías y ayuno intermitente.

## Plan de Cambios Anteriores

- **Refactorización y Limpieza del Código (Análisis Estático):**
  - **Objetivo:** Eliminar todas las advertencias y errores reportados por `flutter analyze` para mejorar la calidad y robustez del código.
  - Se corrigieron las advertencias `use_build_context_synchronously` capturando el `BuildContext` antes de operaciones asíncronas.
  - Se solucionó la advertencia `library_private_types_in_public_api` renombrando clases de estado privadas a públicas.
  - Se restauró la lógica del método `deleteUser` en el `UserProvider` para que acepte un `userId`, corrigiendo una regresión.
  - Se actualizó el test de widgets (`widget_test.dart`) para que limpie todos los perfiles de usuario existentes antes de ejecutarse, mejorando su fiabilidad.
  - **Resultado:** El comando `flutter analyze` ahora reporta **"No issues found!"**.

- **Reestructuración de la Navegación de Recompensas y Rachas:** Se unificaron las pantallas de "Mis Logros" y "Rachas" en una sola vista con una barra de navegación inferior.
- **Implementación de Racha de Ayuno:** Se añadió la lógica y la UI para seguir la racha de días consecutivos completando un ayuno intermitente.
- **Mejora de Gráficos de Progreso:** Se rediseñaron los gráficos de peso y agua para incluir interactividad, indicadores de máximo/mínimo y líneas de objetivo.
- **Añadir Seguimiento de Consumo de Agua:** Se añadió una tarjeta a la pantalla de progreso con un gráfico del consumo de agua semanal.
- **Implementación Inicial de Rutinas por Defecto:** Se añadió la lógica para crear un conjunto de rutinas de entrenamiento la primera vez que se inicia la aplicación.
- **Ampliación y Corrección de la Base de Datos de Ejercicios:** Se reorganizó y limpió la lista inicial de ejercicios.
- **Funcionalidades Avanzadas para el Historial:** Se implementó el borrado de sesiones, "Deshacer" y filtro por fecha.
- **Rediseño de la Interfaz Principal y Corrección de Errores:** Se separó el progreso a largo plazo del resumen diario y se corrigieron errores del analizador.
