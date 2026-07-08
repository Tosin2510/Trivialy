import 'package:flutter/material.dart';
class PersonalBestBanner extends StatelessWidget{
  const PersonalBestBanner({super.key});
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    double dynamicMargin = (screenWidth * 0.04).clamp(16.0,24.0);
    double dynamicPadding = (screenWidth * 0.06).clamp(20.0, 28.0);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: dynamicMargin, vertical: 8.0),
      padding: EdgeInsets.all(dynamicPadding),
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PERSONAL BEST',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  fontSize: (screenWidth * 0.04).clamp(11.0, 13.0)
                ),
              ),
              const Icon(Icons.emoji_events,
                 color: Colors.amber,
                 size: 24
                 )
            ]
          ),
          const SizedBox(height: 2),
          Text(
            '850 pts',
            style: TextStyle(
              color: Colors.white,
              fontSize: (screenWidth * 0.11).clamp(28.0, 40.0),
              fontWeight: FontWeight.bold
            )
          )
        ],)
    );
  }
}