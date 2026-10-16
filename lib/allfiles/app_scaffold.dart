import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import 'app_bars.dart';

/// Estructura común de las tres pantallas principales:
/// TopBar + contenido + BottomBar con navegación por rutas.
class AppScaffold extends StatelessWidget {
  final String title;
  final int currentIndex;
  final Widget body;
  final Widget? floatingActionButton;

  const AppScaffold({
    super.key,
    required this.title,
    required this.currentIndex,
    required this.body,
    this.floatingActionButton,
  });

  static const _destinations = [
    BottomDestination(icon: Icons.list_alt, label: 'Tareas'),
    BottomDestination(icon: Icons.water_drop_outlined, label: 'Hábitos'),
    BottomDestination(icon: Icons.person_outline, label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            TopBar(title: title, avatarLetter: 'C'),
            Expanded(child: body),
          ],
        ),
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: BottomBar(
        destinations: _destinations,
        currentIndex: currentIndex,
        onTap: (i) => AppRoutes.goToTab(context, i, current: currentIndex),
      ),
    );
  }
}
