import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_manager_app/src/core/constants/app_constants.dart';
import 'package:property_manager_app/src/core/localization/app_localizations.dart';
import 'package:property_manager_app/src/presentation/providers/auth_state_provider.dart';
import 'package:property_manager_app/src/presentation/providers/onboarding_provider.dart';
import 'package:property_manager_app/src/presentation/widgets/gradient_text.dart';

// class SplashScreen extends ConsumerStatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   ConsumerState<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends ConsumerState<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _scaleAnimation;
//   bool _minimumTimePassed = false;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 2000),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );

//     _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
//     );

//     _animationController.forward();

//     // ✅ Delay with safe setState
//     Future.delayed(const Duration(seconds: 10), () {
//       if (mounted) {
//         setState(() {
//           _minimumTimePassed = true;
//         });
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authState = ref.watch(authStateProvider);
//     final l10n = AppLocalizations.of(context);
//     return Scaffold(
//       backgroundColor: Theme.of(context).primaryColorLight,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             AnimatedBuilder(
//               animation: _animationController,
//               builder: (context, child) {
//                 return Transform.scale(
//                   scale: _scaleAnimation.value,
//                   child: FadeTransition(
//                     opacity: _fadeAnimation,
//                     child: Image.asset(
//                       'assets/images/splash.png', // ✅ Make sure the path is correct
//                       width: 150, // or your preferred size
//                       height: 150,
//                       fit: BoxFit.contain,
//                     ),
//                   ),
//                 );
//               },
//             ),
//             const SizedBox(height: 30),
//             FadeTransition(
//               opacity: _fadeAnimation,
//               child: GradientText(
//                 text: l10n!.appTitle.toUpperCase(),
//                 style: Theme.of(context).textTheme.headlineMedium!.copyWith(
//                   fontSize: 32, // 👈 Set your desired size here
//                   fontWeight: FontWeight.w800,
//                 ),
//                 gradient: AppConstants.primaryGradient,
//                 textAlign: TextAlign.center,
//                 isAnimated: true,
//               ),
//             ),
//             const SizedBox(height: 50),
//             if (authState.isLoading || !_minimumTimePassed) ...[
//               const SizedBox(
//                 width: 30,
//                 height: 30,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 3,
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 authState.isInitialized
//                     ? 'Signing you in...'
//                     : 'Initializing...',
//                 style: const TextStyle(color: Colors.white70, fontSize: 16),
//               ),
//             ],
//             if (authState.error != null) ...[
//               const Icon(Icons.error_outline, color: Colors.white70, size: 30),
//               const SizedBox(height: 16),
//               Text(
//                 'Initialization failed',
//                 style: const TextStyle(color: Colors.white70, fontSize: 16),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }



class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingReady = ref.watch(onboardingProvider);
    final authState = ref.watch(authStateProvider);

    // Optional: show loader only until both are ready
    final isReady = onboardingReady && authState.isInitialized;

    return Scaffold(
      body: Center(
        child: isReady
            ? const Text('Redirecting...') // This won’t show long due to GoRouter redirect
            : const CircularProgressIndicator(),
      ),
    );
  }
}
