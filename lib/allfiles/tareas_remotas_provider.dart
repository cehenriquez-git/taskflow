import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../data/tareas_api.dart';
import '../../domain/task.dart';

/// Un único cliente HTTP para toda la app; se cierra al destruir el provider.
final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final tareasApiProvider = Provider<TareasApi>((ref) {
  return TareasApi(ref.watch(httpClientProvider));
});

/// Estado asíncrono (cargando / datos / error) de las tareas del servidor.
class TareasRemotasNotifier extends AsyncNotifier<List<Task>> {
  /// Carga inicial: Riverpod pone el estado en "cargando" automáticamente
  /// y lo cambia a "datos" o "error" cuando el Future termina.
  @override
  Future<List<Task>> build() {
    return ref.watch(tareasApiProvider).obtenerTareas();
  }

  /// Recarga manual (botón "Reintentar" o gesto de deslizar).
  Future<void> recargar() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(tareasApiProvider).obtenerTareas(),
    );
  }

  /// Envía una tarea al servidor y la agrega a la lista.
  /// Si falla, la excepción llega a la pantalla y la lista NO se pierde
  /// (por eso no se usa AsyncValue.guard aquí).
  Future<Task> crear(Task tarea) async {
    final creada = await ref.read(tareasApiProvider).crearTarea(tarea);
    state = AsyncData([...state.value ?? <Task>[], creada]);
    return creada;
  }
}

final tareasRemotasProvider =
    AsyncNotifierProvider<TareasRemotasNotifier, List<Task>>(
  TareasRemotasNotifier.new,
);
