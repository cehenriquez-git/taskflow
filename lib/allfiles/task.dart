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
  final String id;
  final String title;

  /// CAMBIO (Formularios): descripción opcional (máx. 200 caracteres).
  final String description;

  /// CAMBIO (Formularios): fecha límite (solo importa el día).
  final DateTime dueDate;

  /// CAMBIO (Formularios): General, Estudio, Trabajo o Personal.
  final String category;

  final Priority priority;
  final bool done;

  const Task({
    required this.id,
    required this.title,
    this.description = '',
    required this.dueDate,
    this.category = 'General',
    required this.priority,
    this.done = false,
  });

  /// Texto secundario de las tarjetas, p. ej. "Hoy · Estudio".
  /// Ahora se DERIVA de dueDate y category (una sola fuente de verdad).
  String get meta => '$dateLabel · $category';

  /// "Hoy", "Mañana" o dd/MM/aaaa.
  String get dateLabel {
    final now = DateTime.now();
    // UTC solo para que el cambio de horario de verano no altere la diferencia.
    final hoy = DateTime.utc(now.year, now.month, now.day);
    final limite = DateTime.utc(dueDate.year, dueDate.month, dueDate.day);
    final dias = limite.difference(hoy).inDays;
    if (dias == 0) return 'Hoy';
    if (dias == 1) return 'Mañana';
    return formatDate(dueDate);
  }

  /// dd/MM/aaaa
  static String formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? category,
    Priority? priority,
    bool? done,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      done: done ?? this.done,
    );
  }
}
