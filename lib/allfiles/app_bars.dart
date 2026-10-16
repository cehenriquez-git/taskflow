import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';

/// Barra superior: alto 56 · título 22 pt negrita · avatar ø36.
class TopBar extends StatelessWidget {
  final String title;
  final String avatarLetter;

  const TopBar({
    super.key,
    required this.title,
    required this.avatarLetter,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.topBarHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.margin),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: AppDimensions.titleSize,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
            Container(
              width: AppDimensions.avatarSize,
              height: AppDimensions.avatarSize,
              decoration: const BoxDecoration(
                color: AppColors.chipBg,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                avatarLetter,
                style: const TextStyle(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Un destino de la barra inferior.
class BottomDestination {
  final IconData icon;
  final String label;
  const BottomDestination({required this.icon, required this.label});
}

/// Barra inferior: alto 72 · tres destinos repartidos por igual.
class BottomBar extends StatelessWidget {
  final List<BottomDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomBar({
    super.key,
    required this.destinations,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.bottomBarHeight,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: Colors.black.withOpacity(0.05))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(destinations.length, (i) {
            final selected = i == currentIndex;
            final color =
                selected ? AppColors.primaryDark : AppColors.textMuted;
            return Expanded(
              child: InkWell(
                onTap: () => onTap(i),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(destinations[i].icon, color: color, size: 24),
                    const SizedBox(height: 4),
                    Text(
                      destinations[i].label,
                      style: TextStyle(
                        fontSize: 12,
                        color: color,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
