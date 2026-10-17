import 'package:flutter/foundation.dart';

/// Usuario autenticado.
@immutable
class AuthUser {
  final String nombre;
  final String correo;

  const AuthUser({required this.nombre, required this.correo});
}
