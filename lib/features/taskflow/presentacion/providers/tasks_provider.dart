import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/task.dart';

/// Notifier que centraliza TODO el estado de la lista de tareas.
/// Antes vivía en `_TaskflowPageState._tasks` (setState); ahora vive aquí y
/// cualquier widget puede leerlo sin pasar por la pantalla.
class TasksNotifier extends Notifier<List<Task>> {
  /// Estado inicial (datos de ejemplo, antes estaban en la pantalla).
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

  /// Agregar. El estado es inmutable: se crea una lista NUEVA.
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

  /// Completar / descompletar.
  void toggle(String id) {
    state = [
      for (final t in state)
        if (t.id == id) t.copyWith(done: !t.done) else t,
    ];
  }

  /// Eliminar.
  void remove(String id) {
    state = state.where((t) => t.id != id).toList();
  }
}

/// Provider principal: expone `List<Task>` y sus operaciones.
final tasksProvider = NotifierProvider<TasksNotifier, List<Task>>(
  TasksNotifier.new,
);

// ---------------------------------------------------------------------------
// Providers derivados: se recalculan solos cuando cambia `tasksProvider`.
// Reemplazan los valores que antes estaban escritos a mano en la pantalla
// ('12', '7', 0.60, '3 tareas pendientes').
// ---------------------------------------------------------------------------

final totalTasksProvider = Provider<int>(
  (ref) => ref.watch(tasksProvider).length,
);

final completedTasksProvider = Provider<int>(
  (ref) => ref.watch(tasksProvider).where((t) => t.done).length,
);

final pendingTasksProvider = Provider<int>(
  (ref) => ref.watch(totalTasksProvider) - ref.watch(completedTasksProvider),
);

final progressProvider = Provider<double>((ref) {
  final total = ref.watch(totalTasksProvider);
  if (total == 0) return 0;
  return ref.watch(completedTasksProvider) / total;
});

// ---------------------------------------------------------------------------
// Índice de la barra inferior (antes `_navIndex` con setState).
// ---------------------------------------------------------------------------

class NavIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) => state = index;
}

final navIndexProvider = NotifierProvider<NavIndexNotifier, int>(
  NavIndexNotifier.new,
);
