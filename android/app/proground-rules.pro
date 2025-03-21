## Flutter-specific rules
#-keep class io.flutter.** { *; }
#-dontwarn io.flutter.embedding.**
#
## Keep Kotlin metadata
#-keepclassmembers class kotlin.Metadata { *; }
#
## Prevent warnings about missing annotations
#-dontwarn javax.annotation.**
#
## Example rules for libraries (modify based on your dependencies)
#-keep class com.google.gson.** { *; }
#-dontwarn com.google.gson.**
#
## Keep Retrofit classes (if used)
#-keep class retrofit2.** { *; }
#-dontwarn retrofit2.**
#
## Keep serialized classes
#-keepclassmembers class * {
#    @com.google.gson.annotations.SerializedName <fields>;
#}
#################################################################################
## 1) Google Play - SplitCompat
#################################################################################
## Tells R8/ProGuard not to fail the build when classes from these packages
## are missing, and optionally keeps them if referenced reflectively.
#-dontwarn com.google.android.play.core.splitcompat.**
#-keep class com.google.android.play.core.splitcompat.** { *; }
#
#################################################################################
## 2) Oppo / HeyTap Push
#################################################################################
#-dontwarn com.heytap.msp.push.**
#-keep class com.heytap.msp.push.** { *; }
#
#################################################################################
## 3) Huawei Push
#################################################################################
#-dontwarn com.huawei.hms.**
#-keep class com.huawei.hms.** { *; }
#
#################################################################################
## 4) Vivo Push
#################################################################################
#-dontwarn com.vivo.push.**
#-keep class com.vivo.push.** { *; }
#
#################################################################################
## 5) Xiaomi Push
#################################################################################
#-dontwarn com.xiaomi.mipush.sdk.**
#-keep class com.xiaomi.mipush.sdk.** { *; }
#
#################################################################################
## 6) Jackson Java7 Support (java.beans.*)
#################################################################################
#-dontwarn java.beans.**
#-keep class java.beans.** { *; }
#
#################################################################################
## 7) Conscrypt (OkHttp platform)
#################################################################################
#-dontwarn org.conscrypt.**
#-keep class org.conscrypt.** { *; }
#
#################################################################################
## 8) W3C DOM (org.w3c.dom.bootstrap)
#################################################################################
#-dontwarn org.w3c.dom.bootstrap.**
#-keep class org.w3c.dom.bootstrap.** { *; }
#
#################################################################################
## 9) Flutter (if not already covered by default rules)
#################################################################################
#-dontwarn io.flutter.**
#-keep class io.flutter.** { *; }
#
#################################################################################
## 10) Kotlin Metadata (usually safe to keep)
#################################################################################
#-keepclassmembers class kotlin.Metadata { *; }
#
#################################################################################
## NOTES:
##  - The '-dontwarn' directive stops R8/ProGuard from failing when classes are
##    missing in these packages.
##  - The '-keep' directive prevents R8 from removing or modifying references to
##    those classes if they're used reflectively.
##  - If you truly do NOT use any code paths referencing these classes at runtime,
##    the '-dontwarn' lines might be sufficient by themselves. In that case, you
##    could remove the corresponding '-keep' lines.
##  - Conversely, if you DO need these classes at runtime (e.g., you do use
##    multi-vendor push in production), you should add the actual dependencies
##    instead of just ignoring them.
#################################################################################
#
#-keep class * implements android.os.Parcelable {
#  public static final android.os.Parcelable$Creator *;
#}
#-keep class * implements java.io.Serializable { *; }
#-keepclassmembers class * implements java.io.Serializable {
#    static final long serialVersionUID;
#    private static final java.io.ObjectStreamField[] serialPersistentFields;
#    !static !transient <fields>;
#    private void writeObject(java.io.ObjectOutputStream);
#    private void readObject(java.io.ObjectInputStream);
#    java.lang.Object writeReplace();
#    java.lang.Object readResolve();
#}
#
#
#-keepclassmembers class * {
#    @android.webkit.JavascriptInterface <methods>;
#}
#
#-keepattributes *Annotation*
#-dontwarn com.razorpay.**
#-keep class com.razorpay.** {*;}
#
#-optimizations !method/inlining/
#-keepclasseswithmembers class * {
#  public void onPayment*(...);
#}
#
#-keep @interface proguard.annotation.Keep
#-keep @proguard.annotation.Keep class * {*;}
#-keepclasseswithmembers class * {
#    @proguard.annotation.Keep *;
#}
#-keepclassmembers class * {
#    @proguard.annotation.Keep *;
#}
#
## Razorpay Proguard Rules
#-keep class com.razorpay.** { *; }
#-dontwarn com.razorpay.**
#
#
#-keep class proguard.annotation.Keep { *; }
#-keep @proguard.annotation.Keep class * { *; }
#-keep @proguard.annotation.KeepClassMembers class * { *; }
#-keep class com.razorpay.** { *; }
#
#
#-keep class tvi.webrtc.** { *; }
#-keep class com.twilio.video.** { *; }
#-keepattributes InnerClasses
#
#
##optimmization app
##-keep class com.yourpackage.** { *; }
##-dontwarn okhttp3.**
# Flutter default ProGuard rules



-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**

# Keep Firebase classes (if you're using Firebase services)
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Keep Retrofit classes (if using Retrofit for API calls)
-keep class retrofit2.** { *; }
-dontwarn retrofit2.**

# Keep Gson classes (if using Gson for JSON parsing)
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# Keep OkHttp3 classes (if using OkHttp)
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**

# Keep Glide (if using for image loading)
-keep class com.bumptech.glide.** { *; }
-dontwarn com.bumptech.glide.**

# Keep Room Database entities (if using Room DB)
-keep class androidx.room.** { *; }
-dontwarn androidx.room.**

# Keep WorkManager classes (if using WorkManager)
-keep class androidx.work.** { *; }
-dontwarn androidx.work.**

# Prevent obfuscation of model classes (if using JSON serialization)
-keep class com.yourpackage.models.** { *; }

# Keep Java reflection classes
-keepattributes *Annotation*

# Prevent stripping classes with "keep" annotation
#-keep @androidx.annotation.Keep class * { *; }
#
## Ensure all Parcelable classes are kept
#-keep class * implements android.os.Parcelable { *; }
#
## Retain methods with @JavascriptInterface
#-keepclassmembers class * {
#    @android.webkit.JavascriptInterface <methods>;
#}

# Keep Kotlin metadata annotations (if using Kotlin)
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.Metadata

# Keep Dagger (if using dependency injection)
-keep class dagger.** { *; }
-dontwarn dagger.**

# Keep Play Services classes (if using Google APIs)
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Keep Timber (if using logging library Timber)
-keep class timber.log.** { *; }
-dontwarn timber.log.**

# Keep ExoPlayer (if using for video/audio streaming)
-keep class com.google.android.exoplayer2.** { *; }
-dontwarn com.google.android.exoplayer2.**

# Keep WebRTC (if using for video calls)
-keep class org.webrtc.** { *; }
-dontwarn org.webrtc.**

# Prevent warnings from missing classes
-dontwarn javax.annotation.**

# Optimize ProGuard rules
-optimizationpasses 5
-dontoptimize
-dontpreverify
