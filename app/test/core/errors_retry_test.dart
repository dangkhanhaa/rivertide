import 'package:flutter_test/flutter_test.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/core/errors/retry_policy.dart';

void main() {
  test('deterministic errors are not retried', () {
    expect(providerRetry(0, const NotFoundException('x')), isNull);
    expect(providerRetry(0, const ParseException('x')), isNull);
  });

  test('network errors back off then stop', () {
    expect(providerRetry(0, const NetworkException('x')), const Duration(milliseconds: 500));
    expect(providerRetry(2, const NetworkException('x')), const Duration(seconds: 2));
    expect(providerRetry(4, const NetworkException('x')), isNull);
  });
}
