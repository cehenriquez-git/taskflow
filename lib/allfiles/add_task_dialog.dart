import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/task.dart';
import '../providers/tasks_provider.dart';

/// Diálogo para agregar una tarea. Usa `ref.read(...notifier)` para ejecutar
/// la acción (en callbacks se usa read, no watch).
class AddTaskDialog extends ConsumerStatefulWidget {
  const AddTaskDialog({super.key});

  @override
  ConsumerState<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends ConsumerState<AddTaskDialog> {
  final _titleCtrl = TextEditingController();
  final _metaCtrl = TextEditingController(text: 'Hoy');
  Priority _priority = Priority.media;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _metaCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    final meta = _metaCtrl.text.trim();

    ref
        .read(tasksProvider.notifier)
        .add(
          title: title,
          meta: meta.isEmpty ? 'Hoy' : meta,
          priority: _priority,
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva tarea'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleCtrl,
            autofocus: true,
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
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Agregar')),
      ],
    );
  }
}
