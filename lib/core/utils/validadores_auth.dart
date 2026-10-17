/// Reglas de validación de Login y Registro.
/// No importa Flutter. Convención: `null` = válido; String = mensaje de error.
class ValidadoresAuth {
  ValidadoresAuth._();

  static const int nombreMin = 3;
  static const int passwordMin = 8;

  static final _correoRegex =
      RegExp(r'^[\w.+\-]+@[A-Za-z0-9\-]+(\.[A-Za-z0-9\-]+)*\.[A-Za-z]{2,}$');

  static String? nombre(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return 'Escribe tu nombre completo.';
    if (texto.length < nombreMin) {
      return 'El nombre debe tener al menos $nombreMin caracteres.';
    }
    return null;
  }

  static String? correo(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return 'Escribe tu correo electrónico.';
    if (!_correoRegex.hasMatch(texto)) {
      return 'Escribe un correo válido, por ejemplo nombre@correo.com.';
    }
    return null;
  }

  static String? password(String? valor) {
    final texto = valor ?? '';
    if (texto.isEmpty) return 'Escribe tu contraseña.';
    if (texto.length < passwordMin) {
      return 'La contraseña debe tener al menos $passwordMin caracteres.';
    }
    return null;
  }

  /// VALIDACIÓN CRUZADA: la confirmación depende del valor actual de la
  /// contraseña, que se recibe como parámetro.
  static String? confirmacion(String? valor, String password) {
    final texto = valor ?? '';
    if (texto.isEmpty) return 'Confirma tu contraseña.';
    if (texto != password) return 'Las contraseñas no coinciden.';
    return null;
  }
}
