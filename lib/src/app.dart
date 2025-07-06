// lib/src/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:property_manager_app/src/presentation/providers/notification_provider.dart';
import 'core/localization/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/utils/app_lifecycle_handler.dart';
import 'presentation/providers/locale_provider.dart';
import 'presentation/widgets/error_boundary.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  late AppLifecycleHandler _lifecycleHandler;

  @override
  void initState() {
    super.initState();
    _initializeAppComponents();
  }

  void _initializeAppComponents() {
    // Initialize lifecycle handler
    _lifecycleHandler = ref.read(appLifecycleProvider);
    WidgetsBinding.instance.addObserver(_lifecycleHandler);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleHandler);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeProvider);

    // 🔔 This will initialize notifications when the app starts
    ref.listen<NotificationState>(notificationProvider, (previous, next) {
      if (next.error != null) {
        print('❌ Notification error: ${next.error}');
      }
      if (next.fcmToken != null) {
        print('🎯 FCM Token received in app: ${next.fcmToken}');
      }
    });

    return ErrorBoundary(
      child: MaterialApp.router(
        title: 'Property Manager',
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        theme: _buildTheme(),
        builder: (context, child) {
          return MediaQuery(
            // Ensure text doesn't scale beyond reasonable limits
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(
                MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.2),
              ),
            ),
            child: child!,
          );
        },
      ),
    );
  }

  // ThemeData _buildTheme() {
  //   return ThemeData(
  //     primarySwatch: Colors.blue,
  //     useMaterial3: true,

  //     // Color scheme
  //     colorScheme: ColorScheme.fromSeed(
  //       seedColor: Colors.blue,
  //       brightness: Brightness.light,
  //     ),

  //     // App bar theme
  //     appBarTheme: const AppBarTheme(
  //       centerTitle: true,
  //       elevation: 0,
  //       scrolledUnderElevation: 1,
  //       backgroundColor: Colors.transparent,
  //       foregroundColor: Colors.black87,
  //     ),

  //     // Elevated button theme
  //     elevatedButtonTheme: ElevatedButtonThemeData(
  //       style: ElevatedButton.styleFrom(
  //         elevation: 0,
  //         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //         textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  //       ),
  //     ),

  //     // Text button theme
  //     textButtonTheme: TextButtonThemeData(
  //       style: TextButton.styleFrom(
  //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //       ),
  //     ),

  //     // Card theme
  //     cardTheme: CardThemeData(
  //       elevation: 2,
  //       shadowColor: Colors.black.withOpacity(0.1),
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //     ),

  //     // Input decoration theme
  //     inputDecorationTheme: InputDecorationTheme(
  //       border: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(8),
  //         borderSide: BorderSide(color: Colors.grey[300]!),
  //       ),
  //       enabledBorder: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(8),
  //         borderSide: BorderSide(color: Colors.grey[300]!),
  //       ),
  //       focusedBorder: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(8),
  //         borderSide: const BorderSide(color: Colors.blue, width: 2),
  //       ),
  //       errorBorder: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(8),
  //         borderSide: const BorderSide(color: Colors.red),
  //       ),
  //       focusedErrorBorder: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(8),
  //         borderSide: const BorderSide(color: Colors.red, width: 2),
  //       ),
  //       contentPadding: const EdgeInsets.symmetric(
  //         horizontal: 16,
  //         vertical: 12,
  //       ),
  //       filled: true,
  //       fillColor: Colors.grey[50],
  //     ),

  //     // List tile theme
  //     listTileTheme: const ListTileThemeData(
  //       contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.all(Radius.circular(8)),
  //       ),
  //     ),

  //     // Bottom navigation bar theme
  //     bottomNavigationBarTheme: const BottomNavigationBarThemeData(
  //       elevation: 8,
  //       type: BottomNavigationBarType.fixed,
  //       selectedItemColor: Colors.blue,
  //       unselectedItemColor: Colors.grey,
  //       showUnselectedLabels: true,
  //       selectedLabelStyle: TextStyle(
  //         fontSize: 12,
  //         fontWeight: FontWeight.w600,
  //       ),
  //       unselectedLabelStyle: TextStyle(fontSize: 12),
  //     ),

  //     // Floating action button theme
  //     floatingActionButtonTheme: const FloatingActionButtonThemeData(
  //       elevation: 4,
  //       shape: CircleBorder(),
  //     ),

  //     // Divider theme
  //     dividerTheme: DividerThemeData(
  //       color: Colors.grey[300],
  //       thickness: 1,
  //       space: 1,
  //     ),

  //     // Chip theme
  //     chipTheme: ChipThemeData(
  //       backgroundColor: Colors.grey[100],
  //       selectedColor: Colors.blue[100],
  //       disabledColor: Colors.grey[200],
  //       labelStyle: const TextStyle(fontSize: 12),
  //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //     ),

  //     // Progress indicator theme
  //     progressIndicatorTheme: const ProgressIndicatorThemeData(
  //       color: Colors.blue,
  //       linearTrackColor: Colors.grey,
  //       circularTrackColor: Colors.grey,
  //     ),

  //     // Snack bar theme
  //     snackBarTheme: SnackBarThemeData(
  //       backgroundColor: Colors.grey[800],
  //       contentTextStyle: const TextStyle(color: Colors.white),
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //       behavior: SnackBarBehavior.floating,
  //       // margin: const EdgeInsets.all(16),
  //     ),

  //     // Dialog theme
  //     dialogTheme: DialogThemeData(
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //       elevation: 8,
  //       backgroundColor: Colors.white,
  //       titleTextStyle: const TextStyle(
  //         fontSize: 20,
  //         fontWeight: FontWeight.w600,
  //         color: Colors.black87,
  //       ),
  //       contentTextStyle: const TextStyle(fontSize: 16, color: Colors.black54),
  //     ),

  //     // Typography
  //     textTheme: const TextTheme(
  //       headlineLarge: TextStyle(
  //         fontSize: 32,
  //         fontWeight: FontWeight.bold,
  //         color: Colors.black87,
  //       ),
  //       headlineMedium: TextStyle(
  //         fontSize: 28,
  //         fontWeight: FontWeight.w600,
  //         color: Colors.black87,
  //       ),
  //       headlineSmall: TextStyle(
  //         fontSize: 24,
  //         fontWeight: FontWeight.w600,
  //         color: Colors.black87,
  //       ),
  //       titleLarge: TextStyle(
  //         fontSize: 20,
  //         fontWeight: FontWeight.w600,
  //         color: Colors.black87,
  //       ),
  //       titleMedium: TextStyle(
  //         fontSize: 18,
  //         fontWeight: FontWeight.w500,
  //         color: Colors.black87,
  //       ),
  //       titleSmall: TextStyle(
  //         fontSize: 16,
  //         fontWeight: FontWeight.w500,
  //         color: Colors.black87,
  //       ),
  //       bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
  //       bodyMedium: TextStyle(fontSize: 14, color: Colors.black87),
  //       bodySmall: TextStyle(fontSize: 12, color: Colors.black54),
  //       labelLarge: TextStyle(
  //         fontSize: 14,
  //         fontWeight: FontWeight.w500,
  //         color: Colors.black87,
  //       ),
  //       labelMedium: TextStyle(
  //         fontSize: 12,
  //         fontWeight: FontWeight.w500,
  //         color: Colors.black87,
  //       ),
  //       labelSmall: TextStyle(
  //         fontSize: 10,
  //         fontWeight: FontWeight.w500,
  //         color: Colors.black54,
  //       ),
  //     ),
  //   );
  // }

  ThemeData _buildTheme() {
    const Color primaryGradientStart = Color(0xFF5A5FFF); // Blue-ish
    const Color primaryGradientEnd = Color(0xFFB833F2); // Purple-ish

    final MaterialColor customPrimarySwatch =
        MaterialColor(primaryGradientStart.value, <int, Color>{
          50: Color(0xFFE8E9FF),
          100: Color(0xFFC5C6FF),
          200: Color(0xFF9FA3FF),
          300: Color(0xFF7A80FF),
          400: primaryGradientStart,
          500: Color(0xFF484DDB),
          600: Color(0xFF3A3EC0),
          700: Color(0xFF2B2EA5),
          800: Color(0xFF1D1F8A),
          900: Color(0xFF0F0F6F),
        });

    return ThemeData(
      primarySwatch: customPrimarySwatch,
      useMaterial3: true,
      fontFamily: 'SF Pro Display', // Add to pubspec.yaml
      visualDensity: VisualDensity.adaptivePlatformDensity, //
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGradientStart,
        brightness: Brightness.light,
      ),

      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      switchTheme: SwitchThemeData(
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryGradientEnd,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryGradientStart, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),

      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryGradientStart,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
        shape: CircleBorder(),
      ),

      dividerTheme: DividerThemeData(
        color: Colors.grey[300],
        thickness: 1,
        space: 1,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: primaryGradientStart.withOpacity(0.1),
        selectedColor: primaryGradientEnd.withOpacity(0.3),
        disabledColor: Colors.grey[200],
        labelStyle: const TextStyle(fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryGradientStart,
        linearTrackColor: Colors.grey[300],
        circularTrackColor: Colors.grey[300],
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: primaryGradientEnd,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),

      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        backgroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        contentTextStyle: const TextStyle(fontSize: 16, color: Colors.black54),
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        titleSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.black87),
        bodySmall: TextStyle(fontSize: 12, color: Colors.black54),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Colors.black54,
        ),
      ),
    );
  }
}
