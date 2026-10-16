import 'package:flutter/material.dart';

/// Nombres de las rutas de TaskFlow (un solo lugar, sin "strings sueltos").
///
/// Mapa de pantallas:
///   /              -> Listado de tareas (pantalla inicial)
///   /tarea         -> Detalle de tarea (recibe un id como argumento)
///   /tarea/nueva   -> Formulario de tarea (sin argumentos = crear;
///                     con una Task como argumento = editar). Devuelve la
///                     Task validada con Navigator.pop, o null si se cancela.
///   /habitos       -> Hábitos (rama independiente)
///   /perfil        -> Perfil (rama independiente)
///   /nube          -> Tareas en la nube (API REST, Semana 14)
///   /laboratorio   -> Laboratorio de asincronía (Semana 14)
class AppRoutes {
  AppRoutes._();

  static const home = '/';
  static const habitos = '/habitos';
  static const perfil = '/perfil';
  static const tarea = '/tarea';
  static const nuevaTarea = '/tarea/nueva';
  static const tareasRemotas = '/nube';
  static const laboratorio = '/laboratorio';

  // Orden = destinos de la barra inferior (Tareas, Hábitos, Perfil).
  static const _tabs = [home, habitos, perfil];

  /// Cambia de pestaña. Usa pushReplacementNamed para que la pila no crezca
  /// cada vez que se toca la barra inferior.
  static void goToTab(
    BuildContext context,
    int index, {
    required int current,
  }) {
    if (index == current) return;
    Navigator.of(context).pushReplacementNamed(_tabs[index]);
  }
}
