import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/validadores_tarea.dart';
import '../../domain/task.dart';

/// Notifier que centraliza TODO el estado de la lista de tareas.
///
/// Estado de la APP: aquí solo entran tareas ya validadas. Los borradores
/// del formulario (texto en edición, foco, etc.) son estado efímero y viven
/// en el State de la pantalla.
class TasksNotifier extends Notifier<List<Task>> {
  @override
  List<Task> build() {
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final manana = DateTime(ahora.year, ahora.month, ahora.day + 1);

    return [
      Task(
        id: '1',
        title:
            'Terminar el laboratorio de layouts y composición visual del curso',
        dueDate: hoy,
        category: 'Estudio',
        priority: Priority.alta,
      ),
      Task(
        id: '2',
        title: 'Revisar los pull requests',
        dueDate: hoy,
        category: 'Trabajo',
        priority: Priority.media,
        done: true,
      ),
      Task(
        id: '3',
        title: 'Leer la documentación',
        dueDate: manana,
        category: 'Estudio',
        priority: Priority.baja,
      ),
    ];
  }

  /// Recibe una tarea ya construida por el formulario.
  void add(Task task) {
    // Defensa en profundidad: aunque la UI ya validó, el gestor de estado
    // no acepta datos inválidos de NINGÚN origen (API, almacenamiento, etc.).
    if (!_esValida(task)) return;
    state = [...state, task];
  }

  void toggle(String id) {
    state = [
      for (final t in state)
        if (t.id == id) t.copyWith(done: !t.done) else t,
    ];
  }

  /// Reemplaza la tarea con el mismo id (la usa el modo edición).
  void update(Task task) {
    if (!_esValida(task)) return;
    state = [
      for (final t in state)
        if (t.id == task.id) task else t,
    ];
  }

  void remove(String id) {
    state = state.where((t) => t.id != id).toList();
  }

  bool _esValida(Task t) =>
      ValidadoresTarea.titulo(t.title) == null &&
      ValidadoresTarea.descripcion(t.description) == null;
}

final tasksProvider =
    NotifierProvider<TasksNotifier, List<Task>>(TasksNotifier.new);

/// Provider derivado parametrizado (Provider.family).
/// El detalle lo observa por id, así que se actualiza en vivo si la tarea
/// cambia desde cualquier lugar. Devuelve null si la tarea ya no existe.
final taskByIdProvider = Provider.family<Task?, String>((ref, id) {
  final tasks = ref.watch(tasksProvider);
  for (final t in tasks) {
    if (t.id == id) return t;
  }
  return null;
});

// ---------------------------------------------------------------------------
// Providers derivados para contadores y progreso.
// ---------------------------------------------------------------------------

final totalTasksProvider =
    Provider<int>((ref) => ref.watch(tasksProvider).length);

final completedTasksProvider =
    Provider<int>((ref) => ref.watch(tasksProvider).where((t) => t.done).length);

final pendingTasksProvider = Provider<int>(
  (ref) => ref.watch(totalTasksProvider) - ref.watch(completedTasksProvider),
);

final progressProvider = Provider<double>((ref) {
  final total = ref.watch(totalTasksProvider);
  if (total == 0) return 0;
  return ref.watch(completedTasksProvider) / total;
});
