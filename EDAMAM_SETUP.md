# 🔑 Configuración de API Edamam

## Estado Actual
- ✅ Credenciales configuradas en el código
- ✅ ID de aplicación: `fbdcb21b`
- ✅ API Key configurada
- ❌ Error 401: No autorizado

## Solución - Activa tu API

### Paso 1: Verifica tu cuenta
1. Ve a: **https://developer.edamam.com/**
2. Inicia sesión con tu cuenta

### Paso 2: Verifica la aplicación
1. Haz clic en **"Applications"** o **"Mis Aplicaciones"**
2. Busca la aplicación con ID: **fbdcb21b**
3. Verifica que esté **ACTIVA** (no suspendida o en revisión)

### Paso 3: Verifica el plan
1. En tu aplicación, busca **"Plan"** o **"Subscription"**
2. Debe decir **"Developer (Free)"** o similar
3. Si dice **"No plan"** o **"Inactive"**:
   - Haz clic en **"Choose Plan"** o **"Select Plan"**
   - Selecciona el **plan gratuito** (Developer/Free)
   - Confirma la selección

### Paso 4: Verifica las APIs habilitadas
1. En la configuración de tu aplicación, busca **"APIs"** o **"Enabled APIs"**
2. Asegúrate que estén habilitadas:
   - ✅ **Food Database API**
   - ✅ **Nutrition Analysis API** (opcional)
   - ✅ **Recipe Search API** (opcional)

### Paso 5: Prueba desde el navegador
Abre este link en tu navegador (debería mostrar resultados JSON):
```
https://api.edamam.com/api/food-database/v2/parser?app_id=fbdcb21b&app_key=fc2b9a0cfd4e8e6a535f8c87b89760ad&ingr=apple
```

## ¿Qué verás si funciona?
Deberías ver un JSON con información de alimentos:
```json
{
  "text": "apple",
  "parsed": [...],
  "hints": [
    {
      "food": {
        "foodId": "...",
        "label": "Apple",
        "nutrients": { ... }
      }
    }
  ]
}
```

## ¿Qué hacer si sigue sin funcionar?

### Opción A: Crear nueva aplicación
1. Ve a **https://developer.edamam.com/admin/applications**
2. Haz clic en **"Create a new application"**
3. Selecciona **Food Database API**
4. Elige el plan **Developer (Free)**
5. Copia las nuevas credenciales
6. Dímelas para actualizar el código

### Opción B: Contactar soporte
Si nada funciona, contacta a Edamam:
- Email: **info@edamam.com**
- Explica que tienes error 401 aunque las credenciales son correctas

## Plan Gratuito - Límites
- **10,000 llamadas/mes** (suficiente para uso personal)
- Sin necesidad de tarjeta de crédito
- Acceso a base de datos completa de alimentos

## Mejoras en el código (ya implementadas)
✅ Botón de búsqueda visible con texto "Buscar"
✅ Mensajes de error claros que explican el problema
✅ Manejo de errores 401, 403 con instrucciones
