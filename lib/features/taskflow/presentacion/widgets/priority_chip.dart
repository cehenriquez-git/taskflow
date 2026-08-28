import 'package:flutter/material.dart';

import '../../domain/task.dart';

/// Etiqueta de prioridad (Alta / Media / Baja) que aparece en cada tarea.
class PriorityChip extends StatelessWidget {
  final Priority priority;

  const PriorityChip({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: priority.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        priority.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: priority.foreground,
        ),
      ),
    );
  }
}
