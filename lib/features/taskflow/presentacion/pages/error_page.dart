import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';

/// Pantalla de error controlada: ruta desconocida o argumentos faltantes.
class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Esta pantalla no existe o faltan datos.'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.home,
                (_) => false,
              ),
              child: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    );
  }
}
