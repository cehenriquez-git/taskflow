import 'package:flutter/material.dart';

import '../../features/auth/presentacion/pages/login_page.dart';
import '../../features/auth/presentacion/pages/publicaciones_page.dart';
import '../../features/auth/presentacion/pages/registro_page.dart';
import '../../features/taskflow/domain/task.dart';
import '../../features/taskflow/presentacion/pages/detalle_tarea_page.dart';
import '../../features/taskflow/presentacion/pages/error_page.dart';
import '../../features/taskflow/presentacion/pages/habitos_page.dart';
import '../../features/taskflow/presentacion/pages/laboratorio_async_page.dart';
import '../../features/taskflow/presentacion/pages/nueva_tarea_page.dart';
import '../../features/taskflow/presentacion/pages/perfil_page.dart';
import '../../features/taskflow/presentacion/pages/tareas_remotas_page.dart';
import '../../features/taskflow/presentacion/pages/taskflow_page.dart';
import 'app_routes.dart';

/// Tabla de rutas y generador de rutas con argumentos.
class AppRouter {
  AppRouter._();

  /// Rutas estáticas (no necesitan argumentos ni devuelven datos).
  static final Map<String, WidgetBuilder> routes = {
    AppRoutes.login: (_) => const LoginPage(),
    AppRoutes.publicaciones: (_) => const PublicacionesPage(),
    AppRoutes.home: (_) => const TaskflowPage(),
    AppRoutes.habitos: (_) => const HabitosPage(),
    AppRoutes.perfil: (_) => const PerfilPage(),
    AppRoutes.tareasRemotas: (_) => const TareasRemotasPage(),
    AppRoutes.laboratorio: (_) => const LaboratorioAsyncPage(),
  };

  /// Rutas dinámicas: /tarea recibe el id; /tarea/nueva un Task? opcional;
  /// /registro devuelve un String (el correo) con pop.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == AppRoutes.tarea) {
      final taskId = settings.arguments as String?;
      if (taskId == null) {
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

    if (settings.name == AppRoutes.nuevaTarea) {
      final args = settings.arguments;
      final inicial = args is Task ? args : null; // null = crear
      return MaterialPageRoute<Task>(
        settings: settings,
        builder: (_) => NuevaTareaPage(inicial: inicial),
      );
    }

    // CAMBIO (Semana 15): <String> declara el tipo que Registro devuelve
    // con pop. Sin él, pushNamed<String> fallaría en tiempo de ejecución.
    if (settings.name == AppRoutes.registro) {
      return MaterialPageRoute<String>(
        settings: settings,
        builder: (_) => const RegistroPage(),
      );
    }

    return null; // Ruta no reconocida -> onUnknownRoute
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => const ErrorPage());
  }
}
