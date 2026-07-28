import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trivialy/features/quiz/services/weekly_challenge_service.dart';

// This is a widget that displays the weekly leaderboard banner and shows the user's rank.
class GoldLeagueBanner extends StatefulWidget{
  const GoldLeagueBanner({super.key});

  @override
  State<GoldLeagueBanner> createState() => _GoldLeagueBannerState();
}

class _GoldLeagueBannerState extends State<GoldLeagueBanner> {
  final WeeklyChallengeService _service = WeeklyChallengeService();
  bool _isLoading = true;
  int? _rank;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _isLoading = false);
      return;
    }

    final String weekId = _service.currentWeekId;
    final snapshot = await FirebaseFirestore.instance
      .collection('weekly_leaderboard')
      .doc(weekId)
      .collection('entries')
      .orderBy('score', descending: true)
      .get();

    int? rank;
    for (int i= 0; i < snapshot.docs.length; i++) {
      if (snapshot.docs[i].id == uid) {
        rank = i + 1;
        break;
      }
    }

    if (mounted) {
      setState(() {
        _rank = rank;
        _isLoading = false;
      });
    }
  }

  int _daysUntilReset() {
    final DateTime nowUtc = DateTime.now().toUtc();
    final int daysUntil = (DateTime.monday - nowUtc.weekday + 7) % 7;
    return daysUntil == 0 ? 7 : daysUntil;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    double dynamicMargin = (screenWidth * 0.04).clamp(16.0, 24.0);
    double dynamicPadding = (screenWidth * 0.05).clamp(16.0, 24.0);
    double trophySize = (screenWidth * 0.1).clamp(32.0, 44.0);
    double titleSize = (screenWidth * 0.045).clamp(16.0, 19.0);
    double subtitleSize = (screenWidth * 0.033).clamp(12.0, 14.0);

    final int daysLeft = _daysUntilReset();
    final String subtitle = _isLoading
      ? 'Loading...'
      : _rank != null
        ? 'Rank #$_rank • ${daysLeft == 1 ? '1 day' : '$daysLeft days'} left'
        : 'Not ranked yet • ${daysLeft == 1 ? '1 day' : '$daysLeft days'} left';

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
                'Weekly Leaderboard', 
                style: TextStyle(
                  color: Colors.white,
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold
                )
              ),
              Text(
                subtitle,
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
