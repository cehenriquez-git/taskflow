import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/taskflow/presentacion/pages/taskflow_page.dart';

void main() => runApp(const TaskFlowApp());

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
