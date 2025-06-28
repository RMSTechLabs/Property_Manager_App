// lib/src/presentation/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_manager_app/src/core/localization/app_localizations.dart';
import 'package:property_manager_app/src/presentation/providers/auth_state_provider.dart';
import 'package:property_manager_app/src/presentation/widgets/gradient_button.dart';
import 'package:property_manager_app/src/presentation/widgets/gradient_text.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(authStateProvider.notifier)
          .login(_emailController.text.trim(), _passwordController.text);

      // Navigation is handled by router redirect
    }
  }

  @override
  // Widget build(BuildContext context) {
  //   final authState = ref.watch(authStateProvider);
  //   final l10n = AppLocalizations.of(context);
  //   ref.listen<AuthState>(authStateProvider, (previous, next) {
  //     if (next.error != null) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
  //       );
  //     }
  //   });
  //   return Scaffold(
  //     // backgroundColor: Theme.of(context).primaryColorLight,
  //     body: SafeArea(
  //       child: Center(
  //         child: SingleChildScrollView(
  //           padding: const EdgeInsets.all(24.0),
  //           child: Form(
  //             key: _formKey,
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               crossAxisAlignment: CrossAxisAlignment.stretch,
  //               children: [
  //                 GradientText(
  //                   text: l10n!.signIn,
  //                   style: Theme.of(context).textTheme.headlineMedium!.copyWith(
  //                     fontSize: 30,
  //                     fontWeight: FontWeight.w800,
  //                   ),
  //                   gradient: const LinearGradient(
  //                     colors: [Color(0xFF5A5FFF), Color(0xFFB833F2)],
  //                   ),
  //                   textAlign: TextAlign.center,
  //                 ),
  //                 const SizedBox(height: 10),
  //                 Text(
  //                   "Dubai's premier property management platform. Streamline operations, enhance security, and build stronger communities.",
  //                   style: Theme.of(context).textTheme.headlineMedium!.copyWith(
  //                     fontSize: 13,
  //                     fontWeight: FontWeight.w400,
  //                     color: Colors.black,
  //                   ),
  //                   textAlign: TextAlign.center,
  //                 ),
  //                 const SizedBox(height: 48),
  //                 TextFormField(
  //                   controller: _emailController,
  //                   keyboardType: TextInputType.emailAddress,
  //                   decoration: InputDecoration(
  //                     labelText: l10n.email,
  //                     prefixIcon: const Icon(Icons.email),
  //                     border: const OutlineInputBorder(),
  //                   ),
  //                   validator: (value) {
  //                     if (value == null || value.isEmpty) {
  //                       return l10n.invalidEmail;
  //                     }
  //                     if (!value.contains('@')) {
  //                       return l10n.invalidEmail;
  //                     }
  //                     return null;
  //                   },
  //                 ),
  //                 const SizedBox(height: 16),
  //                 TextFormField(
  //                   controller: _passwordController,
  //                   obscureText: _obscurePassword,
  //                   decoration: InputDecoration(
  //                     labelText: l10n.password,
  //                     prefixIcon: const Icon(Icons.lock),
  //                     border: const OutlineInputBorder(),
  //                     suffixIcon: IconButton(
  //                       icon: Icon(
  //                         _obscurePassword
  //                             ? Icons.visibility
  //                             : Icons.visibility_off,
  //                       ),
  //                       onPressed: () {
  //                         setState(() {
  //                           _obscurePassword = !_obscurePassword;
  //                         });
  //                       },
  //                     ),
  //                   ),
  //                   validator: (value) {
  //                     if (value == null || value.isEmpty) {
  //                       return l10n.invalidPassword;
  //                     }
  //                     return null;
  //                   },
  //                 ),
  //                 const SizedBox(height: 24),
  //                 GradientButton(
  //                   onPressed: authState.isLoading
  //                       ? null
  //                       : () => _handleLogin(),
  //                   label: l10n.login,
  //                   isLoading: authState.isLoading,
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final l10n = AppLocalizations.of(context);

    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorLight,
      body: Stack(
        children: [
          // Yellow blob background
          Positioned(
            top: -20,
            left: -100,
            child: Image.asset(
              'assets/images/background/Vector1.png',
              width: 300,
              height: 300,
            ),
          ),
          Positioned(
            bottom: -70,
            right: -90,
            child: Image.asset(
              'assets/images/background/Vector2.png',
              width: 300,
              height: 300,
            ),
          ),

          // Login form on top
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GradientText(
                        text: l10n!.signIn,
                        style: Theme.of(context).textTheme.headlineMedium!
                            .copyWith(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                            ),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5A5FFF), Color(0xFFB833F2)],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Dubai's premier property management platform. Streamline operations, enhance security, and build stronger communities.",
                        style: Theme.of(context).textTheme.headlineMedium!
                            .copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Colors.white70,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      // Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: l10n.email,
                          prefixIcon: const Icon(Icons.email),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              !value.contains('@')) {
                            return l10n.invalidEmail;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: l10n.password,
                          prefixIcon: const Icon(Icons.lock),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.invalidPassword;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      GradientButton(
                        onPressed: authState.isLoading ? null : _handleLogin,
                        label: l10n.login,
                        isLoading: authState.isLoading,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
