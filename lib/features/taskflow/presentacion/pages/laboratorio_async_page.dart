import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';

/// Cálculo deliberadamente pesado (CPU), sin ninguna espera.
/// Debe ser una función de nivel superior para poder enviarse a un isolate.
int calculoPesado(int n) {
  var total = 0;
  for (var i = 0; i < n; i++) {
    total += i % 7;
  }
  return total;
}

Future<String> _cargarPerfil() =>
    Future.delayed(const Duration(seconds: 2), () => 'Ana');

Future<int> _cargarPendientes() =>
    Future.delayed(const Duration(seconds: 3), () => 7);

/// Laboratorio de la Sesión 1 (ruta '/laboratorio'):
///  1) Orden de ejecución (event loop)
///  2) Secuencial vs concurrente (Stopwatch)
///  3) Cálculo pesado sin isolate vs con isolate
///
/// El indicador de arriba gira SIEMPRE: si se detiene, la interfaz se congeló.
class LaboratorioAsyncPage extends StatefulWidget {
  const LaboratorioAsyncPage({super.key});

  @override
  State<LaboratorioAsyncPage> createState() => _LaboratorioAsyncPageState();
}

class _LaboratorioAsyncPageState extends State<LaboratorioAsyncPage> {
  // Ajusta según tu equipo: en modo debug es más lento que en release.
  static const _iteraciones = 300000000;

  final _registro = <String>[];
  bool _ocupado = false;

  void _log(String mensaje) {
    debugPrint(mensaje);
    if (!mounted) return;
    setState(() => _registro.insert(0, mensaje));
  }

  String _seg(Stopwatch r) => (r.elapsedMilliseconds / 1000).toStringAsFixed(1);

  /// Envuelve una prueba para bloquear los botones mientras corre.
  Future<void> _ejecutar(Future<void> Function() prueba) async {
    setState(() => _ocupado = true);
    try {
      await prueba();
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  /// Sección 1.3: resultado esperado A, E, C, B, D.
  Future<void> _ordenEjecucion() async {
    final orden = <String>[];
    orden.add('A. inicio');
    Future(() => orden.add('B. evento'));
    scheduleMicrotask(() => orden.add('C. microtarea'));
    Future.delayed(Duration.zero, () => orden.add('D. temporizador 0 ms'));
    orden.add('E. fin');

    // Damos tiempo a que el event loop procese todo.
    await Future.delayed(const Duration(milliseconds: 100));
    _log('Orden: ${orden.join(' → ')}');
  }

  /// Sección 1.7: 5 s secuencial vs 3 s concurrente.
  Future<void> _secuencialVsConcurrente() async {
    final reloj = Stopwatch()..start();

    final perfil = await _cargarPerfil();
    final pendientes = await _cargarPendientes();
    _log('Secuencial: ${_seg(reloj)} s → $perfil, $pendientes');

    reloj
      ..reset()
      ..start();

    // Record (Dart 3): cada valor conserva su tipo.
    final (perfil2, pendientes2) =
        await (_cargarPerfil(), _cargarPendientes()).wait;
    _log('Concurrente: ${_seg(reloj)} s → $perfil2, $pendientes2');
  }

  /// Sección 1.8: sin isolate la pantalla se congela; con isolate no.
  Future<void> _calculo({required bool conIsolate}) async {
    // Una pausa breve para que se pinte el estado "ocupado" antes de bloquear.
    await Future.delayed(const Duration(milliseconds: 100));
    final reloj = Stopwatch()..start();

    final int resultado;
    if (conIsolate) {
      // compute funciona en todas las plataformas (en web corre en el mismo hilo).
      resultado = await compute(calculoPesado, _iteraciones);
    } else {
      // Congela la interfaz durante todo el cálculo.
      resultado = calculoPesado(_iteraciones);
    }

    _log(
      '${conIsolate ? 'CON' : 'SIN'} isolate: ${_seg(reloj)} s '
      '(resultado $resultado)',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laboratorio async'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primaryDark,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.margin),
        children: [
          const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 4),
          const Center(
            child: Text(
              'Si el indicador se detiene, la interfaz se congeló.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _ocupado ? null : () => _ejecutar(_ordenEjecucion),
            child: const Text('1. Orden de ejecución (event loop)'),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed:
                _ocupado ? null : () => _ejecutar(_secuencialVsConcurrente),
            child: const Text('2. Secuencial vs concurrente (≈ 8 s)'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _ocupado
                ? null
                : () => _ejecutar(() => _calculo(conIsolate: false)),
            child: const Text('3a. Cálculo pesado SIN isolate (congela)'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _ocupado
                ? null
                : () => _ejecutar(() => _calculo(conIsolate: true)),
            child: const Text('3b. Cálculo pesado CON isolate'),
          ),
          const SizedBox(height: 24),
          const Text(
            'Resultados (anótalos en tu bitácora)',
            style: TextStyle(
              fontSize: AppDimensions.sectionTitleSize,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          if (_registro.isEmpty)
            const Text(
              'Aún no has ejecutado ninguna prueba.',
              style: TextStyle(color: AppColors.textMuted),
            )
          else
            for (final linea in _registro)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.chipBg),
                  ),
                  child: Text(linea),
                ),
              ),
        ],
      ),
    );
  }
}
