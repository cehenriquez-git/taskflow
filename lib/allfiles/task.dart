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
  /// Id LOCAL (String) usado por la app, las rutas y Dismissible.
  final String id;

  /// CAMBIO (Semana 14): id del SERVIDOR. Es null mientras la tarea no se
  /// ha enviado a la API.
  final int? remoteId;

  final String title;

  /// Descripción opcional (máx. 200 caracteres).
  final String description;

  /// Fecha límite (solo importa el día).
  final DateTime dueDate;

  /// General, Estudio, Trabajo o Personal.
  final String category;

  final Priority priority;
  final bool done;

  const Task({
    required this.id,
    this.remoteId,
    required this.title,
    this.description = '',
    required this.dueDate,
    this.category = 'General',
    required this.priority,
    this.done = false,
  });

  // Contador para generar ids locales únicos al convertir desde JSON.
  static int _secuencia = 0;

  /// CAMBIO (Semana 14): construye una Task a partir del JSON de la API.
  /// Lanza [FormatException] si el dato no es utilizable.
  ///
  /// Mapeo (JSONPlaceholder):
  ///  - title     -> title (obligatorio; si falta/está vacío se descarta)
  ///  - completed -> done (si falta o no es `true`, se asume false)
  ///  - id        -> remoteId (si no es int, queda null)
  ///  - La API NO envía fecha: se asigna "hoy + 7 días" (limitación documentada).
  ///  - description, category y priority usan los valores por defecto.
  factory Task.fromJson(Map<String, dynamic> json) {
    final titulo = json['title'];
    if (titulo is! String || titulo.trim().isEmpty) {
      throw const FormatException(
        'La tarea recibida no tiene un título válido.',
      );
    }

    final id = json['id'];
    final remoto = id is int ? id : null;
    final ahora = DateTime.now();

    return Task(
      id: remoto != null
          ? 'api-$remoto'
          : 'api-${ahora.microsecondsSinceEpoch}-${_secuencia++}',
      remoteId: remoto,
      title: titulo.trim(),
      dueDate: DateTime(ahora.year, ahora.month, ahora.day + 7),
      priority: Priority.media,
      done: json['completed'] == true,
    );
  }

  /// CAMBIO (Semana 14): formato que espera la API.
  Map<String, dynamic> toJson() => {
        'title': title,
        'completed': done,
        'userId': 1,
      };

  /// Texto secundario de las tarjetas, p. ej. "Hoy · Estudio".
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
    int? remoteId,
    String? title,
    String? description,
    DateTime? dueDate,
    String? category,
    Priority? priority,
    bool? done,
  }) {
    return Task(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      done: done ?? this.done,
    );
  }
}
