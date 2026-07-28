import 'package:flutter/material.dart';

// Allows the display of a view all button and a tite for each section of the app.
class SectionTitle extends StatelessWidget{
  final String title;
  final bool hasViewAll;
  final String viewAllText;
  final double? customFontSize;
  final FontWeight? customFontWeight;
  final VoidCallback? onViewAllTap;
  final bool isMultiSelect;
  final ValueChanged<bool> onToggleMode;
  const SectionTitle({
    super.key,
    required this.title,
    this.hasViewAll = false,
    this.viewAllText = 'View all',
    this.customFontSize,
    this.customFontWeight,
    this.onViewAllTap,
    required this.isMultiSelect,
    required this.onToggleMode,
  });
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    double dynamicPadding = (screenWidth * 0.04).clamp(16.0, 24.0);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: dynamicPadding, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: customFontSize ?? (screenWidth * 0.055).clamp(16.0, 20.0),
                      fontWeight: customFontWeight ?? FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    )
                  ),
                ),
                const SizedBox(width: 4),
                PopupMenuButton<bool>(
                  initialValue: isMultiSelect,
                  tooltip: 'Selection Mode',
                  icon: const Icon(
                    Icons.tune_rounded,
                    color: Color(0xFF64748B),
                    size: 20,
                  ),
                  offset: const Offset(0, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    ),
                    onSelected: onToggleMode,
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem<bool>(
                        value: false,
                        child: Row(
                          children: [
                            Icon(
                              !isMultiSelect ? Icons.check_circle_rounded : Icons.circle_outlined,
                              color: !isMultiSelect ? const Color(0xFF2563EB) : Colors.black26,
                              size: 20,                       
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Single category',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14
                                ),
                              ),
                          ],
                          ),
                      ),
                      PopupMenuItem<bool> (
                        value: true,
                        child: Row(
                          children: [
                            Icon(
                              isMultiSelect ? Icons.check_circle_rounded : Icons.circle_outlined,
                              color: isMultiSelect ? const Color(0xFF2563EB) : Colors.black26,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Multiple Categories',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                          ],
                          )
                      )
                    ]
                )
              ],
              ),
          ),
            if(hasViewAll)
            TextButton(
              onPressed: onViewAllTap,
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: EdgeInsets.zero
              ),
                child: Text(
                  viewAllText,
                  style: TextStyle(color: Color(0xFF2563EB),
                  fontWeight: FontWeight.w700, )),
            )
        ]
      )
    );
  }
}