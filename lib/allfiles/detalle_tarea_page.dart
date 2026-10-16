import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/task.dart';
import '../providers/tasks_provider.dart';
import '../widgets/priority_chip.dart';

/// Detalle de tarea (ruta '/tarea'). Recibe solo el id y lee la tarea EN VIVO
/// desde Riverpod con taskByIdProvider.
///
/// CAMBIO (Formularios): la edición ya no es inline; reutiliza el formulario
/// validado (NuevaTareaPage con `inicial`) y recibe la tarea editada con pop.
class DetalleTareaPage extends ConsumerStatefulWidget {
  final String taskId;

  const DetalleTareaPage({super.key, required this.taskId});

  @override
  ConsumerState<DetalleTareaPage> createState() => _DetalleTareaPageState();
}

class _DetalleTareaPageState extends ConsumerState<DetalleTareaPage> {
  bool _deleted = false; // evita el parpadeo "no existe" al eliminar

  Future<void> _editar(Task task) async {
    final editada = await Navigator.of(context)
        .pushNamed<Task>(AppRoutes.nuevaTarea, arguments: task);

    // Safe-await: el usuario pudo volver sin guardar (null) o cerrar la pantalla.
    if (editada == null || !mounted) return;
    ref.read(tasksProvider.notifier).update(editada);
  }

  void _delete() {
    final notifier = ref.read(tasksProvider.notifier);
    _deleted = true;
    Navigator.of(context).pop();
    notifier.remove(widget.taskId);
  }

  @override
  Widget build(BuildContext context) {
    final task = ref.watch(taskByIdProvider(widget.taskId));

    if (task == null) {
      if (_deleted) return const Scaffold();
      return Scaffold(
        appBar: AppBar(title: const Text('Tarea no encontrada')),
        body: const Center(child: Text('Esta tarea ya no existe.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de tarea'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primaryDark,
        actions: [
          IconButton(
            tooltip: 'Editar',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _editar(task),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.margin),
        children: _buildView(task),
      ),
    );
  }

  List<Widget> _buildView(Task task) {
    return [
      Text(
        task.title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
          decoration: task.done ? TextDecoration.lineThrough : null,
        ),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          PriorityChip(priority: task.priority),
          const SizedBox(width: 12),
          const Icon(
            Icons.calendar_today_outlined,
            size: 14,
            color: AppColors.textMuted,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              task.meta,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ),
        ],
      ),
      if (task.description.isNotEmpty) ...[
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimensions.taskCardPadding),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppDimensions.taskCardRadius),
            border: Border.all(color: AppColors.chipBg),
          ),
          child: Text(
            task.description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
      const SizedBox(height: 24),
      Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.taskCardRadius),
          border: Border.all(color: AppColors.chipBg),
        ),
        child: SwitchListTile(
          title: const Text('Completada'),
          value: task.done,
          activeThumbColor: AppColors.primaryDark,
          onChanged: (_) =>
              ref.read(tasksProvider.notifier).toggle(widget.taskId),
        ),
      ),
      const SizedBox(height: 24),
      OutlinedButton.icon(
        onPressed: _delete,
        icon: const Icon(Icons.delete_outline),
        label: const Text('Eliminar tarea'),
        style: OutlinedButton.styleFrom(foregroundColor: Colors.red.shade600),
      ),
    ];
  }
}
