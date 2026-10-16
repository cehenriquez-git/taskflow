/// Reglas de negocio para los campos de una Tarea.
/// No importa Flutter: se puede probar con un test unitario simple.
///
/// Convención: `null` = válido; un `String` = mensaje de error para el usuario.
class ValidadoresTarea {
  ValidadoresTarea._();

  static const int tituloMin = 3;
  static const int tituloMax = 60;
  static const int descripcionMax = 200;

  /// Obligatorio, entre [tituloMin] y [tituloMax] caracteres (tras trim()).
  static String? titulo(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) {
      return 'El título es obligatorio.';
    }
    if (texto.length < tituloMin) {
      return 'El título debe tener al menos $tituloMin caracteres.';
    }
    if (texto.length > tituloMax) {
      return 'El título no puede superar $tituloMax caracteres.';
    }
    return null;
  }

  /// Opcional: vacío es válido, pero tiene un máximo.
  static String? descripcion(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.length > descripcionMax) {
      return 'La descripción no puede superar $descripcionMax caracteres.';
    }
    return null;
  }

  /// La fecha límite no puede ser anterior a hoy.
  /// [hoy] es opcional para poder fijar la fecha en las pruebas.
  static String? fechaLimite(DateTime? fecha, {DateTime? hoy}) {
    if (fecha == null) {
      return 'Selecciona una fecha límite.';
    }
    final referencia = hoy ?? DateTime.now();
    final inicioDeHoy =
        DateTime(referencia.year, referencia.month, referencia.day);
    if (fecha.isBefore(inicioDeHoy)) {
      return 'La fecha límite no puede estar en el pasado.';
    }
    return null;
  }
}
