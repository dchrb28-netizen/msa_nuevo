#!/usr/bin/env python3
from PIL import Image

# Cargar la imagen original
img = Image.open('/workspaces/msa_nuevo/android/app/src/main/res/drawable/notificacion.png')

# Convertir a RGBA si no lo es
img = img.convert('RGBA')

# Redimensionar a 48x48 (tamaño apropiado para notification icon)
img_resized = img.resize((48, 48), Image.Resampling.LANCZOS)

# Guardar el ícono redimensionado
img_resized.save('/workspaces/msa_nuevo/android/app/src/main/res/drawable/ic_notification.png', 'PNG')

print("✓ Ícono de notificación creado: ic_notification.png (48x48)")
print(f"  Tamaño del archivo: {img_resized.size}")
