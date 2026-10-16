import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/app_scaffold.dart';

/// Pantalla básica de Hábitos (ruta '/habitos').
/// Datos de ejemplo fijos; más adelante podrían venir de un provider.
class HabitosPage extends StatelessWidget {
  const HabitosPage({super.key});

  static const _habits = [
    (icon: Icons.water_drop_outlined, name: 'Beber agua', detail: '8 vasos al día'),
    (icon: Icons.menu_book_outlined, name: 'Leer', detail: '20 minutos'),
    (icon: Icons.directions_run, name: 'Ejercicio', detail: '30 minutos'),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Hábitos',
      currentIndex: 1,
      body: ListView.separated(
        padding: const EdgeInsets.all(AppDimensions.margin),
        itemCount: _habits.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.gap),
        itemBuilder: (_, i) {
          final h = _habits[i];
          return Container(
            padding: const EdgeInsets.all(AppDimensions.taskCardPadding),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppDimensions.taskCardRadius),
              border: Border.all(color: AppColors.chipBg),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.chipBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(h.icon, color: AppColors.primaryDark),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        h.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        h.detail,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
