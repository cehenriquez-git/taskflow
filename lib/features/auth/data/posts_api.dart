import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../taskflow/data/tareas_api.dart' show ApiException;
import '../domain/post.dart';

/// Toda la comunicación HTTP de las publicaciones vive aquí. Las pantallas
/// nunca usan `http`; aquí también se traducen los errores técnicos a
/// mensajes comprensibles (ApiException).
class PostsApi {
  PostsApi(this._client);

  final http.Client _client;
  static const _host = 'jsonplaceholder.typicode.com';
  static const _limite = Duration(seconds: 10);

  /// GET /posts?_page=N&_limit=M
  Future<List<Post>> obtenerPosts({
    required int pagina,
    required int limite,
  }) async {
    final uri = Uri.https(_host, '/posts', {
      '_page': '$pagina',
      '_limit': '$limite',
    });

    final respuesta = await _enviar(() => _client.get(uri));

    if (respuesta.statusCode != 200) {
      throw ApiException(
        'El servidor respondió con un error (${respuesta.statusCode}).',
        codigo: respuesta.statusCode,
      );
    }

    final Object? datos;
    try {
      datos = jsonDecode(respuesta.body);
    } on FormatException {
      throw const ApiException(
        'El servidor envió una respuesta que no es JSON válido.',
      );
    }
    if (datos is! List) {
      throw const ApiException(
        'La respuesta del servidor no tiene el formato esperado.',
      );
    }

    final posts = <Post>[];
    for (final item in datos) {
      if (item is! Map<String, dynamic>) continue;
      try {
        posts.add(Post.fromJson(item));
      } on FormatException {
        // Un post defectuoso no impide mostrar los demás.
      }
    }
    return posts;
  }

  Future<http.Response> _enviar(
    Future<http.Response> Function() peticion,
  ) async {
    try {
      return await peticion().timeout(_limite);
    } on TimeoutException {
      throw const ApiException(
        'El servidor tardó demasiado en responder. Intenta de nuevo.',
      );
    } on http.ClientException {
      throw const ApiException(
        'No fue posible conectar con el servidor. Revisa tu conexión a internet.',
      );
    }
  }
}
