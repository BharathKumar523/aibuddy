/// Converts the `data` field of a success envelope into a typed value.
typedef JsonParser<T> = T Function(Object? json);

/// The unwrapped success envelope:
/// `{ "success": true, "data": ..., "meta": {...} }`.
class ApiResponse<T> {
  const ApiResponse({required this.data, this.meta = const <String, dynamic>{}});

  final T data;

  /// Pagination info such as `nextCursor` and `hasMore`. Empty when absent.
  final Map<String, dynamic> meta;
}

/// Casts a decoded JSON value to an object map, or throws a clear
/// [FormatException] that `ApiClient` turns into an `UnknownException`.
Map<String, dynamic> asJsonMap(Object? json) {
  if (json is Map<String, dynamic>) return json;
  throw FormatException('Expected a JSON object but got ${json.runtimeType}');
}

/// Casts a decoded JSON value to a list of object maps.
List<Map<String, dynamic>> asJsonList(Object? json) {
  if (json is List) return json.map(asJsonMap).toList(growable: false);
  throw FormatException('Expected a JSON array but got ${json.runtimeType}');
}
