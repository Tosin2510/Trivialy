import 'package:flutter/material.dart';
class GoldLeagueBanner extends StatelessWidget{
  const GoldLeagueBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    double dynamicMargin = (screenWidth * 0.04).clamp(16.0, 24.0);
    double dynamicPadding = (screenWidth * 0.05).clamp(16.0, 24.0);
    double trophySize = (screenWidth * 0.1).clamp(32.0, 44.0);
    double titleSize = (screenWidth * 0.045).clamp(16.0, 19.0);
    double subtitleSize = (screenWidth * 0.033).clamp(12.0, 14.0);
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: dynamicMargin, vertical: 8.0),
      padding: EdgeInsets.all(dynamicPadding),
      decoration: BoxDecoration(
        color: const Color(0xFFB45309),
        borderRadius: BorderRadius.circular(24)
    ),
    child: Row(
      children: [
        Icon(Icons.emoji_events, color: Colors.amber, size: trophySize),
        const SizedBox(width: 16,),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gold League', style: 
                TextStyle(color: Colors.white,
                fontSize: titleSize,
                fontWeight: FontWeight.bold
                )
              ),
              Text('Rank #4 • 2 days left', 
              style: TextStyle(
                color: Colors. white.withValues(alpha: 0.8),
                fontSize: subtitleSize
              )
              )
            ],))
      ],)
    );
  }
}