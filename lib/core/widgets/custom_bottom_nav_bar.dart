import 'package:flutter/material.dart';

// This is the custom navigation bar that allows users to navigate between the different app screens
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap
    });

  @override
  // This handles the build for both big and small screen size.
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    double iconSize = (screenWidth * 0.065).clamp(22.0, 28.0);
    double labelSize = (screenWidth * 0.028).clamp(11.0, 13.0);
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      // This part lets users know which screen they tap and are currently on...cos the colours will be different.
      selectedItemColor: const Color(0xFF2563EB),
      unselectedItemColor: Colors.grey.withValues(alpha: 0.6),
      currentIndex: 0,
      onTap: onTap,
      iconSize: iconSize,
      selectedLabelStyle: TextStyle(
        fontSize: labelSize,
        fontWeight: FontWeight.w700,
        ),
      unselectedLabelStyle: TextStyle(
        fontSize: labelSize,
        fontWeight: FontWeight.w600,
      ),
      items: [
        // This part holds the icons and the labels for the bottom nav bar.
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.emoji_events_rounded), label: 'Ranks'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Profile')
      ],
    );
  }
}