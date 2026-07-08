import 'package:flutter/material.dart';
class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    double iconSize = (screenWidth * 0.065).clamp(22.0, 28.0);
    double labelSize = (screenWidth * 0.028).clamp(11.0, 13.0);
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF2563EB),
      unselectedItemColor: Colors.grey.withValues(alpha: 0.6),
      currentIndex: 0,
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
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.track_changes_outlined), label: 'Play'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Profile')
      ],
    );
  }
}