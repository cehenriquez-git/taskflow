import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/tareas_api.dart';
import '../../domain/task.dart';
import '../providers/tareas_remotas_provider.dart';
import '../widgets/priority_chip.dart';

/// Pantalla «Tareas en la nube» (ruta '/nube').
/// `AsyncValue.when` obliga a escribir las tres ramas: ninguna queda en blanco.
class TareasRemotasPage extends ConsumerWidget {
  const TareasRemotasPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTareas = ref.watch(tareasRemotasProvider);
    final notifier = ref.read(tareasRemotasProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tareas en la nube'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primaryDark,
      ),
      body: asyncTareas.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _VistaError(
          mensaje: error is ApiException
              ? error.mensaje
              : 'Ocurrió un error inesperado.',
          onReintentar: notifier.recargar,
        ),
        data: (tareas) => RefreshIndicator(
          onRefresh: notifier.recargar, // deslizar hacia abajo para recargar
          child: tareas.isEmpty
              ? ListView(
                  children: const [
                    SizedBox(height: 120),
                    Center(child: Text('El servidor no tiene tareas.')),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.margin,
                    AppDimensions.margin,
                    AppDimensions.margin,
                    88, // espacio para el FAB
                  ),
                  itemCount: tareas.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppDimensions.gap),
                  itemBuilder: (context, i) => _TareaRemotaTile(task: tareas[i]),
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.cloud_upload),
        label: const Text('Nueva tarea'),
        onPressed: () => _crearTarea(context, ref),
      ),
    );
  }

  Future<void> _crearTarea(BuildContext context, WidgetRef ref) async {
    // Reutilizamos el formulario de la Semana 13 sin modificarlo:
    // devuelve una Task ya validada con Navigator.pop.
    final nueva =
        await Navigator.of(context).pushNamed<Task>(AppRoutes.nuevaTarea);
    if (nueva == null || !context.mounted) return;

    // Se obtiene ANTES del siguiente await: así, aunque el usuario salga de
    // la pantalla mientras se envía, el aviso no usa un context desmontado.
    final mensajero = ScaffoldMessenger.of(context);
    mensajero.showSnackBar(const SnackBar(content: Text('Enviando tarea...')));

    try {
      final creada =
          await ref.read(tareasRemotasProvider.notifier).crear(nueva);
      mensajero
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Tarea "${creada.title}" creada (id ${creada.remoteId ?? '-'}).',
            ),
          ),
        );
    } on ApiException catch (e) {
      mensajero
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(e.mensaje)));
    }
  }
}

class _TareaRemotaTile extends StatelessWidget {
  const _TareaRemotaTile({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.taskCardPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.taskCardRadius),
        border: Border.all(color: AppColors.chipBg),
      ),
      child: Row(
        children: [
          Icon(
            task.done ? Icons.check_circle : Icons.radio_button_unchecked,
            color: task.done ? AppColors.primaryDark : AppColors.textMuted,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                    decoration: task.done ? TextDecoration.lineThrough : null,
                    decorationColor: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  task.remoteId == null ? 'Sin id' : 'id ${task.remoteId}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          PriorityChip(priority: task.priority),
        ],
      ),
    );
  }
}

class _VistaError extends StatelessWidget {
  const _VistaError({required this.mensaje, required this.onReintentar});

  final String mensaje;
  final Future<void> Function() onReintentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(mensaje, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onReintentar,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
