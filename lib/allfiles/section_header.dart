import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';

/// Encabezado de sección: título 17 pt + enlace 13 pt en dorado.
class SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    required this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.margin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: AppDimensions.sectionTitleSize,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel,
              style: const TextStyle(
                fontSize: AppDimensions.sectionLinkSize,
                fontWeight: FontWeight.w600,
                color: AppColors.gold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
