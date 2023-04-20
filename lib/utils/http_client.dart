import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:firebase_performance_dio/firebase_performance_dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'http_interceptors/auth_interceptor.dart';
import 'http_interceptors/error_interceptor.dart';
import 'http_interceptors/user_agent_interceptor.dart';

class HttpClient {
  late Dio _dio;

  HttpClient({BaseOptions? options}) {
    _dio = Dio(
            (options ?? BaseOptions()).copyWith(validateStatus: (int? status) {
      return status != null && status >= 200 && status < 400;
    }))
        /*..httpClientAdapter = Http2Adapter(
        ConnectionManager(
          idleTimeout: const Duration(seconds: 10),
          onClientCreate: (_, config) =>
          config.onBadCertificate = (_) => true,
        ),
      )*/
        ;
    _dio.interceptors.addAll([
      ErrorInterceptor(),
      AuthInterceptor(),
      UserAgentInterceptor(),
      DioFirebasePerformanceInterceptor(),
      /*CookieManager(PersistCookieJar(
        ignoreExpires: true,
        storage: FileStorage("${GetIt.I<Directory>().path}/.cookies/"),
      )),*/
    ]);

    if (kDebugMode) {
      _dio.interceptors.add(PrettyDioLogger(
        requestHeader: false,
        responseHeader: true,
        responseBody: false,
        request: false,
        requestBody: false,
      ));
    }
    // _dio.addSentry();
  }

  Dio get dio => _dio;

  static CacheOptions defaultCacheOptions = CacheOptions(
    // A default store is required for interceptor.
    store: MemCacheStore(),
    // Default.
    policy: CachePolicy.request,
    // Optional. Returns a cached response on error but for statuses 401 & 403.
    // hitCacheOnErrorExcept: [401, 403, 500],
    // Optional. Overrides any HTTP directive to delete entry past this duration.
    maxStale: const Duration(hours: 1),
    // Default. Allows 3 cache sets and ease cleanup.
    priority: CachePriority.normal,
    // Default. Body and headers encryption with your own algorithm.
    cipher: null,
    // Default. Key builder to retrieve requests.
    keyBuilder: CacheOptions.defaultCacheKeyBuilder,
    // Default. Allows to cache POST requests.
    // Overriding [keyBuilder] is strongly recommended.
    allowPostMethod: false,
  );
}
