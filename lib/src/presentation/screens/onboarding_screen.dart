import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_manager_app/src/core/constants/app_constants.dart';
import 'package:property_manager_app/src/data/models/onboarding_model.dart';
import 'package:property_manager_app/src/presentation/providers/onboarding_provider.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _floatingController;
  late AnimationController _pulseController;
  late AnimationController _particleController;

  int _currentPage = 0;
  static const int _totalPages = 4;

  final List<OnboardingData> _slides = [
    OnboardingData(
      centralIcon: '🏢',
      floatingIcons: ['🇦🇪', '⭐', '🌟', '✨'],
      title: 'Welcome to\nProperty Manager UAE',
      subtitle:
          'Your all-in-one solution for modern property management in the UAE',
      isWelcome: true,
    ),
    OnboardingData(
      centralIcon: '👥',
      floatingIcons: ['🔑', '📱', '🚪', '✅'],
      title: 'Smart Visitor\nManagement',
      subtitle:
          'Pre-approve guests, track entries, and enhance security with digital visitor logs and instant notifications',
    ),
    OnboardingData(
      centralIcon: '🔧',
      floatingIcons: ['⚡', '🛠️', '📋', '⏰'],
      title: 'Effortless\nMaintenance',
      subtitle:
          'Submit requests, track progress, and communicate with technicians in real-time for faster resolutions',
    ),
    OnboardingData(
      centralIcon: '🏘️',
      floatingIcons: ['💬', '📢', '🎉', '📅'],
      title: 'Connected\nCommunity',
      subtitle:
          'Stay informed with announcements, book amenities, and connect with neighbors in your building',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _particleController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    } else {
      _handleGetStarted(context);
    }
  }

  // void _previousPage() {
  //   if (_currentPage > 0) {
  //     _pageController.previousPage(
  //       duration: const Duration(milliseconds: 600),
  //       curve: Curves.easeOutCubic,
  //     );
  //   }
  // }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
    );
  }

  void _handleGetStarted(BuildContext context) async {
    HapticFeedback.mediumImpact();
    // Wait for onboarding to complete
    await ref.read(onboardingProvider.notifier).complete();
    // Navigate to login
    if (context.mounted) {
      context.replace('/login'); // or context.replace('/login')
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isTablet = size.width > 600;
    final isSmallScreen = size.height < 700;

    // Calculate available height for content
    final availableHeight = size.height - statusBarHeight - bottomPadding;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppConstants.primaryGradient),
        child: SafeArea(
          child: Stack(
            children: [
              ..._buildBackgroundOrbs(size),
              Column(
                children: [
                  // PageView takes calculated space
                  SizedBox(
                    height: availableHeight * (isSmallScreen ? 0.70 : 0.75),
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (page) {
                        if (!mounted) return;
                        setState(() => _currentPage = page);
                        HapticFeedback.selectionClick();
                      },
                      itemCount: _totalPages,
                      itemBuilder: (context, index) {
                        return _buildOnboardingSlide(
                          _slides[index],
                          size,
                          isTablet,
                          isSmallScreen,
                        );
                      },
                    ),
                  ),
                  // Bottom section takes remaining space
                  Expanded(
                    child: _buildBottomSection(size, isTablet, isSmallScreen),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingSlide(
    OnboardingData data,
    Size size,
    bool isTablet,
    bool isSmallScreen,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.08,
        vertical: isSmallScreen ? size.height * 0.02 : size.height * 0.03,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Floating illustration - responsive sizing
          _buildFloatingIllustration(data, size, isTablet, isSmallScreen),

          SizedBox(
            height: isSmallScreen ? size.height * 0.03 : size.height * 0.05,
          ),

          // Content text
          _buildContentText(data, size, isTablet, isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildFloatingIllustration(
    OnboardingData data,
    Size size,
    bool isTablet,
    bool isSmallScreen,
  ) {
    // Responsive illustration sizing
    double illustrationSize;
    if (isTablet) {
      illustrationSize = size.width * 0.25;
    } else if (isSmallScreen) {
      illustrationSize = size.width * 0.45;
    } else {
      illustrationSize = size.width * 0.55;
    }

    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -10 * _floatingController.value),
          child: SizedBox(
            width: illustrationSize,
            height: illustrationSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Central circle
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: illustrationSize * 0.55,
                      height: illustrationSize * 0.55,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: isSmallScreen ? 40 : 60,
                            offset: const Offset(0, 15),
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.1),
                            blurRadius: 0,
                            spreadRadius: isSmallScreen ? 15 : 20,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Transform.scale(
                          scale: 1.0 + _pulseController.value * 0.1,
                          child: Text(
                            data.centralIcon,
                            style: TextStyle(
                              fontSize:
                                  illustrationSize *
                                  (isSmallScreen ? 0.18 : 0.2),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Floating elements
                ..._buildFloatingElements(
                  data,
                  illustrationSize,
                  isSmallScreen,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildFloatingElements(
    OnboardingData data,
    double size,
    bool isSmallScreen,
  ) {
    final positions = [
      Offset(size * 0.7, size * 0.2), // Top right
      Offset(size * 0.15, size * 0.65), // Bottom left
      Offset(size * 0.1, size * 0.25), // Top left
      Offset(size * 0.8, size * 0.7), // Bottom right
    ];

    // Responsive element sizes
    final elementSizes = isSmallScreen
        ? [size * 0.12, size * 0.10, size * 0.08, size * 0.09]
        : [size * 0.15, size * 0.12, size * 0.1, size * 0.11];

    return List.generate(data.floatingIcons.length, (index) {
      return AnimatedBuilder(
        animation: _floatingController,
        builder: (context, child) {
          final animationOffset =
              (index * 0.5 + _floatingController.value) *
              (isSmallScreen ? 6 : 10);
          return Positioned(
            left: positions[index].dx,
            top: positions[index].dy + animationOffset,
            child: Container(
              width: elementSizes[index],
              height: elementSizes[index],
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: isSmallScreen ? 20 : 30,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  data.floatingIcons[index],
                  style: TextStyle(fontSize: elementSizes[index] * 0.4),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildContentText(
    OnboardingData data,
    Size size,
    bool isTablet,
    bool isSmallScreen,
  ) {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _getResponsiveTitleSize(
                size,
                isTablet,
                isSmallScreen,
                data.isWelcome,
              ),
              fontWeight: data.isWelcome ? FontWeight.w700 : FontWeight.w800,
              color: Colors.white,
              height: 1.1,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(
            height: isSmallScreen ? size.height * 0.015 : size.height * 0.02,
          ),
          Container(
            constraints: BoxConstraints(
              maxWidth: isTablet ? size.width * 0.6 : size.width * 0.85,
            ),
            child: Text(
              data.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: _getResponsiveSubtitleSize(
                  size,
                  isTablet,
                  isSmallScreen,
                ),
                color: Colors.white.withOpacity(0.8),
                height: 1.4,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getResponsiveTitleSize(
    Size size,
    bool isTablet,
    bool isSmallScreen,
    bool isWelcome,
  ) {
    if (isTablet) {
      return isWelcome ? size.width * 0.06 : size.width * 0.07;
    } else if (isSmallScreen) {
      return isWelcome ? size.width * 0.06 : size.width * 0.065;
    } else {
      return isWelcome ? size.width * 0.07 : size.width * 0.08;
    }
  }

  double _getResponsiveSubtitleSize(
    Size size,
    bool isTablet,
    bool isSmallScreen,
  ) {
    if (isTablet) {
      return size.width * 0.03;
    } else if (isSmallScreen) {
      return size.width * 0.035;
    } else {
      return size.width * 0.04;
    }
  }

  Widget _buildBottomSection(Size size, bool isTablet, bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.1,
        vertical: isSmallScreen ? size.height * 0.02 : size.height * 0.03,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Swipe hint
          if (!isSmallScreen)
            Text(
              'Swipe to explore features →',
              style: TextStyle(
                fontSize: size.width * 0.03,
                color: Colors.white.withOpacity(0.6),
              ),
            ),

          // Indicator dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_totalPages, (index) {
              return GestureDetector(
                onTap: () => _goToPage(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(
                    horizontal: isSmallScreen
                        ? size.width * 0.01
                        : size.width * 0.015,
                  ),
                  width: isSmallScreen ? size.width * 0.015 : size.width * 0.02,
                  height: isSmallScreen
                      ? size.width * 0.015
                      : size.width * 0.02,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? const Color(0xFFFFD700)
                        : Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                    boxShadow: _currentPage == index
                        ? [
                            BoxShadow(
                              color: const Color(0xFFFFD700).withOpacity(0.5),
                              blurRadius: 15,
                            ),
                          ]
                        : null,
                  ),
                ),
              );
            }),
          ),

          // Next button
          GestureDetector(
            onTap: _nextPage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _getButtonSize(size, isTablet, isSmallScreen),
              height: _getButtonSize(size, isTablet, isSmallScreen),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.3),
                    blurRadius: isSmallScreen ? 25 : 35,
                    offset: const Offset(0, 12),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  _currentPage == _totalPages - 1
                      ? Icons.check
                      : Icons.arrow_forward_ios,
                  color: const Color(0xFF1a1a1a),
                  size: _getButtonIconSize(size, isTablet, isSmallScreen),
                ),
              ),
            ),
          ),
          // GestureDetector(
          //   onTap: _nextPage,
          //   child: AnimatedContainer(
          //     duration: const Duration(milliseconds: 200),
          //     // width: _getButtonSize(size, isTablet, isSmallScreen),
          //     width: _currentPage == _totalPages - 1
          //         ? _getButtonSize(size, isTablet, isSmallScreen) * 2
          //         : _getButtonSize(size, isTablet, isSmallScreen),

          //     height: _getButtonSize(size, isTablet, isSmallScreen),
          //     decoration: BoxDecoration(
          //       color: const Color(0xFFFFD700),
          //       // shape: BoxShape.circle,
          //       shape: _currentPage == _totalPages - 1
          //           ? BoxShape.rectangle
          //           : BoxShape.circle,
          //       borderRadius: _currentPage == _totalPages - 1
          //           ? BorderRadius.circular(30)
          //           : null,//
          //       boxShadow: [
          //         BoxShadow(
          //           color: const Color(0xFFFFD700).withOpacity(0.3),
          //           blurRadius: isSmallScreen ? 25 : 35,
          //           offset: const Offset(0, 12),
          //         ),
          //         BoxShadow(
          //           color: Colors.black.withOpacity(0.1),
          //           blurRadius: 15,
          //           offset: const Offset(0, 5),
          //         ),
          //       ],
          //     ),
          //     child: Center(
          //       child: _currentPage == _totalPages - 1
          //           ? Text(
          //               "Get Started",
          //               style: TextStyle(
          //                 color: const Color(0xFF1a1a1a),
          //                 fontWeight: FontWeight.bold,
          //                 fontSize:
          //                     _getButtonIconSize(
          //                       size,
          //                       isTablet,
          //                       isSmallScreen,
          //                     ) *
          //                     0.6,
          //               ),
          //             )
          //           : Icon(
          //               Icons.arrow_forward_ios,
          //               color: const Color(0xFF1a1a1a),
          //               size: _getButtonIconSize(size, isTablet, isSmallScreen),
          //             ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  double _getButtonSize(Size size, bool isTablet, bool isSmallScreen) {
    if (isTablet) {
      return size.width * 0.12;
    } else if (isSmallScreen) {
      return size.width * 0.14;
    } else {
      return size.width * 0.16;
    }
  }

  double _getButtonIconSize(Size size, bool isTablet, bool isSmallScreen) {
    if (isTablet) {
      return size.width * 0.04;
    } else if (isSmallScreen) {
      return size.width * 0.05;
    } else {
      return size.width * 0.06;
    }
  }

  List<Widget> _buildBackgroundOrbs(Size size) {
    return [
      Positioned(
        top: -size.height * 0.2,
        left: -size.width * 0.4,
        child: AnimatedBuilder(
          animation: _floatingController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                20 * _floatingController.value,
                -20 * _floatingController.value,
              ),
              child: Container(
                width: size.width * 0.8,
                height: size.width * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFff6b9d).withOpacity(0.6),
                      const Color(0xFFc471ed).withOpacity(0.6),
                      const Color(0xFF12c2e9).withOpacity(0.6),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      Positioned(
        bottom: -size.height * 0.1,
        right: -size.width * 0.25,
        child: AnimatedBuilder(
          animation: _floatingController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                -15 * _floatingController.value,
                15 * _floatingController.value,
              ),
              child: Container(
                width: size.width * 0.5,
                height: size.width * 0.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFff6b9d).withOpacity(0.4),
                      const Color(0xFFc471ed).withOpacity(0.4),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ];
  }
}
