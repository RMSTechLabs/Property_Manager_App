// lib/main.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'src/app.dart';
import 'src/core/utils/app_lifecycle_handler.dart';
import 'src/core/utils/background_task_handler.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize error handling
  await _initializeErrorHandling();

  // Load environment variables
  await _loadEnvironment();

  // Set system UI preferences
  await _configureSystemUI();

  // Run the app with proper error boundary
  runApp(ProviderScope(child: const PropertyManagerApp()));
}

/// Initialize global error handling
Future<void> _initializeErrorHandling() async {
  // Handle Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    _logError('Flutter Error', details.exception, details.stack);
  };

  // Handle errors outside of Flutter framework
  PlatformDispatcher.instance.onError = (error, stack) {
    _logError('Platform Error', error, stack);
    return true;
  };
}

/// Load environment configuration
Future<void> _loadEnvironment() async {
  try {
    await dotenv.load(fileName: ".env");
    print('✅ Environment variables loaded successfully');
  } catch (e) {
    print('⚠️ Failed to load .env file: $e');
    print('📝 Using default configuration values');
  }
}

/// Configure system UI appearance
Future<void> _configureSystemUI() async {
  // Set preferred screen orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configure system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
}

/// Log errors with proper formatting
void _logError(String type, Object error, StackTrace? stackTrace) {
  print('🚨 $type: $error');
  if (stackTrace != null) {
    print('📍 Stack Trace: $stackTrace');
  }

  // In production, you would send this to crash reporting service
  // Example: FirebaseCrashlytics.instance.recordError(error, stackTrace);
}

/// Main App Widget with Enhanced Initialization
class PropertyManagerApp extends ConsumerStatefulWidget {
  const PropertyManagerApp({super.key});

  @override
  ConsumerState<PropertyManagerApp> createState() => _PropertyManagerAppState();
}

class _PropertyManagerAppState extends ConsumerState<PropertyManagerApp>
    with WidgetsBindingObserver {
  late AppLifecycleHandler _lifecycleHandler;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// Initialize app-specific configurations
  Future<void> _initializeApp() async {
    try {
      // Initialize lifecycle handler
      _lifecycleHandler = ref.read(appLifecycleProvider);
      WidgetsBinding.instance.addObserver(_lifecycleHandler);
      WidgetsBinding.instance.addObserver(this);

      // Initialize background task handler
      BackgroundTaskHandler.initialize(ref);

      // Mark as initialized
      setState(() {
        _isInitialized = true;
      });

      print('✅ App initialization completed successfully');
    } catch (e, stackTrace) {
      _logError('App Initialization Error', e, stackTrace);

      // Still mark as initialized to prevent infinite loading
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    // Clean up observers and handlers
    WidgetsBinding.instance.removeObserver(_lifecycleHandler);
    WidgetsBinding.instance.removeObserver(this);
    BackgroundTaskHandler.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        print('📱 App resumed');
        break;
      case AppLifecycleState.paused:
        print('📱 App paused');
        break;
      case AppLifecycleState.detached:
        print('📱 App detached');
        break;
      case AppLifecycleState.inactive:
        print('📱 App inactive');
        break;
      case AppLifecycleState.hidden:
        print('📱 App hidden');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while initializing
    if (!_isInitialized) {
      return MaterialApp(
        title: 'Property Manager',
        debugShowCheckedModeBanner: false,
        home: const InitializationScreen(),
      );
    }

    // Return main app
    return const App();
  }
}

/// Initialization Loading Screen
class InitializationScreen extends StatefulWidget {
  const InitializationScreen({super.key});

  @override
  State<InitializationScreen> createState() => _InitializationScreenState();
}

class _InitializationScreenState extends State<InitializationScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.home_work,
                        size: 64,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            FadeTransition(
              opacity: _fadeAnimation,
              child: const Text(
                'Property Manager',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            FadeTransition(
              opacity: _fadeAnimation,
              child: const Text(
                'Initializing...',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color.fromRGBO(255, 255, 255, 0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
