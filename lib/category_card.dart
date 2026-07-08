import 'package:flutter/material.dart';
class CategoryCard extends StatelessWidget{
  final String title;
  final IconData icon;
  final Color iconColor;
  final bool isMultiSelect;
  final VoidCallback? onTap;
  final bool isSelected;
  
  const CategoryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.isMultiSelect,
    this.onTap,
    this.isSelected = false,
  });
  @override
    Widget build(BuildContext context) {
      final double screenWidth = MediaQuery.sizeOf(context).width;
      double titleSize = (screenWidth * 0.055).clamp(20.0, 23.0);
      return Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        shadowColor: Colors.black.withValues(alpha: 0.03),
        elevation: 4,
        child: Stack(
          children: [
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: iconColor, size: 24)
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: titleSize,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E293B),
                          height: 1.2
                        )
                      ),
                    ],
                  ),
                ],
              ),
            ),
      ),
      if (isMultiSelect)
      Positioned(
        top: 8,
        right: 8,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFF2563EB): Colors.white,
                border: Border.all(
                  color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: isSelected
                ? const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 14,
                )
                : null
              ),
          )
          )
      )
      ])
    );
  }
}