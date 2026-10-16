import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/task.dart';
import '../providers/tasks_provider.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/header_card.dart';
import '../widgets/quote_card.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_card.dart';
import '../widgets/task_card.dart';

/// Pantalla «Resumen del día» (ruta '/').
class TaskflowPage extends ConsumerWidget {
  const TaskflowPage({super.key});

  /// Abre el formulario y recibe la tarea creada (o null si el usuario
  /// volvió sin guardar). Solo entonces la tarea entra a Riverpod.
  Future<void> _abrirNuevaTarea(BuildContext context, WidgetRef ref) async {
    final nueva =
        await Navigator.of(context).pushNamed<Task>(AppRoutes.nuevaTarea);

    // El usuario presionó "atrás" sin guardar: no hay nada que hacer.
    if (nueva == null) return;

    // ref.read (no watch): estamos dentro de un callback.
    ref.read(tasksProvider.notifier).add(nueva);

    // Safe-await: comprobar que el contexto siga montado antes de usarlo.
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tarea "${nueva.title}" creada')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);
    final total = ref.watch(totalTasksProvider);
    final completed = ref.watch(completedTasksProvider);
    final pending = ref.watch(pendingTasksProvider);
    final progress = ref.watch(progressProvider);

    return AppScaffold(
      title: 'TaskFlow',
      currentIndex: 0,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nueva tarea'),
        onPressed: () => _abrirNuevaTarea(context, ref),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 88), // espacio para el FAB extendido
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            HeaderCard(
              greeting: 'Buenos días, Cristian',
              date: 'Viernes 28 de agosto',
              subtitle:
                  '$pending ${pending == 1 ? 'tarea pendiente' : 'tareas pendientes'} para hoy',
              progress: progress,
            ),
            const SizedBox(height: 46),
            _buildStatsRow(total: total, completed: completed),
            const SizedBox(height: 24),
            SectionHeader(
              title: 'Tareas de hoy',
              actionLabel: 'Ver todas',
              onAction: () {},
            ),
            const SizedBox(height: AppDimensions.gap),
            ..._buildTaskList(context, ref, tasks),
            const SizedBox(height: AppDimensions.gap),
            const QuoteCard(
              quote:
                  'La disciplina es el puente entre las metas y los logros que realmente importan.',
              author: 'Jim Rohn',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow({required int total, required int completed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.margin),
      child: Row(
        children: [
          Expanded(child: StatCard(value: '$total', label: 'Tareas')),
          const SizedBox(width: AppDimensions.gap),
          Expanded(child: StatCard(value: '$completed', label: 'Completadas')),
          const SizedBox(width: AppDimensions.gap),
          const Expanded(child: StatCard(value: '5', label: 'Racha semanal')),
        ],
      ),
    );
  }

  List<Widget> _buildTaskList(
    BuildContext context,
    WidgetRef ref,
    List<Task> tasks,
  ) {
    if (tasks.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.margin),
          child: Text(
            'No tienes tareas. Toca "Nueva tarea" para agregar una.',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      ];
    }

    final notifier = ref.read(tasksProvider.notifier);

    return List.generate(tasks.length, (i) {
      final task = tasks[i];
      return Padding(
        padding: EdgeInsets.only(
          left: AppDimensions.margin,
          right: AppDimensions.margin,
          bottom: i == tasks.length - 1 ? 0 : AppDimensions.gap,
        ),
        child: Dismissible(
          key: ValueKey(task.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => notifier.remove(task.id),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(AppDimensions.taskCardRadius),
            ),
            child: const Icon(Icons.delete_outline, color: AppColors.white),
          ),
          // Tocar la tarjeta abre el detalle; se envía SOLO el id.
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context)
                .pushNamed(AppRoutes.tarea, arguments: task.id),
            child: TaskCard(
              task: task,
              onToggle: () => notifier.toggle(task.id),
            ),
          ),
        ),
      );
    });
  }
}
