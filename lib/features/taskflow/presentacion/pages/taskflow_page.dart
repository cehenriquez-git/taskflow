import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/task.dart';
import '../providers/tasks_provider.dart';
import '../widgets/add_task_dialog.dart';
import '../widgets/app_bars.dart';
import '../widgets/header_card.dart';
import '../widgets/quote_card.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_card.dart';
import '../widgets/task_card.dart';

/// Pantalla «Resumen del día» de TaskFlow.
///
/// ANTES: StatefulWidget con `_tasks`, `_navIndex` y setState.
/// AHORA: ConsumerWidget sin estado propio; lee providers con `ref.watch`.
class TaskflowPage extends ConsumerWidget {
  const TaskflowPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watch => la pantalla se reconstruye sola cuando cambian estos valores.
    final tasks = ref.watch(tasksProvider);
    final total = ref.watch(totalTasksProvider);
    final completed = ref.watch(completedTasksProvider);
    final pending = ref.watch(pendingTasksProvider);
    final progress = ref.watch(progressProvider);
    final navIndex = ref.watch(navIndexProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const TopBar(title: 'TaskFlow', avatarLetter: 'A'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
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
                    // Aire por la insignia superpuesta (ø76 / 2 + margen).
                    const SizedBox(height: 46),
                    _buildStatsRow(total: total, completed: completed),
                    const SizedBox(height: 24),
                    SectionHeader(
                      title: 'Tareas de hoy',
                      actionLabel: 'Ver todas',
                      onAction: () {},
                    ),
                    const SizedBox(height: AppDimensions.gap),
                    ..._buildTaskList(ref, tasks),
                    const SizedBox(height: AppDimensions.gap),
                    const QuoteCard(
                      quote: 'La disciplina es el puente entre las metas y los logros que realmente importan.',
                      author: 'Jim Rohn',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
        onPressed: () => showDialog<void>(
          context: context,
          builder: (_) => const AddTaskDialog(),
        ),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomBar(
        currentIndex: navIndex,
        // read => dentro de un callback solo se ejecuta una acción.
        onTap: (i) => ref.read(navIndexProvider.notifier).select(i),
        destinations: const [
          BottomDestination(icon: Icons.list_alt, label: 'Tareas'),
          BottomDestination(icon: Icons.water_drop_outlined, label: 'Hábitos'),
          BottomDestination(icon: Icons.person_outline, label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildStatsRow({required int total, required int completed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.margin),
      child: Row(
        children: [
          Expanded(
            child: StatCard(value: '$total', label: 'Tareas'),
          ),
          const SizedBox(width: AppDimensions.gap),
          Expanded(
            child: StatCard(value: '$completed', label: 'Completadas'),
          ),
          const SizedBox(width: AppDimensions.gap),
          // La racha aún no tiene lógica; se mantiene fija.
          const Expanded(
            child: StatCard(value: '5', label: 'Racha semanal'),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTaskList(WidgetRef ref, List<Task> tasks) {
    if (tasks.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.margin),
          child: Text(
            'No tienes tareas. Toca + para agregar una.',
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
        // Deslizar hacia la izquierda elimina la tarea.
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
          child: TaskCard(task: task, onToggle: () => notifier.toggle(task.id)),
        ),
      );
    });
  }
}
