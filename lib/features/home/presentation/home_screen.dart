import 'package:flutter/material.dart';
import 'package:trivialy/core/widgets/category_card.dart';
import 'package:trivialy/core/widgets/custom_bottom_nav_bar.dart';
import 'package:trivialy/features/home/presentation/dashboard_header.dart';
import 'package:trivialy/core/widgets/gold_league_banner.dart';
import 'package:trivialy/core/widgets/personal_best_banner.dart';
import 'package:trivialy/features/profile/presentation/profile_screen.dart';
import 'package:trivialy/features/quiz/presentation/quiz_setup_screen.dart';
import 'package:trivialy/features/quiz/presentation/rank_screen.dart';
import 'package:trivialy/core/widgets/section_title.dart';
import 'package:trivialy/core/widgets/weekly_challenge_banner.dart';

// This is the app's responsive home screen, shows categories, weekly challenges and so on.
// It is responsive to big snd small screens like tablets, mobile phones...
class ResponsiveLayout {
  static const double mobileMax = 600;
  static const double tabletMax = 1100;
  static bool isMobile(BuildContext context) => 
    MediaQuery.sizeOf(context).width <= mobileMax;
  static bool isTablet(BuildContext context) =>
    MediaQuery.sizeOf(context).width > mobileMax &&
    MediaQuery.sizeOf(context).width <= tabletMax;
}

class HomeScreen extends StatefulWidget{
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showAllCategories = false;
  bool _isMultiSelect = false;
  final Set<String> _selectedCategories = {};
  // Other categories that pop up when the user presses view all.
  final List<Map<String, dynamic>> _extraCategories = [
    {'title': 'Entertainment', 'icon': Icons.movie_creation_outlined, 'color': Colors.deepOrange},
    {'title': 'Art', 'icon': Icons.palette_outlined, 'color': Colors.purple},
    {'title': 'Geography', 'icon': Icons.public_rounded, 'color': Colors.teal},
    {'title': 'Music', 'icon': Icons.music_note_rounded, 'color': Colors.pink},
    {'title': 'Food & Drink', 'icon': Icons.restaurant_rounded, 'color': Colors.deepPurple},
  ];

  @override
  // The build.
  Widget build(BuildContext context) {
    final bool showCheckboxes = _isMultiSelect && _selectedCategories.isNotEmpty;
    final double screenWidth = MediaQuery.sizeOf(context).width;
    int crossAxisCount = 2;
    if (screenWidth > ResponsiveLayout.mobileMax) {
      crossAxisCount = 3;
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Stack(
              children: [
                // Supports custom scrolling.
                CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    const SliverToBoxAdapter(child: DashBoardHeader()),
                    const SliverToBoxAdapter(child: PersonalBestBanner()),
                    SliverToBoxAdapter(
                      child: SectionTitle(
                        title: 'Choose a Category',
                        hasViewAll: true,
                        // The screen can switch between showing all categories or showing less categories.
                        viewAllText: _showAllCategories ? 'Show less' : 'View all',
                        customFontSize: 20.0,
                        customFontWeight: FontWeight.w800,
                        onViewAllTap: () {
                          setState(() {
                            _showAllCategories = !_showAllCategories;
                          });
                        },
                        // Allows users to switch btwn single and multiple category.
                        isMultiSelect: _isMultiSelect,
                        onToggleMode: (bool newValue) {
                          setState((){
                            _isMultiSelect = newValue;
                            _selectedCategories.clear();
                          });
                        }
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: (screenWidth * 0.04).clamp(16.0, 24.0),
                        vertical: 20.0      
                      ),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: (screenWidth * 0.03).clamp(12.0,20.0),
                          crossAxisSpacing: (screenWidth * 0.03).clamp(12.0, 20.0),
                          childAspectRatio: 1.02,
                        ),
                        // Basically rep the category card in some form of grid.
                        delegate: SliverChildListDelegate([
                          CategoryCard(
                            title: 'General Knowledge',
                            icon: Icons.public,
                            iconColor: Colors.blue,
                            isMultiSelect: showCheckboxes,
                            isSelected: _selectedCategories.contains('General Knowledge'),
                            onTap: () => _handleCategoryTap('General Knowledge', Icons.public)
                          ),
                          CategoryCard(
                            title: 'Science',
                            icon: Icons.science,
                            iconColor: Colors.blueGrey,
                            isMultiSelect: showCheckboxes,
                            isSelected: _selectedCategories.contains('Science'),
                            onTap: () => _handleCategoryTap('Science', Icons.science)
                          ),
                          CategoryCard(
                            title: 'History',
                            icon: Icons.menu_book,
                            iconColor: Colors.brown,
                            isMultiSelect: showCheckboxes,
                            isSelected: _selectedCategories.contains('History'),
                            onTap: () => _handleCategoryTap('History', Icons.menu_book)
                          ),
                          CategoryCard(
                            title: 'Sports',
                            icon: Icons.sports_soccer,
                            iconColor: Colors.black87,
                            isMultiSelect: showCheckboxes,
                            isSelected: _selectedCategories.contains('Sports'),
                            onTap: () => _handleCategoryTap('Sports', Icons.sports_soccer)
                          ),
                          // This comes up when the user clicks on view all.
                          // It shows the category card for those other categories too.
                          if(_showAllCategories)
                            ..._extraCategories.map((item) {
                              final String currentTitle = item['title'] ?? '';
                              final IconData currentIcon = item['icon'] ?? Icons.psychology_rounded;
                              return CategoryCard(
                                title: currentTitle,
                                icon: item['icon'],
                                iconColor: item['color'],
                                isMultiSelect: showCheckboxes,
                                isSelected: _selectedCategories.contains(currentTitle),
                                onTap: () => _handleCategoryTap(currentTitle, currentIcon),
                            );
                            })
                        ])
                      )
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top:16.0),
                        child: Column(
                          children: const [
                            WeeklyChallengeBanner(),
                            GoldLeagueBanner(),
                            SizedBox(height: 40),
                          ]
                        )
                      )
                    )
                  ],
                ),
                
                // Rep the selected categories.
                // If the user is seleting multipe category, then some sort of banner shows up.
                if (_isMultiSelect && _selectedCategories.isNotEmpty) 
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Selected Categories',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500
                                ),
                              ),
                              const SizedBox(height: 2),
                              // This shows the number of categories the user selects.
                              Text(
                                '${_selectedCategories.length} selected',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
                          ),
                          // If the suer clicks on deselect all, the selected caategries get cleared off.
                          Row(
                            children: [
                              TextButton(
                                onPressed: () {
                                  setState(() => _selectedCategories.clear());
                                }, 
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white70,
                                ),
                                child: const Text(
                                  'Deselect All',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 13
                                  ),
                                )
                              ),
                              const SizedBox(width: 8,),
                              // When the user select start, the users are led to the quiz setup screen.
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => QuizSetupScreen(
                                        selectedCategories: _selectedCategories,
                                      )
                                    )
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                                child: const Text('Start', style: TextStyle(fontWeight: FontWeight.bold))
                              ),
                            ],
                          )
                        ]
                      )
                    )
                  )
              ],
            ),
          ),
        )
      ),
      // This part shows the bottom navigation bar.
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) return;

          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RankScreen()
              ),
            );
          }

          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileScreen()
              ),
            );
          }
        },
      ),
    );
  }

// If the user checks or unchecks a selected categgory, this part either add or remove it from the categories selected.
  void _handleCategoryTap(String categoryTitle, IconData categoryIcon) {
    setState(() {
      if(_isMultiSelect) {
        if (_selectedCategories.contains(categoryTitle)) {
          _selectedCategories.remove(categoryTitle);
        } else {
          _selectedCategories.add(categoryTitle);
        }        
      } else {
        _selectedCategories.clear();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizSetupScreen(
              selectedCategories: {categoryTitle},
              categoryIcon: categoryIcon,
              ),
          )
        );
      }
    });
  }
}