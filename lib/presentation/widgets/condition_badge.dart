import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/book_model.dart';

class ConditionBadge extends StatelessWidget {
  final BookCondition condition;
  final bool compact;

  const ConditionBadge({
    super.key,
    required this.condition,
    this.compact = false,
  });

  Color get _backgroundColor {
    switch (condition) {
      case BookCondition.newCondition:
        return AppColors.conditionNew.withValues(alpha: 0.1);
      case BookCondition.likeNew:
        return AppColors.conditionLikeNew.withValues(alpha: 0.1);
      case BookCondition.good:
        return AppColors.conditionGood.withValues(alpha: 0.1);
      case BookCondition.used:
        return AppColors.conditionUsed.withValues(alpha: 0.1);
    }
  }

  Color get _textColor {
    switch (condition) {
      case BookCondition.newCondition:
        return AppColors.conditionNew;
      case BookCondition.likeNew:
        return AppColors.conditionLikeNew;
      case BookCondition.good:
        return AppColors.conditionGood;
      case BookCondition.used:
        return AppColors.conditionUsed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(compact ? 6 : 8),
      ),
      child: Text(
        condition.displayName,
        style: TextStyle(
          fontSize: compact ? 11 : 12,
          fontWeight: FontWeight.w600,
          color: _textColor,
        ),
      ),
    );
  }
}
