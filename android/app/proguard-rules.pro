## Flutter specific
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

## Supabase / GoTrue
-keep class io.supabase.** { *; }
-dontwarn io.supabase.**

## Google Play Core (deferred components)
-dontwarn com.google.android.play.core.**
