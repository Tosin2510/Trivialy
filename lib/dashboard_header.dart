import 'package:flutter/material.dart';
import 'package:trivialy/header_badge.dart';
import 'package:trivialy/header_badge_icon.dart';
class DashBoardHeader extends StatelessWidget{
  const DashBoardHeader({super.key});
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    double dynamicPadding = (screenWidth * 0.04).clamp(16.0,24.0);

    return Padding(
      padding: EdgeInsets.all(dynamicPadding),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1A56DB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('T', 
               style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 20
            )
            ),
          )),
          const SizedBox(width: 12),
          Text(
            'Trivialy',
            style: TextStyle(
              fontSize: (screenWidth * 0.060).clamp(22.0, 24.0),
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          const HeaderBadge(
            icon: '🔥',
            value: '12'
          ),
          HeaderBadgeIcon(
            icon: Icons.monetization_on_rounded,
            iconColor: Colors.amber.shade700,
            value: '850',
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.notifications_none_rounded,
            color: Colors.amber,
            size: (screenWidth * 0.07).clamp(24.0, 30.0),
          )
        ]
      )
    );
  }
}