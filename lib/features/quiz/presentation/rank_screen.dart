import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trivialy/features/quiz/services/weekly_challenge_service.dart';

class Leaderboard {
  final String uid;
  final String name;
  final int score;

  Leaderboard({required this.uid, required this.name, required this.score});
}

class RankScreen extends StatefulWidget {
  const RankScreen({super.key});

  @override
  State<RankScreen> createState() => _RankScreenState();
}

class _RankScreenState extends State<RankScreen> {
  final WeeklyChallengeService _weeklyService = WeeklyChallengeService();
  bool _isLoading = true;
  String? _errorMessage;
  List<Leaderboard> _entryList = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final String weekId = _weeklyService.currentWeekId;
      final snapshot = await FirebaseFirestore.instance
        .collection('weekly_leaderboard')
        .doc(weekId)
        .collection('entries')
        .orderBy('score', descending: true)
        .limit(50)
        .get();

        final List<Leaderboard> entries = [];
        for (final doc in snapshot.docs) {
          final int score = (doc.data()['score'] as num?)?.toInt() ?? 0;
          final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(doc.id)
            .get();
          final String name = userDoc.data()?['name'] as String? ?? 'Player';
          entries.add(Leaderboard(uid: doc.id, name: name, score: score));
        }

        if (mounted) {
          setState(() {
            _entryList = entries;
            _isLoading = false;
          });
        }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Could not load the leaderboard. Please try again.';
        });
      }
    }
  }

  String _nameInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final String? myUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(
            color: Color(0xFF64748B),
          ),)
          : _errorMessage != null
           ? Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
            ),
           )
           : _entryList.isEmpty
             ? _buildEmptyState()
             : _buildLeaderBoard(screenWidth, myUid),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events_outlined, size: 56, color: Color(0xFF94A3B8),),
            const SizedBox(height: 16,),
            const Text(
              'No ranking yet this week',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              )
            ),
            const SizedBox(height: 6,),
            const Text(
              'Be the first to complete the weekly challenge!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderBoard(double screenWidth, String? myUid) {
    final List<Leaderboard> mainRank = _entryList.take(3).toList();
    final List<Leaderboard> remainingRank = _entryList.skip(3).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all((screenWidth * 0.05).clamp(16.0, 24.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Leaderboard',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.emoji_events_rounded, size: 16, color: Color(0xFFB45309),),
                    SizedBox(width: 4,),
                    Text(
                      'This week',
                      style: TextStyle(
                        color: Color(0xFFB45309),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 24,),
          if (mainRank.isNotEmpty) _buildMainRank(mainRank, myUid),
          if (_entryList.length < 3) ...[
            const SizedBox(height: 20,),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16)
              ),
              child: const Row(
                children: [
                  Icon(Icons.groups_rounded, color: Color(0xFF2563EB), size: 20,),
                  SizedBox(width: 10,),
                  Expanded(
                    child: Text(
                      'Invite friends to join and compete on the leaderboard!',
                      style: TextStyle(
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ))
                ],
              ),
            )
          ],
          const SizedBox(height: 20),
          ...List.generate(remainingRank.length, (index) {
            final entry = remainingRank[index];
            final int rank = index + 4;
            final bool isUser = entry.uid == myUid;
            return _buildRankRow(rank, entry, isUser);
          })
        ],
      ),
    );
  }

  Widget _buildRankRow(int rank, Leaderboard entry, bool isUser) {
    return Container (
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isUser ? Border.all(color: const Color(0xFF2563EB), width : 1.5) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '$rank',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
          const SizedBox(width: 8,),
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.1),
            child: Text(
              _nameInitials(entry.name),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Color(0xFF2563EB)
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUser ? 'You' : entry.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isUser ? const Color(0xFF2563EB) : const Color(0xFF0F172A)
                  )
                )
              ],
            )
          ),
          Text(
            '${entry.score}',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: Color(0xFF0F172A),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMainRank(List<Leaderboard> mainRank, String? myUid) {
    if (mainRank.length == 1) {
      return SizedBox(
        width: double.infinity,
        child: _buildMainRankSpot(mainRank[0], 1, myUid),
      );
    }
    Leaderboard? first = mainRank.isNotEmpty ? mainRank[0] : null;
    Leaderboard? second = mainRank.length > 1 ? mainRank[1] : null;
    Leaderboard? third = mainRank.length > 2 ? mainRank[2] : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
          if (second != null) Expanded(child: _buildMainRankSpot(second, 2, myUid),),
          if (first != null) Expanded(child: _buildMainRankSpot(first, 1, myUid),),
          if (third != null) Expanded(child: _buildMainRankSpot(third, 3, myUid),) 
      ],
    );
  }

  Widget _buildMainRankSpot(Leaderboard entry, int place, String? myUid) {
    final bool isFirst = place == 1;
    final double avatarSize = isFirst ? 64 : 52;
    final bool isMe = entry.uid == myUid;

    final double elevatedHeight = place == 1 ? 56 : (place == 2 ? 40 : 28);
    final Color elevationColor = place == 1 ? 
      const Color(0xFFFDE68A)
      : place == 2 
         ? const Color(0xFFE2E8F0)
         : const Color(0xFFFED7AA);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isFirst)
          const Icon(Icons.emoji_events_rounded, color: Color(0xFFCA8A04), size: 22),
          if (isFirst) const SizedBox(height: 4,),
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2563EB).withValues(alpha: 0.12),
              border: Border.all(
                color: isFirst ? const Color(0xFFCA8A04) : const Color(0xFF2563EB),
                width: isFirst ? 3 : 2
              )
            ),
            child: Center(
              child: Text(
                _nameInitials(entry.name),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: isFirst ? 20 : 16,
                  color: const Color(0xFF2563EB)
                ),
              ),
            ),
          ),
          const SizedBox(height: 8,),
          Text(
            isMe ? 'You' : entry.name,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isMe ? const Color(0xFF2563EB) : const Color(0xFF0F172A),
            ),
          ),
          Text(
            '${entry.score}',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10,),
          SizedBox(
            width: 80,
            child: Container(
              height: elevatedHeight,
              decoration: BoxDecoration(
                color: elevationColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Center(
                child: Text(
                  '$place',
                  style: TextStyle(
                    fontSize: place == 1 ? 20 : 16,
                    fontWeight: FontWeight.w900,
                    color: place == 1
                      ? const Color(0xFF92400E)
                      : place == 2
                        ? const Color(0xFF475569)
                        : const Color(0xFF9A3412)
                  ),
                ),
              ),
            ),
          )
      ],
    );
  }
}