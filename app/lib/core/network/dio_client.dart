import 'dart:async';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rivertide/core/errors/app_exception.dart';

part 'dio_client.g.dart';

/// Responses above this size are rejected: external data is untrusted (CLAUDE.md 3.1).
const int maxResponseBytes = 8 * 1024 * 1024;

@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      responseType: ResponseType.plain,
    ),
  );
  dio.interceptors.add(_RetryInterceptor(dio));
  ref.onDispose(dio.close);
  return dio;
}

/// GET text from an https URL and map every failure to [AppException].
Future<String> getText(Dio dio, Uri uri) async {
  if (uri.scheme != 'https') throw const NetworkException('only https allowed');
  try {
    final resp = await dio.getUri<String>(uri);
    final body = resp.data ?? '';
    if (body.length > maxResponseBytes) throw const ParseException('response too large');
    return body;
  } on DioException catch (e) {
    throw mapDioException(e);
  }
}

AppException mapDioException(DioException e) => switch (e.type) {
  DioExceptionType.connectionTimeout ||
  DioExceptionType.receiveTimeout ||
  DioExceptionType.sendTimeout => TimeoutAppException(e.message ?? 'timeout'),
  DioExceptionType.badResponse when e.response?.statusCode == 429 => const RateLimitedException(
    '429',
  ),
  DioExceptionType.badResponse when e.response?.statusCode == 404 => const NotFoundException('404'),
  DioExceptionType.badResponse => ServerException(
    'http ${e.response?.statusCode}',
    code: '${e.response?.statusCode}',
  ),
  _ => NetworkException(e.message ?? e.type.name),
};

/// Retries idempotent GETs twice with 1 s then 3 s backoff (docs/rules/02 §7).
class _RetryInterceptor extends Interceptor {
  _RetryInterceptor(this._dio);

  final Dio _dio;
  static const _delays = [Duration(seconds: 1), Duration(seconds: 3)];

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final attempt = (err.requestOptions.extra['retry'] as int?) ?? 0;
    final status = err.response?.statusCode ?? 0;
    final retriable =
        err.requestOptions.method == 'GET' &&
        attempt < _delays.length &&
        (err.type != DioExceptionType.badResponse || status >= 500);
    if (!retriable) return handler.next(err);
    await Future<void>.delayed(_delays[attempt]);
    err.requestOptions.extra['retry'] = attempt + 1;
    try {
      handler.resolve(await _dio.fetch<Object?>(err.requestOptions));
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}
