import 'package:flutter/material.dart';
// This stateless widget handle the header badge in itself.
class HeaderBadge extends StatelessWidget{
  final String icon;
  final String value;
  const HeaderBadge({
    super.key,
    required this.icon,
    required this.value,
  });
  // The build part...
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    double innerHorizontalPadding = (screenWidth * 0.025).clamp(8.0, 14.0);
    double dynamicFontSize = (screenWidth * 0.035).clamp(12.0,14.0);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: innerHorizontalPadding, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 4,
          offset: const Offset(0,2)
          )],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: 
          TextStyle(
            fontSize: dynamicFontSize
            )),
            const SizedBox(
              width: 4
            ),
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold,
              fontSize: dynamicFontSize,
              color: const Color(0xFF334155),
              )
            )
        ]
      )
    );
  }
}