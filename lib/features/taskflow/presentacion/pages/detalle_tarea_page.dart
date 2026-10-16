import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/task.dart';
import '../providers/tasks_provider.dart';
import '../widgets/priority_chip.dart';

/// Detalle de tarea (ruta '/tarea'). Recibe solo el id y lee la tarea EN VIVO
/// desde Riverpod con taskByIdProvider. Incluye modo edición (misma pantalla).
class DetalleTareaPage extends ConsumerStatefulWidget {
  final String taskId;

  const DetalleTareaPage({super.key, required this.taskId});

  @override
  ConsumerState<DetalleTareaPage> createState() => _DetalleTareaPageState();
}

class _DetalleTareaPageState extends ConsumerState<DetalleTareaPage> {
  final _titleCtrl = TextEditingController();
  final _metaCtrl = TextEditingController();
  Priority _priority = Priority.media;
  bool _editing = false;
  bool _deleted = false; // evita el parpadeo "no existe" al eliminar

  @override
  void dispose() {
    _titleCtrl.dispose();
    _metaCtrl.dispose();
    super.dispose();
  }

  void _startEdit(Task task) {
    _titleCtrl.text = task.title;
    _metaCtrl.text = task.meta;
    setState(() {
      _priority = task.priority;
      _editing = true;
    });
  }

  void _save() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    final meta = _metaCtrl.text.trim();
    ref.read(tasksProvider.notifier).update(
          widget.taskId,
          title: title,
          meta: meta.isEmpty ? 'Hoy' : meta,
          priority: _priority,
        );
    setState(() => _editing = false);
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
        title: Text(_editing ? 'Editar tarea' : 'Detalle de tarea'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primaryDark,
        actions: [
          if (_editing)
            IconButton(
              tooltip: 'Cancelar',
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _editing = false),
            ),
          IconButton(
            tooltip: _editing ? 'Guardar' : 'Editar',
            icon: Icon(_editing ? Icons.check : Icons.edit_outlined),
            onPressed: _editing ? _save : () => _startEdit(task),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.margin),
        children: _editing ? _buildEditor() : _buildView(task),
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

  List<Widget> _buildEditor() {
    return [
      TextField(
        controller: _titleCtrl,
        minLines: 1,
        maxLines: 3,
        decoration: const InputDecoration(labelText: 'Título'),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _metaCtrl,
        decoration: const InputDecoration(
          labelText: 'Detalle (ej. Hoy · Universidad)',
        ),
      ),
      const SizedBox(height: 16),
      Wrap(
        spacing: 8,
        children: [
          for (final p in Priority.values)
            ChoiceChip(
              label: Text(p.label),
              selected: _priority == p,
              onSelected: (_) => setState(() => _priority = p),
            ),
        ],
      ),
      const SizedBox(height: 24),
      FilledButton(onPressed: _save, child: const Text('Guardar cambios')),
    ];
  }
}
