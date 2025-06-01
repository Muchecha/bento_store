import 'dart:developer';

import 'package:bento_store/core/utils/error_handler.dart';
import 'package:bento_store/features/auth/domain/repositories/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AuthInterceptor extends Interceptor {
  final AuthRepository authRepository;

  AuthInterceptor(this.authRepository);

  @override
  Future<void> onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    if (options.path.contains('auth/login')) {
      return handler.next(options);
    }

    final token = await authRepository.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }
}

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int retries;
  final int retryDelayMilliseconds;

  RetryInterceptor({
    required this.dio,
    this.retries = 3,
    this.retryDelayMilliseconds = 1000,
  });

  @override
  Future<void> onError(
      DioException err,
      ErrorInterceptorHandler handler,
      ) async {
    if (_shouldRetry(err)) {
      var requestOptions = err.requestOptions;
      final extraAttempts = requestOptions.extra['attempts'] ?? 0;

      if (extraAttempts < retries) {
        log('🔄 Tentando reconectar (${extraAttempts + 1}/$retries)');

        await Future.delayed(Duration(milliseconds: retryDelayMilliseconds));

        // Incrementar contador de tentativas
        requestOptions.extra['attempts'] = extraAttempts + 1;

        // Tentar novamente com as mesmas opções
        try {
          final response = await dio.fetch(requestOptions);
          return handler.resolve(response);
        } catch (e) {
          if (e is DioException) {
            return handler.next(e);
          }
          return handler.next(
            DioException(requestOptions: requestOptions, error: e),
          );
        }
      }
    }

    return handler.next(err);
  }

  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError ||
        (error.type == DioExceptionType.unknown &&
            error.error is Exception &&
            error.error.toString().contains('SocketException'));
  }
}

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final errorMessage = AppErrorHandler.handleDioError(err);
    log('❌ Dio Error: ${err.type} - $errorMessage');

    // Criamos uma nova DioException com a mensagem amigável
    final newError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: errorMessage,
    );

    handler.next(newError);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      log('🌐 Requisição [${options.method}] ${options.uri}');
      if (options.data != null) {
        log('📦 Dados enviados: ${options.data}');
      }
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      log('✅ Resposta [${response.statusCode}] ${response.requestOptions.uri}');
    }

    handler.next(response);
  }
}