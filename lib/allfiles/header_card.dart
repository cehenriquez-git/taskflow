import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/progress_badge.dart';

/// Tarjeta de cabecera (alto 104 · radio 20) con la insignia ø76
/// superpuesta al borde inferior derecho.
class HeaderCard extends StatelessWidget {
  final String greeting;
  final String date;
  final String subtitle;
  final double progress;

  const HeaderCard({
    super.key,
    required this.greeting,
    required this.date,
    required this.subtitle,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.margin),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: AppDimensions.headerCardHeight,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(
                AppDimensions.headerCardRadius,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  greeting,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    date,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
                Flexible(
                  child: Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          // Insignia superpuesta: mitad fuera del borde inferior (ø76 / 2 = 38).
          Positioned(
            right: 16,
            bottom: -(AppDimensions.badgeSize / 2),
            child: ProgressBadge(
              progress: progress,
              size: AppDimensions.badgeSize,
            ),
          ),
        ],
      ),
    );
  }
}
