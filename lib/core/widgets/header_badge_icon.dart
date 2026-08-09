import 'package:flutter/material.dart';
class HeaderBadgeIcon extends StatelessWidget{
  // This widget handles the header badge icon and all...
  final IconData icon;
  final Color iconColor;
  final String value;
  const HeaderBadgeIcon({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.value,
  });
  @override
  // The build part.
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    double innerHorizontalPadding = (screenWidth * 0.025).clamp(8.0, 14.0);
    double dynamicFontSize = (screenWidth * 0.035).clamp(12.0, 14.0);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: innerHorizontalPadding, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 4,
          offset: const Offset(0,2)
        )]
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
          size: dynamicFontSize,
          color: const Color(0xFF334155),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: dynamicFontSize,
              color: const Color(0xFF334155),
            )
          )
        ]
      )
    );
  }
}