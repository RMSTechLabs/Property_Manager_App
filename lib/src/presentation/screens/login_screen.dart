// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:property_manager_app/src/core/constants/app_constants.dart';
// import 'package:property_manager_app/src/core/localization/app_localizations.dart';
// import 'package:property_manager_app/src/presentation/providers/auth_state_provider.dart';
// import 'package:property_manager_app/src/presentation/widgets/gradient_button.dart';
// import 'package:property_manager_app/src/core/utils/app_snackbar.dart';

// class LoginScreen extends ConsumerStatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   ConsumerState<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends ConsumerState<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _otpController = TextEditingController();

//   bool _obscurePassword = true;
//   Timer? _otpTimer;
//   int _otpTimeLeft = 0;

//   @override
//   void initState() {
//     super.initState();
//     // Clear any previous auth errors when screen loads
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(authStateProvider.notifier).state = ref
//           .read(authStateProvider)
//           .copyWith(error: null);
//     });
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     _otpController.dispose();
//     _otpTimer?.cancel();
//     super.dispose();
//   }

//   void _startOtpTimer() {
//     _otpTimeLeft = 300; // 5 minutes
//     _otpTimer?.cancel();
//     _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (mounted) {
//         setState(() {
//           if (_otpTimeLeft > 0) {
//             _otpTimeLeft--;
//           } else {
//             timer.cancel();
//           }
//         });
//       }
//     });
//   }

//   void _stopOtpTimer() {
//     _otpTimer?.cancel();
//     if (mounted) {
//       setState(() {
//         _otpTimeLeft = 0;
//       });
//     }
//   }

//   Future<void> _handleLogin() async {
//     if (!_formKey.currentState!.validate()) return;
//     await ref
//         .read(authStateProvider.notifier)
//         .login(_emailController.text.trim(), "1234");
//   }

//   Future<void> _handleOtpVerification() async {
//     final otp = _otpController.text.trim();
//     if (otp.length != 6) {
//       AppSnackBar.showError(
//         context: context,
//         message: 'Please enter a valid 6-digit OTP',
//       );
//       return;
//     }
//     await ref.read(authStateProvider.notifier).validateOtp(otp.toString());
//   }

//   Future<void> _handleResendOtp() async {
//     _otpController.clear();
//     await ref.read(authStateProvider.notifier).resendOtp();
//   }

//   Widget _buildLoginForm(AppLocalizations? l10n) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Email Field
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "Email Address",
//               style: TextStyle(
//                 fontSize: 14,
//                 color: AppConstants.black50,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             const SizedBox(height: 8),
//             TextFormField(
//               controller: _emailController,
//               keyboardType: TextInputType.emailAddress,
//               textInputAction: TextInputAction.next,
//               decoration: InputDecoration(
//                 hintText: "Enter your email",
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(color: AppConstants.white50),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(color: AppConstants.white50),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(
//                     color: AppConstants.purple50,
//                     width: 2,
//                   ),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 16,
//                 ),
//               ),
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter your email address';
//                 }
//                 if (!RegExp(
//                   r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
//                 ).hasMatch(value)) {
//                   return l10n?.invalidEmail ?? 'Invalid email';
//                 }
//                 return null;
//               },
//             ),
//           ],
//         ),
//         const SizedBox(height: 20),

//         // Password Field
//         // Column(
//         //   crossAxisAlignment: CrossAxisAlignment.start,
//         //   children: [
//         //     const Text(
//         //       "Password",
//         //       style: TextStyle(
//         //         fontSize: 14,
//         //         color: AppConstants.black50,
//         //         fontWeight: FontWeight.w500,
//         //       ),
//         //     ),
//         //     const SizedBox(height: 8),
//         //     TextFormField(
//         //       controller: _passwordController,
//         //       obscureText: _obscurePassword,
//         //       textInputAction: TextInputAction.done,
//         //       onFieldSubmitted: (_) => _handleLogin(),
//         //       decoration: InputDecoration(
//         //         hintText: "Enter your password",
//         //         border: OutlineInputBorder(
//         //           borderRadius: BorderRadius.circular(12),
//         //           borderSide: const BorderSide(color: AppConstants.white50),
//         //         ),
//         //         enabledBorder: OutlineInputBorder(
//         //           borderRadius: BorderRadius.circular(12),
//         //           borderSide: const BorderSide(color: AppConstants.white50),
//         //         ),
//         //         focusedBorder: OutlineInputBorder(
//         //           borderRadius: BorderRadius.circular(12),
//         //           borderSide: const BorderSide(
//         //             color: AppConstants.purple50,
//         //             width: 2,
//         //           ),
//         //         ),
//         //         contentPadding: const EdgeInsets.symmetric(
//         //           horizontal: 16,
//         //           vertical: 16,
//         //         ),
//         //         suffixIcon: IconButton(
//         //           icon: Icon(
//         //             _obscurePassword ? Icons.visibility_off : Icons.visibility,
//         //             color: AppConstants.gray,
//         //           ),
//         //           onPressed: () {
//         //             setState(() {
//         //               _obscurePassword = !_obscurePassword;
//         //             });
//         //           },
//         //         ),
//         //       ),
//         //       validator: (value) {
//         //         if (value == null || value.isEmpty) {
//         //           return 'Please enter your password';
//         //         }
//         //         if (value.length <4) {
//         //           return 'Password must be at least 4 characters';
//         //         }
//         //         return null;
//         //       },
//         //     ),
//         //   ],
//         // ),
//       ],
//     );
//   }

//   Widget _buildOtpForm() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Email Display (Read-only)
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "Email Address",
//               style: TextStyle(
//                 fontSize: 14,
//                 color: AppConstants.black50,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade100,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: AppConstants.white50),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       _emailController.text,
//                       style: const TextStyle(fontSize: 16),
//                     ),
//                   ),
//                   const Icon(Icons.lock, size: 18, color: AppConstants.gray),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 20),

//         // OTP Field
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "Verification Code",
//               style: TextStyle(
//                 fontSize: 14,
//                 color: AppConstants.black50,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             const SizedBox(height: 8),
//             TextFormField(
//               controller: _otpController,
//               keyboardType: TextInputType.number,
//               maxLength: 6,
//               autofocus: true,
//               textInputAction: TextInputAction.done,
//               onFieldSubmitted: (_) => _handleOtpVerification(),
//               decoration: InputDecoration(
//                 hintText: "Enter 6-digit OTP",
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(color: AppConstants.white50),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(color: AppConstants.white50),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(
//                     color: AppConstants.purple50,
//                     width: 2,
//                   ),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 16,
//                 ),
//                 counterText: '',
//                 suffixIcon: _otpTimeLeft > 0
//                     ? Padding(
//                         padding: const EdgeInsets.all(12),
//                         child: SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(
//                             value: _otpTimeLeft / 120,
//                             strokeWidth: 2,
//                             backgroundColor: Colors.grey.shade300,
//                             valueColor: const AlwaysStoppedAnimation<Color>(
//                               AppConstants.purple50,
//                             ),
//                           ),
//                         ),
//                       )
//                     : const Icon(Icons.timer_off, color: Colors.red),
//               ),
//               inputFormatters: [
//                 FilteringTextInputFormatter.digitsOnly,
//                 LengthLimitingTextInputFormatter(6),
//               ],
//             ),
//           ],
//         ),

//         // Timer display
//         if (_otpTimeLeft > 0)
//           Padding(
//             padding: const EdgeInsets.only(top: 8),
//             child: Text(
//               'Code expires in ${_otpTimeLeft ~/ 60}:${(_otpTimeLeft % 60).toString().padLeft(2, '0')}',
//               style: TextStyle(
//                 color: Colors.orange.shade700,
//                 fontSize: 12,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),

//         // Resend OTP option
//         if (_otpTimeLeft == 0)
//           Padding(
//             padding: const EdgeInsets.only(top: 8),
//             child: Center(
//               child: TextButton(
//                 onPressed: _handleResendOtp,
//                 child: const Text(
//                   'Resend OTP',
//                   style: TextStyle(
//                     color: AppConstants.purple50,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authState = ref.watch(authStateProvider);
//     final l10n = AppLocalizations.of(context);
//     final screenHeight = MediaQuery.of(context).size.height;

//     // Listen to auth state changes
//     ref.listen<AuthState>(authStateProvider, (previous, next) {
//       // Handle errors
//       if (next.error != null && !next.isLoading) {
//         AppSnackBar.showError(context: context, message: next.error!);
//       }

//       // Handle step transitions
//       if (previous?.step != next.step) {
//         switch (next.step) {
//           case AuthStep.otpSent:
//             _startOtpTimer();
//             AppSnackBar.showSuccess(
//               context: context,
//               message: 'OTP sent successfully to ${_emailController.text}',
//             );
//             break;
//           case AuthStep.verified:
//             _stopOtpTimer();
//             AppSnackBar.showSuccess(
//               context: context,
//               message: 'Login successful!',
//             );
//             // Delay the navigation to avoid calling context during build
//             // Future.microtask(() {
//             //   context.replace('/home');
//             // });
//             // Navigation will be handled by router
//             break;
//           default:
//             break;
//         }
//       }
//     });

//     final showOtpForm = authState.needsOtpVerification;
//     final formHeight = showOtpForm ? screenHeight * 0.45 : screenHeight * 0.55;

//     return Scaffold(
//       body: Container(
//         height: screenHeight,
//         decoration: const BoxDecoration(
//           gradient: AppConstants.secondartGradient,
//         ),
//         child: SafeArea(
//           child: Stack(
//             children: [
//               // Top content
//               Positioned(
//                 top: 0,
//                 left: 0,
//                 right: 0,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(
//                         left: 30,
//                         top: 60,
//                         bottom: 7,
//                         right: 5,
//                       ),
//                       child: Text(
//                         "PropertyManager",
//                         style: GoogleFonts.lato(
//                           textStyle: const TextStyle(
//                             fontSize: 32,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(left: 30, right: 5),
//                       child: Text(
//                         "Dubai's premier property management platform. Streamline operations, enhance security, and build stronger communities.",
//                         style: GoogleFonts.lato(
//                           textStyle: Theme.of(context).textTheme.headlineMedium!
//                               .copyWith(
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.w400,
//                                 color: Colors.white70,
//                                 letterSpacing: 0.1,
//                                 height: 1.1,
//                               ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // Bottom form container
//               Positioned(
//                 bottom: 0,
//                 left: 13,
//                 right: 13,
//                 child: Container(
//                   height: formHeight,
//                   decoration: const BoxDecoration(
//                     color: AppConstants.whiteColor,
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(30),
//                       topRight: Radius.circular(30),
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black12,
//                         blurRadius: 20,
//                         offset: Offset(0, -5),
//                       ),
//                     ],
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(24.0),
//                     child: SingleChildScrollView(
//                       child: Form(
//                         key: _formKey,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             const SizedBox(height: 16),
//                             Text(
//                               showOtpForm ? 'Verify OTP' : "Welcome Back",
//                               style: GoogleFonts.lato(
//                                 textStyle: const TextStyle(
//                                   fontSize: 28,
//                                   letterSpacing: 0.07,
//                                   fontWeight: FontWeight.bold,
//                                   color: AppConstants.black,
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               showOtpForm
//                                   ? "Please enter the OTP sent to ${_emailController.text}"
//                                   : "Enter your details below",
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 color: AppConstants.black50,
//                               ),
//                             ),
//                             const SizedBox(height: 32),

//                             // Dynamic form content
//                             if (showOtpForm)
//                               _buildOtpForm()
//                             else
//                               _buildLoginForm(l10n),

//                             const SizedBox(height: 32),

//                             // Submit button
//                             SizedBox(
//                               width: double.infinity,
//                               height: 56,
//                               child: GradientButton(
//                                 onPressed: authState.isLoading
//                                     ? null
//                                     : (showOtpForm
//                                           ? _handleOtpVerification
//                                           : _handleLogin),
//                                 label: showOtpForm
//                                     ? (authState.step == AuthStep.verifyingOtp
//                                           ? 'Verifying...'
//                                           : 'Verify OTP')
//                                     : (authState.step == AuthStep.authenticating
//                                           ? 'Signing In...'
//                                           : 'Sign In'),
//                                 isLoading: authState.isLoading,
//                               ),
//                             ),

//                             const SizedBox(height: 24),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:property_manager_app/src/core/constants/app_constants.dart';
import 'package:property_manager_app/src/core/localization/app_localizations.dart';
import 'package:property_manager_app/src/core/utils/app_snackbar.dart';
import 'package:property_manager_app/src/presentation/providers/auth_state_provider.dart';
import 'package:property_manager_app/src/presentation/widgets/gradient_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  bool _obscurePassword = true;
  Timer? _otpTimer;
  int _otpTimeLeft = 0;

  @override
  void initState() {
    super.initState();
    // Clear any previous auth errors when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authStateProvider.notifier).state = ref
          .read(authStateProvider)
          .copyWith(error: null);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    _otpTimer?.cancel();
    super.dispose();
  }

  void _startOtpTimer() {
    _otpTimeLeft = 300; // 5 minutes
    _otpTimer?.cancel();
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_otpTimeLeft > 0) {
            _otpTimeLeft--;
          } else {
            timer.cancel();
          }
        });
      }
    });
  }

  void _stopOtpTimer() {
    _otpTimer?.cancel();
    if (mounted) {
      setState(() {
        _otpTimeLeft = 0;
      });
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authStateProvider.notifier)
        .login(_emailController.text.trim(), "1234");
  }

  Future<void> _handleOtpVerification() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      AppSnackBar.showError(
        context: context,
        message: 'Please enter a valid 6-digit OTP',
      );
      return;
    }
    await ref.read(authStateProvider.notifier).validateOtp(otp.toString());
  }

  Future<void> _handleResendOtp() async {
    _otpController.clear();
    await ref.read(authStateProvider.notifier).resendOtp();
  }

  Widget _buildLoginForm(AppLocalizations? l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Email Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Email Address",
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF2D3748), // Dark slate gray
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              style: const TextStyle(
                color: Color(0xFF2D3748), // Dark slate gray
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: "Enter your email",
                hintStyle: const TextStyle(
                  color: Color(0xFF718096), // Muted gray
                  fontSize: 16,
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha:0.9), // More opaque white background
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha:0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha:0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppConstants.purple50,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: Color(0xFF718096),
                  size: 20,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email address';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return l10n?.invalidEmail ?? 'Invalid email';
                }
                return null;
              },
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Password Field (kept commented as per requirement)
        // Column(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     const Text(
        //       "Password",
        //       style: TextStyle(
        //         fontSize: 14,
        //         color: AppConstants.black50,
        //         fontWeight: FontWeight.w500,
        //       ),
        //     ),
        //     const SizedBox(height: 8),
        //     TextFormField(
        //       controller: _passwordController,
        //       obscureText: _obscurePassword,
        //       textInputAction: TextInputAction.done,
        //       onFieldSubmitted: (_) => _handleLogin(),
        //       decoration: InputDecoration(
        //         hintText: "Enter your password",
        //         border: OutlineInputBorder(
        //           borderRadius: BorderRadius.circular(12),
        //           borderSide: const BorderSide(color: AppConstants.white50),
        //         ),
        //         enabledBorder: OutlineInputBorder(
        //           borderRadius: BorderRadius.circular(12),
        //           borderSide: const BorderSide(color: AppConstants.white50),
        //         ),
        //         focusedBorder: OutlineInputBorder(
        //           borderRadius: BorderRadius.circular(12),
        //           borderSide: const BorderSide(
        //             color: AppConstants.purple50,
        //             width: 2,
        //           ),
        //         ),
        //         contentPadding: const EdgeInsets.symmetric(
        //           horizontal: 16,
        //           vertical: 16,
        //         ),
        //         suffixIcon: IconButton(
        //           icon: Icon(
        //             _obscurePassword ? Icons.visibility_off : Icons.visibility,
        //             color: AppConstants.gray,
        //           ),
        //           onPressed: () {
        //             setState(() {
        //               _obscurePassword = !_obscurePassword;
        //             });
        //           },
        //         ),
        //       ),
        //       validator: (value) {
        //         if (value == null || value.isEmpty) {
        //           return 'Please enter your password';
        //         }
        //         if (value.length <4) {
        //           return 'Password must be at least 4 characters';
        //         }
        //         return null;
        //       },
        //     ),
        //   ],
        // ),
      ],
    );
  }

  Widget _buildOtpForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Email Display (Read-only)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Email Address",
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF2D3748), // Dark slate gray
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha:0.7), // Semi-transparent white
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha:0.5)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.email_outlined,
                    color: Color(0xFF718096),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _emailController.text,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF2D3748), // Dark slate gray
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Icon(Icons.lock, size: 18, color: Color(0xFF718096)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // OTP Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Verification Code",
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF2D3748), // Dark slate gray
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleOtpVerification(),
              style: const TextStyle(
                color: Color(0xFF2D3748), // Dark slate gray
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 3.0, // Better spacing for OTP
              ),
              decoration: InputDecoration(
                hintText: "• • • • • •",
                hintStyle: const TextStyle(
                  color: Color(0xFF718096), // Muted gray
                  fontSize: 18,
                  letterSpacing: 3.0,
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha:0.9), // More opaque white background
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha:0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha:0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppConstants.purple50,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                counterText: '',
                prefixIcon: const Icon(
                  Icons.security,
                  color: Color(0xFF718096),
                  size: 20,
                ),
                suffixIcon: _otpTimeLeft > 0
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            value: _otpTimeLeft / 300,
                            strokeWidth: 2,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppConstants.purple50,
                            ),
                          ),
                        ),
                      )
                    : const Icon(Icons.timer_off, color: Colors.red),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
            ),
          ],
        ),

        // Timer display
        if (_otpTimeLeft > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(
                  Icons.timer,
                  size: 16,
                  color: Colors.orange.shade700,
                ),
                const SizedBox(width: 4),
                Text(
                  'Code expires in ${_otpTimeLeft ~/ 60}:${(_otpTimeLeft % 60).toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

        // Resend OTP option
        if (_otpTimeLeft == 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white.withValues(alpha:0.1),
                ),
                child: TextButton.icon(
                  onPressed: _handleResendOtp,
                  icon: const Icon(
                    Icons.refresh,
                    size: 16,
                    color: AppConstants.purple50,
                  ),
                  label: const Text(
                    'Resend OTP',
                    style: TextStyle(
                      color: AppConstants.purple50,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final l10n = AppLocalizations.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    // Listen to auth state changes
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      // Handle errors
      if (next.error != null && !next.isLoading) {
        AppSnackBar.showError(context: context, message: next.error!);
      }

      // Handle step transitions
      if (previous?.step != next.step) {
        switch (next.step) {
          case AuthStep.otpSent:
            _startOtpTimer();
            AppSnackBar.showSuccess(
              context: context,
              message: 'OTP sent successfully to ${_emailController.text}',
            );
            break;
          case AuthStep.verified:
            _stopOtpTimer();
            AppSnackBar.showSuccess(
              context: context,
              message: 'Login successful!',
            );
            // Delay the navigation to avoid calling context during build
            // Future.microtask(() {
            //   context.replace('/home');
            // });
            // Navigation will be handled by router
            break;
          default:
            break;
        }
      }
    });

    final showOtpForm = authState.needsOtpVerification;
    final formHeight = showOtpForm ? screenHeight * 0.45 : screenHeight * 0.55;

    return Scaffold(
      body: SizedBox(
        height: screenHeight,
        width: double.infinity,
        child: Stack(
          children: [
            // Background with gradient + image overlay
            Positioned.fill(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  // Primary gradient background
                  gradient: AppConstants.secondartGradient,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    // Image overlay with reduced opacity
                    // image: DecorationImage(
                    //   image: const AssetImage('assets/images/overlay.jpg'),
                    //   fit: BoxFit.cover,
                    //   alignment: Alignment.center,
                    //   // Image overlay with transparency
                    //   colorFilter: ColorFilter.mode(
                    //     Colors.white.withValues(alpha: 0.15), // Very low opacity for subtle overlay
                    //     BlendMode.modulate,
                    //   ),
                    //   onError: (exception, stackTrace) {
                    //     // debug//print('Image loading error: $exception');
                    //   },
                    // ),
                  ),
                  // Additional gradient overlay for depth
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.1),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Content with SafeArea
            SafeArea(
              child: Stack(
                children: [
                  // Top content
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 30,
                            top: 60,
                            bottom: 7,
                            right: 5,
                          ),
                          child: Text(
                            "PropertyManager",
                            style: GoogleFonts.lato(
                              textStyle: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    offset: Offset(2, 2),
                                    blurRadius: 6,
                                    color: Colors.black38,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 30, right: 20),
                          child: Text(
                            "Dubai's premier property management platform. Streamline operations, enhance security, and build stronger communities.",
                            style: GoogleFonts.lato(
                              textStyle: Theme.of(context).textTheme.headlineMedium!
                                  .copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white.withValues(alpha:0.9),
                                    letterSpacing: 0.1,
                                    height: 1.1,
                                    shadows: const [
                                      Shadow(
                                        offset: Offset(1, 1),
                                        blurRadius: 3,
                                        color: Colors.black26,
                                      ),
                                    ],
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom form container with glassmorphism effect
                  Positioned(
                    bottom: 0,
                    left: 13,
                    right: 13,
                    child: Container(
                      height: formHeight,
                      decoration: BoxDecoration(
                        // Glassmorphism effect
                        color: Colors.white.withValues(alpha:0.25),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha:0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha:0.1),
                            blurRadius: 25,
                            offset: const Offset(0, -8),
                          ),
                          BoxShadow(
                            color: Colors.white.withValues(alpha:0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha:0.3),
                              Colors.white.withValues(alpha:0.1),
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: SingleChildScrollView(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 16),
                                  Text(
                                    showOtpForm ? 'Verify OTP' : "Welcome Back",
                                    style: GoogleFonts.lato(
                                      textStyle: const TextStyle(
                                        fontSize: 28,
                                        letterSpacing: 0.07,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1A202C), // Very dark gray
                                        shadows: [
                                          Shadow(
                                            offset: Offset(1, 1),
                                            blurRadius: 2,
                                            color: Colors.white54,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    showOtpForm
                                        ? "Please enter the OTP sent to ${_emailController.text}"
                                        : "Enter your details below",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF4A5568), // Medium gray
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 32),

                                  // Dynamic form content
                                  if (showOtpForm)
                                    _buildOtpForm()
                                  else
                                    _buildLoginForm(l10n),

                                  const SizedBox(height: 32),

                                  // Submit button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: GradientButton(
                                      onPressed: authState.isLoading
                                          ? null
                                          : (showOtpForm
                                                ? _handleOtpVerification
                                                : _handleLogin),
                                      label: showOtpForm
                                          ? (authState.step == AuthStep.verifyingOtp
                                                ? 'Verifying...'
                                                : 'Verify OTP')
                                          : (authState.step == AuthStep.authenticating
                                                ? 'Signing In...'
                                                : 'Sign In'),
                                      isLoading: authState.isLoading,
                                    ),
                                  ),

                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}