import 'package:flutter/material.dart';

class AssessmentStepBadge extends StatelessWidget {
  const AssessmentStepBadge({
    super.key,
    required this.step,
    required this.totalSteps,
    this.backgroundColor = const Color(0x26FFFFFF),
    this.activeColor = const Color(0xFF31C14B),
    this.inactiveColor = const Color(0x66FFFFFF),
    this.textColor = Colors.white,
    this.borderColor = const Color(0x4DFFFFFF),
  });

  final int step;
  final int totalSteps;
  final Color backgroundColor;
  final Color activeColor;
  final Color inactiveColor;
  final Color textColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(totalSteps, (index) {
            final isActive = index < step;
            return Padding(
              padding: EdgeInsets.only(right: index == totalSteps - 1 ? 6 : 3),
              child: Container(
                width: index == step - 1 ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive ? activeColor : inactiveColor,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            );
          }),
          Text(
            '$step of $totalSteps',
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
