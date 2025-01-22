# Mantém as classes usadas pelo Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Mantém as classes do Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Mantém classes de debug
-dontwarn