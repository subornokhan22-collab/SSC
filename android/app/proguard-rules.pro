# Keep rules for the release build (isMinifyEnabled = true).
#
# R8 strips classes it cannot see being used. Anything reached only through
# reflection or JNI has to be kept explicitly, or the app compiles fine and
# then crashes at runtime.

# Flutter engine + plugin registration (JNI / reflection).
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.**

# printing / pdf — talks to the Android print framework via reflection.
-keep class net.nfet.flutter.printing.** { *; }
-dontwarn net.nfet.**

# Supabase / OkHttp / Kotlin serialisation used by supabase_flutter.
-keep class io.supabase.** { *; }
-keepclassmembers class ** {
    @kotlinx.serialization.Serializable <fields>;
}
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn kotlinx.serialization.**

# shared_preferences / androidx datastore.
-keep class androidx.startup.** { *; }
-dontwarn androidx.**

# Google ML Kit document scanner (Camera button): the plugin talks to
# Google Play services' scanner API; keep both sides intact or the
# native side NPEs at runtime.
-keep class com.google_mlkit_document_scanner.** { *; }
-keep class com.google.mlkit.vision.documentscanner.** { *; }
-keep class com.google.android.gms.vision.documentscanner.** { *; }
-keep class com.google.android.gms.common.GoogleApiAvailability { *; }
-keep class com.google.android.gms.common.internal.** { *; }
-keep class com.google.android.gms.common.moduleinstall.** { *; }
-dontwarn com.google.android.gms.**

# Keep annotations and generic signatures so reflective lookups still resolve.
-keepattributes *Annotation*, Signature, InnerClasses, EnclosingMethod

# Silence notes about missing optional desugaring targets.
-dontwarn java.lang.invoke.**
-dontwarn javax.annotation.**
