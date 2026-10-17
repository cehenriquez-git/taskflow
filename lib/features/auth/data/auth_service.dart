import '../domain/auth_user.dart';

/// Error de autenticación con mensaje apto para el usuario.
class AuthException implements Exception {
  final String mensaje;
  const AuthException(this.mensaje);

  @override
  String toString() => mensaje;
}

/// Autenticación SIMULADA: no hay servidor, pero el comportamiento es el de
/// uno real (espera asíncrona de 1.5 s, credenciales válidas o inválidas).
/// Las cuentas viven en memoria mientras la app esté abierta.
class AuthService {
  static const _espera = Duration(milliseconds: 1500);

  // Cuenta de demostración para probar el Login sin registrarse.
  final Map<String, ({String nombre, String password})> _cuentas = {
    'demo@taskflow.com': (nombre: 'Usuario Demo', password: '12345678'),
  };

  Future<AuthUser> iniciarSesion(String correo, String password) async {
    await Future.delayed(_espera);
    final clave = correo.trim().toLowerCase();
    final cuenta = _cuentas[clave];
    if (cuenta == null || cuenta.password != password) {
      throw const AuthException(
        'Correo o contraseña incorrectos. Revisa tus datos e intenta de nuevo.',
      );
    }
    return AuthUser(nombre: cuenta.nombre, correo: clave);
  }

  Future<void> registrar({
    required String nombre,
    required String correo,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    final clave = correo.trim().toLowerCase();
    if (_cuentas.containsKey(clave)) {
      throw const AuthException('Ya existe una cuenta con ese correo.');
    }
    _cuentas[clave] = (nombre: nombre.trim(), password: password);
  }
}
