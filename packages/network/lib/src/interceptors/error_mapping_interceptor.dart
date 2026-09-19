import 'package:dio/dio.dart';
import 'package:network/src/errors/dio_error_mapper.dart';

/// Last interceptor in the chain: replaces every remaining [DioException]'s
/// `error` with a typed `Failure`, so nothing above `network` sees Dio types.
class ErrorMappingInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err.copyWith(error: mapDioException(err)));
  }
}
