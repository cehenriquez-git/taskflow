import 'package:flutter/foundation.dart';

/// Publicación de JSONPlaceholder (/posts).
@immutable
class Post {
  final int id;
  final int userId;
  final String title;
  final String body;

  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  /// Lanza [FormatException] si el dato no es utilizable.
  factory Post.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final titulo = json['title'];
    final cuerpo = json['body'];
    if (id is! int || titulo is! String || titulo.trim().isEmpty) {
      throw const FormatException('Publicación con formato inválido.');
    }
    return Post(
      id: id,
      userId: json['userId'] is int ? json['userId'] as int : 0,
      title: titulo.trim(),
      body: cuerpo is String ? cuerpo.replaceAll('\n', ' ').trim() : '',
    );
  }
}
