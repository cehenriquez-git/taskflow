import 'package:flutter/material.dart';

import '../../features/taskflow/presentacion/pages/detalle_tarea_page.dart';
import '../../features/taskflow/presentacion/pages/error_page.dart';
import '../../features/taskflow/presentacion/pages/habitos_page.dart';
import '../../features/taskflow/presentacion/pages/perfil_page.dart';
import '../../features/taskflow/presentacion/pages/taskflow_page.dart';
import 'app_routes.dart';

/// Tabla de rutas y generador de rutas con argumentos.
class AppRouter {
  AppRouter._();

  /// Rutas estáticas (no necesitan argumentos).
  static final Map<String, WidgetBuilder> routes = {
    AppRoutes.home: (_) => const TaskflowPage(),
    AppRoutes.habitos: (_) => const HabitosPage(),
    AppRoutes.perfil: (_) => const PerfilPage(),
  };

  /// Rutas dinámicas: /tarea recibe el id de la tarea como argumento.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == AppRoutes.tarea) {
      final taskId = settings.arguments as String?;
      if (taskId == null) {
        // Navegación mal formada: pantalla de error controlada.
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ErrorPage(),
        );
      }
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => DetalleTareaPage(taskId: taskId),
      );
    }
    return null; // Ruta no reconocida -> onUnknownRoute
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => const ErrorPage());
  }
}
