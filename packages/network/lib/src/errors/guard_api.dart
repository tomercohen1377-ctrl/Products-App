import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:network/src/errors/dio_error_mapper.dart';

/// Runs a data-source call and turns any transport or parsing problem into a
/// typed [Failed], so repositories return [Result] and never throw.
///
/// Programming errors (anything that is not a network or payload-shape
/// problem) are deliberately not caught.
Future<Result<T>> guardApi<T>(Future<T> Function() action) async {
  try {
    return Success(await action());
  } on DioException catch (exception) {
    return Failed(mapDioException(exception));
  } on Exception catch (exception) {
    return Failed(UnknownFailure(cause: exception));
  } on TypeError catch (error) {
    return Failed(UnknownFailure(cause: error));
  }
}
