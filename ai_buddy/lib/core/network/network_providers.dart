import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_buddy/core/config/app_constants.dart';
import 'package:ai_buddy/core/config/env.dart';
import 'package:ai_buddy/core/network/api_client.dart';
import 'package:ai_buddy/core/network/interceptors/auth_interceptor.dart';
import 'package:ai_buddy/core/network/interceptors/logging_interceptor.dart';
import 'package:ai_buddy/core/session/unauthorized_signal.dart';
import 'package:ai_buddy/core/storage/storage_providers.dart';

/// The single configured Dio instance.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      headers: <String, dynamic>{'Accept': 'application/json'},
    ),
  );

  dio.interceptors.addAll(<Interceptor>[
    AuthInterceptor(
      tokenStorage: ref.watch(tokenStorageProvider),
      // The session listens to this signal and signs the user out.
      onUnauthorized: ref.watch(unauthorizedSignalProvider).notify,
    ),
    if (kDebugMode) LoggingInterceptor(),
  ]);

  ref.onDispose(dio.close);
  return dio;
}, name: 'dioProvider');

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(ref.watch(dioProvider)),
  name: 'apiClientProvider',
);
