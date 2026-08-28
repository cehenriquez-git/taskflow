import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/task.dart';
import 'priority_chip.dart';

/// Tarjeta de tarea: alto 84 · relleno 16 · casilla 22 · radio 16.
class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;

  const TaskCard({super.key, required this.task, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.taskCardHeight,
      padding: const EdgeInsets.all(AppDimensions.taskCardPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.taskCardRadius),
        border: Border.all(color: AppColors.chipBg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCheckbox(),
          const SizedBox(width: 12),
          Expanded(child: _buildContent()),
          const SizedBox(width: 8),
          PriorityChip(priority: task.priority),
        ],
      ),
    );
  }

  // Casilla 22
  Widget _buildCheckbox() {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        width: AppDimensions.checkboxSize,
        height: AppDimensions.checkboxSize,
        decoration: BoxDecoration(
          color: task.done ? AppColors.primaryDark : AppColors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: task.done ? AppColors.primaryDark : AppColors.textMuted,
            width: 1.5,
          ),
        ),
        child: task.done
            ? const Icon(Icons.check, size: 16, color: AppColors.white)
            : null,
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Título largo: máx. 2 líneas con recorte por puntos suspensivos
        Flexible(
          child: Text(
            task.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
              decoration: task.done ? TextDecoration.lineThrough : null,
              decorationColor: AppColors.textMuted,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 12,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                task.meta,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
