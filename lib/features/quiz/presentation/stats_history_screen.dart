import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trivialy/features/quiz/services/quiz_history_service.dart';

class StatsHistoryScreen extends StatefulWidget{
  const StatsHistoryScreen({super.key});

  @override
  State<StatsHistoryScreen> createState() => _StatsHistoryScreenState();
}

class _StatsHistoryScreenState extends State<StatsHistoryScreen> {
  final QuizHistoryService _service = QuizHistoryService();
  bool _isLoading = true;
  List<QuizAttempt> _attempts = [];

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
    final attempts = await _service.getHistory(uid);
    if (mounted) {
      setState(() {
        _attempts = attempts;
        _isLoading = false;
      });
    }
  }

  int get _totalChallenges => _attempts.length;

  int get _bestPercentage =>
    _attempts.isEmpty ? 0 : _attempts.map((a) => a.scorePercentage).reduce((u, v) => u > v ? u : v);

    double get _averagePercentage {
      if (_attempts.isEmpty) return 0;
      final sum = _attempts.fold<int>(0, (acc, a) => acc + a.scorePercentage);
      return sum / _attempts.length;
    }

    @override
    Widget build(BuildContext context) {
      final double screenWidth = MediaQuery.sizeOf(context).width;

      return Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        body: SafeArea(
          child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB),),)
            : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all((screenWidth *0.05).clamp(16.0, 24.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context), 
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
                    ),
                    const Text(
                      'My stats & History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A)
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16,),
                if (_attempts.isEmpty)
                  _buildEmptyState()
                else ...[
                  Row(
                    children: [
                      _buildSummaryCard('$_totalChallenges', 'Challenges\nPlayed', const Color(0xFF2563EB)),
                      const SizedBox(width: 12,),
                      _buildSummaryCard('$_bestPercentage', 'Best\nScore', const Color(0xFF16A34A)),
                      const SizedBox(width: 12,),
                      _buildSummaryCard ('${_averagePercentage.round()}%', 'Average\nScore', const Color(0xFFB45309)),
                    ],
                  ),
                  const SizedBox(height: 28,),
                  const Text(
                    'Performance Overview',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16,),
                  _buildBarChart(),
                  const SizedBox(height: 28,),
                  const Text(
                    'Attempt History',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12,),
                  ..._attempts.reversed.map(_buildHistoryRow),
                ]
              ],
            ),
        ),
      ));
    }

    Widget _buildEmptyState() {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.bar_chart_rounded, size: 56, color: Color(0xFF94A3B8)),
              const SizedBox(height: 16,),
              const Text(
                'No History yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A)
                ),
              ),
              const SizedBox(height: 6,),
              const Text(
                'Complete a weekly challenge to see your stats here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF64748B), fontSize: 13,
                ),
              )
            ],
          ),
        ),
      );
    }

    Widget _buildSummaryCard (String value, String label, Color color) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8, offset: const Offset(0, 4)
              )
            ]
          ),
          child: Column(
            children: [
              Text(
                value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color),
              ),
              const SizedBox(height: 4,),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                  height: 1.3
                ),
              )
            ],
          ),
        )
      );
    }

    Widget _buildBarChart() {
      // I will be showing at most the last 8 attempts...
      // I am etting the average day score percentage for the graph

      final Map<DateTime, List<QuizAttempt>> byDay = {};
      for (final attempt in _attempts) {
        if (attempt.completedAt == null) continue;
        final val = attempt.completedAt!.toLocal();
        final dayKey = DateTime(val.year, val.month, val.day);
        byDay.putIfAbsent(dayKey, () => []).add(attempt);
      }

      final List<DateTime> sortedDays = byDay.keys.toList()..sort();
      final List<DateTime> recentDays = sortedDays.length > 8 ? sortedDays.sublist(sortedDays.length - 8) : sortedDays;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            padding: const EdgeInsets.fromLTRB(8, 20, 16, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8, offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: 28,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('100', style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8)),),
                      Text('50', style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8)),),
                      Text('0', style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8)),),
                      SizedBox(height: 18,)
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        bottom: 18,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(height: 1, color: const Color(0xFFF1F5F9)),
                            Container(height: 1, color: const Color(0xFFF1F5F9)),
                            Container(height: 1, color: const Color(0xFFF1F5F9))
                          ],
                        )
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: recentDays.map((day) {
                            final List<QuizAttempt> dayAttempt = byDay[day]!;
                            final double avgPercentage = dayAttempt.map((a) => a.scorePercentage).reduce((u, v) => u + v) / dayAttempt.length;
                            final bool includesWeekly = dayAttempt.any((a) => a.isWeeklyChallenge);
                            final Color barColor = includesWeekly ? const Color(0xFFB45309) : const Color(0xFF2563EB);
                            return SizedBox(
                              width: 28,
                              child: FractionallySizedBox(
                                heightFactor: (avgPercentage / 100).clamp(0.03, 1.0),
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: barColor,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6))
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: recentDays.map((day) {
                            return SizedBox(
                              width: 28,
                              child: Text(
                                '${day.month}/${day.day}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8)),
                              ),
                            );
                          }).toList()
                        )
                      )
                    ],
                  )
                )
              ]
            ),
          ),
          const SizedBox(height: 12,),
          _buildLegend(),
        ]);
    }

    Widget _buildLegend() {
      return Row(
        children: [
          _buildLegendDot(const Color(0xFF2563EB), 'Practice only'),
          const SizedBox(width: 20,),
          _buildLegendDot(const Color(0xFFB45309), 'Includes weekly challenge')
        ],
      );
    }

    Widget _buildLegendDot(Color color, String label) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6,),
          Text(
            label, 
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
          )
        ],
      );
    }

    Widget _buildHistoryRow(QuizAttempt attempt) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4),
            )
          ]
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF2563EB),),
            ),
            const SizedBox(width: 12,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attempt.isWeeklyChallenge ? 'Weekly Challenge' : attempt.category,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF0F172A)
                    ),
                  ),
                  Text(
                    '${attempt.score} points',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  )
                ],
              )
            ),
            Text(
              '${attempt.scorePercentage}%',
              style: const TextStyle(
                fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A)
              ),
            )
          ],
        ),
      );
    }
}

