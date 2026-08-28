import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../domain/task.dart';
import '../widgets/app_bars.dart';
import '../widgets/header_card.dart';
import '../widgets/quote_card.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_card.dart';
import '../widgets/task_card.dart';

/// Pantalla «Resumen del día» de TaskFlow.
class TaskflowPage extends StatefulWidget {
  const TaskflowPage({super.key});

  @override
  State<TaskflowPage> createState() => _TaskflowPageState();
}

class _TaskflowPageState extends State<TaskflowPage> {
  int _navIndex = 0;

  // Datos de ejemplo. En una app real vendrían de la capa data/domain.
  final List<Task> _tasks = [
    const Task(
      title:
          'Terminar el laboratorio de layouts y composición visual del curso',
      meta: 'Hoy · Universidad',
      priority: Priority.alta,
    ),
    const Task(
      title: 'Revisar los pull requests',
      meta: 'Hoy · Trabajo',
      priority: Priority.media,
      done: true,
    ),
    const Task(
      title: 'Leer la documentación',
      meta: 'Mañana · Aprendizaje',
      priority: Priority.baja,
    ),
  ];

  void _toggle(int index) {
    setState(() {
      _tasks[index] = _tasks[index].copyWith(done: !_tasks[index].done);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    const HeaderCard(
                      greeting: 'Buenos días, Cristian',
                      date: 'Viernes 28 de agosto',
                      subtitle: '3 tareas pendientes para hoy',
                      progress: 0.60,
                    ),
                    // Aire por la insignia superpuesta (ø76 / 2 + margen).
                    const SizedBox(height: 46),
                    _buildStatsRow(),
                    const SizedBox(height: 24),
                    SectionHeader(
                      title: 'Tareas de hoy',
                      actionLabel: 'Ver todas',
                      onAction: () {},
                    ),
                    const SizedBox(height: AppDimensions.gap),
                    ..._buildTaskList(),
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
      bottomNavigationBar: BottomBar(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
        destinations: const [
          BottomDestination(icon: Icons.list_alt, label: 'Tareas'),
          BottomDestination(icon: Icons.water_drop_outlined, label: 'Hábitos'),
          BottomDestination(icon: Icons.person_outline, label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.margin),
      child: Row(
        children: [
          Expanded(
            child: StatCard(value: '12', label: 'Tareas'),
          ),
          SizedBox(width: AppDimensions.gap),
          Expanded(
            child: StatCard(value: '7', label: 'Completadas'),
          ),
          SizedBox(width: AppDimensions.gap),
          Expanded(
            child: StatCard(value: '5', label: 'Racha semanal'),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTaskList() {
    return List.generate(_tasks.length, (i) {
      return Padding(
        padding: EdgeInsets.only(
          left: AppDimensions.margin,
          right: AppDimensions.margin,
          bottom: i == _tasks.length - 1 ? 0 : AppDimensions.gap,
        ),
        child: TaskCard(task: _tasks[i], onToggle: () => _toggle(i)),
      );
    });
  }
}
