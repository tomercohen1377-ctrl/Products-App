import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const success = Success<int>(2);
  const failed = Failed<int>(NetworkFailure());

  test('exposes value and failure accessors', () {
    expect(success.isSuccess, isTrue);
    expect(success.valueOrNull, 2);
    expect(success.failureOrNull, isNull);

    expect(failed.isSuccess, isFalse);
    expect(failed.valueOrNull, isNull);
    expect(failed.failureOrNull, const NetworkFailure());
  });

  test('fold picks the matching branch', () {
    expect(
      success.fold(onSuccess: (v) => 'ok $v', onFailure: (_) => 'bad'),
      'ok 2',
    );
    expect(
      failed.fold(onSuccess: (v) => 'ok $v', onFailure: (f) => 'bad $f'),
      'bad NetworkFailure()',
    );
  });

  test('map transforms success and leaves failure untouched', () {
    expect(success.map((v) => v * 10), const Success<int>(20));
    expect(failed.map((v) => v * 10), const Failed<int>(NetworkFailure()));
  });

  test('is value-equal', () {
    expect(const Success<int>(1), const Success<int>(1));
    expect(const Success<int>(1), isNot(const Success<int>(2)));
    expect(
      const Failed<int>(ServerFailure(statusCode: 500)),
      const Failed<int>(ServerFailure(statusCode: 500)),
    );
  });
}
