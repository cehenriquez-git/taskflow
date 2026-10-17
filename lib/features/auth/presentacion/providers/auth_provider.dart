import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/auth_service.dart';
import '../../domain/auth_user.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Estado de SESIÓN: el usuario autenticado (null = sin sesión).
/// Vive en un provider global (ProviderScope, por encima del Navigator) porque
/// lo necesitan varias pantallas y debe sobrevivir a la navegación.
class AuthNotifier extends Notifier<AuthUser?> {
  @override
  AuthUser? build() => null;

  /// Lanza [AuthException] si las credenciales no son válidas.
  Future<void> iniciarSesion({
    required String correo,
    required String password,
  }) async {
    state = await ref.read(authServiceProvider).iniciarSesion(correo, password);
  }

  /// Registra la cuenta; NO inicia sesión (el usuario vuelve al Login).
  Future<void> registrar({
    required String nombre,
    required String correo,
    required String password,
  }) {
    return ref.read(authServiceProvider).registrar(
          nombre: nombre,
          correo: correo,
          password: password,
        );
  }

  void cerrarSesion() => state = null;
}

final authProvider =
    NotifierProvider<AuthNotifier, AuthUser?>(AuthNotifier.new);
