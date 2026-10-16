import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validadores_tarea.dart';
import '../../domain/task.dart';

/// Formulario de tarea (ruta '/tarea/nueva').
///
/// - Sin argumentos: crea una tarea nueva.
/// - Con [inicial]: modo edición (mismo formulario, campos precargados).
///
/// Patrón "Opción B": la pantalla NO conoce Riverpod. Valida y devuelve la
/// tarea con Navigator.pop(context, tarea); quien la abrió decide qué hacer.
/// Si el usuario vuelve sin guardar, el resultado es null.
class NuevaTareaPage extends StatefulWidget {
  final Task? inicial;

  const NuevaTareaPage({super.key, this.inicial});

  @override
  State<NuevaTareaPage> createState() => _NuevaTareaPageState();
}

class _NuevaTareaPageState extends State<NuevaTareaPage> {
  // Estado EFÍMERO: vive y muere con esta pantalla.
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _fechaCtrl = TextEditingController();
  final _descripcionFocus = FocusNode();

  DateTime? _fechaLimite;
  Priority _prioridad = Priority.media;
  String _categoria = 'General';

  static const _categoriasBase = ['General', 'Estudio', 'Trabajo', 'Personal'];
  late final List<String> _categorias;

  bool get _esEdicion => widget.inicial != null;

  @override
  void initState() {
    super.initState();
    _categorias = [..._categoriasBase];

    final t = widget.inicial;
    if (t != null) {
      _tituloCtrl.text = t.title;
      _descripcionCtrl.text = t.description;
      _fechaLimite = t.dueDate;
      _fechaCtrl.text = Task.formatDate(t.dueDate);
      _prioridad = t.priority;
      _categoria = t.category;
      // Por si la tarea trae una categoría que no está en la lista base.
      if (!_categorias.contains(t.category)) _categorias.add(t.category);
    }
  }

  // Todo lo que creamos y tiene dispose(), lo liberamos (4 creados = 4 liberados).
  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    _fechaCtrl.dispose();
    _descripcionFocus.dispose();
    super.dispose();
  }

  /// Selector de fecha: impide elegir días pasados desde la interfaz.
  Future<void> _elegirFecha() async {
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);

    // En edición la fecha guardada puede estar vencida; initialDate nunca
    // puede ser anterior a firstDate (showDatePicker lanzaría una aserción).
    final actual = _fechaLimite;
    final inicial = (actual != null && !actual.isBefore(hoy)) ? actual : hoy;

    final elegida = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: hoy,
      lastDate: DateTime(hoy.year + 2),
      helpText: 'Fecha límite de la tarea',
    );
    if (elegida == null || !mounted) return; // canceló o la pantalla ya no existe
    setState(() {
      _fechaLimite = elegida; // primero la fuente de verdad…
      _fechaCtrl.text = Task.formatDate(elegida); // …luego el texto mostrado
    });
  }

  /// Valida todo y DEVUELVE la tarea a quien abrió la pantalla.
  void _guardar() {
    if (!_formKey.currentState!.validate()) return;

    final base = widget.inicial;
    final tarea = Task(
      id: base?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: _tituloCtrl.text.trim(),
      description: _descripcionCtrl.text.trim(),
      dueDate: _fechaLimite!, // seguro: el validador ya lo exigió
      category: _categoria,
      priority: _prioridad,
      done: base?.done ?? false,
    );
    Navigator.of(context).pop(tarea);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar tarea' : 'Nueva tarea'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primaryDark,
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        // ListView y no Column: con teclado abierto o texto ampliado el
        // formulario se desplaza sin overflow.
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Título: obligatorio, contador visible, foco al siguiente campo.
            TextFormField(
              controller: _tituloCtrl,
              autofocus: !_esEdicion,
              decoration: const InputDecoration(
                labelText: 'Título *',
                helperText: 'Obligatorio, entre 3 y 60 caracteres',
                border: OutlineInputBorder(),
              ),
              maxLength: ValidadoresTarea.tituloMax,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _descripcionFocus.requestFocus(),
              validator: ValidadoresTarea.titulo,
            ),
            const SizedBox(height: 12),

            // Descripción: opcional, varias líneas (Enter = salto de línea).
            TextFormField(
              controller: _descripcionCtrl,
              focusNode: _descripcionFocus,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              minLines: 2,
              maxLines: 4,
              maxLength: ValidadoresTarea.descripcionMax,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              validator: ValidadoresTarea.descripcion,
            ),
            const SizedBox(height: 12),

            // Fecha: campo de solo lectura que abre el calendario.
            // El validador ignora el texto y valida _fechaLimite (fuente de verdad).
            TextFormField(
              controller: _fechaCtrl,
              readOnly: true,
              onTap: _elegirFecha,
              decoration: const InputDecoration(
                labelText: 'Fecha límite *',
                hintText: 'Toca para elegir',
                helperText: 'Obligatoria, no puede ser anterior a hoy',
                suffixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              validator: (_) => ValidadoresTarea.fechaLimite(_fechaLimite),
            ),
            const SizedBox(height: 12),

            // Prioridad y categoría: opciones cerradas → no hay error posible.
            DropdownButtonFormField<Priority>(
              // Si tu Flutter es anterior a 3.33 y el analizador marca error,
              // cambia `initialValue` por `value`.
              initialValue: _prioridad,
              decoration: const InputDecoration(
                labelText: 'Prioridad',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final p in Priority.values)
                  DropdownMenuItem(value: p, child: Text(p.label)),
              ],
              onChanged: (valor) =>
                  setState(() => _prioridad = valor ?? Priority.media),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _categoria,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final c in _categorias)
                  DropdownMenuItem(value: c, child: Text(c)),
              ],
              onChanged: (valor) =>
                  setState(() => _categoria = valor ?? 'General'),
            ),
            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _guardar,
              icon: const Icon(Icons.check),
              label: Text(_esEdicion ? 'Guardar cambios' : 'Guardar tarea'),
            ),
          ],
        ),
      ),
    );
  }
}
