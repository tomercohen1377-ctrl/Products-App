import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:network/src/config/api_extras.dart';

/// Logs method, path and status only. Headers and bodies are never logged,
/// so tokens and passwords cannot leak into logs.
class ApiLogInterceptor extends Interceptor {
  ApiLogInterceptor(this._logger, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppLogger _logger;
  final DateTime Function() _now;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[ApiExtras.startedAt] = _now().millisecondsSinceEpoch;
    _logger.debug('--> ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _logger.debug(
      '<-- ${response.statusCode} ${response.requestOptions.method} '
      '${response.requestOptions.path}${_elapsed(response.requestOptions)}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final status = err.response?.statusCode ?? err.type.name;
    _logger.debug(
      '<-- $status ${err.requestOptions.method} '
      '${err.requestOptions.path}${_elapsed(err.requestOptions)}',
    );
    handler.next(err);
  }

  String _elapsed(RequestOptions options) {
    final started = options.extra[ApiExtras.startedAt];
    if (started is! int) return '';
    return ' (${_now().millisecondsSinceEpoch - started}ms)';
  }
}
