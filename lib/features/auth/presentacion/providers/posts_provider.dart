import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../taskflow/data/tareas_api.dart' show ApiException;
import '../../../taskflow/presentacion/providers/tareas_remotas_provider.dart'
    show httpClientProvider;
import '../../data/posts_api.dart';
import '../../domain/post.dart';

final postsApiProvider = Provider<PostsApi>((ref) {
  return PostsApi(ref.watch(httpClientProvider));
});

/// Datos del listado paginado.
@immutable
class PostsState {
  final List<Post> posts;
  final int pagina; // última página cargada
  final bool hayMas; // false cuando ya no hay más páginas
  final bool cargandoMas; // hay una petición de página en curso
  final String? errorMas; // mensaje si falló la carga de la siguiente página

  const PostsState({
    required this.posts,
    required this.pagina,
    required this.hayMas,
    this.cargandoMas = false,
    this.errorMas,
  });

  PostsState copyWith({
    List<Post>? posts,
    int? pagina,
    bool? hayMas,
    bool? cargandoMas,
    String? errorMas,
    bool limpiarError = false,
  }) {
    return PostsState(
      posts: posts ?? this.posts,
      pagina: pagina ?? this.pagina,
      hayMas: hayMas ?? this.hayMas,
      cargandoMas: cargandoMas ?? this.cargandoMas,
      errorMas: limpiarError ? null : (errorMas ?? this.errorMas),
    );
  }
}

/// Estado de la PRIMERA carga = AsyncValue (cargando / datos / error).
/// Estado de las páginas siguientes = banderas dentro de [PostsState].
class PostsNotifier extends AsyncNotifier<PostsState> {
  static const tamanoPagina = 15;

  @override
  Future<PostsState> build() => _primeraPagina();

  Future<PostsState> _primeraPagina() async {
    final posts = await ref
        .read(postsApiProvider)
        .obtenerPosts(pagina: 1, limite: tamanoPagina);
    return PostsState(
      posts: posts,
      pagina: 1,
      hayMas: posts.length == tamanoPagina,
    );
  }

  /// Botón «Reintentar» ([mostrarCarga] = true) o deslizar para recargar
  /// ([mostrarCarga] = false: el RefreshIndicator ya muestra su propio spinner).
  Future<void> recargar({bool mostrarCarga = true}) async {
    if (mostrarCarga) state = const AsyncLoading();
    state = await AsyncValue.guard(_primeraPagina);
  }

  /// Scroll infinito: pide la siguiente página.
  Future<void> cargarMas({bool reintento = false}) async {
    final actual = state.value;
    if (actual == null) return;
    if (actual.cargandoMas) return; // evita peticiones duplicadas
    if (!actual.hayMas) return; // no hay más páginas
    if (actual.errorMas != null && !reintento) return; // espera al botón

    state = AsyncData(actual.copyWith(cargandoMas: true, limpiarError: true));

    try {
      final siguiente = actual.pagina + 1;
      final nuevos = await ref
          .read(postsApiProvider)
          .obtenerPosts(pagina: siguiente, limite: tamanoPagina);

      final base = state.value ?? actual;
      state = AsyncData(
        base.copyWith(
          posts: [...base.posts, ...nuevos],
          pagina: siguiente,
          hayMas: nuevos.length == tamanoPagina,
          cargandoMas: false,
        ),
      );
    } on ApiException catch (e) {
      // La lista ya cargada NO se pierde: solo se muestra el error al final.
      final base = state.value ?? actual;
      state = AsyncData(
        base.copyWith(cargandoMas: false, errorMas: e.mensaje),
      );
    }
  }
}

final postsProvider =
    AsyncNotifierProvider<PostsNotifier, PostsState>(PostsNotifier.new);
