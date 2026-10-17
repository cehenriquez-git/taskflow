import 'package:flutter/material.dart';

/// Nombres de las rutas de TaskFlow (un solo lugar, sin "strings sueltos").
///
/// Mapa de pantallas:
///   /login          -> Login (pantalla inicial, Semana 15)
///   /registro       -> Registro. Devuelve con Navigator.pop el correo
///                      registrado (String), o null si el usuario vuelve atrás.
///   /publicaciones  -> Listado de posts (API REST con paginación)
///   /              -> Listado de tareas (TaskFlow)
///   /tarea         -> Detalle de tarea (recibe un id como argumento)
///   /tarea/nueva   -> Formulario de tarea (crear / editar)
///   /habitos       -> Hábitos (rama independiente)
///   /perfil        -> Perfil (rama independiente)
///   /nube          -> Tareas en la nube (API REST, Semana 14)
///   /laboratorio   -> Laboratorio de asincronía (Semana 14)
class AppRoutes {
  AppRoutes._();

  // CAMBIO (Semana 15): autenticación y publicaciones.
  static const login = '/login';
  static const registro = '/registro';
  static const publicaciones = '/publicaciones';

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
