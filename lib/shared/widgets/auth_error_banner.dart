import 'package:flutter/material.dart';

/// Mensaje de error del formulario (credenciales inválidas, correo repetido...).
class AuthErrorBanner extends StatelessWidget {
  final String mensaje;

  const AuthErrorBanner({super.key, required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true, // los lectores de pantalla lo anuncian al aparecer
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                mensaje,
                style: TextStyle(color: Colors.red.shade900, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
