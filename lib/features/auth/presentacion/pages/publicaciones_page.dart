import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../taskflow/data/tareas_api.dart' show ApiException;
import '../../domain/post.dart';
import '../providers/auth_provider.dart';
import '../providers/posts_provider.dart';

/// Listado de publicaciones (ruta '/publicaciones').
/// Estados: cargando · datos · error con «Reintentar» · lista vacía,
/// además de pull-to-refresh y scroll infinito.
class PublicacionesPage extends ConsumerStatefulWidget {
  const PublicacionesPage({super.key});

  @override
  ConsumerState<PublicacionesPage> createState() => _PublicacionesPageState();
}

class _PublicacionesPageState extends ConsumerState<PublicacionesPage> {
  final _scroll = ScrollController();

  /// Se pide la siguiente página cuando faltan menos de 300 px para el final.
  static const _umbral = 300.0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_alDesplazar);
  }

  @override
  void dispose() {
    _scroll.dispose(); // todo lo que se crea y tiene dispose() se libera
    super.dispose();
  }

  void _alDesplazar() {
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;
    if (pos.pixels >= pos.maxScrollExtent - _umbral) {
      ref.read(postsProvider.notifier).cargarMas();
    }
  }

  void _cerrarSesion() {
    ref.read(authProvider.notifier).cerrarSesion();
    ref.invalidate(postsProvider); // el siguiente usuario empieza de cero
    // Limpia la pila: «atrás» no regresa al listado.
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncPosts = ref.watch(postsProvider);
    final usuario = ref.watch(authProvider);
    final notifier = ref.read(postsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primaryDark,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Publicaciones',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            if (usuario != null)
              Text(
                'Hola, ${usuario.nombre}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Mis tareas',
            icon: const Icon(Icons.checklist),
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.home),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: _cerrarSesion,
          ),
        ],
      ),
      // Las cuatro ramas de estado de la petición.
      body: asyncPosts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _VistaError(
          mensaje: error is ApiException
              ? error.mensaje
              : 'Ocurrió un error inesperado.',
          onReintentar: notifier.recargar,
        ),
        data: (estado) => RefreshIndicator(
          onRefresh: () => notifier.recargar(mostrarCarga: false),
          child: estado.posts.isEmpty
              ? _VistaVacia(onRecargar: notifier.recargar)
              : ListView.builder(
                  controller: _scroll,
                  // Siempre desplazable: el pull-to-refresh funciona aunque
                  // el contenido no llene la pantalla.
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppDimensions.margin),
                  itemCount: estado.posts.length + 1, // +1 = pie
                  itemBuilder: (context, i) {
                    if (i == estado.posts.length) {
                      return _PieLista(
                        estado: estado,
                        onReintentar: () =>
                            notifier.cargarMas(reintento: true),
                      );
                    }
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppDimensions.gap),
                      child: _PostCard(post: estado.posts[i]),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.taskCardPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.taskCardRadius),
        border: Border.all(color: AppColors.chipBg),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Publicación #${post.id}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            post.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            post.body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Lo que ve el usuario al final de la lista:
/// cargando la siguiente página · error al cargarla · fin de los datos.
class _PieLista extends StatelessWidget {
  const _PieLista({required this.estado, required this.onReintentar});

  final PostsState estado;
  final VoidCallback onReintentar;

  @override
  Widget build(BuildContext context) {
    if (estado.cargandoMas) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (estado.errorMas != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(estado.errorMas!, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onReintentar,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    if (!estado.hayMas) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Estás al día: no hay más publicaciones.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ),
      );
    }
    return const SizedBox(height: 24);
  }
}

class _VistaVacia extends StatelessWidget {
  const _VistaVacia({required this.onRecargar});

  final Future<void> Function() onRecargar;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        const Icon(Icons.inbox_outlined, size: 48, color: AppColors.textMuted),
        const SizedBox(height: 12),
        const Center(child: Text('No hay publicaciones por mostrar.')),
        const SizedBox(height: 16),
        Center(
          child: OutlinedButton.icon(
            onPressed: onRecargar,
            icon: const Icon(Icons.refresh),
            label: const Text('Recargar'),
          ),
        ),
      ],
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
