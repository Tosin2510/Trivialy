import 'package:flutter/material.dart';
import 'package:trivialy/features/quiz/presentation/quiz_screen.dart';
class QuizSetupScreen extends StatefulWidget {
  final Set<String> selectedCategories;
  final IconData categoryIcon;
  const QuizSetupScreen({
    super.key,
    required this.selectedCategories,
    this.categoryIcon = Icons.psychology_rounded,
  });
  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}
class _QuizSetupScreenState extends State<QuizSetupScreen> {
  int _questionCount = 10;
  String _difficulty = 'Medium';
  final List<int> _questionOptions = [10, 20, 30, 40, 50];
  final List<String> _difficultyLevels = ['Easy', 'Medium', 'Hard'];
  final List<String> _timeOptions = ['5 mins', '10 mins', '15 mins', '20 mins', '30 mins'];
  late final TextEditingController _timeController;
  late final TextEditingController _questionsController;

  @override
  void initState() {
    super.initState();
    _timeController = TextEditingController(text: '10 mins');
    _questionsController = TextEditingController(text: '10');
  }
  @override
  void dispose() {
    _timeController.dispose();
    _questionsController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final bool isMulti = widget.selectedCategories.length > 1;
    final String displayTitle = isMulti ? 'Mixed Quiz': widget.selectedCategories.first;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF0F172A)
          ),
          onPressed: () => Navigator.pop(context)
      ),
      title: const Text(
        'Quiz Setup',
        style: TextStyle(color: Color(0xFF0F172A),
        fontWeight: FontWeight.bold
        ),
      ),
    ),
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isMulti ? Icons.layers_rounded: widget.categoryIcon,
                            size: 64,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          displayTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A)
                          )
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isMulti
                            ? '${widget.selectedCategories.length} categories combined'
                            : 'Single Category Mode',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          )
                        )
                      ],
                      )
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Number of Questions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B)
                      )
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0,4),
                          )
                        ],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _questionCount,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF64748B)),
                          style: const TextStyle(fontSize: 16, 
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A)),
                          borderRadius: BorderRadius.circular(16),
                          items: _questionOptions.map((int value){
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text('$value Questions'),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            if (newValue != null) {
                              setState(() => _questionCount = newValue);
                            }
                          }
                        )
                      )
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Time Limit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B)
                      )
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha:0.02),
                            blurRadius: 8,
                            offset: const Offset(0,4)
                          )
                        ]
                      ),
                      child: TextFormField(
                        controller: _timeController,
                        keyboardType: TextInputType.text,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A)
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type or choose time...',
                          hintStyle: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.normal
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          border: InputBorder.none,
                          suffixIcon: PopupMenuButton<String>(
                            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                            color: Color(0xFF64748B)
                            ),
                            onSelected: (String value) {
                              setState((){
                                _timeController.text = value;
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)
                            ),
                            itemBuilder: (BuildContext context) {
                              return _timeOptions.map((String option){
                                return PopupMenuItem<String>(
                                  value: option,
                                  child : Text(
                                    option,
                                    style: TextStyle(fontWeight: FontWeight.w500)
                                  ),
                                );
                              }).toList();
                            }
                          )
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Difficulty Level',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B)
                      )),
                      const SizedBox(height: 10),
                      Row(
                        children: _difficultyLevels.map((level){
                          final bool isSelected = _difficulty == level;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: GestureDetector(
                                onTap: () => setState(() => _difficulty = level),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFF0F172A)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFF0F172A): Colors.transparent,
                                      width: 1.5
                                    )
                                  ),
                                  child: Text(
                                    level,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected? Colors.white: const Color(0xFF475569),
                                    )
                                  )
                                )
                              ),
                              )
                          );
                        }).toList()
                      ),
                      const SizedBox(height: 32),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color : Colors.black.withValues(alpha: 0.01),
                            blurRadius: 10,
                            offset: const Offset(0,4),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.info_outline_rounded,
                                color: Color(0xFF2563EB),
                                size: 20
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Quiz Guidelines',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A)
                                  )
                                ),
                              ],),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                child: Divider(color: Color(0xFFE2E8F0)),
                                ),
                                _buildRuleRow(Icons.timer_outlined, 'The timer acts across the selection framework',),
                                const SizedBox(height: 12),
                                _buildRuleRow(Icons.stars_rounded, 'Score multiplier scale automatically with target difficulty values.')
                          ],
                          )
                      )
                      ]
              )
            )
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(
                          categoryTitle: displayTitle,
                          amount: _questionCount,
                          difficulty: _difficulty.toLowerCase(),
                          categoryIds: _resolveCategoryIds(),
                          timeLimit: _parseTimeLimit(),
                        )
                        )
                      );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Let\'s Play',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    )
                  ),
                )
              )
          )
        ],
        ))
    );
  }
Duration _parseTimeLimit() {
  final String text = _timeController.text.trim();
  final RegExp digitsOnly = RegExp(r'\d+');
  final Match? match = digitsOnly.firstMatch(text);
  final int minutes = match != null ? int.parse(match.group(0)!) : 10;
  return Duration(minutes: minutes);
}
Widget _buildRuleRow(IconData icon, String rule) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon,
      size: 18,
      color: const Color(0xFF64748B)
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          rule,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF475569),
            height: 1.4
          )
        )
        )
    ]
  );
}
List<String> _resolveCategoryIds() {
  const Map<String, String> categoryNames = {
    'General Knowledge': 'general_knowledge',
    'Science': 'science',
    'History': 'history',
    'Sports': 'sport_and_leisure',
    'Entertainment': 'film_and_tv',
    'Art': 'arts_and_literature',
    'Geography' : 'geography',
    'Music' : 'music',
    'Food & Drink': 'food_and_drink',
  };

  return widget.selectedCategories
     .map((title) => categoryNames[title])
     .whereType<String>()
     .toList();
  }
}