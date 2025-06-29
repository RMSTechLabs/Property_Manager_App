// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ✅ Exposes if onboarding is complete
final onboardingProvider = StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  final notifier = OnboardingNotifier(ref);
  notifier.loadStatus(); // Load onboarding status at app start
  return notifier;
});

// ✅ Used by router to know if onboarding status is ready
final onboardingReadyProvider = StateProvider<bool>((ref) => false);

class OnboardingNotifier extends StateNotifier<bool> {
  final Ref _ref;

  OnboardingNotifier(this._ref) : super(false);

  Future<void> loadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('onboarding_complete') ?? false;

    // ✅ Let router know onboarding check is complete
    Future.microtask(() {
      _ref.read(onboardingReadyProvider.notifier).state = true;
    });
  }

  Future<void> complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    state = true;
  }
}


// final onboardingProvider = StateNotifierProvider<OnboardingNotifier, bool>((
//   ref,
// ) {
//   final notifier = OnboardingNotifier();
//   notifier.loadStatus(); // ✅ triggers status load
//   return notifier;
// });

// final onboardingReadyProvider = Provider<bool>((ref) {

//   return ref.read(onboardingProvider.notifier).isInitialized;
// });

// class OnboardingNotifier extends StateNotifier<bool> {
//   bool _isInitialized = false;

//   bool get isInitialized => _isInitialized;

//   OnboardingNotifier() : super(false);

//   Future<void> loadStatus() async {
//     final prefs = await SharedPreferences.getInstance();
//     state = prefs.getBool('onboarding_complete') ?? false;
//     _isInitialized = true;
//   }

//   Future<void> complete() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('onboarding_complete', true);
//     state = true;
//   }
// }
