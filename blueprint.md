# Blueprint de la Aplicación de Salud y Bienestar

## Descripción General

Esta es una aplicación de Flutter diseñada para el seguimiento de la salud y el bienestar. Permite a los usuarios registrar y visualizar su consumo de agua y alimentos, así como sus medidas corporales. La app cuenta con un diseño moderno, temas claro y oscuro, y una navegación intuitiva.

## Estilo y Diseño

- **Tema:** Material 3, con un esquema de color dinámico basado en un color semilla (`seedColor`).
- **Tipografía:** Se utiliza el paquete `google_fonts` para una apariencia visual consistente y moderna.
- **Componentes:**
  - **`AppBar` principal:** Muestra el título de la pantalla actual y un menú de opciones.
  - **`BottomNavigationBar`:** Permite la navegación entre las secciones principales: "Registros", "Favoritos" y "Ejercicios".
  - **`TabBar` secundaria:** Utilizada en las secciones de "Registros" y "Favoritos" para navegar entre vistas como "Hoy" e "Historial", o "De la Web" y "Creadas". Estas barras de pestañas tienen un fondo de color distintivo e iconos para mejorar la usabilidad.

## Características Implementadas

- **Tema Dinámico:**
  - El tema de la aplicación (claro/oscuro) se gestiona con el paquete `provider`.
  - El color principal de la app se puede cambiar dinámicamente, y todos los componentes se adaptan a él.

- **Navegación Principal (BottomNavigationBar):**
  - **Registros:** Pantalla principal para el seguimiento de agua, comida y medidas.
  - **Favoritos:** Sección para gestionar rutinas o alimentos preferidos.
  - **Ejercicios:** Espacio dedicado al registro de actividad física.

- **Sección de Registros (`LogsScreen`):
  - Contiene una `TabBar` para navegar entre las sub-secciones: "Agua", "Comida" y "Medidas".
  - Cada sub-sección tiene su propia `TabBar` interna para ver los datos de "Hoy" y el "Historial", con iconos y un fondo de color para una mejor experiencia de usuario.

- **Sección de Favoritos (`FavoritesScreen`):
  - Similar a la sección de registros, utiliza una `TabBar` con iconos y fondo de color para diferenciar entre rutinas "De la Web" y "Creadas".

- **Sección de Ejercicios (`WorkoutsScreen`):
  - Pantalla dedicada a las rutinas de ejercicio, con una `TabBar` para cambiar entre "De la Web" y "Creadas".

## Plan Actual (Última Petición)

**Petición del Usuario:** "Como pusiste la barra en favorito hazlo en agua, comida, medidas... eso y los iconos con texto"

**Plan de Ejecución:**

1.  **Analizar la petición:** El usuario quiere que las `TabBar` de las secciones "Agua", "Comida" y "Medidas" tengan el mismo estilo que la de "Favoritos", lo que implica añadir un fondo de color e iconos a las pestañas "Hoy" e "Historial".

2.  **Modificar `water_log_screen.dart`:**
    - Envolver la `TabBar` en un `Container` para aplicarle un color de fondo (`seedColor` con opacidad).
    - Añadir un `Icon` a cada `Tab` (`Icons.today` para "Hoy" y `Icons.history` para "Historial").

3.  **Modificar `food_log_screen.dart`:**
    - Replicar el mismo cambio: añadir un `Container` con color de fondo y los `Icon` correspondientes a la `TabBar`.

4.  **Modificar `body_measurement_screen.dart`:**
    - Aplicar la misma estructura: un `Container` para el color y los `Icon` para las pestañas.

5.  **Confirmar y Subir Cambios:**
    - Crear un commit con un mensaje descriptivo de los cambios realizados.
    - Subir el commit al repositorio remoto en GitHub.
