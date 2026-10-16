import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/task.dart';

/// Notifier que centraliza TODO el estado de la lista de tareas.
class TasksNotifier extends Notifier<List<Task>> {
  @override
  List<Task> build() => const [
        Task(
          id: '1',
          title:
              'Terminar el laboratorio de layouts y composición visual del curso',
          meta: 'Hoy · Universidad',
          priority: Priority.alta,
        ),
        Task(
          id: '2',
          title: 'Revisar los pull requests',
          meta: 'Hoy · Trabajo',
          priority: Priority.media,
          done: true,
        ),
        Task(
          id: '3',
          title: 'Leer la documentación',
          meta: 'Mañana · Aprendizaje',
          priority: Priority.baja,
        ),
      ];

  void add({
    required String title,
    required String meta,
    required Priority priority,
  }) {
    final task = Task(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      meta: meta,
      priority: priority,
    );
    state = [...state, task];
  }

  void toggle(String id) {
    state = [
      for (final t in state)
        if (t.id == id) t.copyWith(done: !t.done) else t,
    ];
  }

  /// NUEVO: edición de una tarea (la usa el modo edición del detalle).
  void update(
    String id, {
    String? title,
    String? meta,
    Priority? priority,
  }) {
    state = [
      for (final t in state)
        if (t.id == id)
          t.copyWith(title: title, meta: meta, priority: priority)
        else
          t,
    ];
  }

  void remove(String id) {
    state = state.where((t) => t.id != id).toList();
  }
}

final tasksProvider =
    NotifierProvider<TasksNotifier, List<Task>>(TasksNotifier.new);

/// NUEVO: provider derivado parametrizado (Provider.family).
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

// NOTA: se eliminó navIndexProvider. Ahora la ruta actual determina qué
// pestaña está seleccionada (cada pantalla indica su propio currentIndex).
