# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Flutter Local Notifications
-keep class com.dexterous.** { *; }

# Image Compress
-keep class com.fluttercandies.flutter_image_compress.** { *; }

# General Flutter rules
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Google Play Core - Fix for missing classes
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

# Keep all classes that extend SplitCompatApplication
-keep class * extends com.google.android.play.core.splitcompat.SplitCompatApplication { *; }

# Additional rules for R8
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# Keep Flutter embedding classes
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }