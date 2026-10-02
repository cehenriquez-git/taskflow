import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/taskflow/presentacion/pages/taskflow_page.dart';

// CAMBIO (Guía 5): la app se envuelve en ProviderScope, que es el contenedor
// donde viven todos los providers de Riverpod.
void main() => runApp(const ProviderScope(child: TaskFlowApp()));

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const TaskflowPage(),
    );
  }
}
