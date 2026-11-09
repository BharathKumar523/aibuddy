import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Answers Dio requests from a table of canned responses keyed by
/// "METHOD /path", and records every request, so repositories can be tested
/// against the real ApiClient without a server.
class StubHttpAdapter implements HttpClientAdapter {
  StubHttpAdapter(this.routes);

  /// e.g. `{'POST /auth/login': (200, {'success': true, 'data': {...}})}`
  final Map<String, (int, Object?)> routes;
  final List<RequestOptions> requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final route = routes['${options.method} ${options.path}'];
    if (route == null) {
      return ResponseBody.fromString(
        jsonEncode(<String, dynamic>{
          'success': false,
          'error': <String, dynamic>{'code': 'NOT_FOUND', 'message': 'No stub'},
        }),
        404,
        headers: <String, List<String>>{
          Headers.contentTypeHeader: <String>[Headers.jsonContentType],
        },
      );
    }
    final (status, body) = route;
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
