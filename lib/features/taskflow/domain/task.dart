import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Prioridad de una tarea.
enum Priority { alta, media, baja }

/// Estilos visuales asociados a cada prioridad.
extension PriorityStyle on Priority {
  String get label {
    switch (this) {
      case Priority.alta:
        return 'Alta';
      case Priority.media:
        return 'Media';
      case Priority.baja:
        return 'Baja';
    }
  }

  Color get background {
    switch (this) {
      case Priority.alta:
        return AppColors.gold;
      case Priority.media:
      case Priority.baja:
        return AppColors.chipBg;
    }
  }

  Color get foreground {
    switch (this) {
      case Priority.alta:
        return AppColors.white;
      case Priority.media:
        return AppColors.primaryMedium;
      case Priority.baja:
        return AppColors.textMuted;
    }
  }
}

/// Entidad de dominio que representa una tarea.
@immutable
class Task {
  final String title;
  final String meta; // p. ej. "Hoy · Universidad"
  final Priority priority;
  final bool done;

  const Task({
    required this.title,
    required this.meta,
    required this.priority,
    this.done = false,
  });

  Task copyWith({
    String? title,
    String? meta,
    Priority? priority,
    bool? done,
  }) {
    return Task(
      title: title ?? this.title,
      meta: meta ?? this.meta,
      priority: priority ?? this.priority,
      done: done ?? this.done,
    );
  }
}
