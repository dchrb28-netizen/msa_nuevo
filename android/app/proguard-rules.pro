# Reglas ProGuard para MiSaludActiva
# Mantener clases de Flutter
-keep class io.flutter.** { *; }
-keep class androidx.lifecycle.** { *; }
-dontwarn io.flutter.**

# Mantener clases de plugins de Flutter
-keep class io.flutter.plugins.** { *; }

# Mantener anotaciones
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Mantener números de línea para stack traces
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
