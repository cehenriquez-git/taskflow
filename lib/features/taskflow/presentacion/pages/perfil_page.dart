import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/tasks_provider.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/stat_card.dart';

/// Pantalla básica de Perfil (ruta '/perfil'). Reutiliza los providers
/// derivados para mostrar el resumen de tareas.
class PerfilPage extends ConsumerWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = ref.watch(totalTasksProvider);
    final completed = ref.watch(completedTasksProvider);
    final pending = ref.watch(pendingTasksProvider);

    return AppScaffold(
      title: 'Perfil',
      currentIndex: 2,
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.margin),
        children: [
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 88,
              height: 88,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.primaryDark,
                shape: BoxShape.circle,
              ),
              child: const Text(
                'C',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Cristian',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: StatCard(value: '$total', label: 'Tareas')),
              const SizedBox(width: AppDimensions.gap),
              Expanded(
                child: StatCard(value: '$completed', label: 'Completadas'),
              ),
              const SizedBox(width: AppDimensions.gap),
              Expanded(child: StatCard(value: '$pending', label: 'Pendientes')),
            ],
          ),
        ],
      ),
    );
  }
}
