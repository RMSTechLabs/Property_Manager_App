// widgets/scaffold_with_nav.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';

class BottomTab extends StatelessWidget {
  final Widget child;

  const BottomTab({super.key, required this.child});

  // int _locationToTabIndex(String location) {
  //   if (location.startsWith('/settings')) return 1;
  //   if (location.startsWith('/profile')) return 2;
  //   return 0;
  // }

  int _locationToTabIndex(String location) {
  // if (location.startsWith('/settings')) return 1;
  if (location.startsWith('/profile')) return 1; // index shifted
  return 0;
}

  // void _onItemTapped(BuildContext context, int index, int currentIndex) {
  //   if (index == currentIndex) return;

  //   switch (index) {
  //     case 0:
  //       context.pushNamed('home');
  //       break;
  //     case 1:
  //       context.pushNamed('settings');
  //       break;
  //     case 2:
  //       context.pushNamed('profile');
  //       break;
  //   }
  // }

  void _onItemTapped(BuildContext context, int index, int currentIndex) {
  if (index == currentIndex) return;

  switch (index) {
    case 0:
      context.pushNamed('home');
      break;
    // case 1:
    //   context.pushNamed('settings');
    //   break;
    case 1:
      context.pushNamed('profile'); // now index 1 is profile
      break;
  }
}


  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _locationToTabIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => _onItemTapped(context, index, currentIndex),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF6366F1),
          unselectedItemColor: AppConstants.black50,
          selectedLabelStyle: GoogleFonts.lato(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.lato(fontSize: 12),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.settings_outlined),
            //   activeIcon: Icon(Icons.settings),
            //   label: 'Settings',
            // ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
